library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


entity PacketRx is
    generic (
        SYMBOL_WIDTH                : positive := 8; -- typically a BYTE
        DATA_SYMBOLS                : positive := 3; -- DATA_SYMBOLS does not include the last checksum symbol
        HEADER_SYMBOLS              : positive := 2
    );
    port (
        CLK                         : in STD_LOGIC;
        RST                         : in STD_LOGIC;
        
        READY_OUT                   : out STD_LOGIC;
        VALID_IN                    : in STD_LOGIC;
        
        READY_IN                    : in STD_LOGIC;
        VALID_OUT                   : out STD_LOGIC;

        HEADER_IN                   : in  STD_LOGIC_VECTOR(HEADER_SYMBOLS*SYMBOL_WIDTH-1 downto 0);
        
        DATA_OUT                    : out STD_LOGIC_VECTOR(DATA_SYMBOLS*SYMBOL_WIDTH-1 downto 0);
        SYMBOL_IN                   : in  STD_LOGIC_VECTOR(SYMBOL_WIDTH-1 downto 0)
    );
end PacketRx;

architecture Behavioral of PacketRx is

    -- total symbols = DATA_SYMBOLS + 1 checksum symbol
    signal packet_sig               : std_logic_vector((HEADER_SYMBOLS+DATA_SYMBOLS+1)*SYMBOL_WIDTH-1 downto 0);
    signal header_sig               : std_logic_vector( HEADER_SYMBOLS                *SYMBOL_WIDTH-1 downto 0);
    signal data_sig                 : std_logic_vector(                DATA_SYMBOLS   *SYMBOL_WIDTH-1 downto 0);

    signal symbol_newest_sig        : std_logic_vector(SYMBOL_WIDTH-1 downto 0);
    signal symbol_oldest_sig        : std_logic_vector(SYMBOL_WIDTH-1 downto 0);

    signal shift_en_sig             : std_logic;
    signal ready_out_sig            : std_logic;
    signal packet_complete_sig      : std_logic;
    signal checksum_sig             : std_logic_vector(SYMBOL_WIDTH-1 downto 0);
    signal checksum_next_sig        : std_logic_vector(SYMBOL_WIDTH-1 downto 0);

begin

    symbol_oldest_sig   <= packet_sig((HEADER_SYMBOLS+DATA_SYMBOLS+1)*SYMBOL_WIDTH-1 downto (HEADER_SYMBOLS+DATA_SYMBOLS  )*SYMBOL_WIDTH); -- first header symbol
    header_sig          <= packet_sig((HEADER_SYMBOLS+DATA_SYMBOLS+1)*SYMBOL_WIDTH-1 downto (               DATA_SYMBOLS+1)*SYMBOL_WIDTH);
    data_sig            <= packet_sig((               DATA_SYMBOLS+1)*SYMBOL_WIDTH-1 downto                                 SYMBOL_WIDTH);
    symbol_newest_sig   <= packet_sig(                                SYMBOL_WIDTH-1 downto                                 0           );

    DATA_OUT            <= data_sig;

    shift_en_sig        <= VALID_IN     and     ready_out_sig;
    READY_OUT           <=                      ready_out_sig;

    checksum_next_sig   <= std_logic_vector(unsigned(checksum_sig) + unsigned(symbol_newest_sig) - unsigned(symbol_oldest_sig));

    packet_complete_sig <= '1' when (header_sig = HEADER_IN and symbol_newest_sig = checksum_sig) else '0';

    

    shift_reg: entity work.Reg1DSymbols
        generic map (
            LENGTH          => HEADER_SYMBOLS + DATA_SYMBOLS + 1,
            SYMBOL_WIDTH    => SYMBOL_WIDTH,
            BIG_ENDIAN      => TRUE -- PacketRx is always "big endian"
        )
        port map (
            CLK             => CLK,
            RST             => RST,
            
            SHIFT_EN        => shift_en_sig,
            SHIFT_IN        => SYMBOL_IN,
            PAR_OUT         => packet_sig
        );
        
    checksum_reg: entity work.Reg1D
        generic map (
            LENGTH              => SYMBOL_WIDTH
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
    
            PAR_EN              => shift_en_sig,
            PAR_IN              => checksum_next_sig,
            PAR_OUT             => checksum_sig
        );
        
    FSM: entity work.PacketRxFSM
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            READY_OUT           => ready_out_sig,
            VALID_IN            => VALID_IN,
            
            READY_IN            => READY_IN,
            VALID_OUT           => VALID_OUT,
            
            PACKET_COMPLETE     => packet_complete_sig
        );

    ILA : entity work.ila_PacketRx
    port map (
        clk             => CLK,
        probe0          => symbol_newest_sig,
        probe1          => symbol_oldest_sig,
        probe2(0)       => shift_en_sig,
        probe3(0)       => ready_out_sig,
        probe4(0)       => packet_complete_sig,
        probe5          => checksum_sig,
        probe6          => checksum_next_sig,
        probe7          => header_sig,
        probe8          => data_sig
    );


end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MemoryMapServer is
    generic (
        -- symbol width [bits]
        SYMBOL_WIDTH                : positive := 8; -- typically a BYTE
        -- length of server ID (header) [symbols]
        SERVER_ID_LEN		        : positive := 2;
        -- lengths of packet fields (data frame) [symbols]
        CONTROL_LEN                 : positive := 1;
        MEM_ADDR_LEN                : positive := 2;
        MEM_DATA_LEN		        : positive := 1
    );
    port (
        CLK                         : in STD_LOGIC;
        RST                         : in STD_LOGIC;

        -- packet
        SERVER_ID                   : in STD_LOGIC_VECTOR (SERVER_ID_LEN*SYMBOL_WIDTH-1 downto 0);

        -- serially receive packet via SYMBOL_IN, and serially transmit packet via SYMBOL_OUT
        SYMBOL_IN                   : in STD_LOGIC_VECTOR (SYMBOL_WIDTH-1 downto 0);
        SYMBOL_OUT                  : out STD_LOGIC_VECTOR (SYMBOL_WIDTH-1 downto 0);

        -- handshake TO serial
        SYM_READY_IN                : in STD_LOGIC;
        SYM_VALID_OUT               : out STD_LOGIC;
        -- handshake FROM serial
        SYM_READY_OUT               : out STD_LOGIC;
        SYM_VALID_IN                : in STD_LOGIC;

        -- if CONTROL_OUT indicates the transaction is READ, then memory will ignore DATA_OUT.
        -- if CONTROL_OUT indicates the transaction is WRITE, then DATA_OUT will be written, and DATA_IN should be ignored by client.
        CONTROL_OUT                 : out STD_LOGIC_VECTOR (CONTROL_LEN*SYMBOL_WIDTH-1 downto 0); -- can be used for R/W bit, sequencing, and/or client ID
        ADDR_OUT                    : out STD_LOGIC_VECTOR (MEM_ADDR_LEN*SYMBOL_WIDTH-1 downto 0);
        DATA_OUT                    : out STD_LOGIC_VECTOR (MEM_DATA_LEN*SYMBOL_WIDTH-1 downto 0); -- only applicable for WRITE
        DATA_IN                     : in STD_LOGIC_VECTOR (MEM_DATA_LEN*SYMBOL_WIDTH-1 downto 0);

        -- handshake TO memory
        MEM_READY_IN                : in STD_LOGIC;
        MEM_VALID_OUT               : out STD_LOGIC;
        -- handshake FROM memory
        MEM_READY_OUT               : out STD_LOGIC;
        MEM_VALID_IN                : in STD_LOGIC
        
    );
end MemoryMapServer;

architecture Behavioral of MemoryMapServer is
    
    signal rx_packet_sig        : std_logic_vector((MEM_ADDR_LEN+MEM_DATA_LEN)*SYMBOL_WIDTH-1 downto 0);
    signal tx_packet_sig        : std_logic_vector((MEM_ADDR_LEN+MEM_DATA_LEN)*SYMBOL_WIDTH-1 downto 0);
    
    signal control_sig          : std_logic_vector(CONTROL_LEN*SYMBOL_WIDTH-1 downto 0);
    signal addr_sig             : std_logic_vector(MEM_ADDR_LEN*SYMBOL_WIDTH-1 downto 0);

begin
    
    PacketRxBuffered_module: entity work.PacketRxBuffered
        generic map (
            SYMBOL_WIDTH            => SYMBOL_WIDTH,
            HEADER_SYMBOLS          => SERVER_ID_LEN,
            DATA_SYMBOLS            => CONTROL_LEN + MEM_ADDR_LEN + MEM_DATA_LEN
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            HEADER                  => SERVER_ID,
            
            -- upstream
            SYMBOL_IN               => SYMBOL_IN,
            VALID_IN                => SYM_VALID_IN,
            READY_OUT               => SYM_READY_OUT,
            
            -- downstream
            DATA_OUT              	=> rx_packet_sig,
            VALID_OUT               => MEM_VALID_OUT,
            READY_IN                => MEM_READY_IN
        );
        
    control_sig     <= rx_packet_sig((CONTROL_LEN + MEM_ADDR_LEN + MEM_DATA_LEN)*SYMBOL_WIDTH-1 downto (MEM_ADDR_LEN + MEM_DATA_LEN)*SYMBOL_WIDTH);
    addr_sig        <= rx_packet_sig((              MEM_ADDR_LEN + MEM_DATA_LEN)*SYMBOL_WIDTH-1 downto (               MEM_DATA_LEN)*SYMBOL_WIDTH);
    DATA_OUT        <= rx_packet_sig((                             MEM_DATA_LEN)*SYMBOL_WIDTH-1 downto                                          0);
    
    CONTROL_OUT     <= control_sig;
    ADDR_OUT        <= addr_sig;    
    
    tx_packet_sig   <= control_sig & addr_sig & DATA_IN; -- CONTROL and ADDR do same thing, and could be combined into same signal, but seperated for clarity.
    
    PacketTxBuffered_module: entity work.PacketTxBuffered
        generic map (
            SYMBOL_WIDTH            => SYMBOL_WIDTH,
            HEADER_SYMBOLS          => SERVER_ID_LEN,
            DATA_SYMBOLS            => CONTROL_LEN + MEM_ADDR_LEN + MEM_DATA_LEN
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            HEADER                  => SERVER_ID,
            
            -- upstream
            DATA_IN                 => tx_packet_sig,
            VALID_IN                => MEM_VALID_IN,
            READY_OUT               => MEM_READY_OUT,
            
            -- downstream
            SYMBOL_OUT              => SYMBOL_OUT,
            VALID_OUT               => SYM_VALID_OUT,
            READY_IN                => SYM_VALID_IN
        );

end Behavioral;

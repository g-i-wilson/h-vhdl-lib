library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPIHalfDuplex is
    generic (
        SCK_HALF_PERIOD_WIDTH   : positive := 8
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        
        -- data path IN
        READY_OUT               : out STD_LOGIC;
        VALID_IN                : in STD_LOGIC;
        DATA_IN                 : in STD_LOGIC_VECTOR (7 downto 0);
        -- data path OUT
        READY_IN                : in STD_LOGIC;
        VALID_OUT               : out STD_LOGIC;
        DATA_OUT                : out STD_LOGIC_VECTOR (7 downto 0);

        -- SPI
        SCK_HALF_PERIOD         : in STD_LOGIC_VECTOR (SCK_HALF_PERIOD_WIDTH-1 downto 0);
        MISO                    : in STD_LOGIC;
        MOSI                    : out STD_LOGIC;
        SCK                     : out STD_LOGIC;
        CS                      : out STD_LOGIC;
        TRISTATE_EN             : out STD_LOGIC
    );
end SPIHalfDuplex;

architecture Behavioral of SPIHalfDuplex is

    -- data busses
    signal valid_buffer_sig     : std_logic_vector(7 downto 0);
    signal data_in_msb_sig      : std_logic;
    signal miso_sync_sig        : std_logic;
    signal bit_count_sig        : std_logic_vector(3 downto 0);

    -- timer signals
    signal write_len_sig        : std_logic_vector(7 downto 0);
    signal read_len_sig         : std_logic_vector(7 downto 0);
    signal bit_count_rst_sig    : std_logic;
    signal rw_count_rst_sig     : std_logic;
    
    -- FSM inputs
    signal write_done_sig       : std_logic;
    signal read_done_sig        : std_logic;
    signal byte_done_sig        : std_logic;
    signal sck_edge_sig         : std_logic;
    
    -- FSM outputs
    signal sck_en_sig               : std_logic;
    signal bit_count_en_sig         : std_logic;
    signal bit_count_rst_fsm_sig    : std_logic;
    signal write_count_en_sig       : std_logic;
    signal read_count_en_sig        : std_logic;
    signal rw_count_rst_fsm_sig     : std_logic;
    signal tristate_en_sig          : std_logic;
    signal load_write_len_sig       : std_logic;
    signal load_read_len_sig        : std_logic;
    signal load_data_in_sig         : std_logic;
    signal shift_data_in_sig        : std_logic;
    signal shift_data_out_sig       : std_logic;


begin

    ----------------------------------------------------
    -- FSM
    ----------------------------------------------------
    
    FSM: entity work.SPIHalfDuplexFSM
        port map ( 
            -- inputs
            CLK                 => CLK,
            RST                 => RST,
            VALID_IN            => VALID_IN,
            READY_IN            => READY_IN,
            WRITE_DONE          => write_done_sig,
            READ_DONE           => read_done_sig,
            BYTE_DONE           => byte_done_sig,
            SCK_EDGE            => sck_edge_sig,
            -- outputs
            READY_OUT           => READY_OUT,
            VALID_OUT           => VALID_OUT,
            SCK_EN              => sck_en_sig,
            BIT_COUNT_EN        => bit_count_en_sig,
            BIT_COUNT_RST       => bit_count_rst_fsm_sig,
            WRITE_COUNT_EN      => write_count_en_sig,
            READ_COUNT_EN       => read_count_en_sig,
            RW_COUNT_RST        => rw_count_rst_fsm_sig,
            TRISTATE_EN         => TRISTATE_EN,
            LOAD_WRITE_LEN      => load_write_len_sig,
            LOAD_READ_LEN       => load_read_len_sig,
            LOAD_DATA_IN        => load_data_in_sig,
            SHIFT_DATA_IN       => shift_data_in_sig,
            SHIFT_DATA_OUT      => shift_data_out_sig,
            CS                  => CS,
            SCK                 => SCK
        );

    ----------------------------------------------------
    -- LOGIC
    ----------------------------------------------------
    
    SDO_synchronizer : entity work.Synchronizer
    generic map (
            SYNC_LENGTH          => 3
    )
    port map
    (
        RST             => RST,
        CLK             => CLK,
        SIG_IN        	=> MISO,
        SIG_OUT         => miso_sync_sig
    );

    bit_count_rst_sig <= RST or bit_count_rst_fsm_sig;
    
    rw_count_rst_sig <= RST or rw_count_rst_fsm_sig;
    
    MOSI <= data_in_msb_sig;
    

    ----------------------------------------------------
    -- REGISTERS
    ----------------------------------------------------
    
    valid_buffer: entity work.reg1D
        generic map (
            LENGTH              => 8
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            PAR_EN              => VALID_IN,
            PAR_IN              => DATA_IN,
            PAR_OUT             => valid_buffer_sig
        );

    DATA_IN_reg: entity work.reg1D
        generic map (
            LENGTH              => 8
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            PAR_EN              => load_data_in_sig,
            PAR_IN              => valid_buffer_sig,
            
            SHIFT_EN            => shift_data_in_sig,
            SHIFT_OUT           => data_in_msb_sig
        );

    DATA_OUT_reg: entity work.reg1D
        generic map (
            LENGTH              => 8
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            PAR_OUT             => DATA_OUT,
            
            SHIFT_EN            => shift_data_out_sig,
            SHIFT_IN            => miso_sync_sig
        );

    WRITE_LEN_reg: entity work.reg1D
        generic map (
            LENGTH              => 8
        )
        port map (
            CLK                 => CLK,
            RST                 => rw_count_rst_sig,
            
            PAR_EN              => load_write_len_sig,
            PAR_IN              => valid_buffer_sig,
            PAR_OUT             => write_len_sig
        );

    READ_LEN_reg: entity work.reg1D
        generic map (
            LENGTH              => 8
        )
        port map (
            CLK                 => CLK,
            RST                 => rw_count_rst_sig,
            
            PAR_EN              => load_read_len_sig,
            PAR_IN              => valid_buffer_sig,
            PAR_OUT             => read_len_sig
        );


    ----------------------------------------------------
    -- COUNTERS
    ----------------------------------------------------
    
    SCK_EDGE_counter : entity work.clk_div_generic
        generic map (
            period_width        => SCK_HALF_PERIOD_WIDTH
        )
        port map (
            period              => SCK_HALF_PERIOD,
            clk                 => CLK,
            en                  => sck_en_sig,
            rst                 => RST,
            en_out              => sck_edge_sig
        );
        
    bit_counter : entity work.Timer
        generic map (
            WIDTH               => 3 -- defaults to "000" through "111", which is 8 combinations
        )
        port map (
            CLK                 => CLK,
            EN                  => bit_count_en_sig,
            RST                 => bit_count_rst_sig,
            DONE                => byte_done_sig
        );

    WRITE_counter : entity work.Timer
        generic map (
            WIDTH               => 8
        )
        port map (
            CLK                 => CLK,
            EN                  => write_count_en_sig,
            RST                 => rw_count_rst_sig,
            COUNT_END           => write_len_sig,
            DONE                => write_done_sig
        );
        
    READ_counter : entity work.Timer
        generic map (
            WIDTH               => 8
        )
        port map (
            CLK                 => CLK,
            EN                  => read_count_en_sig,
            RST                 => rw_count_rst_sig,
            COUNT_END           => read_len_sig,
            DONE                => read_done_sig
        );
        

end Behavioral;

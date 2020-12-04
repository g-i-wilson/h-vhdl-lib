library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPIMaster is
    generic (
        SCK_HALF_PERIOD_WIDTH   : positive := 8;
        MISO_DETECTOR_SAMPLES   : positive := 16;
        ADDR_WIDTH              : positive := 16;
        DATA_WIDTH              : positive := 8;
        COUNTER_WIDTH           : positive := 8
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        
        -- R/W
        WRITE                   : in STD_LOGIC;
        
        -- upstream
        READY_OUT               : out STD_LOGIC;
        VALID_IN                : in STD_LOGIC;
        
        -- downstream
        READY_IN                : in STD_LOGIC := '1';
        VALID_OUT               : out STD_LOGIC;

        -- ADDR & DATA
        ADDR                    : in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
        DATA_IN                 : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        DATA_OUT                : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        
        -- SPI
        SCK_HALF_PERIOD         : in STD_LOGIC_VECTOR (SCK_HALF_PERIOD_WIDTH-1 downto 0);
        MISO                    : in STD_LOGIC := '1';
        MOSI                    : out STD_LOGIC;
        SCK                     : out STD_LOGIC;
        CS                      : out STD_LOGIC;
        TRISTATE_EN             : out STD_LOGIC
    );
end SPIMaster;

architecture Behavioral of SPIMaster is

    -- data busses
    signal valid_buffer_sig     : std_logic_vector(7 downto 0);
    signal mosi_sig             : std_logic;
    signal miso_sync_sig        : std_logic;
    signal bit_count_sig        : std_logic_vector(3 downto 0);

    -- FSM inputs
    signal addr_done_sig        : std_logic;
    signal data_done_sig        : std_logic;
    signal sck_edge_sig         : std_logic;
    
    -- FSM outputs
    signal sck_rst_fsm_sig      : std_logic;
    signal ready_out_sig        : std_logic;
    signal counter_en_sig       : std_logic;
    signal counter_rst_fsm_sig  : std_logic;
    signal data_in_shift_en_sig : std_logic;
    signal data_out_shift_en_sig : std_logic;

    signal sck_rst_sig          : std_logic;
    signal counter_rst_sig      : std_logic;
    signal data_in_par_en_sig   : std_logic;
    signal data_in_sig          : std_logic_vector(ADDR_WIDTH+DATA_WIDTH-1 downto 0);
    signal counter_sig          : std_logic_vector(COUNTER_WIDTH-1 downto 0);

    signal state_debug          : std_logic_vector(3 downto 0);


begin

    ----------------------------------------------------
    -- FSM
    ----------------------------------------------------
    
    FSM: entity work.SPIMasterFSM
        port map ( 
            -- inputs
            CLK                 => CLK,
            RST                 => RST,
            VALID_IN            => VALID_IN,
            READY_IN            => READY_IN,
            WRITE               => WRITE,
            ADDR_DONE           => addr_done_sig,
            DATA_DONE           => data_done_sig,
            SCK_EDGE            => sck_edge_sig,
            -- outputs
            READY_OUT           => ready_out_sig,
            VALID_OUT           => VALID_OUT,
            SCK_RST             => sck_rst_fsm_sig,
            TRISTATE_EN         => TRISTATE_EN,
            COUNTER_EN          => counter_en_sig,
            COUNTER_RST         => counter_rst_fsm_sig,
            SHIFT_IN_REG        => data_in_shift_en_sig,
            SHIFT_OUT_REG       => data_out_shift_en_sig,
            CS                  => CS,
            SCK                 => SCK,
            -- debug outputs
            STATE               => state_debug
        );

    ----------------------------------------------------
    -- LOGIC
    ----------------------------------------------------

    MISO_detector: entity work.EdgeDetector
    generic map (
        SAMPLE_LENGTH             => MISO_DETECTOR_SAMPLES,
        SUM_WIDTH                 => SCK_HALF_PERIOD_WIDTH,
        LOGIC_HIGH                => MISO_DETECTOR_SAMPLES*3/4-1,
        LOGIC_LOW                 => MISO_DETECTOR_SAMPLES/4,
        SUM_START                 => MISO_DETECTOR_SAMPLES/2
    )
    port map (
        RST                       => RST,
        CLK                       => CLK,
        
        SAMPLE                    => '1',
        SIG_IN                    => MISO,
        
        DATA                      => miso_sync_sig
    );
    
    counter_rst_sig         <= RST or counter_rst_fsm_sig;
    sck_rst_sig             <= RST or sck_rst_fsm_sig;
    
    MOSI                    <= mosi_sig;
    
    READY_OUT               <= ready_out_sig;
    data_in_par_en_sig      <= VALID_IN and ready_out_sig;
    
    data_in_sig             <= ADDR & DATA_IN;

    ----------------------------------------------------
    -- REGISTERS
    ----------------------------------------------------
    
    DATA_IN_reg: entity work.reg1D
        generic map (
            LENGTH              => ADDR_WIDTH + DATA_WIDTH
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            PAR_EN              => data_in_par_en_sig,
            PAR_IN              => data_in_sig,
            
            SHIFT_EN            => data_in_shift_en_sig,
            SHIFT_OUT           => mosi_sig
        );

    DATA_OUT_reg: entity work.reg1D
        generic map (
            LENGTH              => DATA_WIDTH
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            PAR_OUT             => DATA_OUT,
            
            SHIFT_EN            => data_out_shift_en_sig,
            SHIFT_IN            => miso_sync_sig
        );

    ----------------------------------------------------
    -- COUNTERS
    ----------------------------------------------------
    
    SCK_EDGE_pules : entity work.PulseGenerator
    generic map (
        WIDTH                   => SCK_HALF_PERIOD_WIDTH
    )
    port map ( 
        CLK                     => CLK,
        RST                     => sck_rst_sig,
        EN                      => '1',
        PERIOD                  => SCK_HALF_PERIOD,
        INIT_PERIOD             => SCK_HALF_PERIOD,
        PULSE                   => sck_edge_sig
    );
        
    counter : entity work.Timer
        generic map (
            WIDTH               => COUNTER_WIDTH
        )
        port map (
            CLK                 => CLK,
            EN                  => counter_en_sig,
            RST                 => counter_rst_fsm_sig,
            COUNT               => counter_sig
        );
        
     addr_done_sig <= '1' when (counter_sig = std_logic_vector(to_unsigned(ADDR_WIDTH-1, COUNTER_WIDTH))) else '0';
     
     data_done_sig <= '1' when (counter_sig = std_logic_vector(to_unsigned(ADDR_WIDTH+DATA_WIDTH-1, COUNTER_WIDTH))) else '0';
                
        
--    ila0: entity work.ila_SPITransaction
--    port map (
--        CLK => CLK,
--        probe0 => byte_done_sig & write_done_sig & read_done_sig & shift_data_in_sig & shift_data_out_sig & "000",
--        probe1 => write_len_sig,
--        probe2 => read_len_sig,
--        probe3 => state_debug
--    );


end Behavioral;

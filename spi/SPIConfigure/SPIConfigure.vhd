library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPIConfigure is
    generic (
        ADDR_WIDTH                  : positive := 16;
        DATA_WIDTH		            : positive := 8;
        CONFIG_LENGTH               : positive := 4;
        VERIFY_LENGTH               : positive := 2;
        SCK_HALF_PERIOD_WIDTH       : positive := 8;
        VERIFY_RETRY_PERIOD_WIDTH   : positive := 28;
        COUNTER_WIDTH               : positive := 8;
        BIG_ENDIAN                  : boolean := TRUE;
        MISO_DETECTOR_SAMPLES       : positive := 16
    );
    port (
        CLK                         : in STD_LOGIC;
        RST                         : in STD_LOGIC;
        CONFIG                      : in STD_LOGIC_VECTOR ((ADDR_WIDTH+DATA_WIDTH)*CONFIG_LENGTH-1 downto 0);
        VERIFY                      : in STD_LOGIC_VECTOR ((ADDR_WIDTH+DATA_WIDTH)*VERIFY_LENGTH-1 downto 0);
        
        SCK_HALF_PERIOD	            : in STD_LOGIC_VECTOR (SCK_HALF_PERIOD_WIDTH-1 downto 0);
        
        CS                          : out STD_LOGIC;
        SCK                         : out STD_LOGIC;
        MISO                        : in STD_LOGIC;
        MOSI                        : out STD_LOGIC;
        TRISTATE_EN                 : out STD_LOGIC;
        
        VERIFY_PASS                 : out STD_LOGIC;
        VERIFY_FAIL                 : out STD_LOGIC;
        VERIFY_RETRY                : in STD_LOGIC := '1';
        VERIFY_RETRY_PERIOD         : in STD_LOGIC_VECTOR (VERIFY_RETRY_PERIOD_WIDTH-1 downto 0) := x"5F5E0FF"; -- 100MHz/1Hz-1 to hex
        
        VERIFY_ADDR                 : out STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
        VERIFY_DATA                 : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        ACTUAL_DATA                 : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        
        -- debug
        STATE                       : out STD_LOGIC_VECTOR (3 downto 0)
    );
end SPIConfigure;

architecture Behavioral of SPIConfigure is

    signal reg_valid_sig        : std_logic;
    signal spi_ready_sig        : std_logic;
    signal spi_valid_sig        : std_logic;
    signal ready_to_verify_sig  : std_logic;

    signal config_select_sig    : std_logic;
    signal counter_en_sig       : std_logic;
    signal counter_rst_sig      : std_logic;
    signal counter_rst_fsm_sig  : std_logic;
    signal retry_en_sig         : std_logic;
    signal retry_rst_sig        : std_logic;
    signal retry_rst_fsm_sig    : std_logic;
    signal verified_data_sig    : std_logic;
    signal config_done_sig      : std_logic;
    signal verify_done_sig      : std_logic;
    signal retry_sig            : std_logic;
    signal write_sig            : std_logic;
    
    signal count_sig            : std_logic_vector(COUNTER_WIDTH-1 downto 0);
    signal en_config_sig        : std_logic;
    signal en_verify_sig        : std_logic;
    signal config_out_sig       : std_logic_vector(ADDR_WIDTH+DATA_WIDTH-1 downto 0);
    signal verify_out_sig       : std_logic_vector(ADDR_WIDTH+DATA_WIDTH-1 downto 0);
    signal reg_out_sig          : std_logic_vector(ADDR_WIDTH+DATA_WIDTH-1 downto 0);

    signal spi_out_sig          : std_logic_vector(DATA_WIDTH-1 downto 0);

begin
    
    FSM: entity work.SPIConfigureFSM
        port map ( 
            CLK             => CLK,
            RST             => RST,
    
            SPI_READY       => spi_ready_sig,
            SPI_VALID       => spi_valid_sig,        
            VERIFIED_DATA   => verified_data_sig,
            CONFIG_DONE     => config_done_sig,
            VERIFY_DONE     => verify_done_sig,
            ALLOW_RETRY     => VERIFY_RETRY,
            RETRY			=> retry_sig,
            
            EN_CONFIG       => en_config_sig,
            EN_VERIFY       => en_verify_sig,
            REG_VALID       => reg_valid_sig,
            READY_TO_VERIFY => ready_to_verify_sig,
            CONFIG_SELECT   => config_select_sig,
            COUNTER_EN      => counter_en_sig,
            COUNTER_RST     => counter_rst_fsm_sig,
            RETRY_EN        => retry_en_sig,
            RETRY_RST       => retry_rst_fsm_sig,
            VERIFY_PASS     => VERIFY_PASS,
            VERIFY_FAIL     => VERIFY_FAIL,
            WRITE           => write_sig,
            
            STATE           => STATE
        );

    counter_rst_sig     <= RST or counter_rst_fsm_sig;
    retry_rst_sig       <= RST or retry_rst_fsm_sig;
            
    Transaction_counter : entity work.Timer
        generic map (
            WIDTH               => COUNTER_WIDTH
        )
        port map (
            CLK                 => CLK,
            EN                  => counter_en_sig,
            RST                 => counter_rst_sig,
            COUNT               => count_sig
        );

    config_done_sig     <= '1' when (count_sig = std_logic_vector(to_unsigned(CONFIG_LENGTH-1, COUNTER_WIDTH))) else '0';
        
    Retry_timer : entity work.Timer
        generic map (
            WIDTH               => VERIFY_RETRY_PERIOD_WIDTH
        )
        port map (
            CLK                 => CLK,
            EN                  => retry_en_sig,
            RST                 => retry_rst_sig,
            COUNT_END           => VERIFY_RETRY_PERIOD,
            DONE                => retry_sig
        );
    
    verify_done_sig     <= '1' when (count_sig = std_logic_vector(to_unsigned(VERIFY_LENGTH-1, COUNTER_WIDTH))) else '0';
        
    CONFIG_reg: entity work.Reg1DSymbols
        generic map (
            LENGTH              => CONFIG_LENGTH,
            SYMBOL_WIDTH        => ADDR_WIDTH + DATA_WIDTH,
            BIG_ENDIAN          => BIG_ENDIAN
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            SHIFT_EN            => en_config_sig,
            SHIFT_OUT           => config_out_sig,
            SHIFT_IN            => config_out_sig,
            
            DEFAULT_STATE       => CONFIG
        );
        
    VERIFY_reg: entity work.Reg1DSymbols
        generic map (
            LENGTH              => VERIFY_LENGTH,
            SYMBOL_WIDTH        => ADDR_WIDTH + DATA_WIDTH,
            BIG_ENDIAN          => BIG_ENDIAN
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            SHIFT_EN            => en_verify_sig,
            SHIFT_OUT           => verify_out_sig,
            
            DEFAULT_STATE       => VERIFY
        );

    reg_out_sig         <= config_out_sig when (config_select_sig = '1') else verify_out_sig;
    verified_data_sig   <= '1' when (verify_out_sig(DATA_WIDTH-1 downto 0) = spi_out_sig) else '0';

    SPIMaster_module: entity work.SPIMaster
        generic map (
            SCK_HALF_PERIOD_WIDTH   =>  SCK_HALF_PERIOD_WIDTH,
            ADDR_WIDTH              =>  ADDR_WIDTH,
            DATA_WIDTH              =>  DATA_WIDTH,
            COUNTER_WIDTH           =>  COUNTER_WIDTH,
            MISO_DETECTOR_SAMPLES   => MISO_DETECTOR_SAMPLES
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            
            -- R/W
            WRITE                   => write_sig,
            
            -- upstream
            READY_OUT               => spi_ready_sig,
            VALID_IN                => reg_valid_sig,
            
            -- downstream
            READY_IN                => ready_to_verify_sig,
            VALID_OUT               => spi_valid_sig,
    
            -- ADDR & DATA
            ADDR                    => reg_out_sig(ADDR_WIDTH+DATA_WIDTH-1 downto DATA_WIDTH),
            DATA_IN                 => reg_out_sig(DATA_WIDTH-1 downto 0),
            DATA_OUT                => spi_out_sig,
            
            -- SPI
            SCK_HALF_PERIOD         => SCK_HALF_PERIOD,
            MISO                    => MISO,
            MOSI                    => MOSI,
            SCK                     => SCK,
            CS                      => CS,
            TRISTATE_EN             => TRISTATE_EN
        );
        
    VERIFY_ADDR     <= verify_out_sig(ADDR_WIDTH+DATA_WIDTH-1 downto DATA_WIDTH);
    VERIFY_DATA     <= reg_out_sig(DATA_WIDTH-1 downto 0);
    ACTUAL_DATA     <= spi_out_sig;

end Behavioral;

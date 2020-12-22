library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity FreqBurst is
    generic (
        SAMPLE_PERIOD_WIDTH     : positive := 8;
        CYCLES_WIDTH            : positive := 8;
        RF_FREQ_WIDTH           : positive := 4;
        RF_DIV_PERIOD_WIDTH     : positive := 8;
        SAMPLE_COUNT_WIDTH      : positive := 16
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;        
        
        -- settings
        SAMPLE_PERIOD           : in std_logic_vector(SAMPLE_PERIOD_WIDTH-1 downto 0);
        
        -- upstream handshake
        VALID_IN                : in std_logic;
        READY_OUT               : out std_logic;

        -- input data
        -- cycles-1 (total number of repeated cycles with same start/step/end frequency)
        CYCLES                  : in std_logic_vector(CYCLES_WIDTH-1 downto 0);
        -- start frequency
        RF_FREQ_START           : in std_logic_vector(RF_FREQ_WIDTH-1 downto 0);
        -- end frequency
        RF_FREQ_END             : in std_logic_vector(RF_FREQ_WIDTH-1 downto 0);
        -- divided-down RF frequency input (idealy should be lower than sample rate to prevent skipping period samples)
        RF_FREQ_DIV             : in std_logic;
        -- PRE segment duration (units of samples)
        PRE_DURATION            : in std_logic_vector(SAMPLE_COUNT_WIDTH-1 downto 0);
        -- STEP segment duration (each step; units of samples; total STEP segment duration is freq_delta*step_duration)
        STEP_DURATION           : in std_logic_vector(SAMPLE_COUNT_WIDTH-1 downto 0);
        -- POST segment duration (units of samples)
        POST_DURATION           : in std_logic_vector(SAMPLE_COUNT_WIDTH-1 downto 0);
        
        -- output data & control
        -- ADC sample pulse
        SAMPLE_PULSE            : out std_logic;
        -- control output frequency setting
        RF_FREQ                 : out std_logic_vector(RF_FREQ_WIDTH-1 downto 0);
        -- output period of divided-down RF frequency (in units of clock cycles)
        RF_FREQ_DIV_PERIOD      : out std_logic_vector(RF_DIV_PERIOD_WIDTH-1 downto 0);
        -- output cycle count (contiguous cycles with same start/step/end frequency)
        CYCLE_COUNT             : out std_logic_vector(CYCLES_WIDTH-1 downto 0);
        -- output sample count (sample count in the current cycle)
        SAMPLE_COUNT            : out std_logic_vector(SAMPLE_COUNT_WIDTH-1 downto 0);

        -- downstream valid
        VALID_OUT               : out std_logic;
        
        
        -- debug
        STATE                   : out std_logic_vector(3 downto 0)
    );
end FreqBurst;


architecture Behavioral of FreqBurst is

    -- FSM & control signals
    signal adc_sample_sig           : std_logic;
    signal timer_en_sig             : std_logic;
    signal timer_en_fsm_sig         : std_logic;
    signal timer_done_sig           : std_logic;
    signal timer_rst_sig            : std_logic;
    signal timer_rst_fsm_sig        : std_logic;
    signal timer_end_sig            : std_logic_vector(SAMPLE_COUNT_WIDTH-1 downto 0);
    signal freq_counter_en_sig      : std_logic;
    signal freq_counter_done_sig    : std_logic;
    signal freq_counter_rst_sig     : std_logic;
    signal freq_counter_rst_fsm_sig : std_logic;
    signal freq_count_sig           : std_logic_vector(RF_FREQ_WIDTH-1 downto 0);
    signal freq_out_sig             : std_logic_vector(RF_FREQ_WIDTH-1 downto 0);
    signal cycle_en_sig             : std_logic;
    signal cycle_done_sig           : std_logic;
    signal cycle_rst_sig            : std_logic;
    signal cycle_rst_fsm_sig        : std_logic;
    signal sample_en_sig            : std_logic;
    signal sample_en_fsm_sig        : std_logic;
    signal sample_rst_sig           : std_logic;
    signal sample_rst_fsm_sig       : std_logic;
    signal zero_pre_sig             : std_logic;
    signal zero_step_sig            : std_logic;
    signal zero_post_sig            : std_logic;
    signal segment_sig              : std_logic_vector(1 downto 0);

    -- RX data signals
    signal cycle_end_sig            : std_logic_vector(CYCLES_WIDTH-1 downto 0);
    signal freq_start_sig           : std_logic_vector(RF_FREQ_WIDTH-1 downto 0);
    signal freq_end_sig             : std_logic_vector(RF_FREQ_WIDTH-1 downto 0);
    signal time_pre_sig             : std_logic_vector(SAMPLE_COUNT_WIDTH-1 downto 0);
    signal time_step_sig            : std_logic_vector(SAMPLE_COUNT_WIDTH-1 downto 0);
    signal time_post_sig            : std_logic_vector(SAMPLE_COUNT_WIDTH-1 downto 0);

    -- TX data signals
    signal freq_div_period_sig      : std_logic_vector(RF_DIV_PERIOD_WIDTH-1 downto 0);
    signal cycle_count_sig          : std_logic_vector(RF_DIV_PERIOD_WIDTH-1 downto 0);
    signal sample_count_sig         : std_logic_vector(SAMPLE_COUNT_WIDTH-1 downto 0);
    
begin

    --------------------------------------------------------------
    -- FSM & sample rate
    --------------------------------------------------------------
    
    FSM: entity work.FreqBurstFSM
        port map ( 
            CLK             => CLK,
            RST             => RST,
            
            READY_OUT       => READY_OUT,
            VALID_IN        => VALID_IN,
    
            SAMPLE_IN      => adc_sample_sig,
    
            SEGMENT         => segment_sig,

            TIMER_EN        => timer_en_fsm_sig,
            TIMER_RST       => timer_rst_fsm_sig,
            TIMER_DONE      => timer_done_sig,

            ZERO_PRE        => zero_pre_sig,
            ZERO_STEP       => zero_step_sig,
            ZERO_POST       => zero_post_sig,
            
            FREQ_RST        => freq_counter_rst_fsm_sig,
            FREQ_EN         => freq_counter_en_sig,
            FREQ_DONE       => freq_counter_done_sig,
            
            CYCLE_RST       => cycle_rst_fsm_sig,
            CYCLE_EN        => cycle_en_sig,
            CYCLE_DONE      => cycle_done_sig,
    
            SAMPLE_RST      => sample_rst_fsm_sig,
            SAMPLE_EN       => sample_en_fsm_sig,
            
            -- debug
            STATE           => STATE
        );

    sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH                       => SAMPLE_PERIOD_WIDTH
    )
    port map (
        CLK                         => CLK,
        EN                          => '1',
        RST                         => RST,
        PERIOD                      => SAMPLE_PERIOD,
        INIT_PERIOD                 => SAMPLE_PERIOD,
        PULSE                       => adc_sample_sig
    );
    
    SAMPLE_PULSE <= adc_sample_sig; -- conituous sample pulses; this keeps the ADCs operating continuously, eliminating startup transiants
    
    VALID_OUT <= sample_en_sig; -- all the sample pulses that happen while sample_en_fsm_sig is on

    --------------------------------------------------------------
    -- segment MUX & zero-step signals
    --------------------------------------------------------------

    process (
        segment_sig,
        freq_start_sig,
        freq_end_sig,
        freq_count_sig,
        time_pre_sig,
        time_step_sig,
        time_post_sig
    ) begin
        case segment_sig is
            when "01" => 
                freq_out_sig <= freq_start_sig;
            when "11" =>
                freq_out_sig <= freq_count_sig;
            when "10" =>
                freq_out_sig <= freq_end_sig;
            when others =>
                freq_out_sig <= freq_end_sig; -- maintain END frequency between bursts
        end case;
        case segment_sig is
            when "01" => 
                timer_end_sig <= time_pre_sig;
            when "11" =>
                timer_end_sig <= time_step_sig;
            when "10" =>
                timer_end_sig <= time_post_sig;
            when others =>
                timer_end_sig <= time_pre_sig;
        end case;
    end process;
    
    zero_pre_sig    <= '1' when time_pre_sig = x"0000" else '0';
    zero_step_sig   <= '1' when time_step_sig = x"0000" else '0';
    zero_post_sig   <= '1' when time_post_sig = x"0000" else '0';
    
    --------------------------------------------------------------
    -- input registers
    --------------------------------------------------------------

    CYCLES_reg : entity work.Reg1D
        generic map (
            LENGTH      => CYCLES_WIDTH
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => VALID_IN,
            PAR_IN      => CYCLES,
            PAR_OUT     => cycle_end_sig
        );
        
    RF_FREQ_START_reg : entity work.Reg1D
        generic map (
            LENGTH      => RF_FREQ_WIDTH
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => VALID_IN,
            PAR_IN      => RF_FREQ_START,
            PAR_OUT     => freq_start_sig
        );
        
    RF_FREQ_END_reg : entity work.Reg1D
        generic map (
            LENGTH      => RF_FREQ_WIDTH
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => VALID_IN,
            PAR_IN      => RF_FREQ_END,
            PAR_OUT     => freq_end_sig
        );
        
    PRE_DURATION_reg : entity work.Reg1D
        generic map (
            LENGTH      => SAMPLE_COUNT_WIDTH
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => VALID_IN,
            PAR_IN      => PRE_DURATION,
            PAR_OUT     => time_pre_sig
        );
        
    STEP_DURATION_reg : entity work.Reg1D
        generic map (
            LENGTH      => SAMPLE_COUNT_WIDTH
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => VALID_IN,
            PAR_IN      => STEP_DURATION,
            PAR_OUT     => time_step_sig
        );
        
    POST_DURATION_reg : entity work.Reg1D
        generic map (
            LENGTH      => SAMPLE_COUNT_WIDTH
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => VALID_IN,
            PAR_IN      => POST_DURATION,
            PAR_OUT     => time_post_sig
        );
        
    --------------------------------------------------------------
    -- counters and timers
    --------------------------------------------------------------

    PeriodDetector_module: entity work.PeriodDetector
        generic map (
            SAMPLE_LENGTH           => 16,
            SUM_WIDTH               => 4,
            LOGIC_HIGH              => 13,
            LOGIC_LOW               => 2,
            SUM_START               => 7,
            PERIOD_WIDTH            => RF_DIV_PERIOD_WIDTH
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN                      => '1',
            
            SIG_IN                  => RF_FREQ_DIV,
            
            PERIOD                  => RF_FREQ_DIV_PERIOD
        );    
    
    timer_en_sig <= adc_sample_sig and timer_en_fsm_sig;
    timer_rst_sig <= timer_rst_fsm_sig or RST;
    
    sample_timer : entity work.Timer
        generic map (
            WIDTH                   => SAMPLE_COUNT_WIDTH
        )
        port map (
            CLK                     => CLK,
            EN                      => timer_en_sig,
            RST                     => timer_rst_sig,
            COUNT_END               => timer_end_sig,
    
            DONE                    => timer_done_sig
        );

    freq_counter_rst_sig <= freq_counter_rst_fsm_sig or RST;

    frequency_counter : entity work.TimerBidirectional
        generic map (
            WIDTH                   => RF_FREQ_WIDTH
        )
        port map (
            CLK                     => CLK,
            EN                      => freq_counter_en_sig,
            RST                     => freq_counter_rst_sig,
            COUNT_START             => freq_start_sig,
            COUNT_END               => freq_end_sig,
    
            COUNT                   => freq_count_sig,
            DONE                    => freq_counter_done_sig
        );

    freq_out_reg : entity work.Reg1D
        generic map (
            LENGTH      => RF_FREQ_WIDTH
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => '1',
            PAR_IN      => freq_out_sig,
            PAR_OUT     => RF_FREQ
        );
        
    cycle_rst_sig <= cycle_rst_fsm_sig or RST;

    cycle_counter : entity work.Timer
        generic map (
            WIDTH                   => CYCLES_WIDTH
        )
        port map (
            CLK                     => CLK,
            EN                      => cycle_en_sig,
            RST                     => cycle_rst_sig,
            COUNT_END               => cycle_end_sig,
    
            COUNT                   => CYCLE_COUNT,
            DONE                    => cycle_done_sig
        );
        
    sample_en_sig <= adc_sample_sig and sample_en_fsm_sig;
    sample_rst_sig <= sample_rst_fsm_sig or RST;
    
    sample_counter : entity work.Timer
        generic map (
            WIDTH                   => SAMPLE_COUNT_WIDTH
        )
        port map (
            CLK                     => CLK,
            EN                      => sample_en_sig,
            RST                     => sample_rst_sig,
    
            COUNT                   => SAMPLE_COUNT
        );

end Behavioral;

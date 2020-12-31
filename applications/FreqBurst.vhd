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
    	-- Sample rate
        SAMPLE_PERIOD           : positive := 99;   -- units of clock cycles (minus 1)
        SAMPLE_PERIOD_WIDTH     : positive := 8;
        -- Serial rate
        SERIAL_RATE             : positive := 99;   -- units of clock cycles (minus 1)
        -- RF freq (DAC)
        RF_FREQ_WIDTH           : positive := 4;    -- width of output vlaues to DAC controlling RF freq
        -- RF div
        RF_DIV_PERIOD_WIDTH     : positive := 8;    -- width of div-freq period (units of clock cycles)
        RF_DIV_MA_LENGTH        : positive := 4;    -- number of samples in MA filter
        RF_DIV_MA_SUM_WIDTH     : positive := 12;   -- width of div-freq MA sum
        RF_DIV_MA_SUM_SHIFT     : positive := 2;    -- divide the MA sum by shifting
        -- cycles
        CYCLE_COUNT_WIDTH       : positive := 8;    -- width of cycles-1 total & width of cycle count
        -- samples
        SAMPLE_COUNT_WIDTH      : positive := 16;   -- width of samples-1 totals & width of sample counts
        -- I & Q (ADCs)
        ADC_WIDTH               : positive := 16    -- width of I & Q data input from ADCs
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;        
        -- RF freq (simple DAC)
        RF_FREQ                 : out std_logic_vector(RF_FREQ_WIDTH-1 downto 0);
        -- RF div
        RF_DIV                  : in std_logic;        
        -- I & Q (simple delta-sigma ADCs)
        I_ADC_CMP               : in std_logic;
        I_ADC_INV               : out std_logic;
        Q_ADC_CMP               : in std_logic;
        Q_ADC_INV               : out std_logic;
        -- Serial IO
        RX                      : in std_logic;
        TX                      : out std_logic
    );
end FreqBurst;


architecture Behavioral of FreqBurst is

    -- handshakes
    signal rx_valid_out_sig         : std_logic;
    signal ramp_ready_sig           : std_logic;
    signal ramp_valid_out_sig       : std_logic;
    -- RF freq
    signal rx_ramp_start_sig        : std_logic_vector(RF_FREQ_WIDTH-1 downto 0);
    signal rx_ramp_end_sig          : std_logic_vector(RF_FREQ_WIDTH-1 downto 0);
    -- RF div
    signal rf_div_period_sig        : std_logic_vector(RF_DIV_PERIOD_WIDTH-1 downto 0);
    signal rf_div_ma_sum_sig        : std_logic_vector(RF_DIV_MA_SUM_WIDTH-1 downto 0);
    signal rf_div_ma_filtered_sig   : std_logic_vector(RF_DIV_PERIOD_WIDTH-1 downto 0);
    -- Cycle total & count
    signal rx_cycles_sig            : std_logic_vector(CYCLE_COUNT_WIDTH-1 downto 0);
    signal cycle_count_sig          : std_logic_vector(CYCLE_COUNT_WIDTH-1 downto 0);
    -- Sample totals & count
    signal rx_pre_sig               : std_logic_vector(SAMPLE_COUNT_WIDTH-1 downto 0);
    signal rx_step_sig              : std_logic_vector(SAMPLE_COUNT_WIDTH-1 downto 0);
    signal rx_post_sig              : std_logic_vector(SAMPLE_COUNT_WIDTH-1 downto 0);
    signal sample_count_sig         : std_logic_vector(SAMPLE_COUNT_WIDTH-1 downto 0);
    -- I & Q data (ADCs)
    signal adc_sample_sig           : std_logic;
    signal i_adc_sig                : std_logic_vector(ADC_WIDTH-1 downto 0);
    signal q_adc_sig                : std_logic_vector(ADC_WIDTH-1 downto 0);
    -- ramp FSM state
    signal ramp_state_sig           : std_logic_vector(3 downto 0);
    -- telemetry
    signal serial_alarm_sig         : std_logic_vector(1 downto 0);
    signal rx_data_sig              : std_logic_vector(8*8-1 downto 0);
    signal tx_data_sig              : std_logic_vector(8*8-1 downto 0);
    
begin

    I_ADC: entity work.ADCSimpleDeltaSigma
        generic map (
            SIG_OUT_WIDTH    		=> ADC_WIDTH
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
                    
            EN_SAMPLE               => adc_sample_sig,
            EN_OUT                  => adc_sample_sig,
    
            CMP_IN                  => I_ADC_CMP,
            INV_OUT                 => I_ADC_INV,
    
            SIG_OUT                 => i_adc_sig
        );
    
    Q_ADC: entity work.ADCSimpleDeltaSigma
        generic map (
            SIG_OUT_WIDTH    		=> ADC_WIDTH
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
                    
            EN_SAMPLE               => adc_sample_sig,
            EN_OUT                  => adc_sample_sig,
    
            CMP_IN                  => Q_ADC_CMP,
            INV_OUT                 => Q_ADC_INV,
    
            SIG_OUT                 => q_adc_sig
        );
    
    RF_output_freq: entity work.RampSampling
        generic map (
            SAMPLE_PERIOD_WIDTH     => SAMPLE_PERIOD_WIDTH,
            SAMPLE_COUNT_WIDTH      => SAMPLE_COUNT_WIDTH,
            CYCLE_COUNT_WIDTH       => CYCLE_COUNT_WIDTH,
            RAMP_WIDTH              => RF_FREQ_WIDTH
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,        
            
            -- settings
            SAMPLE_PERIOD           => std_logic_vector(to_unsigned(SAMPLE_PERIOD,SAMPLE_PERIOD_WIDTH)),
            
            -- upstream handshake
            VALID_IN                => rx_valid_out_sig,
            READY_OUT               => ramp_ready_sig,
    
            -- input data
            -- start frequency
            RAMP_START              => rx_ramp_start_sig,
            -- end frequency
            RAMP_END                => rx_ramp_end_sig,
            -- cycles-1 (total number of repeated cycles with same start/step/end)
            CYCLES                  => rx_cycles_sig,
            -- PRE segment duration (units of samples)
            PRE_DURATION            => rx_pre_sig,
            -- STEP segment duration (each step; units of samples; total duration of segment is ramp_delta*step_duration)
            STEP_DURATION           => rx_step_sig,
            -- POST segment duration (units of samples)
            POST_DURATION           => rx_post_sig,
            
            -- output data & control
            -- ADC sample pulse
            SAMPLE_PULSE            => adc_sample_sig,
            -- control output frequency setting
            RAMP                    => RF_FREQ,
            -- output cycle count (contiguous cycles with same start/step/end)
            CYCLE_COUNT             => cycle_count_sig,
            -- output sample count (sample count in the current cycle)
            SAMPLE_COUNT            => sample_count_sig,
    
            -- downstream valid
            VALID_OUT               => ramp_valid_out_sig,
            
            -- debug
            STATE                   => ramp_state_sig
        );

    RF_input_period: entity work.PeriodDetector
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
            
            SIG_IN                  => RF_DIV,
            PERIOD                  => rf_div_period_sig
        );  
          
    MAFilter_module : entity work.MAFilter
        generic map (
            SAMPLE_LENGTH       => 8,
            SAMPLE_WIDTH        => RF_DIV_PERIOD_WIDTH,
            SUM_WIDTH           => RF_DIV_PERIOD_WIDTH + 4,
            SUM_START           => 0,
            SIGNED_ARITHMETIC   => false
        )
        port map (
            CLK             => CLK,
            EN              => '1',
            RST             => RST,
            SIG_IN          => rf_div_period_sig,
            SUM_OUT         => rf_div_ma_sum_sig
        );

    rf_div_ma_filtered_sig <= rf_div_ma_sum_sig(RF_DIV_PERIOD_WIDTH+3-1 downto 3);
    
    tx_data_sig <=  i_adc_sig & 
                    q_adc_sig & 
                    rf_div_period_sig & 
                    cycle_count_sig & 
                    sample_count_sig ;

    telemetry: entity work.PacketSerialFullDuplex
        -- Serial baud rate is clk_freq/100
        generic map (
            RX_HEADER_BYTES         => 2,
            RX_DATA_BYTES           => 8,
            TX_HEADER_BYTES         => 2,
            TX_DATA_BYTES           => 8
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            
            SERIAL_RX               => RX,
            SERIAL_TX               => TX,
            SERIAL_ALARM            => serial_alarm_sig,
    
            -- RX data
            VALID_OUT               => rx_valid_out_sig,
            RX_HEADER		        => x"0102",
            RX_DATA  		        => rx_data_sig,
            
            -- TX data
            VALID_IN                => ramp_valid_out_sig,
            TX_HEADER		        => x"0102",
            TX_DATA  		        => tx_data_sig
        );
    
    rx_ramp_start_sig   <= rx_data_sig(8*8-1 downto 8*7+4);
    rx_ramp_end_sig     <= rx_data_sig(8*7+3 downto 8*7);
    rx_cycles_sig       <= rx_data_sig(8*7-1 downto 8*6);
    rx_pre_sig          <= rx_data_sig(8*6-1 downto 8*4);
    rx_step_sig         <= rx_data_sig(8*4-1 downto 8*2);
    rx_post_sig         <= rx_data_sig(8*2-1 downto 0);

end Behavioral;

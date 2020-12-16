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
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;

        I_CMP_IN                : in std_logic;
        I_INV_OUT               : out std_logic;
        Q_CMP_IN                : in std_logic;
        Q_INV_OUT               : out std_logic;

        RF_EN                   : out std_logic;
        RF_FREQ                 : out std_logic_vector(3 downto 0);

        SERIAL_TX               : out std_logic;
        SERIAL_RX               : in std_logic
    );
end FreqBurst;


architecture Behavioral of FreqBurst is

    -- FSM control signals
    signal timer_en_sig             : std_logic;
    signal timer_done_sig           : std_logic;
    signal timer_rst_sig            : std_logic;
    signal timer_end_sig            : std_logic_vector(15 downto 0);
    signal freq_counter_en_sig      : std_logic;
    signal freq_counter_done_sig    : std_logic;
    signal freq_counter_rst_sig     : std_logic;
    signal cycle_en_sig             : std_logic;
    signal cycle_done_sig           : std_logic;
    signal cycle_rst_sig            : std_logic;
    signal sample_en_sig            : std_logic;
    signal sample_rst_sig           : std_logic;

    -- RX control signals
    signal packet_rx_data_sig       : std_logic_vector(8*8-1 downto 0);
    signal packet_rx_data_reg_sig   : std_logic_vector(8*8-1 downto 0);
    signal packet_rx_valid_sig      : std_logic;
    signal serial_alarm_sig         : std_logic_vector(1 downto 0);

    -- TX control signals
    signal adc_sample_sig           : std_logic;


    -- RX data signals
    signal cycle_end_sig            : std_logic_vector(7 downto 0);
    signal freq_start_sig           : std_logic_vector(3 downto 0);
    signal freq_end_sig             : std_logic_vector(3 downto 0);
    signal time_pre_sig             : std_logic_vector(15 downto 0);
    signal time_step_sig            : std_logic_vector(15 downto 0);
    signal time_post_sig            : std_logic_vector(15 downto 0);

    -- TX data signals
    signal i_out_sig                : std_logic_vector(15 downto 0);
    signal q_out_sig                : std_logic_vector(15 downto 0);
    signal cycle_count_sig          : std_logic_vector(7 downto 0);
    signal sample_count_sig         : std_logic_vector(15 downto 0);
    
begin

    ADC_sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH                       => 8
    )
    port map (
        CLK                         => CLK,
        EN                          => '1',
        RST                         => RST,
        PERIOD                      => x"63", -- 100MHz/1MHz-1 to hex
        INIT_PERIOD                 => x"63",
        PULSE                       => adc_sample_sig
    );


    I_ADC: entity work.ADCSimpleDeltaSigma
        generic map (
            ADC_PERIOD_WIDTH        => 8,
            SIG_OUT_WIDTH    		=> 16
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            CMP_IN                  => I_CMP_IN,
            EN_SAMPLE               => adc_sample_sig,
            EN_OUT                  => adc_sample_sig,
            INV_OUT                 => I_INV_OUT,
            SIG_OUT                 => i_out_sig
        );

    Q_ADC: entity work.ADCSimpleDeltaSigma
        generic map (
            ADC_PERIOD_WIDTH        => 8,
            SIG_OUT_WIDTH    		=> 16
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            CMP_IN                  => Q_CMP_IN,
            EN_SAMPLE               => adc_sample_sig,
            EN_OUT                  => adc_sample_sig,
            INV_OUT                 => Q_INV_OUT,
            SIG_OUT                 => q_out_sig
        );


    FreqBurstTelemetry_module: entity work.FreqBurstTelemetry
        port map (
            CLK                     => CLK,
            RST                     => RST,
            
            SERIAL_RX               => SERIAL_RX,
            SERIAL_TX               => SERIAL_TX,
            SERIAL_ALARM            => serial_alarm_sig,
    
            -- RX valid
            VALID_OUT               => packet_rx_valid_sig,
            -- RX data (8 bytes)
            CYCLES					=> cycle_end_sig, -- cycles-1
            FREQ_START				=> freq_start_sig,
            FREQ_END				=> freq_end_sig,
            TIME_PRE	    		=> time_pre_sig, -- units of samples
            TIME_STEP			  	=> time_step_sig, -- units of samples
            TIME_POST 	  			=> time_post_sig, -- units of samples
            
            -- TX valid
            VALID_IN                => adc_sample_sig,
            -- TX data (7 bytes)
            I_ADC					=> i_out_sig,
            Q_ADC					=> q_out_sig,
            CYCLE_COUNT 			=> cycle_count_sig,        
            SAMPLE_COUNT			=> sample_count_sig -- could roll over
        );
    
    
    sample_timer : entity work.Timer
        generic map (
            WIDTH                   => 16
        )
        port map (
            CLK                     => CLK,
            EN                      => timer_en_sig,
            RST                     => timer_rst_sig,
            COUNT_END               => timer_end_sig,
    
            DONE                    => timer_done_sig
        );

    frequency_counter : entity work.TimerBidirectional
        generic map (
            WIDTH                   => 4
        )
        port map (
            CLK                     => CLK,
            EN                      => freq_counter_en_sig,
            RST                     => freq_counter_rst_sig,
            COUNT_START             => freq_start_sig,
            COUNT_END               => freq_end_sig,
    
            COUNT                   => RF_FREQ,
            DONE                    => freq_counter_done_sig
        );

    cycle_counter : entity work.Timer
        generic map (
            WIDTH                   => 8
        )
        port map (
            CLK                     => CLK,
            EN                      => cycle_en_sig,
            RST                     => cycle_rst_sig,
            COUNT_END               => cycle_end_sig,
    
            COUNT                   => cycle_count_sig,
            DONE                    => cycle_done_sig
        );
    
    sample_counter : entity work.Timer
        generic map (
            WIDTH                   => 16
        )
        port map (
            CLK                     => CLK,
            EN                      => sample_en_sig,
            RST                     => sample_rst_sig,
    
            COUNT                   => sample_count_sig
        );

end Behavioral;

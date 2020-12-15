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
        ADC_PERIOD_WIDTH        : positive := 8
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;

        ADC_PERIOD              : in std_logic_vector(ADC_PERIOD_WIDTH-1 downto 0);
        UART_PERIOD             : in std_logic_vector(15 downto 0);

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

  signal adc_sample_sig         : std_logic;
  signal i_out_sig              : std_logic_vector(15 downto 0);
  signal q_out_sig              : std_logic_vector(15 downto 0);
  
  signal adc_combined_sig       : std_logic_vector(31 downto 0);

  signal packet_rx_valid_sig    : std_logic;
  signal packet_rx_data_sig     : std_logic_vector(8*8-1 downto 0);
  signal packet_rx_data_reg_sig : std_logic_vector(8*8-1 downto 0);
  signal serial_alarm_sig       : std_logic_vector(1 downto 0);

begin

    ADC_sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => ADC_PERIOD_WIDTH
    )
    port map (
        CLK             => CLK,
        EN              => '1',
        RST             => RST,
        PERIOD          => x"63", -- 100MHz/1MHz-1 to hex
        INIT_PERIOD     => x"63",
        PULSE           => adc_sample_sig
    );


    I_ADC: entity work.ADCSimpleDeltaSigma
        generic map (
            ADC_PERIOD_WIDTH        => 8,
            SIG_OUT_WIDTH    		    => 16
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
            SIG_OUT_WIDTH    		    => 16
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

    adc_combined_sig <= i_out_sig & q_out_sig;
    

    FreqBurstTelemetry_module: entity work.FreqBurstTelemetry
        port map (
            CLK                     => CLK,
            RST                     => RST,
            
            SERIAL_RX               => SERIAL_RX,
            SERIAL_TX               => SERIAL_TX,
            SERIAL_ALARM            => serial_alarm_sig,
    
            -- RX data (8 bytes)
            VALID_OUT               => packet_rx_valid_sig,
            CYCLES					=> cycle_end_sig, -- cycles-1
            FREQ_START				=> freq_start_sig,
            FREQ_END				=> freq_end_sig,
            TIME_PRE	    		=> time_pre_sig, -- units of samples
            TIME_STEP			  	=> time_step_sig, -- units of samples
            TIME_POST 	  			=> time_post_sig, -- units of samples
            
            -- TX data (7 bytes)
            VALID_IN                => adc_sample_sig,
            I_ADC					=> i_out_sig,
            Q_ADC					=> q_out_sig,
            CYCLE_COUNT 			=> cycle_count_sig,        
            SAMPLE_COUNT			=> sample_count_sig, -- could roll over
        );
    
    
    receive_reg : entity work.Reg1D
        generic map (
            LENGTH      => 8*8
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => packet_rx_valid_sig,
            PAR_IN      => packet_rx_data_sig,
            PAR_OUT     => packet_rx_data_reg_sig
        );

    cycle_counter : entity work.Timer
        generic map (
            WIDTH           => 8
        )
        port map (
            CLK             => CLK,
            EN              => cycle_en_sig,
            RST             => cycle_rst_sig,
            COUNT_END       => cycle_end_sig,
    
            COUNT           => cycle_count_sig,
            DONE            => cycle_done_sig
        );
    
    sample_counter : entity work.Timer
        generic map (
            WIDTH           => 16
        )
        port map (
            CLK             => CLK,
            EN              => sample_en_sig,
            RST             => sample_rst_sig,
    
            COUNT           => sample_count_sig
        );
    


end Behavioral;

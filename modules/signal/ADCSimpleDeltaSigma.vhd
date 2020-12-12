library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ADCSimpleDeltaSigma is
    generic (
        ADC_PERIOD_WIDTH        : positive := 8;
        SIG_OUT_WIDTH    		: positive := 12
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;
                
        ADC_PERIOD              : in std_logic_vector(ADC_PERIOD_WIDTH-1 downto 0);

        CMP_IN                  : in std_logic;
        INV_OUT                 : out std_logic;

        VALID                   : out std_logic;
        SIG_OUT                 : out std_logic_vector(SIG_OUT_WIDTH-1 downto 0)
    );
end ADCSimpleDeltaSigma;


architecture Behavioral of ADCSimpleDeltaSigma is

  signal adc_out_sig            : std_logic;
  signal adc_sample_sig         : std_logic;
  signal packet_valid_out       : std_logic;
  signal filter_in_sig          : std_logic_vector(1 downto 0);
  signal filter_out_sig         : std_logic_vector(SIG_OUT_WIDTH-1 downto 0);

begin

    ADC_sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => ADC_PERIOD_WIDTH
    )
    port map (
        CLK             => CLK,
        EN              => '1',
        RST             => RST,
        PERIOD          => ADC_PERIOD, -- x"63" is 100MHz/1MHz-1 to hex
        INIT_PERIOD     => ADC_PERIOD,
        PULSE           => adc_sample_sig
    );

    ADC: entity work.ADC1Bit
        port map (
            CLK                     => CLK,
            EN                      => adc_sample_sig,
            RST                     => RST,
            CMP_IN                  => CMP_IN,
            INV_OUT                 => INV_OUT,
            PDM_OUT                 => adc_out_sig
        );

    filter_in_sig <= (not adc_out_sig) & adc_out_sig; -- +1 for high, -1 for low

    LP_filter: entity work.FIRFilterLP15tap
        generic map (
            SIG_IN_WIDTH        => 2, -- signal input path width
            SIG_OUT_WIDTH       => SIG_OUT_WIDTH -- signal output path width
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN_IN               => adc_sample_sig,
            EN_OUT              => adc_sample_sig,
            SIG_IN              => filter_in_sig,

            SIG_OUT             => SIG_OUT
        );
     
    VALID <= adc_sample_sig;

end Behavioral;

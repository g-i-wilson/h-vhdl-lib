library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ADC1BitFiltered is
    generic (
        WIDTH                   : positive := 16 -- signal output path width
    );
    port (
        CLK                     : in std_logic;
        EN_IN                   : in std_logic;
        EN_OUT                  : in std_logic;
        RST                     : in std_logic;

        CMP_IN                  : in std_logic;
        INV_OUT                 : out std_logic;

        SAMPLE_OUT              : out std_logic;
        SIG_OUT                 : out std_logic_vector(WIDTH-1 downto 0)
    );
end ADC1BitFiltered;


architecture Behavioral of ADC1BitFiltered is

  signal adc_out_sig    : std_logic;
  signal filter_in_sig  : std_logic_vector(1 downto 0);
  signal sample_sig     : std_logic;

begin

    ADC: entity work.ADC1Bit
        port map (
            CLK                     => CLK,
            EN                      => EN_IN,
            RST                     => RST,
            CMP_IN                  => CMP_IN,
            INV_OUT                 => INV_OUT,
            PDM_OUT                 => adc_out_sig
        );

    filter_in_sig <= (not adc_out_sig) & adc_out_sig; -- +1 for high, -1 for low

    -- cutoff freq is aprox 1/63 of sample rate
    LP_filter: entity work.FIRFilterLP63tap
        generic map (
            SIG_IN_WIDTH        => 2, -- signal input path width
            SIG_OUT_WIDTH       => WIDTH -- signal output path width
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN_IN               => EN_IN,
            EN_OUT              => EN_OUT,
            SIG_IN              => filter_in_sig,

            SIG_OUT             => SIG_OUT
        );

end Behavioral;

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
        SIG_OUT_WIDTH    		: positive := 12
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;
                
        EN_SAMPLE               : in std_logic;
        EN_OUT                  : in std_logic;

        CMP_IN                  : in std_logic;
        INV_OUT                 : out std_logic;

        SIG_OUT                 : out std_logic_vector(SIG_OUT_WIDTH-1 downto 0)
    );
end ADCSimpleDeltaSigma;


architecture Behavioral of ADCSimpleDeltaSigma is

  signal adc_in_sig             : std_logic;
  signal adc_out_sig            : std_logic;
  signal filter_in_sig          : std_logic_vector(1 downto 0);
  signal filter_out_sig         : std_logic_vector(SIG_OUT_WIDTH-1 downto 0);

begin

    sync_reg : entity work.Synchronizer
        generic map (
            SYNC_LENGTH     => 3
        )
        port map (
            RST             => RST,
            CLK             => CLK,
            SIG_IN        	=> CMP_IN,
            SIG_OUT         => adc_in_sig
        );

    ADC: entity work.ADC1Bit
        port map (
            CLK                     => CLK,
            EN                      => EN_SAMPLE,
            RST                     => RST,
            CMP_IN                  => adc_in_sig,
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
            EN_IN               => EN_SAMPLE,
            EN_OUT              => EN_OUT,
            SIG_IN              => filter_in_sig,

            SIG_OUT             => SIG_OUT
        );
     

end Behavioral;

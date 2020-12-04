library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ADC1Bit is
  port (
    CLK                       : in std_logic;
    EN                        : in std_logic;
    RST                       : in std_logic;

    CMP_IN                    : in std_logic;

    INV_OUT                   : out std_logic;

    PDM_OUT                   : out std_logic
  );
end ADC1Bit;


architecture Behavioral of ADC1Bit is

    signal pdm_out_sig : std_logic;
    signal cmp_in_sig : std_logic;

begin

    adc: process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
            	pdm_out_sig <= '0';
           	elsif (EN = '1') then
           		pdm_out_sig <= CMP_IN;
           	else
           		pdm_out_sig <= pdm_out_sig;
            end if;
        end if;
    end process;

    PDM_OUT <= pdm_out_sig;
    INV_OUT <= not pdm_out_sig;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Angle1Bit is
    port (
        CLK     : in STD_LOGIC;

        X_IN  : in STD_LOGIC;
		Y_IN  : in STD_LOGIC;

        A_OUT   : out STD_LOGIC_VECTOR(1 downto 0)
    );
end Angle1Bit;

architecture Behavioral of Angle1Bit is

begin

	process (CLK)
	begin
		if rising_edge(CLK) then
			
		end if;
	end process;

end Behavioral;

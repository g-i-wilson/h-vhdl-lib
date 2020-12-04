library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FF is
    port (
        CLK             : in STD_LOGIC;
        EN              : in STD_LOGIC := '1';
        RST             : in STD_LOGIC;
        DEFAULT         : in STD_LOGIC := '0';
        D               : in STD_LOGIC;
        Q               : out STD_LOGIC
   );
end FF;

architecture Behavioral of FF is

    signal q_sig    : std_logic;

begin

    process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                q_sig <= DEFAULT;
            elsif (EN = '1') then
                q_sig <= D;
            else
                q_sig <= q_sig;
            end if;
        end if;
    end process;

    Q <= q_sig;

end Behavioral;

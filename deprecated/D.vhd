library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity D is
    port (
        CLK             : in STD_LOGIC;
        EN              : in STD_LOGIC := '1';
        RST             : in STD_LOGIC;
        DEFAULT_STATE   : in STD_LOGIC := '0';
        D_IN            : in STD_LOGIC;
        D_OUT           : out STD_LOGIC
   );
end D;

architecture Behavioral of D is

    signal d_out_sig    : std_logic;

begin

    process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                d_out_sig <= DEFAULT_STATE;
            elsif (EN = '1') then
                d_out_sig <= D_IN;
            else
                d_out_sig <= d_out_sig;
            end if;
        end if;
    end process;
    
    D_OUT <= d_out_sig;

end Behavioral;

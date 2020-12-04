----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2020 08:32:04 AM
-- Design Name: 
-- Module Name: decoder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder is
    Port ( nibble_in : in STD_LOGIC_VECTOR (3 downto 0);
           level_out : out STD_LOGIC_VECTOR (15 downto 0);
           en : in STD_LOGIC);
end decoder;

architecture Behavioral of decoder is

begin

    process (nibble_in, en)
    begin
        level_out <= (others=>'0');        -- default output value
        if (en = '1') then  -- active high enable pin
            case nibble_in is
                when x"0" => level_out(0) <= '1';
                when x"1" => level_out(1) <= '1';
                when x"2" => level_out(2) <= '1';
                when x"3" => level_out(3) <= '1';
                when x"4" => level_out(4) <= '1';
                when x"5" => level_out(5) <= '1';
                when x"6" => level_out(6) <= '1';
                when x"7" => level_out(7) <= '1';
                when x"8" => level_out(8) <= '1';
                when x"9" => level_out(9) <= '1';
                when x"A" => level_out(10) <= '1';
                when x"B" => level_out(11) <= '1';
                when x"C" => level_out(12) <= '1';
                when x"D" => level_out(13) <= '1';
                when x"E" => level_out(14) <= '1';
                when x"F" => level_out(15) <= '1';
                when others => level_out <= (others=>'0');
            end case;
        end if;
    end process;

end Behavioral;

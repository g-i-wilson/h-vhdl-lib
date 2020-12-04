----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2020 08:36:34 AM
-- Design Name: 
-- Module Name: encoder - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity encoder is
    Port ( level_in : in STD_LOGIC_VECTOR (15 downto 0);
           nibble_out : out STD_LOGIC_VECTOR (3 downto 0);
           en : in STD_LOGIC);
end encoder;

architecture Behavioral of encoder is

begin

    process (level_in, en)
    begin
        nibble_out <= (others=>'0');
        -- higher inputs take precedence over lower inputs
        if (en = '1') then
            for i in 15 downto 0 loop
                if (level_in(i) = '1') then
                    nibble_out <= std_logic_vector(to_unsigned(i, nibble_out'length));
                    exit;
                end if;
            end loop;
         end if;
        
        
--        if (en = '1') then  -- active high enable pin
--            case level_in is
--                when "0000000000000001" => nibble_out <= x"0";
--                when "0000000000000010" => nibble_out <= x"1";
--                when "0000000000000100" => nibble_out <= x"2";
--                when "0000000000001000" => nibble_out <= x"3";
--                when "0000000000010000" => nibble_out <= x"4";
--                when "0000000000100000" => nibble_out <= x"5";
--                when "0000000001000000" => nibble_out <= x"6";
--                when "0000000010000000" => nibble_out <= x"7";
--                when "0000000100000000" => nibble_out <= x"8";
--                when "0000001000000000" => nibble_out <= x"9";
--                when "0000010000000000" => nibble_out <= x"a";
--                when "0000100000000000" => nibble_out <= x"b";
--                when "0001000000000000" => nibble_out <= x"c";
--                when "0010000000000000" => nibble_out <= x"d";
--                when "0100000000000000" => nibble_out <= x"e";
--                when "1000000000000000" => nibble_out <= x"f";
--                when others => nibble_out <= x"0";
--            end case;
--        end if;
    end process;

end Behavioral;

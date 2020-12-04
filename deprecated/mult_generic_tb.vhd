----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2020 08:23:17 AM
-- Design Name: 
-- Module Name: mult_generic_tb - Behavioral
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

entity mult_generic_tb is
--  Port ( );
end mult_generic_tb;

architecture Behavioral of mult_generic_tb is

component mult_generic
    generic (
        in_len : integer
    );
    port (
        in_a : in STD_LOGIC_VECTOR (in_len-1 downto 0);
        in_b : in STD_LOGIC_VECTOR (in_len-1 downto 0);
        mult_out : out STD_LOGIC_VECTOR ((in_len*2)-1 downto 0)
    );
end component;

signal test_a, test_b : std_logic_vector (3 downto 0);
signal test_out : std_logic_vector (7 downto 0);

begin

    mult_1 : mult_generic
        generic map (
            in_len => 4
        )
        port map (
            in_a => test_a,
            in_b => test_b,
            mult_out => test_out
        );
 
    process
    begin
        test_a <= "0000";
        test_b <= "0000";
        wait for 100ns;
        test_a <= "0011";
        test_b <= "0011";
        wait for 100ns;
        test_a <= "0010";
        test_b <= "0001";
        wait for 100ns;
        test_a <= "0010";
        test_b <= "0010";
        wait for 100ns;
        test_a <= "0000";
        test_b <= "0000";
        wait for 100ns;
        test_a <= "1111";
        test_b <= "0001";
        wait for 100ns;
        test_a <= "1111";
        test_b <= "1111";
        wait for 100ns;
        test_a <= "1110";
        test_b <= "0110";
        wait for 100ns;
        test_a <= "1111";
        test_b <= "0111";
        wait for 100us;
    end process;


end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/09/2020 03:05:47 PM
-- Design Name: 
-- Module Name: reg_add_generic - Behavioral
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

entity reg_add_generic is
    Port ( in_a : in STD_LOGIC_VECTOR (1 downto 0);
           in_b : in STD_LOGIC_VECTOR (1 downto 0);
           add_out : out STD_LOGIC_VECTOR (1 downto 0);
           overflow_bit : out STD_LOGIC);
end reg_add_generic;

architecture Behavioral of reg_add_generic is

begin


end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2020 08:32:04 AM
-- Design Name: 
-- Module Name: nwide-sregister - Behavioral
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

entity nwide-sregister is
    Port ( in : in STD_LOGIC_VECTOR (7 downto 0);
           out : out STD_LOGIC_VECTOR (7 downto 0);
           reg : out STD_LOGIC_VECTOR (72 downto 0);
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC);
end nwide-sregister;

architecture Behavioral of nwide-sregister is

begin


end Behavioral;

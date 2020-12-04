----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/10/2020 10:26:50 AM
-- Design Name: 
-- Module Name: decoder_generic - Behavioral
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

entity decoder_generic is
    generic (
        val_width : integer;
    )
    Port ( val_in : in STD_LOGIC_VECTOR (1 downto 0);
           one_out : out STD_LOGIC_VECTOR (1 downto 0));
end decoder_generic;

architecture Behavioral of decoder_generic is

begin


end Behavioral;

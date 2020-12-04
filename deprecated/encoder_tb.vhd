----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/13/2020 11:03:21 AM
-- Design Name: 
-- Module Name: encoder_tb - Behavioral
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

entity encoder_tb is
--  Port ( );
end encoder_tb;


architecture Behavioral of encoder_tb is

component encoder
    Port ( level_in : in STD_LOGIC_VECTOR (15 downto 0);
           nibble_out : out STD_LOGIC_VECTOR (3 downto 0);
           en : in STD_LOGIC);
end component;

signal test_in : std_logic_vector(15 downto 0);
signal test_out : std_logic_vector(3 downto 0);


begin

    encode0: encoder
    port map (
        level_in => test_in,
        nibble_out => test_out,
        en => '1'
    );
    
    process
    begin
    
        test_in <= (others=>'0');
        wait for 20ns;
        
        for a in 0 to 15 loop
            test_in(a) <= '1';
            wait for 20ns;
        end loop;
        
    end process;
    
end Behavioral;

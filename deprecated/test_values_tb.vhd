----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/30/2020 04:38:16 PM
-- Design Name: 
-- Module Name: test_values_tb - Behavioral
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

entity test_values_tb is
--  Port ( );
end test_values_tb;

architecture Behavioral of test_values_tb is

    signal
        test_clk,
        test_rst
        : std_logic;

    signal
        test_out,
        test_start_val,
        test_mult_val
        : std_logic_vector(7 downto 0);

    signal
        test_period
        : std_logic_vector(3 downto 0);

begin


test0: entity work.test_values
    generic map (
        in_width => 8,
        period_width => 4
    )
    Port map (
        clk => test_clk,
        rst => test_rst,
        period => test_period,
        start_val => test_start_val,
        mult_val => test_mult_val,
        test_out => test_out
    );


    process
    
    begin
    
        -- initial
        test_period <= x"3";
        test_mult_val <= x"02";
        test_start_val <= x"04";
        
        test_rst <= '1';
        
        test_clk <= '0';
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        
        test_rst <= '0';


        for a in 0 to 9999 loop
        
            wait for 5ns;
            test_clk <= '1';
            wait for 5ns;
            test_clk <= '0';
                
        end loop;

    end process;


end Behavioral;

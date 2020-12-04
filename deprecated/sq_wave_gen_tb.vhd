----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/27/2020 11:05:12 AM
-- Design Name: 
-- Module Name: sq_wave_gen_tb - Behavioral
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

entity sq_wave_gen_tb is
--  Port ( );
end sq_wave_gen_tb;

architecture Behavioral of sq_wave_gen_tb is


signal test_clk, test_rst, test_sq_out : std_logic;
signal test_half_period : std_logic_vector(7 downto 0) := x"00";

begin

    test0: entity work.square_wave_gen
    generic map (
        half_period_width => 8
    )
    port map (
        clk => test_clk,
        en => '1',
        rst => test_rst,
        half_period => test_half_period,
        sq_out => test_sq_out
    );
    
    process
    
        variable per_mult : integer := 1;
        
    begin
    
        -- initial
        test_rst <= '1';
        
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        test_rst <= '0';
        test_half_period <= x"03";

        for a in 0 to 99 loop
        
            -- change inputs
--            per_mult := per_mult+1;
--            test_half_period <= std_logic_vector(to_signed(per_mult, 8));
            
        
            -- just clock for a while
--            for b in 0 to a*4+4 loop
                -- clock edge
                wait for 5ns;
                test_clk <= '1';
                wait for 5ns;
                test_clk <= '0';
                
--            end loop;
        end loop;

    end process;



end Behavioral;

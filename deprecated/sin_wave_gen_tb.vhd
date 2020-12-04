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

entity sin_wave_gen_tb is
--  Port ( );
end sin_wave_gen_tb;

architecture Behavioral of sin_wave_gen_tb is


signal test_clk, test_rst : std_logic;
signal test_pdm_out : std_logic_vector(0 downto 0);
signal test_sq_out : std_logic_vector(7 downto 0);
signal test_filter_out : std_logic_vector(19 downto 0);

begin

    test0: entity work.sin_wave_gen
    generic map (
        half_period_width => 12,
        sample_period_width => 8,
        pdm_period_width => 4,
        pdm_out_width => 1
    )
    port map (
        clk => test_clk,
        en => '1',
        rst => test_rst,
        half_period => x"100",
        sample_period => x"20",
        pdm_period => x"1",
        pdm_out => test_pdm_out,
        sq_out_debug => test_sq_out,
        filter_out_debug => test_filter_out
    );
    
    process
    
    begin
    
        -- initial
        test_rst <= '1';
        
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        test_rst <= '0';


        for a in 0 to 4096 loop
        
            wait for 5ns;
            test_clk <= '1';
            wait for 5ns;
            test_clk <= '0';
                
        end loop;

    end process;



end Behavioral;

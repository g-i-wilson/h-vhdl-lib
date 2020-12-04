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

entity fun_gen_tb is
--  Port ( );
end fun_gen_tb;

architecture Behavioral of fun_gen_tb is


signal test_clk, test_rst, test_sample_en : std_logic;
signal test_pdm_out_0, test_pdm_out_1 : std_logic_vector(1 downto 0);
signal test_pattern_out_0, test_pattern_out_1 : std_logic_vector(15 downto 0);

begin

      funPos: entity work.fun_gen_sr
      generic map (
        pdm_out_width => 2,
        pattern_length => 8,
        pattern_width => 16
      )
      port map (
        clk => test_clk,
        rst => test_rst,
        repeat_pattern => x"3FFF587C6D3F7B1E7FFE7B1E6D3F587C", --3FFF278112BE04DF000004DF12BE2781",
        sample_period => x"10",
        pdm_period => x"1",
        pdm_out => test_pdm_out_0,
        pattern_out => test_pattern_out_0
      );

      funDiff: entity work.fun_gen_sr
      generic map (
        pdm_out_width => 2,
        pattern_length => 16,
        pattern_width => 16
      )
      port map (
        clk => test_clk,
        rst => test_rst,
        repeat_pattern =>   x"3FFF" &
                            x"587C" &
                            x"6D3F" &
                            x"7B1E" &
                            x"7FFE" &
                            x"7B1E" &
                            x"6D3F" &
                            x"587C" &
                            x"3FFF" &
                            x"2781" &
                            x"12BE" &
                            x"04DF" &
                            x"0000" &
                            x"04DF" &
                            x"12BE" &
                            x"2781" ,
        sample_period => x"10",
        pdm_period => x"1",
        pdm_out => test_pdm_out_1,
        pattern_out => test_pattern_out_1
      );

--    fun00deg: entity work.fun_gen
--    generic map (
--        half_period_width => 12,
--        sample_period_width => 8,
--        pdm_period_width => 4,
--        pdm_out_width => 1
--    )
--    port map (
--        clk => test_clk,
--        en => '1',
--        rst => test_rst,
--        half_period => x"100",
--        sample_period => x"20",
--        pdm_period => x"1",
--        pdm_out => test_pdm_out_0,
--        conv_pattern => x"020913202C363D403D362C20130902" -- approximates a sin wive
--    );
    
    
--    funNeg90deg: entity work.fun_gen
--    generic map (
--        half_period_width => 12,
--        sample_period_width => 8,
--        pdm_period_width => 4,
--        pdm_out_width => 1,
--        phase_lag => 128 -- 90deg phase lag: x"200"/4 = x"80" = 128
--    )
--    port map (
--        clk => test_clk,
--        en => '1',
--        rst => test_rst,
--        half_period => x"100",
--        sample_period => x"20",
--        pdm_period => x"1",
--        pdm_out => test_pdm_out_1,
--        conv_pattern => x"020913202C363D403D362C20130902" -- approximates a sin wive
--    );


    process
    
    begin
    
        -- initial
        test_rst <= '1';
        
        test_clk <= '0';
        wait for 5ns;
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

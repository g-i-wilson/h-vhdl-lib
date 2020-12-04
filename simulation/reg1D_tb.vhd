----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/31/2020 09:31:01 AM
-- Design Name: 
-- Module Name: reg1D_tb - Behavioral
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

entity reg1D_tb is
--  Port ( );
end reg1D_tb;

architecture Behavioral of reg1D_tb is

    signal
        test_clk,
        test_rst,
        test_shift_en,
        test_par_en,
        test_shift_in,
        test_shift_out_0,
        test_shift_out_1
        : std_logic;
        
    signal
        test_par_in,
        test_par_out_0,
        test_par_out_1,
        test_default_state
        : std_logic_vector(7 downto 0);

begin


u0: entity work.reg1D
  generic map (
    length => 8
  )
  port map (
    clk => test_clk,
    rst => test_rst,
    
    shift_en => test_shift_en,
    par_en => test_par_en,
 
    shift_in => test_shift_in,
    par_in => test_par_in,
    
    default_state => test_default_state,
    shift_out => test_shift_out_0,
    par_out => test_par_out_0
  );
  
  u1: entity work.reg1D
  generic map (
    length => 8,
    big_endian => false
  )
  port map (
    clk => test_clk,
    rst => test_rst,
    
    shift_en => test_shift_en,
    par_en => test_par_en,
 
    shift_in => test_shift_in,
    par_in => test_par_in,
    
    default_state => test_default_state,
    shift_out => test_shift_out_1,
    par_out => test_par_out_1
  );

    process
    
    begin
        
        test_default_state <= x"99";

        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;

        test_rst <= '1';
        
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        test_rst <= '0';
        
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        test_shift_in <= '1';

        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        test_shift_en <= '1';

        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        test_par_in <= x"ff";

        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        test_par_en <= '1';

        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        test_shift_en <= '0';

        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        test_rst <= '1';

        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        


    end process;



end Behavioral;

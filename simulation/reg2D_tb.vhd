----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 07/31/2020 03:16:41 PM
-- Design Name:
-- Module Name: reg2D_tb - Behavioral
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

entity reg2D_tb is
--  Port ( );
end reg2D_tb;

architecture Behavioral of reg2D_tb is

    signal
        test_clk,
        test_rst,
        test_shift_en,
        test_par_en,
        test_shift_out
        : std_logic;
        
    signal
        test_par_out
        : std_logic_vector(7 downto 0);
        
    signal
        test_default_state
        : std_logic_vector(31 downto 0);

begin

        reg : entity work.reg2D
        generic map (
          length => 4,
          width => 8
        )
        port map (
          clk      => test_clk,
          rst      => test_rst,

          shift_en => test_shift_en,
          par_en   => test_par_en,

          default_state => test_default_state,

          shift_in   => '1',
          shift_out  => test_shift_out,

          par_in     => test_par_out,
          par_out    => test_par_out
        );



    process
            
    begin
    
        -- initial
        test_default_state <= x"01020304";
        test_rst <= '1';
        test_par_en <= '0';
        test_shift_en <= '0';
        
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        test_rst <= '0';
        test_par_en <= '1';

        for a in 0 to 31 loop
        
                wait for 5ns;
                test_clk <= '1';
                wait for 5ns;
                test_clk <= '0';
                
--            end loop;
        end loop;

        test_rst <= '1';
        test_par_en <= '0';
        test_shift_en <= '0';

        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        test_rst <= '0';
        test_shift_en <= '1';        
        
        for a in 0 to 4095 loop
    
                wait for 5ns;
                test_clk <= '1';
                wait for 5ns;
                test_clk <= '0';
                
--            end loop;
        end loop;
        
   end process;


end Behavioral;

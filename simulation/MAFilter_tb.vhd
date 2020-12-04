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

entity MAFilter_tb is
--  Port ( );
end MAFilter_tb;

architecture Behavioral of MAFilter_tb is


signal test_clk, test_rst, test_in : std_logic;
signal test_sum : std_logic_vector(3 downto 0);

begin

    test0: entity work.MAFilter1Bit
    generic map (
        SAMPLE_LENGTH => 10,
        SUM_WIDTH => 4
    )
    port map (
        clk => test_clk,
        en => '1',
        rst => test_rst,

        SIG_IN => test_in,
        SUM_OUT => test_sum
    );

    process
    begin

        -- initial
        test_rst <= '1';
        test_in <= '0';

        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;

        test_rst <= '0';

        for a in 0 to 19 loop

          test_in <= '1';

          -- clock edge
          wait for 5ns;
          test_clk <= '1';
          wait for 5ns;
          test_clk <= '0';

        end loop;

        for a in 0 to 19 loop

          test_in <= '1';

          -- clock edge
          wait for 5ns;
          test_clk <= '1';
          wait for 5ns;
          test_clk <= '0';

          test_in <= '0';

          for b in 0 to a loop
            -- clock edge
            wait for 5ns;
            test_clk <= '1';
            wait for 5ns;
            test_clk <= '0';
          end loop;

        end loop;

        for a in 0 to 19 loop

          test_in <= '1';

          -- clock edge
          wait for 5ns;
          test_clk <= '1';
          wait for 5ns;
          test_clk <= '0';

          test_in <= '0';

          for b in 0 to 19-a loop
            -- clock edge
            wait for 5ns;
            test_clk <= '1';
            wait for 5ns;
            test_clk <= '0';
          end loop;

        end loop;

    end process;



end Behavioral;

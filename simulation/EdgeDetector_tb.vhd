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

entity EdgeDetector_tb is
--  Port ( );
end EdgeDetector_tb;

architecture Behavioral of EdgeDetector_tb is


signal test_clk, test_rst, test_in, test_event, test_valid, test_data : std_logic;


begin

    test0: entity work.EdgeDetector
  generic map (
    SAMPLE_LENGTH             => 16,
    SUM_WIDTH                 => 4,
    LOGIC_HIGH                => 13,
    LOGIC_LOW                 => 2
  )
  port map (
    RST                       => test_rst,
    EN                        => '1',
    CLK                       => test_clk,

    SIG_IN                    => test_in,

    EDGE_EVENT                => test_event,
    VALID                     => test_valid,
    DATA                      => test_data
  );

    process
    begin

        -- initial
        test_rst <= '1';
        test_in <= '0';

        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;

        test_rst <= '0';

        for a in 0 to 31 loop

          test_in <= '1';

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;

        for a in 0 to 31 loop

          test_in <= '1';

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

          test_in <= '0';

          for b in 0 to a loop
            -- clock edge
            wait for 2ns;
            test_clk <= '1';
            wait for 2ns;
            test_clk <= '0';
          end loop;

        end loop;

        for a in 0 to 31 loop

          test_in <= '1';

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

          test_in <= '0';

          for b in 0 to 31-a loop
            -- clock edge
            wait for 2ns;
            test_clk <= '1';
            wait for 2ns;
            test_clk <= '0';
          end loop;

        end loop;

    end process;



end Behavioral;

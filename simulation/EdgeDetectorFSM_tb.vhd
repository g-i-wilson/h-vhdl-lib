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

entity EdgeDetectorFSM_tb is
--  Port ( );
end EdgeDetectorFSM_tb;

architecture Behavioral of EdgeDetectorFSM_tb is


signal test_clk, test_rst, test_event, test_valid, test_data : std_logic;
signal test_sum : std_logic_vector(3 downto 0);


begin

    test0: entity work.EdgeDetectorFSM
  generic map (
    SUM_WIDTH                 => 4,
    LOGIC_HIGH                => 13,
    LOGIC_LOW                 => 2
  )
  port map (
    RST                       => test_rst,
    EN                        => '1',
    CLK                       => test_clk,

    SUM_IN                    => test_sum,

    EDGE_EVENT                => test_event,
    VALID                     => test_valid,
    DATA                      => test_data
  );

    process
    begin

        -- initial
        test_rst <= '1';
        test_sum <= x"0";

        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;

        test_rst <= '0';

          test_sum <= x"F";

        for a in 0 to 15 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;

        for a in 0 to 15 loop

          test_sum <= std_logic_vector(to_unsigned(15-a,4));

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;

        for a in 0 to 15 loop

          test_sum <= std_logic_vector(to_unsigned(a,4));

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;

    end process;



end Behavioral;

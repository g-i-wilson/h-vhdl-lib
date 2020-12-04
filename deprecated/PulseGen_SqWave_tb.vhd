----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 09/24/2020 10:09:10 AM
-- Design Name:
-- Module Name: Timer_tb - Behavioral
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

entity PulseGen_SqWave_tb is
--  Port ( );
end PulseGen_SqWave_tb;

architecture Behavioral of PulseGen_SqWave_tb is

signal test_clk, test_rst, test_out_0, test_out_1, test_default_0, test_edge_0 : std_logic;
signal test_period_0, test_period_0_init, test_period_1, test_period_1_init : std_logic_vector(3 downto 0);

begin

    test_SquareWaveGenerator: entity work.SquareWaveGenerator
    generic map (
        WIDTH           => 4
    )
    port map (
        CLK             => test_clk,
        RST             => test_rst,
        EN              => '1',
        ON_PERIOD       => test_period_0,
        OFF_PERIOD      => test_period_0,
        INIT_ON_PERIOD  => test_period_0_init,
        INIT_OFF_PERIOD => test_period_0_init,
        DEFAULT_STATE   => test_default_0,

        EDGE_EVENT      => test_edge_0,
        SQUARE_WAVE     => test_out_0
    );

    test_PulseGenerator : entity work.PulseGenerator
        generic map (
            WIDTH               => 4
        )
        port map (
            -- inputs
            CLK                 => test_clk,
            RST                 => test_rst,
            EN                  => '1',
            PERIOD              => test_period_1,
            INIT_PERIOD         => test_period_1_init,
            -- outputs
            PULSE               => test_out_1
        );


    process

    begin

        -- test "typical" values

        -- initial
        test_period_0 <= x"3";
        test_period_0_init <= x"4";
        test_default_0 <= '0';

        test_period_1 <= x"3";
        test_period_1_init <= x"4";

        test_rst <= '1';

        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;

        test_rst <= '0';


        for a in 0 to 31 loop

        -- just clock for a while
            wait for 5ns;
            test_clk <= '1';
            wait for 5ns;
            test_clk <= '0';
        end loop;

        test_period_0 <= x"2";

        test_period_1 <= x"2";

        for a in 0 to 31 loop

        -- just clock for a while
            wait for 5ns;
            test_clk <= '1';
            wait for 5ns;
            test_clk <= '0';
        end loop;


        -- test init with 0 and 1

        test_default_0 <= '1';

        test_period_0_init <= x"0";
        test_period_1_init <= x"0";
        test_rst <= '1';

        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';

        test_rst <= '0';

        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';

        for a in 0 to 15 loop
        -- just clock for a while
            wait for 5ns;
            test_clk <= '1';
            wait for 5ns;
            test_clk <= '0';
        end loop;

        test_period_0_init <= x"1";
        test_period_1_init <= x"1";
        test_rst <= '1';

        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';

        test_rst <= '0';

        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';

        for a in 0 to 15 loop
        -- just clock for a while
            wait for 5ns;
            test_clk <= '1';
            wait for 5ns;
            test_clk <= '0';
        end loop;



        -- test range of period values

        for a in 0 to 15 loop
            test_period_0 <= std_logic_vector(to_unsigned(a, 4));
            test_period_1 <= std_logic_vector(to_unsigned(a, 4));

            for b in 0 to 15 loop
            -- just clock for a while
                wait for 5ns;
                test_clk <= '1';
                wait for 5ns;
                test_clk <= '0';
            end loop;
        end loop;

    end process;

end Behavioral;

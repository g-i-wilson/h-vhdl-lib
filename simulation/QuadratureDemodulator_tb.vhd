library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity QuadratureDemodulator_tb is
--  Port ( );
end QuadratureDemodulator_tb;

architecture Behavioral of QuadratureDemodulator_tb is

    signal test_clk, test_rst, test_sq_wave, test_PM_event, test_PM_out, test_sample_rate : std_logic;
    signal test_PM_sig : std_logic_vector(1 downto 0);
    signal test_fir_out : std_logic_vector(16 downto 0);
--    signal test_I_out, test_Q_out  : std_logic_vector(4 downto 0);
    signal test_PM_period : std_logic_vector(3 downto 0);
    signal test_PA_angle, test_PA_angle_filtered, test_PA_diff, test_PA_diff_filtered, test_PA_2DER : std_logic_vector(15 downto 0);

begin

    sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => 4
    )
    port map (
        CLK             => test_clk,
        EN              => '1',
        RST             => test_rst,
        PERIOD          => x"3",
        INIT_PERIOD     => x"3",
        PULSE           => test_sample_rate
    );


    PM_freq : entity work.SquareWaveGenerator
    generic map (
        WIDTH           => 12
    )
    port map (
        CLK             => test_clk,
        EN              => test_sample_rate,
        RST             => test_rst,
        ON_PERIOD       => x"0FF", -- period-1
        OFF_PERIOD      => x"0FF", -- period-1
        INIT_ON_PERIOD  => x"0FF", -- period-1
        INIT_OFF_PERIOD => x"0FF", -- period-1
        EDGE_EVENT      => test_PM_event,
        SQUARE_WAVE     => test_PM_out
    );

    process(test_PM_out)
    begin
        case test_PM_out is
            when '1' => test_PM_period <= x"3";
            when others => test_PM_period <= x"4";
        end case;
    end process;

    PM_carrier_freq : entity work.SquareWaveGenerator
    generic map (
        WIDTH           => 4
    )
    port map (
        CLK             => test_clk,
        EN              => test_sample_rate,
        RST             => test_rst,
        ON_PERIOD       => test_PM_period,
        OFF_PERIOD      => test_PM_period,
        INIT_ON_PERIOD  => test_PM_period,
        INIT_OFF_PERIOD => test_PM_period,
        SQUARE_WAVE     => test_sq_wave
    );

--    test_PM_sig <= (not test_sq_wave) & test_sq_wave & test_sq_wave & test_sq_wave & test_sq_wave & test_sq_wave & test_sq_wave & test_sq_wave;
    test_PM_sig <= (not test_sq_wave) & test_sq_wave;


    PM_signal_filter: entity work.FIRFilterLP15tap
    generic map (
        SIG_IN_WIDTH        => 2,
        SIG_OUT_WIDTH       => 17
    )
    port map (
        CLK                 => test_clk,
        RST                 => test_rst,
        EN_IN               => '1',
        EN_OUT              => test_sample_rate,
        SIG_IN              => test_PM_sig,

        SIG_OUT             => test_fir_out
    );



    test_quad_demod: entity work.QuadratureDemodulator
        generic map (
            SIG_IN_WIDTH            => 17,
            SIG_OUT_WIDTH           => 16,
            IQ_AMP                  => 1
        )
        port map (
            CLK                     => test_clk,
            RST                     => test_rst,
            EN_IN                   => test_sample_rate, -- sample rate must be 8x frequency of interest
            EN_OUT                  => '1',
            SIG_IN                  => test_fir_out,

            PHASE                   => test_PA_angle,
            PHASE_FILTERED          => test_PA_angle_filtered,
            PHASE_DER               => test_PA_diff,
            PHASE_DER_FILTERED      => test_PA_diff_filtered,
            PHASE_2DER              => test_PA_2DER
        );



        


    process
    begin

        -- initial
        test_rst <= '1';

        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';

        test_rst <= '0';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;

        for a in 0 to 4095 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;

    end process;


end Behavioral;

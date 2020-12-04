----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 10/14/2020 09:49:14 AM
-- Design Name:
-- Module Name: FIRFilter_tb - Behavioral
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

entity LOMixerBaseband_tb is
--  Port ( );
end LOMixerBaseband_tb;

architecture Behavioral of LOMixerBaseband_tb is

    signal test_clk, test_rst, test_sq_wave, test_PM_event, test_PM_out, test_sample_rate, test_angle_reduced_rate : std_logic;
    signal test_PM_sig : std_logic_vector(7 downto 0);
    signal test_I_out, test_Q_out  : std_logic_vector(4 downto 0);
    signal test_angle, test_angle_b, test_angle_slope  : std_logic_vector(7 downto 0);
    signal test_fir_out, test_angle_filtered_ma1, test_angle_filtered_fir1, test_angle_filtered_fir2, test_angle_slope_filtered_ma1, test_angle_slope_filtered_fir1, test_angle_slope_filtered_fir2 : std_logic_vector(16 downto 0);
    signal test_PM_period : std_logic_vector(3 downto 0);

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

    test_PM_sig <= (not test_sq_wave) & test_sq_wave & test_sq_wave & test_sq_wave & test_sq_wave & test_sq_wave & test_sq_wave & test_sq_wave;

--    PM_filter: entity work.FIRFilterLP4f63tap
--        generic map (
--            SIG_IN_WIDTH        => 8,
--            SIG_OUT_WIDTH       => 17
--        )
--        port map (
--            CLK                 => test_clk,
--            RST                 => test_rst,
--            EN_IN               => test_sample_rate,
--            EN_OUT              => test_sample_rate,
--            SIG_IN              => test_PM_sig,

--            SIG_OUT             => test_fir_out
--        );

    PM_filter: entity work.FIRFilter
    generic map (
        LENGTH      => 15, -- number of taps
        WIDTH       => 8, -- width of coef and signal path (x2 after multiplication)
        PADDING     => 1,  -- extra bits may be required if sum of taps causes overflow
        SIGNED_MATH => TRUE
    )
    port map (
        CLK         => test_clk,
        EN          => '1',
        RST         => test_rst,
        COEF_IN     =>  x"02" &
                        x"09" &
                        x"13" &
                        x"20" &
                        x"2C" &
                        x"36" &
                        x"3D" &
                        x"40" &
                        x"3D" &
                        x"36" &
                        x"2C" &
                        x"20" &
                        x"13" &
                        x"09" &
                        x"02" ,

        SHIFT_IN    => test_PM_sig,

        SHIFT_OUT   => open,
        PAR_OUT     => open,
        MULT_OUT    => open,
        SUM_OUT     => test_fir_out
    );

    I: entity work.LOMixerBaseband
        generic map (
            SIG_IN_WIDTH        => 17, -- signal input path width
--            SIG_IN_WIDTH        => 8, -- signal input path width
            SIG_OUT_WIDTH       => 5, -- signal output path width
            PHASE_90_DEG_LAG    => false
        )
        port map (
            CLK                 => test_clk,
            RST                 => test_rst,
            EN_IN               => test_sample_rate,
            EN_OUT              => '1',
            SIG_IN              => test_fir_out,
--            SIG_IN              => test_PM_sig,

            SIG_OUT             => test_I_out
        );

    Q: entity work.LOMixerBaseband
        generic map (
            SIG_IN_WIDTH        => 17, -- signal input path width
--            SIG_IN_WIDTH        => 8, -- signal input path width
            SIG_OUT_WIDTH       => 5, -- signal output path width
            PHASE_90_DEG_LAG    => true
        )
        port map (
            CLK                 => test_clk,
            RST                 => test_rst,
            EN_IN               => test_sample_rate,
            EN_OUT              => '1',
            SIG_IN              => test_fir_out,
--            SIG_IN              => test_PM_sig,

            SIG_OUT             => test_Q_out
        );


    phase_angle: entity work.Angle4Bit
        port map (
            CLK         => test_clk,
            EN          => '1',
            RST         => test_rst,
    
            X_IN        => test_I_out(3 downto 0),
            Y_IN        => test_Q_out(3 downto 0),
    
            A_OUT       => test_angle,
            DIFF_OUT    => test_angle_slope
        );
    phase_angle_multifilter: entity work.MultiFilterFIR15MA31
        generic map (
            SIG_IN_WIDTH            => 8,
            SIG_OUT_WIDTH           => 17,
            REDUCED_RATE_WIDTH      => 4
        )
        port map (
            CLK                     => test_clk,
            EN                      => '1',
            RST                     => test_rst,
            SIG_IN                  => test_angle,
            REDUCED_RATE_PERIOD     => x"3", -- period-1
    
            MA_OUT                  => test_angle_filtered_ma1,
            FIR0_OUT                => test_angle_filtered_fir1,
            FIR1_OUT                => test_angle_filtered_fir2,
            EN_REDUCED              => test_angle_reduced_rate
        );
    phase_angle_slope_multifilter: entity work.MultiFilterFIR63MA127
        generic map (
            SIG_IN_WIDTH            => 8,
            SIG_OUT_WIDTH           => 17,
            REDUCED_RATE_WIDTH      => 4
        )
        port map (
            CLK                     => test_clk,
            EN                      => '1',
            RST                     => test_rst,
            SIG_IN                  => test_angle_slope,
            REDUCED_RATE_PERIOD     => x"3", -- period-1
    
            MA_OUT                  => test_angle_slope_filtered_ma1,
            FIR0_OUT                => test_angle_slope_filtered_fir1,
            FIR1_OUT                => test_angle_slope_filtered_fir2,
            EN_REDUCED              => open
        );
--      phase_angle_filter_ma1 : entity work.MAFilter
--      generic map (
--        SAMPLE_LENGTH             => 32,
--        SAMPLE_WIDTH              => 8,
--        SUM_WIDTH                 => 17,
--        SUM_START                 => 0,
--        SIGNED_ARITHMETIC         => TRUE
--      )
--      port map (
--        RST                       => test_rst,
--        CLK                       => test_clk,
--        EN                        => '1',
--        SIG_IN                    => test_angle,
    
--        SUM_OUT                   => test_angle_filtered_ma1
--      );
--        phase_angle_filter_fir1: entity work.FIRFilterLP15tap
--        generic map (
--            SIG_IN_WIDTH        => 8,
--            SIG_OUT_WIDTH       => 17
--        )
--        port map (
--            CLK                 => test_clk,
--            RST                 => test_rst,
--            EN_IN               => '1',
--            EN_OUT              => '1',
--            SIG_IN              => test_angle,

--            SIG_OUT             => test_angle_filtered_fir1
--        );

    
    

--      phase_angle_slope_filter_ma1 : entity work.MAFilter
--      generic map (
--        SAMPLE_LENGTH             => 128,
--        SAMPLE_WIDTH              => 8,
--        SUM_WIDTH                 => 17,
--        SUM_START                 => 0,
--        SIGNED_ARITHMETIC         => TRUE
--      )
--      port map (
--        RST                       => test_rst,
--        CLK                       => test_clk,
--        EN                        => '1',
--        SIG_IN                    => test_angle_slope,
    
--        SUM_OUT                   => test_angle_slope_filtered_ma1
--      );


--    phase_angle_slope_filter_fir1: entity work.FIRFilterLP63tap
--        generic map (
--            SIG_IN_WIDTH        => 8,
--            SIG_OUT_WIDTH       => 17
--        )
--        port map (
--            CLK                 => test_clk,
--            RST                 => test_rst,
--            EN_IN               => '1',
--            EN_OUT              => test_sample_rate,
--            SIG_IN              => test_angle_slope,

--            SIG_OUT             => test_angle_slope_filtered_fir1
--        );
    
--    phase_angle_slope_filter_fir2: entity work.FIRFilterLP63tap
--        generic map (
--            SIG_IN_WIDTH        => 17,
--            SIG_OUT_WIDTH       => 17
--        )
--        port map (
--            CLK                 => test_clk,
--            RST                 => test_rst,
--            EN_IN               => test_sample_rate,
--            EN_OUT              => test_sample_rate,
--            SIG_IN              => test_angle_slope_filtered_fir1,

--            SIG_OUT             => test_angle_slope_filtered_fir2
--        );



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

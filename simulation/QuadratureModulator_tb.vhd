library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity QuadratureModulator_tb is
--  Port ( );
end QuadratureModulator_tb;

architecture Behavioral of QuadratureModulator_tb is
    constant IQ_AMP  : integer := 2;


    signal test_clk, test_rst, test_sample_rate, test_phase_change_rate : std_logic;
    signal test_mod_out             : std_logic_vector(15 downto 0);
    signal test_mod_filtered_out    : std_logic_vector(15 downto 0);
    signal test_PA_angle            : std_logic_vector(15 downto 0);
    signal test_PA_diff             : std_logic_vector(15 downto 0);
    signal sin_sig                  : std_logic_vector(15 downto 0);
    signal cos_sig                  : std_logic_vector(15 downto 0);
    signal test_i_out_sig           : std_logic_vector(27 downto 0);
    signal test_q_out_sig           : std_logic_vector(27 downto 0);
    signal test_i_out_reduced_sig   : std_logic_vector(27-IQ_AMP downto 0);
    signal test_q_out_reduced_sig   : std_logic_vector(27-IQ_AMP downto 0);
    signal test_freq_re             : std_logic_vector(17 downto 0);
    signal test_freq_im             : std_logic_vector(21 downto 0);
    signal test_phase               : std_logic_vector(15 downto 0);
    signal test_phase_der           : std_logic_vector(15 downto 0);
    
begin

    sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => 8
    )
    port map (
        CLK             => test_clk,
        EN              => '1',
        RST             => test_rst,
        PERIOD          => x"07",
        INIT_PERIOD     => x"07",
        PULSE           => test_sample_rate
    );

    phase_change_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => 8
    )
    port map (
        CLK             => test_clk,
        EN              => '1',
        RST             => test_rst,
        PERIOD          => x"40",
        INIT_PERIOD     => x"40",
        PULSE           => test_phase_change_rate
    );

    sin_gen: entity work.SinusoidGenerator64
        generic map (
            WIDTH           => 16
        )
        port map (
            CLK             => test_clk,
            EN              => test_phase_change_rate,
            RST             => test_rst,
    
            COS_OUT         => cos_sig,
            SIN_OUT         => sin_sig
        );


    test_quad_mod: entity work.QuadratureModulator
        generic map (
            SIG_IN_WIDTH            => 16,
            SIG_OUT_WIDTH           => 16
        )
        port map (
            CLK                     => test_clk,
            RST                     => test_rst,
            EN_IN                   => test_sample_rate, -- sample rate must be 8x frequency of interest
            EN_OUT                  => '1', -- output sample rate could be higher (for example, to maintain precision when bit-width is reduced to small value)
            EN_PHASE                => '1', -- enable the PHASE input (overrides PHASE_CHANGE)
            PHASE                   => cos_sig,
            EN_PHASE_CHANGE         => '0', -- enable the PHASE_CHANGE input
            PHASE_CHANGE            => x"0000",

            SIG_OUT                 => test_mod_out
        );
        
        
    filter_mod_signal: entity work.FIRFilterLP4f63tap
        generic map (
            SIG_IN_WIDTH        => 16, -- signal input path width
            SIG_OUT_WIDTH       => 16 -- signal output path width
        )
        port map (
            CLK                 => test_clk,
            RST                 => test_rst,
            EN_IN               => '1',
            EN_OUT              => '1',
            SIG_IN              => test_mod_out,

            SIG_OUT             => test_mod_filtered_out
        );        

    test_quad_demod: entity work.QuadratureDemodulator
        generic map (
            SIG_IN_WIDTH            => 16,
            SIG_OUT_WIDTH           => 28
        )
        port map (
            CLK                     => test_clk,
            RST                     => test_rst,
            EN_IN                   => test_sample_rate, -- sample rate must be 8x carrier frequency
            EN_OUT                  => test_sample_rate,
            SIG_IN                  => test_mod_filtered_out,

            I_OUT                   => test_i_out_sig,
            Q_OUT                   => test_q_out_sig
        );

    test_i_out_reduced_sig <= test_i_out_sig(27-IQ_AMP downto 0);
    test_q_out_reduced_sig <= test_q_out_sig(27-IQ_AMP downto 0);


    inst_phase: entity work.InstantaneousPhase
    generic map (
        SIG_IN_WIDTH            => 28-IQ_AMP,
        SIG_OUT_WIDTH           => 16
    )
    port map (
        CLK                     => test_clk,
        RST                     => test_rst,
        EN_ANGLE                => '1',
        EN_OUT                  => test_sample_rate,
        RE_IN                   => test_i_out_reduced_sig,
        IM_IN                   => test_q_out_reduced_sig,

        PHASE                   => test_phase,
        PHASE_DER               => test_phase_der
    );
    
--    inst_phase_2der : entity work.Derivative
--    generic map (
--        WIDTH       => SIG_OUT_WIDTH
--    )
--    port map (
--        CLK         => CLK,
--        RST         => RST,
--        EN          => EN_OUT,
--        SIG_IN      => phase_der_sig,
--        DIFF_OUT    => PHASE_2DER
--    );

    
    inst_frequency: entity work.InstantaneousFrequency
    generic map (
        SIG_IN_WIDTH            => 28-IQ_AMP,
        RE_WIDTH                => 18,
        IM_WIDTH                => 22
    )
    port map (
        CLK                     => test_clk,
        RST                     => test_rst,
        EN_IN                   => test_sample_rate,
        EN_OUT                  => '1',
        RE_IN                   => test_i_out_reduced_sig,
        IM_IN                   => test_q_out_reduced_sig,

        FREQ_RE                 => test_freq_re,
        FREQ_IM                 => test_freq_im
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

        for a in 1 to 20000 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;

    end process;


end Behavioral;

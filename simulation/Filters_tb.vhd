library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Filters_tb is
--  Port ( );
end Filters_tb;

architecture Behavioral of Filters_tb is

    signal test_clk : std_logic;
    signal test_rst : std_logic;
    signal test_sample_rate : std_logic;
    signal test_sq_wave_1bit : std_logic;
    signal test_sq_wave : std_logic_vector(1 downto 0);
    signal test_period : std_logic_vector(7 downto 0);

    signal test_lp15 : std_logic_vector(15 downto 0);

    signal test_lp8f63 : std_logic_vector(15 downto 0);
    signal test_lp4f63 : std_logic_vector(15 downto 0);
    signal test_lp2f63 : std_logic_vector(15 downto 0);

    signal test_bp8f63 : std_logic_vector(15 downto 0);

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


    freq : entity work.SquareWaveGenerator
    generic map (
        WIDTH           => 8
    )
    port map (
        CLK             => test_clk,
        EN              => test_sample_rate,
        RST             => test_rst,
        ON_PERIOD       => test_period,
        OFF_PERIOD      => test_period,
        INIT_ON_PERIOD  => test_period,
        INIT_OFF_PERIOD => test_period,
        SQUARE_WAVE     => test_sq_wave_1bit
    );
    test_sq_wave <= (not test_sq_wave_1bit) & test_sq_wave_1bit;




    lp15: entity work.FIRFilterLP15tap
    generic map (
        SIG_IN_WIDTH        => 2,
        SIG_OUT_WIDTH       => 16
    )
    port map (
        CLK                 => test_clk,
        RST                 => test_rst,
        EN_IN               => test_sample_rate,
        EN_OUT              => '1',
        SIG_IN              => test_sq_wave,

        SIG_OUT             => test_lp15
    );
    lp8f63: entity work.FIRFilterLP8f63tap
    generic map (
        SIG_IN_WIDTH        => 2,
        SIG_OUT_WIDTH       => 16
    )
    port map (
        CLK                 => test_clk,
        RST                 => test_rst,
        EN_IN               => test_sample_rate,
        EN_OUT              => '1',
        SIG_IN              => test_sq_wave,

        SIG_OUT             => test_lp8f63
    );
    lp4f63: entity work.FIRFilterLP4f63tap
    generic map (
        SIG_IN_WIDTH        => 2,
        SIG_OUT_WIDTH       => 16
    )
    port map (
        CLK                 => test_clk,
        RST                 => test_rst,
        EN_IN               => test_sample_rate,
        EN_OUT              => '1',
        SIG_IN              => test_sq_wave,

        SIG_OUT             => test_lp4f63
    );
    lp2f63: entity work.FIRFilterLP2f63tap
    generic map (
        SIG_IN_WIDTH        => 2,
        SIG_OUT_WIDTH       => 16
    )
    port map (
        CLK                 => test_clk,
        RST                 => test_rst,
        EN_IN               => test_sample_rate,
        EN_OUT              => '1',
        SIG_IN              => test_sq_wave,

        SIG_OUT             => test_lp2f63
    );
    bp8f63: entity work.FIRFilterBP8f63tap
    generic map (
        SIG_IN_WIDTH        => 2,
        SIG_OUT_WIDTH       => 16
    )
    port map (
        CLK                 => test_clk,
        RST                 => test_rst,
        EN_IN               => test_sample_rate,
        EN_OUT              => '1',
        SIG_IN              => test_sq_wave,

        SIG_OUT             => test_bp8f63
    );


    process
    begin

        -- initial
        test_rst <= '1';
        test_period <= x"01";

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

        for a in 1 to 20 loop

            test_period <= std_logic_vector(to_unsigned(a,8));

            for b in 0 to 1023 loop

              -- clock edge
              wait for 2ns;
              test_clk <= '1';
              wait for 2ns;
              test_clk <= '0';

            end loop;
        end loop;

    end process;


end Behavioral;

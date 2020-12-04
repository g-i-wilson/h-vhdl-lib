
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity BeatFreq is
    generic (
        IN_WIDTH   : positive := 8,
        LO_LENGTH  : positive := 16,
        FILTER_LENGTH : positive := 31
    );
    port (
        CLK     : in STD_LOGIC;

        SIG_IN  : in STD_LOGIC_VECTOR(IN_WIDTH-1 downto 0);
        SIG_OUT   : out STD_LOGIC_VECTOR((WIDTH_IN*2)-1 downto 0);

        LO_COEF   : in STD_LOGIC_VECTOR((IN_WIDTH*2)*LENGTH-1 downto 0) :=
          x"00" &
          x"30" &
          x"59" &
          x"75" &
          x"7F" &
          x"75" &
          x"59" &
          x"30" &
          x"00" &
          x"CF" &
          x"A6" &
          x"8A" &
          x"81" &
          x"8A" &
          x"A6" &
          x"CF";
        FILTER_COEF :

    );
end BeatFreq;

architecture Behavioral of BeatFreq is

    signal mmcm_clk : STD_LOGIC_VECTOR(WIDTH-1 downto 0);;
    signal mmcm_rst : std_logic;

    signal dac_out : std_logic;

    signal adc_out : std_logic;
    signal adc_sample_en : std_logic;
    signal wave_in_sig : std_logic_vector(7 downto 0);
    signal filter_out_sig : std_logic_vector(7 downto 0);

begin

   clk_div : entity work.clk_div_generic
        generic map (
            period_width    => 12
        )
        port map (
            PERIOD          => x"3E8",   -- 100MHz/0.1MHz to hex
            CLK             => mmcm_clk,
            EN              => '1',
            RST             => mmcm_rst,
            EN_OUT          => adc_sample_en
        );


        local_osc: entity work.fun_gen_sr
        generic map (
          sample_period_width => 20,
          pdm_period_width => 12,
          pattern_width => 16,
          pattern_length => 64
        )
        port map (
          clk => clk,
          rst => rst,
          repeat_pattern =>
          sample_period => x"445C0",
          pdm_period => x"AF0",
          pdm_out => slow_sig
        );


        sample_rate : entity work.clk_div_generic
            generic map (
                period_width => sample_period_width
            )
            port map (
                period => sample_period,
                clk => clk,
                en => en,
                rst => rst,
                en_out => sample_en
            );

        sample_en_out <= sample_en;

        shift_reg : entity work.reg2D
            generic map (
              length => pattern_length,
              width => pattern_width
            )
            port map (
              clk      => clk,
              rst      => rst,

              par_en   => sample_en,

              default_state => repeat_pattern,

              par_in     => loopback_sig,
              par_out    => loopback_sig
            );

        pattern_out <= loopback_sig;



    wave_in_sig(7) <= '0';
    wave_in_sig(6 downto 0) <= (others => adc_out);

    filter : entity work.shift_mult_generic
        generic map (
            length => 15,
            width => 8,
            padding => 4
        )
        port map (
            shift_in => wave_in_sig,
            sum_out => led(7 downto 0),
            clk => mmcm_clk,
            en => adc_sample_en,
            rst => mmcm_rst,
            coef_in => x"020913202C363D403D362C20130902"
        );




end Behavioral;

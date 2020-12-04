
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity QuadDemod is
    generic (
        WIDTH_IN   : positive := 4,
        LENGTH  : positive := 15
    );
    port (
        CLK     : in STD_LOGIC;

        SIG_IN  : in STD_LOGIC_VECTOR(WIDTH_IN-1 downto 0);
        COEF_IN   : out STD_LOGIC_VECTOR((WIDTH_IN*2)*LENGTH-1 downto 0) := x"020913202C363D403D362C20130902";

        I_OUT   : out STD_LOGIC_VECTOR((WIDTH_IN*2)-1 downto 0);
        Q_OUT   : out STD_LOGIC_VECTOR(WIDTH_IN*2)-1 downto 0)
    );
end QuadDemod;

architecture Behavioral of QuadDemod is

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


    adc: entity work.ADC1Bit
      port map (
        CLK                     => mmcm_clk,
        EN                      => adc_sample_en,
        RST                     => mmcm_rst,
        CMP_IN                  => XA1_P,
        INV_OUT                 => XA1_N,
        PDM_OUT                 => adc_out
    );

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

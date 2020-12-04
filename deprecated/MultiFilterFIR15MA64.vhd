
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity MultiFilterFIR15MA64 is
    generic (
        SIG_IN_WIDTH            : positive := 8; -- signal input path width
        SIG_OUT_WIDTH           : positive := 16; -- signal output path width
        REDUCED_RATE_WIDTH      : positive := 4 -- width of reduced sample rate period
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN                      : in STD_LOGIC; -- sample rate
        SIG_IN                  : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);
        REDUCED_RATE_PERIOD     : in STD_LOGIC_VECTOR (REDUCED_RATE_WIDTH-1 downto 0); -- period-1

        MA_OUT                  : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        FIR0_OUT                : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        FIR1_OUT                : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        EN_REDUCED              : out STD_LOGIC -- reduced sample rate
    );
end MultiFilterFIR15MA64;

architecture Behavioral of MultiFilterFIR15MA64 is

    signal ma_in_sig        : std_logic_vector(7 downto 0);
    signal ma_out_sig       : std_logic_vector(15 downto 0);

    signal fir0_out_sig     : std_logic_vector(SIG_OUT_WIDTH-1 downto 0);
    signal en_reduced_sig   : std_logic;

begin


    ------------------------------------------
    -- Reduced sample rate
    ------------------------------------------
    reduced_sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => REDUCED_RATE_WIDTH
    )
    port map (
        CLK             => CLK,
        EN              => EN,
        RST             => RST,
        PERIOD          => REDUCED_RATE_PERIOD, -- period-1
        INIT_PERIOD     => REDUCED_RATE_PERIOD, -- period-1
        PULSE           => en_reduced_sig
    );

    ------------------------------------------
    -- FIR option: 2-stages of FIR filters (output at reduced sample rate)
    ------------------------------------------
    FIR_filter_stage_0: entity work.FIRFilterLP15tap
    generic map (
        SIG_IN_WIDTH        => SIG_IN_WIDTH,
        SIG_OUT_WIDTH       => SIG_OUT_WIDTH
    )
    port map (
        CLK                 => CLK,
        RST                 => RST,
        EN_IN               => EN,
        EN_OUT              => en_reduced_sig,
        SIG_IN              => SIG_IN,

        SIG_OUT             => fir0_out_sig
    );
    FIR0_OUT <= fir0_out_sig;

    FIR_filter_stage_1: entity work.FIRFilterLP15tap
    generic map (
        SIG_IN_WIDTH        => SIG_OUT_WIDTH,
        SIG_OUT_WIDTH       => SIG_OUT_WIDTH
    )
    port map (
        CLK                 => CLK,
        RST                 => RST,
        EN_IN               => en_reduced_sig,
        EN_OUT              => en_reduced_sig,
        SIG_IN              => fir0_out_sig,

        SIG_OUT             => FIR1_OUT
    );

    ------------------------------------------
    -- MA option: MA filter (output at full sample rate)
    ------------------------------------------
    MA_in_coupler: entity work.BitWidthCoupler
    generic map (
        SIG_IN_WIDTH            => SIG_IN_WIDTH,
        SIG_OUT_WIDTH           => 8
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN,
        SIG_IN                  => SIG_IN,

        SIG_OUT                 => ma_in_sig
    );
    MA_filter : entity work.MAFilter
    generic map (
        SAMPLE_LENGTH             => 64,
        SAMPLE_WIDTH              => 8,
        SUM_WIDTH                 => 16,
        SUM_START                 => 0,
        SIGNED_ARITHMETIC         => TRUE
    )
    port map (
        RST                       => RST,
        CLK                       => CLK,
        EN                        => EN,
        SIG_IN                    => ma_in_sig,

        SUM_OUT                   => ma_out_sig
    );
    MA_out_coupler: entity work.BitWidthCoupler
    generic map (
        SIG_IN_WIDTH            => 16,
        SIG_OUT_WIDTH           => SIG_OUT_WIDTH
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN,
        SIG_IN                  => ma_out_sig,

        SIG_OUT                 => MA_OUT
    );

end Behavioral;

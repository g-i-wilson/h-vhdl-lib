
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity LOMixerPassband is
    generic (
        SIG_IN_WIDTH            : positive := 1; -- signal input path width
        SIG_OUT_WIDTH           : positive := 4; -- signal output path width
        PHASE_90_DEG_LAG        : boolean := false
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN_IN                   : in STD_LOGIC; -- sample rate must be 8x frequency of interest
        EN_OUT                  : in STD_LOGIC; -- output sample could be higher (for example, to maintain precision when bit-width is reduced to small value)
        SIG_IN                  : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0) := (others=>'0');

        SIG_OUT                 : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0) := (others=>'0')
    );
end LOMixerPassband;

architecture Behavioral of LOMixerPassband is

    signal mixer_out_sig        : std_logic_vector(SIG_IN_WIDTH-1 downto 0);

begin

    ----------------------------------------
    -- LO Mixer
    ----------------------------------------
    gen_I: if not PHASE_90_DEG_LAG generate
        LO: entity work.LOMixer
        generic map (
            SIG_WIDTH               => SIG_IN_WIDTH,
            LO_HALF_PERIOD_WIDTH    => 4
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN                      => EN_IN,
            LO_HALF_PERIOD          => x"4", -- period/2
            SIG_IN                  => SIG_IN,

            SIG_OUT                 => mixer_out_sig
        );
    end generate gen_I;

    gen_Q: if PHASE_90_DEG_LAG generate
        LO: entity work.LOMixer
        generic map (
            SIG_WIDTH               => SIG_IN_WIDTH,
            LO_HALF_PERIOD_WIDTH    => 4
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN                      => EN_IN,
            PHASE                   => x"2", -- offset added to period at init (period/4)
            LO_HALF_PERIOD          => x"4", -- period/2
            SIG_IN                  => SIG_IN,

            SIG_OUT                 => mixer_out_sig
        );
    end generate gen_Q;

    ----------------------------------------
    -- Filter
    ----------------------------------------
    filter: entity work.FIRFilterLP4f15tap
        generic map (
            SIG_IN_WIDTH        => SIG_IN_WIDTH, -- signal input path width
            SIG_OUT_WIDTH       => SIG_OUT_WIDTH -- signal output path width
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN_IN               => EN_IN,
            EN_OUT              => EN_OUT,
            SIG_IN              => mixer_out_sig,

            SIG_OUT             => SIG_OUT
        );

end Behavioral;

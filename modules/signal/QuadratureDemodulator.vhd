
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity QuadratureDemodulator is
    generic (
        SIG_IN_WIDTH            : positive := 1; -- signal input path width
        SIG_OUT_WIDTH           : positive := 4 -- signal output path width
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN_IN                   : in STD_LOGIC; -- sample rate must be 8x carrier frequency
        EN_OUT                  : in STD_LOGIC; -- output sample rate could be higher (for example, to maintain precision when bit-width is reduced to small value)
        SIG_IN                  : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);

        I_OUT                   : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        Q_OUT                   : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0)
    );
end QuadratureDemodulator;

architecture Behavioral of QuadratureDemodulator is

    signal i_out_sig        : std_logic_vector (SIG_OUT_WIDTH-1 downto 0);
    signal q_out_sig        : std_logic_vector (SIG_OUT_WIDTH-1 downto 0);

    signal phase_der_sig    : std_logic_vector (SIG_OUT_WIDTH-1 downto 0);

begin

    I: entity work.LOMixerBaseband
        generic map (
            SIG_IN_WIDTH        => SIG_IN_WIDTH, -- signal input path width
            SIG_OUT_WIDTH       => SIG_OUT_WIDTH,
            PHASE_90_DEG_LAG    => false
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN_IN               => EN_IN, -- sample rate must be 8x carrier frequency
            EN_OUT              => EN_OUT,
            SIG_IN              => SIG_IN,

            SIG_OUT             => I_OUT
        );

    Q: entity work.LOMixerBaseband
        generic map (
            SIG_IN_WIDTH        => SIG_IN_WIDTH, -- signal input path width
            SIG_OUT_WIDTH       => SIG_OUT_WIDTH,
            PHASE_90_DEG_LAG    => true
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN_IN               => EN_IN, -- sample rate must be 8x carrier frequency
            EN_OUT              => EN_OUT,
            SIG_IN              => SIG_IN,

            SIG_OUT             => Q_OUT
        );

end Behavioral;

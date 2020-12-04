
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity QuadratureModulator is
    generic (
        SIG_IN_WIDTH            : positive := 8; -- signal input path width
        SIG_OUT_WIDTH           : positive := 8 -- signal output path width
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN_IN                   : in STD_LOGIC; -- sample rate must be 8x frequency of interest
        EN_OUT                  : in STD_LOGIC; -- output sample rate could be higher (for example, to maintain precision when bit-width is reduced to small value)
        EN_PHASE                : in STD_LOGIC; -- enable the PHASE input (overrides PHASE_CHANGE)
        PHASE                   : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);
        EN_PHASE_CHANGE         : in STD_LOGIC; -- enable the PHASE_CHANGE input
        PHASE_CHANGE            : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);

        SIG_OUT                 : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0)
    );
end QuadratureModulator;

architecture Behavioral of QuadratureModulator is

    signal a_in_sig         : std_logic_vector (7 downto 0);
    signal a_out_sig        : std_logic_vector (7 downto 0);

    signal phase_sig        : std_logic_vector (7 downto 0);
    signal phase_change_sig : std_logic_vector (7 downto 0);

    signal x_out_sig        : std_logic_vector (11 downto 0);
    signal y_out_sig        : std_logic_vector (11 downto 0);

    signal i_out_sig        : std_logic_vector (15 downto 0);
    signal q_out_sig        : std_logic_vector (15 downto 0);

    signal sum_sig          : std_logic_vector (15 downto 0);

begin

    phase_in_coupler: entity work.BitWidthCoupler
        generic map (
            SIG_IN_WIDTH            => SIG_IN_WIDTH,
            SIG_OUT_WIDTH           => 8
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN                      => EN_IN,
            SIG_IN                  => PHASE,

            SIG_OUT                 => phase_sig
        );

    phase_change_in_coupler: entity work.BitWidthCoupler
        generic map (
            SIG_IN_WIDTH            => SIG_IN_WIDTH,
            SIG_OUT_WIDTH           => 8
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN                      => EN_IN,
            SIG_IN                  => PHASE_CHANGE,

            SIG_OUT                 => phase_change_sig
        );

    process(EN_PHASE, phase_sig, EN_PHASE_CHANGE, phase_change_sig)
    begin
        if (EN_PHASE = '1') then
            a_in_sig <= phase_sig;
        elsif (EN_PHASE_CHANGE = '1') then
            a_in_sig <= std_logic_vector(signed(a_out_sig) + signed(phase_change_sig));
        else
            a_in_sig <= a_out_sig;
        end if;
    end process;

    angle_reg : entity work.Reg1D
        generic map (
            LENGTH              => 8
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            PAR_EN              => EN_IN,
            PAR_IN              => a_in_sig,
            PAR_OUT             => a_out_sig
        );

    phase_angle: entity work.UnitVector8Bit
        port map (
            CLK                 => CLK,
            EN                  => EN_IN,
            RST                 => RST,

            A_IN                => a_out_sig,

            X_OUT               => x_out_sig,
            Y_OUT               => y_out_sig
        );

    I: entity work.LOMixerPassband
        generic map (
            SIG_IN_WIDTH        => 12, -- signal input path width
            SIG_OUT_WIDTH       => 16,
            PHASE_90_DEG_LAG    => false
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN_IN               => EN_IN, -- sample rate must be 8x frequency of interest
            EN_OUT              => EN_IN,
            SIG_IN              => x_out_sig,

            SIG_OUT             => i_out_sig
        );

    Q: entity work.LOMixerPassband
        generic map (
            SIG_IN_WIDTH        => 12, -- signal input path width
            SIG_OUT_WIDTH       => 16,
            PHASE_90_DEG_LAG    => true
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN_IN               => EN_IN, -- sample rate must be 8x frequency of interest
            EN_OUT              => EN_IN,
            SIG_IN              => y_out_sig,

            SIG_OUT             => q_out_sig
        );

    sum_sig <= std_logic_vector(signed(i_out_sig) + signed(q_out_sig));

    sig_out_coupler: entity work.BitWidthCoupler
        generic map (
            SIG_IN_WIDTH            => 16,
            SIG_OUT_WIDTH           => SIG_OUT_WIDTH
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN                      => EN_OUT,
            SIG_IN                  => sum_sig,

            SIG_OUT                 => SIG_OUT
        );


end Behavioral;

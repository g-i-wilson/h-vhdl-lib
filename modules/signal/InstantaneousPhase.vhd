
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity InstantaneousPhase is
    generic (
        SIG_IN_WIDTH            : positive := 4; -- signal input path width
        SIG_OUT_WIDTH           : positive := 16; -- signal output path width
        ANGLE_MA_LENGTH         : positive := 16;
        ANGLE_MA_SUM_WIDTH      : positive := 12;
        ANGLE_DIFF_MA_LENGTH    : positive := 2048;
        ANGLE_DIFF_MA_SUM_WIDTH : positive := 12
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN_ANGLE                : in STD_LOGIC;
        EN_OUT                  : in STD_LOGIC;

        RE_IN                   : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);
        IM_IN                   : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);

        PHASE                   : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        PHASE_DER               : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0);
        PHASE_2DER              : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0)
    );
end InstantaneousPhase;

architecture Behavioral of InstantaneousPhase is

    signal re_resized_sig           : STD_LOGIC_VECTOR (3 downto 0);
    signal im_resized_sig           : STD_LOGIC_VECTOR (3 downto 0);

    signal angle_sig                : STD_LOGIC_VECTOR (7 downto 0);
    signal angle_ma_sig             : STD_LOGIC_VECTOR (ANGLE_MA_SUM_WIDTH-1 downto 0);
    signal angle_diff_sig           : STD_LOGIC_VECTOR (7 downto 0);
    signal angle_diff_ma_sig        : STD_LOGIC_VECTOR (ANGLE_DIFF_MA_SUM_WIDTH-1 downto 0);

begin

    RE_coupler: entity work.BitWidthCoupler
    generic map (
        SIG_IN_WIDTH            => SIG_IN_WIDTH,
        SIG_OUT_WIDTH           => 4
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN_ANGLE,
        SIG_IN                  => RE_IN,

        SIG_OUT                 => re_resized_sig
    );

    IM_coupler: entity work.BitWidthCoupler
    generic map (
        SIG_IN_WIDTH            => SIG_IN_WIDTH,
        SIG_OUT_WIDTH           => 4
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN_ANGLE,
        SIG_IN                  => IM_IN,

        SIG_OUT                 => im_resized_sig
    );

    phase_arg_function: entity work.Angle4Bit
        port map (
            CLK                 => CLK,
            EN                  => EN_ANGLE,
            RST                 => RST,

            X_IN                => re_resized_sig,
            Y_IN                => im_resized_sig,

            A_OUT               => angle_sig,
            DIFF_OUT            => angle_diff_sig
        );

    angle_ma_filter: entity work.MAFilter
      generic map (
        SAMPLE_LENGTH             => ANGLE_MA_LENGTH,
        SAMPLE_WIDTH              => 8,
        SUM_WIDTH                 => ANGLE_MA_SUM_WIDTH,
        SUM_START                 => 0,
        SIGNED_ARITHMETIC         => TRUE
      )
      port map (
        CLK                 => CLK,
        RST                 => RST,
        EN                  => EN_ANGLE,
        SIG_IN              => angle_sig,
    
        SUM_OUT             => angle_ma_sig
      );

    angle_filter: entity work.FIRFilterLP15tap
    generic map (
        SIG_IN_WIDTH        => ANGLE_MA_SUM_WIDTH,
        SIG_OUT_WIDTH       => SIG_OUT_WIDTH
    )
    port map (
        CLK                 => CLK,
        RST                 => RST,
        EN_IN               => EN_OUT,
        EN_OUT              => EN_OUT,
        SIG_IN              => angle_ma_sig,

        SIG_OUT             => PHASE
    );

    angle_diff_ma_filter: entity work.MAFilter
      generic map (
        SAMPLE_LENGTH             => ANGLE_DIFF_MA_LENGTH,
        SAMPLE_WIDTH              => 8,
        SUM_WIDTH                 => ANGLE_DIFF_MA_SUM_WIDTH,
        SUM_START                 => 0,
        SIGNED_ARITHMETIC         => TRUE
      )
      port map (
        CLK                 => CLK,
        RST                 => RST,
        EN                  => EN_ANGLE,
        SIG_IN              => angle_diff_sig,
    
        SUM_OUT             => angle_diff_ma_sig
      );

    angle_diff_filter: entity work.FIRFilterLP15tap
    generic map (
        SIG_IN_WIDTH        => ANGLE_DIFF_MA_SUM_WIDTH,
        SIG_OUT_WIDTH       => SIG_OUT_WIDTH
    )
    port map (
        CLK                 => CLK,
        RST                 => RST,
        EN_IN               => EN_OUT,
        EN_OUT              => EN_OUT,
        SIG_IN              => angle_diff_ma_sig,

        SIG_OUT             => PHASE_DER
    );


end Behavioral;

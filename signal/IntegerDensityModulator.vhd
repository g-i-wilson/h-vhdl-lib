library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IntegerDensityModulator is
    -- When the output width is 1, the output becomes Pulse Density Modulation (PDM)
    generic (
        INPUT_WIDTH         : positive := 8;
        OUTPUT_WIDTH        : positive := 1;
        PULSE_COUNT_WIDTH   : positive := 1
    );
    port (
        CLK                 : in STD_LOGIC;
        EN                  : in STD_LOGIC := '1';
        RST                 : in STD_LOGIC;
        PULSE_LENGTH        : in STD_LOGIC_VECTOR (PULSE_COUNT_WIDTH-1 downto 0) := (others=>'1');
        INPUT               : in STD_LOGIC_VECTOR (INPUT_WIDTH-1 downto 0);

        ERROR               : out STD_LOGIC_VECTOR (1+PULSE_COUNT_WIDTH+(INPUT_WIDTH-OUTPUT_WIDTH)-1 downto 0);
--        ERROR_SIGN          : out std_logic;
        OUTPUT              : out STD_LOGIC_VECTOR (OUTPUT_WIDTH-1 downto 0)
    );
end IntegerDensityModulator;


architecture Behavioral of IntegerDensityModulator is

    signal en_pulse_sig             : std_logic;
    signal pos_err                  : std_logic;
    signal out_sig                  : std_logic_vector (INPUT_WIDTH-1 downto 0);
    signal out_short_sig            : std_logic_vector (OUTPUT_WIDTH-1 downto 0);
    signal out_sig_left_shifted     : std_logic_vector (INPUT_WIDTH-1 downto 0);


begin

    sample_rate : entity work.PulseGenerator
        generic map (
            WIDTH       => PULSE_COUNT_WIDTH
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            EN          => EN,
            PERIOD      => PULSE_LENGTH,
            INIT_PERIOD => PULSE_LENGTH,
            PULSE       => en_pulse_sig
        );

    error_function: entity work.DifferenceAccumulator
        generic map (
            IN_WIDTH    => INPUT_WIDTH,
            SUM_WIDTH   => 1+PULSE_COUNT_WIDTH+(INPUT_WIDTH-OUTPUT_WIDTH)
        )
        port map (
            CLK         => CLK,
            EN          => EN,
            RST         => RST,
            IN_A        => INPUT,
            IN_B        => out_sig_left_shifted,
            DIFF_SUM    => ERROR,
            POS_SIGN    => pos_err
        );

    reduce_precision: entity work.ShiftRightReg
        generic map (
            WIDTH       => INPUT_WIDTH,
            PLACES      => (INPUT_WIDTH-OUTPUT_WIDTH)
        )
        port map (
            CLK         => CLK,
            EN          => en_pulse_sig,
            RST         => RST,
            INPUT       => INPUT,
            ROUND_UP    => pos_err,

            OUTPUT      => out_sig
        );

    out_sig_left_shifted <= std_logic_vector(
        shift_left(
            signed(out_sig),
            (INPUT_WIDTH-OUTPUT_WIDTH)
        )
    );

    out_short_sig <= out_sig(OUTPUT_WIDTH-1 downto 0);
    
    OUTPUT <= out_short_sig;

end Behavioral;

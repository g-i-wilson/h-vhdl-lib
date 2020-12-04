
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity FIRFilterBP8f63tap is
    generic (
        SIG_IN_WIDTH            : positive := 8; -- signal input path width
        SIG_OUT_WIDTH           : positive := 8 -- signal output path width
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN_IN                   : in STD_LOGIC; -- sample rate of the FIR filter
        EN_OUT                  : in STD_LOGIC; -- should be same or faster rate than EN_IN, otherwise will undersample the filter output
        SIG_IN                  : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0) := (others=>'0');

        SIG_OUT                 : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0) := (others=>'0')
    );
end FIRFilterBP8f63tap;

architecture Behavioral of FIRFilterBP8f63tap is

    signal filter_in_sig        : std_logic_vector(11 downto 0);
    signal filter_out_sig       : std_logic_vector(24 downto 0);

begin


    sig_in_coupler: entity work.BitWidthCoupler
        generic map (
            SIG_IN_WIDTH            => SIG_IN_WIDTH,
            SIG_OUT_WIDTH           => 12
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN                      => EN_IN,
            SIG_IN                  => SIG_IN,

            SIG_OUT                 => filter_in_sig
        );

    ----------------------------------------
    -- FIRFilter
    ----------------------------------------
    FIR: entity work.FIRFilter
    generic map (
        LENGTH      => 63, -- number of taps
        WIDTH       => 12, -- width of coef and signal path (x2 after multiplication)
        PADDING     => 1,  -- extra bits needed to pad overflow in situation of continuous DC at max level: 2^11-1 0x7FF (pos max) or 2^11 0x800 (neg max)
        SIGNED_MATH => TRUE
    )
    port map (
        CLK         => CLK,
        EN          => EN_IN,
        RST         => RST,
        -- from t-filter.engineerjs.com
        -- 0-0.5 Hz: -40dB (max)
        -- 0.98-1.02 Hz: 5dB (min)
        -- 1.5-4 Hz: -40dB (max)
        -- sample rate: 8 Hz
        -- desired taps: 63
        -- Note: values normalized for 12bit values
        COEF_IN     =>
		x"FFC" &
		x"FFF" &
		x"007" &
		x"012" &
		x"013" &
		x"002" &
		x"FE5" &
		x"FD3" &
		x"FDF" &
		x"FFD" &
		x"00A" &
		x"FF2" &
		x"FD5" &
		x"000" &
		x"09B" &
		x"14E" &
		x"152" &
		x"003" &
		x"DB1" &
		x"BDD" &
		x"C64" &
		x"FF8" &
		x"503" &
		x"82C" &
		x"688" &
		x"007" &
		x"82C" &
		x"41D" &
		x"720" &
		x"FFC" &
		x"967" &
		x"D67" &
		x"967" &
		x"FFC" &
		x"720" &
		x"41D" &
		x"82C" &
		x"007" &
		x"688" &
		x"82C" &
		x"503" &
		x"FF8" &
		x"C64" &
		x"BDD" &
		x"DB1" &
		x"003" &
		x"152" &
		x"14E" &
		x"09B" &
		x"000" &
		x"FD5" &
		x"FF2" &
		x"00A" &
		x"FFD" &
		x"FDF" &
		x"FD3" &
		x"FE5" &
		x"002" &
		x"013" &
		x"012" &
		x"007" &
		x"FFF" &
		x"FFC" ,
        SHIFT_IN    => filter_in_sig,

        SUM_OUT     => filter_out_sig
    );

    sig_out_coupler: entity work.BitWidthCoupler
        generic map (
            SIG_IN_WIDTH            => 25,
            SIG_OUT_WIDTH           => SIG_OUT_WIDTH
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN                      => EN_OUT,
            SIG_IN                  => filter_out_sig,

            SIG_OUT                 => SIG_OUT
        );

end Behavioral;

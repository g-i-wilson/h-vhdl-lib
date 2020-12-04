
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity FIRFilterLP4f63tap is
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
end FIRFilterLP4f63tap;

architecture Behavioral of FIRFilterLP4f63tap is

    signal filter_in_sig        : std_logic_vector(11 downto 0);
    signal filter_out_sig       : std_logic_vector(26 downto 0);

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
        PADDING     => 3,  -- extra bits needed to pad overflow in situation of continuous DC at max level: 2^11-1 0x7FF (pos max) or 2^11 0x800 (neg max)
        SIGNED_MATH => TRUE
    )
    port map (
        CLK         => CLK,
        EN          => EN_IN,
        RST         => RST,
        COEF_IN     =>
            x"FFF" &
            x"FFE" &
            x"FFC" &
            x"FF8" &
            x"FF5" &
            x"FF4" &
            x"FF6" &
            x"000" &
            x"00F" &
            x"025" &
            x"03C" &
            x"050" &
            x"059" &
            x"052" &
            x"034" &
            x"FFF" &
            x"FB6" &
            x"F62" &
            x"F10" &
            x"ED3" &
            x"EBD" &
            x"EE1" &
            x"F4A" &
            x"000" &
            x"0FC" &
            x"232" &
            x"38A" &
            x"4E6" &
            x"623" &
            x"722" &
            x"7C6" &
            x"7FF" &
            x"7C6" &
            x"722" &
            x"623" &
            x"4E6" &
            x"38A" &
            x"232" &
            x"0FC" &
            x"000" &
            x"F4A" &
            x"EE1" &
            x"EBD" &
            x"ED3" &
            x"F10" &
            x"F62" &
            x"FB6" &
            x"FFF" &
            x"034" &
            x"052" &
            x"059" &
            x"050" &
            x"03C" &
            x"025" &
            x"00F" &
            x"000" &
            x"FF6" &
            x"FF4" &
            x"FF5" &
            x"FF8" &
            x"FFC" &
            x"FFE" &
            x"FFF" ,
        SHIFT_IN    => filter_in_sig,

        SUM_OUT     => filter_out_sig
    );

    sig_out_coupler: entity work.BitWidthCoupler
        generic map (
            SIG_IN_WIDTH            => 27,
            SIG_OUT_WIDTH           => SIG_OUT_WIDTH
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN                      => EN_IN,
            SIG_IN                  => filter_out_sig,

            SIG_OUT                 => SIG_OUT
        );

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity FIRFilterLP8f63tap is
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
end FIRFilterLP8f63tap;

architecture Behavioral of FIRFilterLP8f63tap is

    signal filter_in_sig        : std_logic_vector(11 downto 0);
    signal filter_out_sig       : std_logic_vector(25 downto 0);

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
        PADDING     => 2,  -- extra bits needed to pad overflow in situation of continuous DC at max level: 2^11-1 0x7FF (pos max) or 2^11 0x800 (neg max)
        SIGNED_MATH => TRUE
    )
    port map (
        CLK         => CLK,
        EN          => EN_IN,
        RST         => RST,
        COEF_IN     =>
    		x"FFF" &
    		x"FFF" &
    		x"FFE" &
    		x"000" &
    		x"004" &
    		x"008" &
    		x"008" &
    		x"FFF" &
    		x"FF1" &
    		x"FE5" &
    		x"FE8" &
    		x"000" &
    		x"022" &
    		x"03A" &
    		x"030" &
    		x"FFF" &
    		x"FBC" &
    		x"F90" &
    		x"FA4" &
    		x"000" &
    		x"07B" &
    		x"0CA" &
    		x"0A7" &
    		x"FFF" &
    		x"F16" &
    		x"E72" &
    		x"EA5" &
    		x"000" &
    		x"259" &
    		x"50B" &
    		x"72F" &
    		x"7FF" &
    		x"72F" &
    		x"50B" &
    		x"259" &
    		x"000" &
    		x"EA5" &
    		x"E72" &
    		x"F16" &
    		x"FFF" &
    		x"0A7" &
    		x"0CA" &
    		x"07B" &
    		x"000" &
    		x"FA4" &
    		x"F90" &
    		x"FBC" &
    		x"FFF" &
    		x"030" &
    		x"03A" &
    		x"022" &
    		x"000" &
    		x"FE8" &
    		x"FE5" &
    		x"FF1" &
    		x"FFF" &
    		x"008" &
    		x"008" &
    		x"004" &
    		x"000" &
    		x"FFE" &
    		x"FFF" &
    		x"FFF" ,
        SHIFT_IN    => filter_in_sig,

        SUM_OUT     => filter_out_sig
    );

    sig_out_coupler: entity work.BitWidthCoupler
        generic map (
            SIG_IN_WIDTH            => 26,
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity BitWidthCoupler is
    generic (
        SIG_IN_WIDTH            : positive := 16; -- signal input path width
        SIG_OUT_WIDTH           : positive := 16; -- signal output path width
        USE_IDM                 : boolean := TRUE -- choose whether to use IDM when reducing precision
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN                      : in STD_LOGIC;
        SIG_IN                  : in STD_LOGIC_VECTOR (SIG_IN_WIDTH-1 downto 0);

        SIG_OUT                 : out STD_LOGIC_VECTOR (SIG_OUT_WIDTH-1 downto 0)
    );
end BitWidthCoupler;

architecture Behavioral of BitWidthCoupler is

--    signal padding : std_logic_vector(SIG_OUT_WIDTH-SIG_IN_WIDTH-1 downto 0) := (others=>'0');

begin

    ----------------------------------------
    -- IDM signal width reduction
    ----------------------------------------
    gen_out_less_than_IDM : if (SIG_OUT_WIDTH < SIG_IN_WIDTH and USE_IDM) generate
            IDM_output: entity work.IntegerDensityModulator
            -- When the output width is 1, the output becomes Pulse Density Modulation (PDM)
            generic map (
                INPUT_WIDTH         => SIG_IN_WIDTH,
                OUTPUT_WIDTH        => SIG_OUT_WIDTH,
                PULSE_COUNT_WIDTH   => 1
            )
            port map (
                CLK                 => CLK,
                EN                  => EN,
                RST                 => RST,
                PULSE_LENGTH(0)     => '1',
                INPUT               => SIG_IN,
    
                OUTPUT              => SIG_OUT
            );
    end generate gen_out_less_than_IDM;
    
    ----------------------------------------
    -- right-shift signal width reduction
    ----------------------------------------
    gen_out_less_than_shift: if (SIG_OUT_WIDTH < SIG_IN_WIDTH and not USE_IDM) generate
        SIG_OUT <= SIG_IN(SIG_IN_WIDTH-1 downto SIG_IN_WIDTH-SIG_OUT_WIDTH);
    end generate gen_out_less_than_shift;

    ----------------------------------------
    -- pass-through
    ----------------------------------------
    gen_out_equals : if SIG_OUT_WIDTH = SIG_IN_WIDTH generate
        SIG_OUT <= SIG_IN;
    end generate gen_out_equals;

    ----------------------------------------
    -- left-shift signal width increase
    ----------------------------------------
    gen_out_greater_than : if SIG_OUT_WIDTH > SIG_IN_WIDTH generate
--         SIG_OUT <= std_logic_vector( shift_left(signed(SIG_IN), SIG_OUT_WIDTH-SIG_IN_WIDTH) );
        SIG_OUT <= SIG_IN & std_logic_vector(to_unsigned(0, SIG_OUT_WIDTH-SIG_IN_WIDTH)); -- simple shift left (having bugs simulating with shift_left function)
--        SIG_OUT <= SIG_IN & padding;
    end generate gen_out_greater_than;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MulSumReg is
    generic (
        WIDTH       : positive := 8; -- width of coef and signal path (x2 for mult)
        PADDING     : positive := 4; -- extra bits incase of adder overflow
        PHASE_LAG   : integer := 1;   -- additional registers to phase shift signal
        SIGNED_MATH : boolean := TRUE
    );
    port (
        -- clk, en, rst
        CLK         : in STD_LOGIC;
        EN          : in STD_LOGIC;
        RST         : in STD_LOGIC;
        -- data stream value from previous link in shift register
        REG_IN      : in STD_LOGIC_VECTOR    (WIDTH-1 downto 0);
        -- data value will be multiplied by this coef (might be a constant)
        COEF_IN     : in STD_LOGIC_VECTOR    (WIDTH-1 downto 0);
        -- unchanged data value to send to next link
        REG_OUT     : out STD_LOGIC_VECTOR   (WIDTH-1 downto 0);
        -- data*coef output (mainly for debugging purposes)
        MULT_OUT    : out STD_LOGIC_VECTOR   (WIDTH*2-1 downto 0);
        -- sum from previous link (padding to prevent overflow)
        SUM_IN      : in STD_LOGIC_VECTOR    (WIDTH*2+PADDING-1 downto 0);
        -- sum + data*coef to send to next link
        SUM_OUT     : out STD_LOGIC_VECTOR   (WIDTH*2+PADDING-1 downto 0)
    );
end MulSumReg;



architecture Behavioral of MulSumReg is

    signal mult_in_sig      : std_logic_vector(WIDTH*2-1 downto 0);
    signal mult_out_sig     : std_logic_vector(WIDTH*2-1 downto 0);
    signal sum_out_sig      : std_logic_vector(WIDTH*2+PADDING-1 downto 0);
    signal this_reg_sig     : std_logic_vector(WIDTH-1 downto 0);

begin

    -- add the product (padded) to the previous incoming sum
    gen_signed : if SIGNED_MATH generate
        sum_out_sig <= std_logic_vector(
            resize( signed(mult_out_sig) , mult_out_sig'LENGTH  +padding ) +
            signed(sum_in)
        );
    end generate gen_signed;
    gen_unsigned : if not SIGNED_MATH generate
        sum_out_sig <= std_logic_vector(
            resize( unsigned(mult_out_sig) , mult_out_sig'LENGTH  +padding ) +
            unsigned(sum_in)
        );
    end generate gen_unsigned;


    -- pass-through register plus additional phase shift registers
    gen_zero_phase : if PHASE_LAG = 0 generate
    signal_path : entity work.Reg1D
        generic map (
            LENGTH      => WIDTH
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => EN, -- sample enable
            PAR_IN      => REG_IN,
            PAR_OUT     => this_reg_sig
        );
        REG_OUT <= this_reg_sig; -- pass-through reg is same as this reg
    end generate gen_zero_phase;

    -- pass-through register plus additional phase shift registers
    gen_positive_phase : if PHASE_LAG > 0 generate
    signal_path : entity work.Reg2D
        generic map (
            WIDTH       => WIDTH,
            LENGTH      => 1+PHASE_LAG
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => EN, -- sample enable
            PAR_IN      => REG_IN,
            PAR_OUT     => this_reg_sig, -- this reg is last reg in the 2D reg
            FIRST_OUT   => REG_OUT -- pass-through reg is first reg in the 2D reg
        );
    end generate gen_positive_phase;

    -- multiplication register
    mult_reg : entity work.Reg1D
        generic map (
            LENGTH => WIDTH*2
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => EN,
            PAR_IN      => mult_in_sig,
            PAR_OUT     => mult_out_sig
        );
        
    MULT_OUT <= mult_out_sig;

    -- sum register
    sum_reg : entity work.Reg1D
        generic map (
            LENGTH      => WIDTH*2+PADDING
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => EN,
            PAR_IN      => sum_out_sig,
            PAR_OUT     => SUM_OUT
        );


    -- multiplier
    mult1 : entity work.Multiplier
        generic map (
            WIDTH       => WIDTH,
            SIGNED_MATH => SIGNED_MATH
        )
        port map (
            A           => this_reg_sig,
            B           => COEF_IN,
            P           => mult_in_sig
        );

end Behavioral;

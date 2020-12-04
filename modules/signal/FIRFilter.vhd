library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FIRFilter is
    generic (
        LENGTH      : integer := 3; -- number of taps
        WIDTH       : integer := 8; -- width of coef and signal path (x2 after multiplication)
        PADDING     : integer := 4;  -- extra bits may be required if sum of taps causes overflow
        SIGNED_MATH : boolean := TRUE
    );
    port (
        CLK         : in STD_LOGIC;
        EN          : in STD_LOGIC;
        RST         : in STD_LOGIC;
        COEF_IN     : in STD_LOGIC_VECTOR (WIDTH*LENGTH-1 downto 0);
        SHIFT_IN    : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);

        SHIFT_OUT   : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
        PAR_OUT     : out STD_LOGIC_VECTOR ((WIDTH*(LENGTH-1))-1 downto 0);
        MULT_OUT    : out STD_LOGIC_VECTOR (WIDTH*2*LENGTH-1 downto 0);
        SUM_OUT     : out STD_LOGIC_VECTOR (WIDTH*2+PADDING-1 downto 0)
    );
end FIRFilter;



architecture Behavioral of FIRFilter is


signal all_reg_sig : std_logic_vector((WIDTH*(LENGTH-1))-1 downto 0);
-- provides all signals "between" each register, so width*(length-1)

signal all_sum_sig : std_logic_vector(((WIDTH*2+PADDING)*(LENGTH-1))-1 downto 0);


begin

    first_reg : entity work.MulSumReg
        generic map (
            WIDTH       => WIDTH,
            PADDING     => PADDING,
            PHASE_LAG   => 0,
            SIGNED_MATH => SIGNED_MATH
        )
        port map (
            CLK         => CLK,
            EN          => EN,
            RST         => RST,
            REG_IN      => SHIFT_IN,
            REG_OUT     => ALL_REG_SIG  ( WIDTH-1           downto 0 ),
            COEF_IN     => COEF_IN      ( WIDTH-1           downto 0 ),
            MULT_OUT    => MULT_OUT     ( WIDTH*2-1         downto 0 ),
            SUM_IN      => (others=>'0'), -- constant 0
            SUM_OUT     => ALL_SUM_SIG  ( WIDTH*2+PADDING-1 downto 0 )
        );

    gen_middle : for i in 0 to (LENGTH-3) generate -- length 5 regs is: in,0,1,2,out
    middle_reg : entity work.MulSumReg
        generic map (
            WIDTH       => WIDTH,
            PADDING     => PADDING,
            PHASE_LAG   => i+1,
            SIGNED_MATH => SIGNED_MATH
        )
        port map (
            CLK         => CLK,
            EN          => EN,
            RST         => RST,
            REG_IN      => all_reg_sig (  i    *WIDTH             +(WIDTH-1)           downto  i    *WIDTH             ),
            REG_OUT     => all_reg_sig ( (i+1) *WIDTH             +(WIDTH-1)           downto (i+1) *WIDTH             ),
            COEF_IN     => COEF_IN     ( (i+1) *WIDTH             +(WIDTH-1)           downto (i+1) *WIDTH             ),
            MULT_OUT    => MULT_OUT    ( (i+1) *WIDTH*2           +(WIDTH*2-1)         downto (i+1) *WIDTH*2           ),
            SUM_IN      => all_sum_sig (  i    *(WIDTH*2+PADDING) +(WIDTH*2+PADDING-1) downto  i    *(WIDTH*2+PADDING) ),
            SUM_OUT     => all_sum_sig ( (i+1) *(WIDTH*2+PADDING) +(WIDTH*2+PADDING-1) downto (i+1) *(WIDTH*2+PADDING) )
        );
    end generate gen_middle;

    last_reg : entity work.MulSumReg
        generic map (
            width       => WIDTH,
            padding     => PADDING,
            PHASE_LAG   => LENGTH-1,
            SIGNED_MATH => SIGNED_MATH
        )
        port map (
            CLK         => CLK,
            EN          => EN,
            RST         => RST,
            REG_IN      => all_reg_sig  ( all_reg_sig'high  downto all_reg_sig'high -(WIDTH-1)           ),
            REG_OUT     => SHIFT_OUT,
            COEF_IN     => COEF_IN      ( COEF_IN'high      downto COEF_IN'high     -(WIDTH-1)           ),
            MULT_OUT    => MULT_OUT     ( MULT_OUT'high     downto MULT_OUT'high    -(WIDTH*2-1)         ),
            SUM_IN      => all_sum_sig  ( all_sum_sig'high  downto all_sum_sig'high -(WIDTH*2+PADDING-1) ),
            SUM_OUT     => SUM_OUT
        );

    PAR_OUT <= all_reg_sig;

end Behavioral;

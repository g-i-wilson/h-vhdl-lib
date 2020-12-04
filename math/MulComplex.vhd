library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MulComplex is
  generic (
      WIDTH         : positive := 8;
      SIGNED_MATH   : boolean := TRUE;
      PADDING       : positive := 1 -- extra bits to guard against addition overflow
  );
  port (
      CLK           : in STD_LOGIC;
      RST           : in STD_LOGIC;
      EN            : in STD_LOGIC := '1';
      A_REAL        : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
      A_IMAG        : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
      B_REAL        : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
      B_IMAG        : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
      P_REAL        : out STD_LOGIC_VECTOR ((WIDTH*2)-1+PADDING downto 0);
      P_IMAG        : out STD_LOGIC_VECTOR ((WIDTH*2)-1+PADDING downto 0)
  );
end MulComplex;

architecture Behavioral of MulComplex is

    signal ar_br_sig : std_logic_vector ((WIDTH*2)-1+PADDING downto 0);
    signal ai_bi_sig : std_logic_vector ((WIDTH*2)-1+PADDING downto 0);
    signal ar_bi_sig : std_logic_vector ((WIDTH*2)-1+PADDING downto 0);
    signal ai_br_sig : std_logic_vector ((WIDTH*2)-1+PADDING downto 0);

    signal p_real_sig : std_logic_vector ((WIDTH*2)-1+PADDING downto 0);
    signal p_imag_sig : std_logic_vector ((WIDTH*2)-1+PADDING downto 0);

begin

    AR_BR : entity work.MulReg
        generic map (
            WIDTH       => WIDTH,
            SIGNED_MATH => SIGNED_MATH,
            PADDING     => PADDING
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            EN          => EN,
            A           => A_REAL,
            B           => B_REAL,
            P           => ar_br_sig
        );
    AI_BI : entity work.MulReg
        generic map (
            WIDTH       => WIDTH,
            SIGNED_MATH => SIGNED_MATH,
            PADDING     => PADDING
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            EN          => EN,
            A           => A_IMAG,
            B           => B_IMAG,
            P           => ai_bi_sig
        );
    AR_BI : entity work.MulReg
        generic map (
            WIDTH       => WIDTH,
            SIGNED_MATH => SIGNED_MATH,
            PADDING     => PADDING
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            EN          => EN,
            A           => A_REAL,
            B           => B_IMAG,
            P           => ar_bi_sig
        );
    AI_BR : entity work.MulReg
        generic map (
            WIDTH       => WIDTH,
            SIGNED_MATH => SIGNED_MATH,
            PADDING     => PADDING
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            EN          => EN,
            A           => A_IMAG,
            B           => B_REAL,
            P           => ai_br_sig
        );

    gen_signed : if SIGNED_MATH generate
        p_real_sig <= std_logic_vector( signed(ar_br_sig) - signed(ai_bi_sig) );
        p_imag_sig <= std_logic_vector( signed(ar_bi_sig) + signed(ai_br_sig) );
    end generate gen_signed;

    gen_unsigned : if not SIGNED_MATH generate
        p_real_sig <= std_logic_vector( unsigned(ar_br_sig) - unsigned(ai_bi_sig) );
        p_imag_sig <= std_logic_vector( unsigned(ar_bi_sig) + unsigned(ai_br_sig) );
    end generate gen_unsigned;

    P_REAL_reg : entity work.Reg1D
        generic map (
            LENGTH      => WIDTH*2+PADDING
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => EN,
            PAR_IN      => p_real_sig,
            PAR_OUT     => P_REAL
        );

    P_IMAG_reg : entity work.Reg1D
        generic map (
            LENGTH      => WIDTH*2+PADDING
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => EN,
            PAR_IN      => p_imag_sig,
            PAR_OUT     => P_IMAG
        );

end Behavioral;

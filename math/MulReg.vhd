library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MulReg is
  generic (
      WIDTH         : positive := 8;
      SIGNED_MATH   : boolean := TRUE;
      PADDING       : integer := 0 -- extra bits if useful
  );
  port (
      CLK           : in STD_LOGIC;
      RST           : in STD_LOGIC;
      EN            : in STD_LOGIC := '1';
      A             : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
      B             : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
      P             : out STD_LOGIC_VECTOR ((WIDTH*2)-1+PADDING downto 0)
  );
end MulReg;

architecture Behavioral of MulReg is

    signal mul_sig          : std_logic_vector((WIDTH*2)-1 downto 0);
    signal mul_padded_sig   : std_logic_vector((WIDTH*2)-1+PADDING downto 0);

begin

    gen_no_pad: if PADDING=0 generate
        mul_padded_sig <= mul_sig;
    end generate gen_no_pad;

    gen_pad_signed: if (PADDING>0 and SIGNED_MATH) generate
        mul_padded_sig <= std_logic_vector(
            resize( signed(mul_sig) , (WIDTH*2)+PADDING )
        );
    end generate gen_pad_signed;

    gen_pad_unsigned: if (PADDING>0 and not SIGNED_MATH) generate
        mul_padded_sig <= std_logic_vector(
            resize( unsigned(mul_sig) , (WIDTH*2)+PADDING )
        );
    end generate gen_pad_unsigned;


    MUL : entity work.Multiplier
        generic map (
            WIDTH           => WIDTH,
            SIGNED_MATH     => SIGNED_MATH
        )
        port map (
            A               => A,
            B               => B,
            P               => mul_sig
        );

    REG : entity work.Reg1D
    generic map (
        LENGTH              => (WIDTH*2)+PADDING
    )
    port map (
        CLK                 => CLK,
        RST                 => RST,
        PAR_EN              => EN,
        PAR_IN              => mul_padded_sig,
        PAR_OUT             => P
    );


end Behavioral;

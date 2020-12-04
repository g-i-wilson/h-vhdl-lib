library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Multiplier is
  generic (
      WIDTH         : positive := 8;
      SIGNED_MATH   : boolean := TRUE
  );
  port (
      A             : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
      B             : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
      P             : out STD_LOGIC_VECTOR ((WIDTH*2)-1 downto 0)
  );
end Multiplier;

architecture Behavioral of Multiplier is

  begin

      signed_gen: if SIGNED_MATH generate
        P <= std_logic_vector(signed(A) * signed(B));
      end generate signed_gen;

      unsigned_gen: if not SIGNED_MATH generate
        P <= std_logic_vector(unsigned(A) * unsigned(B));
      end generate unsigned_gen;

end Behavioral;

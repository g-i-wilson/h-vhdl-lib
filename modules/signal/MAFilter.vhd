library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity MAFilter is
  generic (
    SAMPLE_LENGTH             : positive := 10;
    SAMPLE_WIDTH              : positive := 1;
    SUM_WIDTH                 : positive := 3;
    SUM_START                 : integer := 0;
    SIGNED_ARITHMETIC         : boolean := false
  );
  port (
    RST                       : in std_logic;
    CLK                       : in std_logic;
    EN                        : in std_logic;
    SIG_IN                    : in std_logic_vector(SAMPLE_WIDTH-1 downto 0);

    SUM_OUT                   : out std_logic_vector(SUM_WIDTH-1 downto 0)
  );
end MAFilter;


architecture Behavioral of MAFilter is

  signal newest_sample    : std_logic_vector(SAMPLE_WIDTH-1 downto 0);
  signal oldest_sample    : std_logic_vector(SAMPLE_WIDTH-1 downto 0);
  signal sum_in_sig       : std_logic_vector(SUM_WIDTH-1 downto 0);
  signal sum_out_sig      : std_logic_vector(SUM_WIDTH-1 downto 0);

begin

  newest_sample <= SIG_IN;

  shift_reg : entity work.Reg2D
  generic map (
    LENGTH          => SAMPLE_LENGTH,
    WIDTH           => SAMPLE_WIDTH
  )
  port map (
    RST             => RST,
    CLK             => CLK,
    PAR_EN          => EN,
    PAR_IN          => newest_sample,
    PAR_OUT         => oldest_sample
  );


  sequential_adder: process (sum_out_sig, newest_sample, oldest_sample)
  begin
    if (SIGNED_ARITHMETIC) then
      sum_in_sig <= std_logic_vector(
        signed(sum_out_sig) + signed(newest_sample) - signed(oldest_sample)
      );
    else
      sum_in_sig <= std_logic_vector(
        (unsigned(sum_out_sig) + unsigned(newest_sample)) - unsigned(oldest_sample)
      );
    end if;
  end process;


  sum_reg : entity work.Reg1D
  generic map (
    LENGTH          => SUM_WIDTH
  )
  port map (
    RST             => RST,
    CLK             => CLK,
    PAR_EN          => EN,
    PAR_IN          => sum_in_sig,
    PAR_OUT         => sum_out_sig,
    DEFAULT_STATE   => std_logic_vector(to_unsigned(SUM_START, SUM_WIDTH))
  );


  SUM_OUT <= sum_out_sig;

end Behavioral;

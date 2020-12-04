library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity SequentialAdder is
  generic (
    SAMPLE_LENGTH             : positive := 10;
    SUM_WIDTH                 : positive := 3
  );
  port (
    RST                       : in std_logic;
    CLK                       : in std_logic;
    SIG_IN                    : in std_logic;

    SUM_OUT                   : out std_logic_vector(SUM_WIDTH-1 downto 0)
  );
end SequentialAdder;


architecture Behavioral of SequentialAdder is

  signal history          : std_logic_vector(SAMPLE_LENGTH-1 downto 0);
  signal sum              : integer := 0;
  signal sum_in           : std_logic_vector(SUM_WIDTH-1 downto 0);

begin

  shift_reg : entity work.Reg1D
  generic map (
    LENGTH          => SAMPLE_LENGTH
  )
  port map (
    RST             => RST,
    CLK             => CLK,
    SHIFT_EN        => '1',
    SHIFT_IN        => SIG_IN,
    PAR_OUT         => history
  );
  

  process (history)
  begin
    sum <= 0;
    for i in (SAMPLE_LENGTH-1) downto 0 loop
      if (history(i) = '1') then
        sum <= sum+1;
      end if;
    end loop;
  end process;
  
  sum_in <= std_logic_vector(to_unsigned(sum,SUM_WIDTH));

  
  sum_reg : entity work.Reg1D
  generic map (
    LENGTH          => SUM_WIDTH
  )
  port map (
    RST             => RST,
    CLK             => CLK,
    PAR_EN          => '1',
    PAR_IN          => sum_in,
    PAR_OUT         => SUM_OUT
  );

end Behavioral;

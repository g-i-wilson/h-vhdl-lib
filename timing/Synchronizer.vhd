library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Synchronizer is
  generic (
    SYNC_LENGTH               : positive := 3
  );
  port (
    RST                       : in std_logic;
    CLK                       : in std_logic;
    SIG_IN                    : in std_logic;

    SIG_OUT                   : out std_logic
  );
end Synchronizer;


architecture Behavioral of Synchronizer is

begin

  shift_reg : entity work.reg1D
  generic map (
    LENGTH          => SYNC_LENGTH
  )
  port map (
    RST             => RST,
    CLK             => CLK,
    SHIFT_EN        => '1',
    SHIFT_IN        => SIG_IN,
    SHIFT_OUT       => SIG_OUT
  );

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity EdgeDetector is
  generic (
    SAMPLE_LENGTH             : positive := 16;
    SUM_WIDTH                 : positive := 4;
    LOGIC_HIGH                : positive := 13;
    LOGIC_LOW                 : positive := 2;
    SUM_START                 : positive := 7
  );
  port (
    RST                       : in std_logic;
    CLK                       : in std_logic;
    SAMPLE                    : in std_logic;

    SIG_IN                    : in std_logic;

    EDGE_EVENT                : out std_logic;
    VALID                     : out std_logic;
    DATA                      : out std_logic;
    SUM                       : out std_logic_vector(SUM_WIDTH-1 downto 0)
  );
end EdgeDetector;


architecture Behavioral of EdgeDetector is

    signal sum_sig  : std_logic_vector(SUM_WIDTH-1 downto 0);
    signal sync_sig : std_logic;

begin

  sync_reg : entity work.Synchronizer
  generic map (
    SYNC_LENGTH     => 3
  )
  port map (
    RST             => RST,
    CLK             => CLK,
    SIG_IN        	=> SIG_IN,
    SIG_OUT         => sync_sig
  );

  moving_average : entity work.MAFilter1Bit
  generic map (
    SAMPLE_LENGTH   => SAMPLE_LENGTH,
    SUM_WIDTH       => SUM_WIDTH,
    SUM_START       => SUM_START
  )
  port map (
    CLK             => CLK,
    EN              => SAMPLE,
    RST             => RST,
    SIG_IN          => sync_sig,
    SUM_OUT         => sum_sig
  );


  FSM: entity work.EdgeDetectorFSM
  generic map (
    SUM_WIDTH                 => SUM_WIDTH,
    LOGIC_HIGH                => LOGIC_HIGH,
    LOGIC_LOW                 => LOGIC_LOW
  )
  port map (
    RST                       => RST,
    CLK                       => CLK,

    SUM_IN                    => sum_sig,

    EDGE_EVENT                => EDGE_EVENT,
    VALID                     => VALID,
    DATA                      => DATA
  );

  SUM <= sum_sig;

end Behavioral;

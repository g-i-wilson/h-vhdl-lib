library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity PeriodDetector is
    generic (
        SAMPLE_LENGTH   : positive := 16;
        SUM_WIDTH       : positive := 4;
        LOGIC_HIGH      : positive := 13;
        LOGIC_LOW       : positive := 2;
        SUM_START       : positive := 7;
        PERIOD_WIDTH    : positive := 8;
        MA_LENGTH       : positive := 4;
        MA_SUM_WIDTH    : positive := 12
    );
    port (
        RST             : in std_logic;
        CLK             : in std_logic;
        EN              : in std_logic := '1';
        
        SIG_IN          : in std_logic;
        
        PERIOD          : out std_logic_vector(PERIOD_WIDTH-1 downto 0)
    );
end PeriodDetector;


architecture Behavioral of PeriodDetector is

    signal edge_sig                 : std_logic;
    signal data_sig                 : std_logic;
    signal rising_edge_sig          : std_logic;
    signal period_sig               : std_logic_vector(PERIOD_WIDTH-1 downto 0);
    signal period_filtered_sig      : std_logic_vector(MA_SUM_WIDTH-1 downto 0);

begin

    EdgeDetector_module: entity work.EdgeDetector
        generic map (
            SAMPLE_LENGTH             => SAMPLE_LENGTH,
            SUM_WIDTH                 => SUM_WIDTH,
            LOGIC_HIGH                => LOGIC_HIGH,
            LOGIC_LOW                 => LOGIC_LOW,
            SUM_START                 => SUM_START
        )
        port map (
            RST                       => RST,
            CLK                       => CLK,
            
            SAMPLE                    => EN,
            SIG_IN                    => SIG_IN,
            
            EDGE_EVENT                => edge_sig,
            DATA                      => data_sig
        );
  
    rising_edge_sig <= edge_sig and data_sig;

    PERIOD_counter: entity work.Period
        generic map (
            WIDTH               => PERIOD_WIDTH
        )
        port map (
            CLK                 => CLK,
            EN                  => EN,
            RST                 => RST,
            EDGE_EVENT          => rising_edge_sig,
            
            PERIOD              => period_sig
        );

    MAFilter_module : entity work.MAFilter
        generic map (
            SAMPLE_LENGTH       => MA_LENGTH,
            SAMPLE_WIDTH        => PERIOD_WIDTH,
            SUM_WIDTH           => MA_SUM_WIDTH,
            SUM_START           => 0,
            SIGNED_ARITHMETIC   => false
        )
        port map (
            CLK             => CLK,
            EN              => rising_edge_sig,
            RST             => RST,
            SIG_IN          => period_sig,
            SUM_OUT         => period_filtered_sig
        );

    PERIOD <= period_filtered_sig(MA_SUM_WIDTH-1 downto MA_SUM_WIDTH-PERIOD_WIDTH);

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ParEdgeDetector is
    generic (
        PAR_WIDTH               : positive := 8;
        SAMPLE_LENGTH           : positive := 16;
        SUM_WIDTH               : positive := 4;
        LOGIC_HIGH              : positive := 13;
        LOGIC_LOW               : positive := 2;
        SUM_START               : positive := 7
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        SAMPLE                  : in STD_LOGIC;
        SIG_IN                  : in STD_LOGIC_VECTOR (PAR_WIDTH-1 downto 0);
        EDGE_EVENT              : out STD_LOGIC_VECTOR (PAR_WIDTH-1 downto 0);
        VALID                   : out STD_LOGIC_VECTOR (PAR_WIDTH-1 downto 0);
        DATA                    : out STD_LOGIC_VECTOR (PAR_WIDTH-1 downto 0)
    );
end ParEdgeDetector;

architecture Behavioral of ParEdgeDetector is

begin

    gen_detectors : for i in 0 to PAR_WIDTH-1 generate
        detector: entity work.EdgeDetector
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
            
            SAMPLE                    => '1',
            SIG_IN                    => SIG_IN(i),
            
            EDGE_EVENT                => EDGE_EVENT(i),
            DATA                      => DATA(i)
        );
    end generate gen_detectors;


end Behavioral;

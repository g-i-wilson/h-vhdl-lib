library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity LogicAnalyzerPacketSerial is
    generic (
        -- Serial rate
        SERIAL_RATE             : positive := 99;   -- units of clock cycles (minus 1)
        -- width & length of analyzer [bytes]
        ANALYZER_WIDTH          : positive := 8;
        ANALYZER_LENGTH         : positive := 4
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;

        TRIGGER                 : in std_logic;
        PROBES                  : in std_logic_vector(ANALYZER_WIDTH*8-1 downto 0);

        RX                      : in std_logic;
        TX                      : out std_logic
    );
end LogicAnalyzerPacketSerial;


architecture Behavioral of LogicAnalyzerPacketSerial is

begin



end Behavioral;

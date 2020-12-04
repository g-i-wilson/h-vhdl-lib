library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI3WireConverter is
    port (
        MASTER_CS                   : in STD_LOGIC;
        MASTER_SCK                  : in STD_LOGIC;
        MASTER_MOSI                 : in STD_LOGIC;
        MASTER_MISO                 : out STD_LOGIC;
        MASTER_TRISTATE_EN          : in STD_LOGIC;
        
        SLAVE_CS                    : out STD_LOGIC;
        SLAVE_SCK                 	: out STD_LOGIC;
        SLAVE_SDA                 	: inout STD_LOGIC
    );
end SPI3WireConverter;

architecture Behavioral of SPI3WireConverter is


begin
    
    SLAVE_SDA <= MASTER_MOSI when (MASTER_TRISTATE_EN = '0') else 'Z';
    
    MASTER_MISO <= SLAVE_SDA;
    
    SLAVE_CS <= MASTER_CS;
    
    SLAVE_SCK <= MASTER_SCK;

end Behavioral;

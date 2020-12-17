library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Period is
    generic (
        WIDTH       : positive := 8
    );
    port ( 
        CLK             : in STD_LOGIC;
        RST             : in STD_LOGIC;
        EN              : in STD_LOGIC := '1';

        EDGE_EVENT      : in STD_LOGIC;
        
        PERIOD          : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
    );
end Period;

architecture Behavioral of Period is

    signal period_rst_sig   : std_logic;
    signal period_sig       : std_logic_vector(WIDTH-1 downto 0);

begin

    period_rst_sig <= RST or EDGE_EVENT;

    PERIOD_counter: entity work.Timer
        generic map (
            WIDTH               => WIDTH
        )
        port map (
            CLK                 => CLK,
            EN                  => EN,
            RST                 => period_rst_sig,

            COUNT               => period_sig
        );

    PERIOD_reg: entity work.Reg1D
        generic map (
            LENGTH              => WIDTH
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,

            PAR_EN              => EDGE_EVENT,
            PAR_IN              => period_sig,
            PAR_OUT             => PERIOD
        );

end Behavioral;

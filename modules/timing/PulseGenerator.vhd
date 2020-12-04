library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PulseGenerator is
    generic (
        WIDTH       : positive := 8
    );
    port ( 
        CLK         : in STD_LOGIC;
        RST         : in STD_LOGIC;
        EN          : in STD_LOGIC := '1';
        PERIOD      : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'1'); -- unsigned
        INIT_PERIOD : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'1'); -- unsigned
        PULSE       : out STD_LOGIC;
        COUNT       : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
    );
end PulseGenerator;

architecture Behavioral of PulseGenerator is

    signal pulse_sig            : std_logic;
    signal timer_rst_sig        : std_logic;
    signal timer_pulse_sig      : std_logic;
    signal period_sig           : std_logic_vector (WIDTH-1 downto 0) := (others=>'0');

begin

    PULSE <= timer_pulse_sig;
    
    timer_rst_sig <= RST or timer_pulse_sig;
    
    Timer_module : entity work.Timer
        generic map (
            WIDTH               => WIDTH
        )
        port map (
            CLK                 => CLK,
            EN                  => EN,
            RST                 => timer_rst_sig,
            COUNT_END           => period_sig,
            DONE                => timer_pulse_sig,
            COUNT               => COUNT
        );

    PERIOD_reg: entity work.Reg1D
        generic map (
            LENGTH              => WIDTH
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,

            PAR_EN              => timer_rst_sig,
            PAR_IN              => PERIOD,
            PAR_OUT             => period_sig,
            
            DEFAULT_STATE       => INIT_PERIOD
        );


end Behavioral;

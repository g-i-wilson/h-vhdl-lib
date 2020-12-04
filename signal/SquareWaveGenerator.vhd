library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SquareWaveGenerator is
    generic (
        WIDTH           : positive := 3 -- default 3-bit counts to 8 : "000" through "111"
    );
    port (
        CLK             : in STD_LOGIC;
        RST             : in STD_LOGIC;
        EN              : in STD_LOGIC := '1';
        ON_PERIOD       : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'1');
        OFF_PERIOD      : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'1');
        INIT_ON_PERIOD  : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'1');
        INIT_OFF_PERIOD : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'1');
        DEFAULT_STATE   : in STD_LOGIC := '0'; -- start in OFF state
        SQUARE_WAVE     : out STD_LOGIC;
        EDGE_EVENT      : out STD_LOGIC;
        COUNT           : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
    );
end SquareWaveGenerator;

architecture Behavioral of SquareWaveGenerator is

    signal state_sig            : std_logic;
    signal timer_rst_sig        : std_logic;
    signal timer_pulse_sig      : std_logic;
    signal event_sig            : std_logic;
    signal on_period_sig        : std_logic_vector (WIDTH-1 downto 0) := (others=>'0');
    signal off_period_sig       : std_logic_vector (WIDTH-1 downto 0) := (others=>'0');
    signal timer_period_sig     : std_logic_vector (WIDTH-1 downto 0) := (others=>'0');

begin

    EDGE_EVENT          <= event_sig;
    SQUARE_WAVE         <= state_sig;
    
    timer_rst_sig       <= RST or timer_pulse_sig;
    timer_period_sig    <= on_period_sig when state_sig = '1' else off_period_sig;
    
    
    Timer_module : entity work.Timer
        generic map (
            WIDTH               => WIDTH
        )
        port map (
            CLK                 => CLK,
            EN                  => EN,
            RST                 => timer_rst_sig,
            COUNT_END           => timer_period_sig,
            DONE                => timer_pulse_sig,
            COUNT               => COUNT
        );

    ON_reg: entity work.Reg1D
        generic map (
            LENGTH              => WIDTH
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,

            PAR_EN              => timer_rst_sig,
            PAR_IN              => ON_PERIOD,
            PAR_OUT             => on_period_sig,
            
            DEFAULT_STATE       => INIT_ON_PERIOD
        );

    OFF_reg: entity work.Reg1D
        generic map (
            LENGTH              => WIDTH
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,

            PAR_EN              => timer_rst_sig,
            PAR_IN              => OFF_PERIOD,
            PAR_OUT             => off_period_sig,
            
            DEFAULT_STATE       => INIT_OFF_PERIOD
        );

    process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                state_sig <= DEFAULT_STATE;
                event_sig <= '0';
            elsif (timer_pulse_sig = '1') then
                state_sig <= not state_sig;
                event_sig <= '1';
            else
                state_sig <= state_sig;
                event_sig <= '0';
            end if;
        end if;
    end process;
    
    
end Behavioral;

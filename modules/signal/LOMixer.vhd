
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity LOMixer is
    generic (
        SIG_WIDTH               : positive := 1; -- signal path width
        LO_HALF_PERIOD_WIDTH    : positive := 16 -- width of timer register for LO
    );
    port (
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        EN                      : in STD_LOGIC;
        LO_HALF_PERIOD          : in STD_LOGIC_VECTOR (LO_HALF_PERIOD_WIDTH-1 downto 0) := (others=>'0');
        PHASE                   : in STD_LOGIC_VECTOR (LO_HALF_PERIOD_WIDTH-1 downto 0) := (others=>'0');
        POLARITY                : in STD_LOGIC := '1';
        DEFAULT_STATE           : in STD_LOGIC := '0';
        SIG_IN                  : in STD_LOGIC_VECTOR (SIG_WIDTH-1 downto 0) := (others=>'0');

        SIG_OUT                 : out STD_LOGIC_VECTOR (SIG_WIDTH-1 downto 0) := (others=>'0')
    );
end LOMixer;

architecture Behavioral of LOMixer is

    signal lo_sig               : STD_LOGIC;
    signal mod_sig              : STD_LOGIC_VECTOR(SIG_WIDTH-1 downto 0);
    signal init_period_sig      : STD_LOGIC_VECTOR (LO_HALF_PERIOD_WIDTH-1 downto 0);

begin

    ----------------------------------------
    -- Square wave "LO"
    ----------------------------------------
    init_period_sig <= std_logic_vector(unsigned(LO_HALF_PERIOD) + unsigned(PHASE));
    
    LO: entity work.SquareWaveGenerator
    generic map (
        WIDTH           => LO_HALF_PERIOD_WIDTH
    )
    port map (
        CLK             => CLK,
        RST             => RST,
        EN              => EN,
        ON_PERIOD       => LO_HALF_PERIOD,
        OFF_PERIOD      => LO_HALF_PERIOD,
        INIT_ON_PERIOD  => init_period_sig,
        INIT_OFF_PERIOD => init_period_sig,
        DEFAULT_STATE   => DEFAULT_STATE,
        
        SQUARE_WAVE     => lo_sig
    );


    ----------------------------------------
    -- Mixer (multiplication, not addition!)
    ----------------------------------------
    mix_greater_than_1 : if SIG_WIDTH > 1 generate
        process (SIG_IN, lo_sig, POLARITY)
        begin
            if (lo_sig = POLARITY) then
                mod_sig <= SIG_IN;
            else
                -- 2's compliment; negating a signed value
                mod_sig <= std_logic_vector(unsigned(not(SIG_IN)) + 1);
                -- SIG_OUT should be treated as signed
            end if;
        end process;
    end generate mix_greater_than_1;

    mix_1 : if SIG_WIDTH = 1 generate
        SIG_OUT(0) <= not (SIG_IN(0) xor lo_sig);
    end generate mix_1;


    ----------------------------------------
    -- Registered output
    ----------------------------------------
    Reg1D_module: entity work.Reg1D
        generic map (
            LENGTH              => SIG_WIDTH
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,

            PAR_EN              => EN,
            PAR_IN              => mod_sig,
            PAR_OUT             => SIG_OUT
        );

end Behavioral;

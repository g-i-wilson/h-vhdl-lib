library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TestUARTSPIBridgeBasys3 is
    port (
        -- inputs
        CLK             : in STD_LOGIC;
        MISO            : in STD_LOGIC;
        RX              : in STD_LOGIC;
        sw              : in STD_LOGIC_VECTOR (15 downto 0);
        -- outputs
        CS              : out STD_LOGIC;
        SCK             : out STD_LOGIC;
        MOSI            : out STD_LOGIC;
        TX              : out STD_LOGIC;
        led             : out STD_LOGIC_VECTOR (15 downto 0)
    );
end TestUARTSPIBridgeBasys3;

architecture Behavioral of TestUARTSPIBridgeBasys3 is

    signal clk_100MHz_sig : std_logic;
    signal rst_100MHz_sig : std_logic;
    signal clk_sig : std_logic;
    signal rst_sig : std_logic;


    signal mosi_sig : std_logic;
    signal sck_sig : std_logic;
    signal cs_sig : std_logic;


    signal pb1_sig : std_logic;
    signal bridge_rst_sig : std_logic;

begin

    MOSI <= mosi_sig;
    SCK <= sck_sig;
    CS <= cs_sig;

    led(5) <= mosi_sig;
    led(4) <= sck_sig;
    led(3) <= cs_sig;


    clk_100MHz_module : entity work.SimpleMMCM2
    generic map (
        CLKIN_PERIOD        => 10.000,
        PLL_MUL             => 10.00,     -- 100MHz * 10.00 = 1GHZ
        PLL_DIV             => 10       -- 1GHz / 10 = 100MHz
    )
    port map (
        CLK_IN              => CLK,
        RST_OUT             => rst_sig,
        CLK_OUT             => clk_sig
    );
    clk_LED: entity work.square_wave_gen
    generic map (
        half_period_width => 28
    )
    port map (
        clk => clk_sig,
        en => '1',
        rst => rst_sig,
        half_period => x"2FAF080",
        sq_out => led(0)
    );

    bridge_rst_sig <= rst_sig or pb1_sig;
    led(1) <= bridge_rst_sig;

    UARTSPIBridge_module: entity work.UARTSPIBridge
    generic map (
        SCK_HALF_PERIOD_WIDTH   => 28
    )
    port map (
        -- inputs
        CLK                     => clk_sig,
        RST                     => bridge_rst_sig,
        RX                      => RX,
        MISO                    => MISO,
        SCK_HALF_PERIOD         => x"2FAF080", -- 100MHz/2Hz to hex
        -- outputs
        TX                      => TX,
        MOSI                    => mosi_sig,
        CS                      => cs_sig,
        SCK                     => sck_sig,
        RX_ERR                  => led(7 downto 6)
    );

  soft_RST: entity work.PushButtonToggle
  port map (
    RST                       => rst_sig,
    CLK                       => clk_sig,

    SIG_IN                    => sw(0),
    SIG_OUT                   => pb1_sig
  );

end Behavioral;

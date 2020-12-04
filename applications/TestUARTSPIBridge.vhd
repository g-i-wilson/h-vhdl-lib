library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TestUARTSPIBridge is
    port (
        CLK_200MHZ_P    : in STD_LOGIC;
        CLK_200MHZ_N    : in STD_LOGIC;
        PB1             : in STD_LOGIC;
        RX              : in STD_LOGIC;
        MISO            : in STD_LOGIC;
        TX              : out STD_LOGIC;
        MOSI            : out STD_LOGIC;
        SCK             : out STD_LOGIC;
        CS              : out STD_LOGIC;
        USER_LED        : out STD_LOGIC_VECTOR (7 downto 0)
    );
end TestUARTSPIBridge;

architecture Behavioral of TestUARTSPIBridge is

    signal clk_200MHz_sig : std_logic;
    signal rst_200MHz_sig : std_logic;
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
    
    USER_LED(5) <= mosi_sig;
    USER_LED(4) <= sck_sig;
    USER_LED(3) <= cs_sig;

    FPGA_clk_module : entity work.DiffClkSelfRst
    port map (
        CLK_IN_P             => CLK_200MHZ_P,
        CLK_IN_N             => CLK_200MHZ_N,
        CLK_OUT              => clk_200MHz_sig,
        RST_OUT              => rst_200MHz_sig
    );


    clk_100MHz_module : entity work.SimpleMMCM
    generic map (
        CLKIN_PERIOD        => 5.000,
        PLL_MUL             => 5.00,     -- 200MHz * 5.00 = 1GHZ
        PLL_DIV             => 10       -- 1GHz / 10 = 100MHz
    )
    port map (
        RST_IN              => rst_200MHz_sig,
        CLK_IN              => clk_200MHz_sig,
        RST_OUT             => rst_sig,
        CLK_OUT             => clk_sig
    );
    clk_LED: entity work.debug_probe
    port map (
        CLK => clk_sig,
        LED => USER_LED(0)
    );
    
    bridge_rst_sig <= rst_sig or pb1_sig;
    USER_LED(1) <= bridge_rst_sig;

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
        RX_ERR                  => USER_LED(7 downto 6)
    );

  soft_RST: entity work.PushButtonToggle
  port map (
    RST                       => rst_sig,
    CLK                       => clk_sig,

    SIG_IN                    => PB1,
    SIG_OUT                   => pb1_sig
  );
  
end Behavioral;

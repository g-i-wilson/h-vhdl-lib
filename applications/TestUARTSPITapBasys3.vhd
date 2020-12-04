library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TestUARTSPITapBasys3 is
    port (
        -- inputs
        CLK             : in STD_LOGIC;
        CS              : in STD_LOGIC;
        SCK             : in STD_LOGIC;
        MISO            : in STD_LOGIC;
        MOSI            : in STD_LOGIC;
        sw              : in STD_LOGIC_VECTOR (15 downto 0);
        -- outputs
        TX              : out STD_LOGIC;
        led             : out STD_LOGIC_VECTOR (15 downto 0)
    );
end TestUARTSPITapBasys3;

architecture Behavioral of TestUARTSPITapBasys3 is

    signal clk_100MHz_sig : std_logic;
    signal rst_100MHz_sig : std_logic;
    signal clk_sig : std_logic;
    signal rst_sig : std_logic;
    signal tx_sig : std_logic;
    signal tx_not_ready_sig : std_logic;
    signal sw_event_sig : std_logic_vector(15 downto 0);
    signal sw_data_sig : std_logic_vector(15 downto 0);
    signal uart_period_sig : std_logic_vector(15 downto 0);

    signal sda_sig : std_logic;
    signal sck_sig : std_logic;
    signal cs_sig : std_logic;


    signal pb1_sig : std_logic;
    signal combined_rst_sig : std_logic;

begin

    sck_sig <= SCK;
    cs_sig <= CS;
    sda_sig <= MOSI when sw_data_sig(13) = '1' else MISO;
    
    TX <= tx_sig;

    led(13) <= sda_sig;
    led(14) <= sck_sig;
    led(15) <= cs_sig;

    led(2) <= tx_sig;
    
    led(3) <= tx_not_ready_sig;

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

    combined_rst_sig <= rst_sig or sw_data_sig(15);
    led(1) <= combined_rst_sig;
    

    uart_period_sig <= "000" & sw_data_sig(12 downto 0);

    UARTSPITap_module: entity work.UARTSPITap
    port map (
        -- inputs
        CLK                     => clk_sig,
        RST                     => combined_rst_sig,
        CS                      => cs_sig,
        SCK                     => sck_sig,
        SDA                     => sda_sig,
        UART_PERIOD             => uart_period_sig,
        TEST_BYTE               => x"41",
        TEST_EN                 => sw_event_sig(14),
        -- outputs
        TX                      => tx_sig,
        TX_NOT_READY            => tx_not_ready_sig
    );

    baud_config: entity work.ParEdgeDetector
    generic map (
        PAR_WIDTH                 => 16,
        SAMPLE_LENGTH             => 32,
        SUM_WIDTH                 => 5,
        LOGIC_HIGH                => 24,
        LOGIC_LOW                 => 8,
        SUM_START                 => 15
    )
    port map (
        RST                       => rst_sig,
        CLK                       => clk_sig,
        
        SAMPLE                    => '1',
        SIG_IN                    => sw,
        
        EDGE_EVENT                => sw_event_sig,
        DATA                      => sw_data_sig
    );
    
    ila0: entity work.ila_uartspitaptesting
    port map (
        CLK => clk_sig,
        probe0 => uart_period_sig,
        probe1(0) => tx_sig
    );

    
end Behavioral;

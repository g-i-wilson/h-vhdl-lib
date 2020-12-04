library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TestSPITransactionBasys3 is
    port (
        -- inputs
        CLK             : in STD_LOGIC;
        --CS              : in STD_LOGIC;
        --SCK             : in STD_LOGIC;
        --MISO            : in STD_LOGIC;
        --MOSI            : in STD_LOGIC;
        --sw              : in STD_LOGIC_VECTOR (15 downto 0);
        -- outputs
        TX              : out STD_LOGIC;
        led             : out STD_LOGIC_VECTOR (15 downto 0)
    );
end TestSPITransactionBasys3;

architecture Behavioral of TestSPITransactionBasys3 is

    signal clk_100MHz_sig : std_logic;
    signal rst_100MHz_sig : std_logic;
    signal clk_sig : std_logic;
    signal rst_sig : std_logic;
    signal tx_sig : std_logic;
    signal tri_sig : std_logic;
    signal spi_ready_sig : std_logic;
    signal reg_valid_sig : std_logic;
    signal spi_valid_sig : std_logic;
    signal reg_out_sig : std_logic_vector(23 downto 0);

    signal sda_sig : std_logic;
    signal sck_sig : std_logic;
    signal cs_sig : std_logic;


    signal pb1_sig : std_logic;
    signal combined_rst_sig : std_logic;

begin
    
    MMCM_100MHz_module : entity work.SimpleMMCM2
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

    SPI_config_reg: entity work.Reg1DSymbols
        generic map (
            LENGTH              => 4,
            SYMBOL_WIDTH        => 24
        )
        port map (
            CLK                 => clk_sig,
            RST                 => rst_sig,
            
            SHIFT_EN            => spi_ready_sig,
            SHIFT_IN            => reg_out_sig,
            SHIFT_OUT           => reg_out_sig,
            
            DEFAULT_STATE       => 
                x"ABCD55" &
                x"BCDEAA" &
                x"CDEF55" &
                x"AAAAAA"
        );

    SPITransaction_module: entity work.SPITransaction
        generic map (
            SCK_HALF_PERIOD_WIDTH   =>  24,
            MISO_DETECTOR_SAMPLES   =>  16,
            ADDR_WIDTH              =>  16,
            DATA_WIDTH              =>  8,
            COUNTER_WIDTH           =>  8
        )
        port map (
            CLK                     => clk_sig,
            RST                     => rst_sig,
            
            -- R/W
            WRITE                   => '1',
            
            -- upstream
            READY_OUT               => spi_ready_sig,
            VALID_IN                => '1',
            
            -- downstream
            READY_IN                => open,
            VALID_OUT               => spi_valid_sig,
    
            -- ADDR & DATA
            ADDR                    => reg_out_sig(23 downto 8),
            DATA_IN                 => reg_out_sig(7 downto 0),
            DATA_OUT                => open,
            
            -- SPI
            SCK_HALF_PERIOD         => x"98967F", -- 100MHz/10Hz-1 to hex
            MISO                    => open,
            MOSI                    => sda_sig,
            SCK                     => sck_sig,
            CS                      => cs_sig,
            TRISTATE_EN             => tri_sig
        );
    
    
    led(15) <= cs_sig;
    led(14) <= sck_sig;
    led(13) <= sda_sig;
    led(12) <= tri_sig;

    UARTSPITap_module: entity work.UARTSPITap
        port map (
            -- inputs
            CLK                     => clk_sig,
            RST                     => rst_sig,
            CS                      => cs_sig,
            SCK                     => sck_sig,
            SDA                     => sda_sig,
            UART_PERIOD             => x"0063",
            TEST_BYTE               => x"41",
            TEST_EN                 => '0',
            -- outputs
            TX                      => tx_sig,
            TX_NOT_READY            => open
        );

    TX <= tx_sig;


end Behavioral;

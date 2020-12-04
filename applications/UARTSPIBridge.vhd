library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UARTSPIBridge is
    generic (
        SCK_HALF_PERIOD_WIDTH   : positive
    );
    port (
        -- inputs
        CLK                     : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        RX                      : in STD_LOGIC;
        MISO                    : in STD_LOGIC;
        SCK_HALF_PERIOD         : in STD_LOGIC_VECTOR(SCK_HALF_PERIOD_WIDTH-1 downto 0);
        -- outputs
        TX                      : out STD_LOGIC;
        MOSI                    : out STD_LOGIC;
        CS                      : out STD_LOGIC;
        SCK                     : out STD_LOGIC;
        RX_ERR                  : out STD_LOGIC_VECTOR(1 downto 0);
        TRISTATE_EN             : out STD_LOGIC
    );
end UARTSPIBridge;

architecture Behavioral of UARTSPIBridge is

    signal data_out_rx_sig      : std_logic_vector(7 downto 0);
    signal data_out_spi_sig     : std_logic_vector(7 downto 0);

    signal valid_out_rx_sig     : std_logic;
    signal valid_out_spi_sig    : std_logic;
    
    signal ready_out_spi_sig        : std_logic;
    signal ready_out_tx_sig         : std_logic;

begin

    
    RX_module: entity work.SerialRx
    port map (
        -- inputs
        CLK                     => CLK,
        EN                      => '1',
        RST                     => RST,
        RX                      => RX,
        -- outputs
        VALID                   => valid_out_rx_sig,
        DATA                    => data_out_rx_sig,
        ALARM                   => RX_ERR
    );


    SPI_module: entity work.SPITransaction
    generic map (
        SCK_HALF_PERIOD_WIDTH   => SCK_HALF_PERIOD_WIDTH,
        MISO_DETECTOR_SAMPLES   => 16
    )
    port map (
        CLK                     => CLK,
        RST                     => RST,
        
        -- data path IN
        READY_OUT               => ready_out_spi_sig,
        VALID_IN                => valid_out_rx_sig,
        DATA_IN                 => data_out_rx_sig,
        -- data path OUT
        READY_IN                => ready_out_tx_sig,
        VALID_OUT               => valid_out_spi_sig,
        DATA_OUT                => data_out_spi_sig,
        
        -- SPI
        SCK_HALF_PERIOD         => SCK_HALF_PERIOD,
        MOSI                    => MOSI,
        MISO                    => MISO,
        SCK                     => SCK,
        CS                      => CS,
        TRISTATE_EN             => TRISTATE_EN
    );


    TX_module: entity work.SerialTx
    port map ( 
        -- inputs
        CLK                     => CLK,
        EN                      => '1',
        RST                     => RST,
        BIT_TIMER_PERIOD        => x"28B1", -- 100e6/9600 to hex (units of clock cycles)
        VALID                   => valid_out_spi_sig,
        DATA                    => data_out_spi_sig,
--        DATA                    => x"AB",
        -- outputs
        READY                   => ready_out_tx_sig,
        TX                      => TX
    );


--    data_in_tx_sig <= data_out_rx_sig when valid_out_rx_sig = '1' else data_out_spi_sig;
    
--    valid_in_tx_sig <= valid_out_rx_sig or valid_out_spi_sig;
    
    
    ila0: entity work.ila_uartspi_testing
    port map (
        CLK => CLK,
        probe0 => valid_out_rx_sig & ready_out_spi_sig & "000000",
        probe1 => valid_out_spi_sig & ready_out_tx_sig & "000000",
        probe2 => data_out_rx_sig,
        probe3 => data_out_spi_sig
    );


end Behavioral;

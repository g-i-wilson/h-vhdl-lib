library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPISerial is
    generic (
        -- packet header
        HEADER_BYTES		        : positive := 2;
        -- packet data (contains SPI_ADDR, CONTROL, SPI_DATA)
        SPI_ADDR_BYTES              : positive := 2;
        SPI_CTL_BYTES               : positive := 1; -- contains R/W indication
        SPI_DATA_BYTES		        : positive := 1;

        SCK_HALF_PERIOD_WIDTH       : positive := 8;
        BIT_COUNTER_WIDTH           : positive := 8;
        MISO_DETECTOR_SAMPLES       : positive := 16;
        BIT_PERIOD                  : positive := 100 -- 1MHz buad rate @ 100MHz clock
    );
    port (
        CLK                         : in STD_LOGIC;
        RST                         : in STD_LOGIC;

        RX                          : in STD_LOGIC;
        TX                          : out STD_LOGIC;

        RX_HEADER                   : in STD_LOGIC_VECTOR (HEADER_BYTES*8-1 downto 0);
        TX_HEADER                   : in STD_LOGIC_VECTOR (HEADER_BYTES*8-1 downto 0);

        SCK_HALF_PERIOD	            : in STD_LOGIC_VECTOR (SCK_HALF_PERIOD_WIDTH-1 downto 0);

        CS                          : out STD_LOGIC;
        SCK                         : out STD_LOGIC;
        MISO                        : in STD_LOGIC;
        MOSI                        : out STD_LOGIC;
        TRISTATE_EN                 : out STD_LOGIC
    );
end SPISerial;

architecture Behavioral of SPISerial is

    signal rx_valid_sig         : std_logic;
    signal spi_ready_sig        : std_logic;
    signal spi_valid_sig        : std_logic;

    signal serial_alarm_sig     : std_logic_vector(1 downto 0);

    signal write_sig            : std_logic;

    signal spi_in_sig           : std_logic_vector((SPI_DATA_BYTES)*8-1 downto 0);
    signal spi_out_sig          : std_logic_vector((SPI_DATA_BYTES)*8-1 downto 0);
    
    signal rx_data_sig          : std_logic_vector((SPI_ADDR_BYTES+SPI_CTL_BYTES+SPI_DATA_BYTES)*8-1 downto 0);
    signal rx_data_reg_sig      : std_logic_vector((SPI_ADDR_BYTES+SPI_CTL_BYTES+SPI_DATA_BYTES)*8-1 downto 0);
    signal tx_data_sig          : std_logic_vector((SPI_ADDR_BYTES+SPI_CTL_BYTES+SPI_DATA_BYTES)*8-1 downto 0);

begin

    telemetry: entity work.PacketSerialFullDuplex
        -- Serial baud rate is clk_freq/100
        generic map (
            RX_HEADER_BYTES         => HEADER_BYTES,
            RX_DATA_BYTES           => SPI_ADDR_BYTES + SPI_CTL_BYTES + SPI_DATA_BYTES,
            TX_HEADER_BYTES         => HEADER_BYTES,
            TX_DATA_BYTES           => SPI_ADDR_BYTES                 + SPI_DATA_BYTES,
            BIT_PERIOD              => BIT_PERIOD
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,

            SERIAL_RX               => RX,
            SERIAL_TX               => TX,
            RX_ALARM                => serial_alarm_sig,

            -- RX data
            VALID_OUT               => rx_valid_sig,
            RX_HEADER		        => RX_HEADER,
            RX_DATA  		        => rx_data_sig,

            -- TX data
            VALID_IN                => spi_valid_sig,
            TX_HEADER		        => TX_HEADER,
            TX_DATA  		        => tx_data_sig
        );

    rx_data_reg: entity work.Reg1D
        generic map (
            LENGTH              =>  (SPI_ADDR_BYTES + SPI_CTL_BYTES + SPI_DATA_BYTES) * 8
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,

            PAR_EN              => rx_valid_sig,
            PAR_IN              => rx_data_sig,
            PAR_OUT             => rx_data_reg_sig
        );

    -- map addr from input packet to output packet
    spi_addr_sig    <= rx_data_reg_sig((SPI_ADDR_BYTES + SPI_CTL_BYTES + SPI_DATA_BYTES)*8-1 downto (SPI_CTL_BYTES + SPI_DATA_BYTES)*8);
    spi_ctl_sig     <= rx_data_reg_sig((                 SPI_CTL_BYTES + SPI_DATA_BYTES)*8   downto (                SPI_DATA_BYTES)*8);
    spi_in_sig      <= rx_data_reg_sig((                                 SPI_DATA_BYTES)*8-1 downto                                  0);
    
    -- SPI addr_sig & SPI output
    tx_data_sig     <= spi_addr_sig & spi_out_sig;
    
    -- write indication when the control byte == 'w'
    write_sig <= '1' when spi_ctl_sig = x"77" else '0';
    
    SPIMaster_module: entity work.SPIMaster
        generic map (
            SCK_HALF_PERIOD_WIDTH   =>  SCK_HALF_PERIOD_WIDTH,
            ADDR_WIDTH              =>  SPI_ADDR_BYTES*8,
            DATA_WIDTH              =>  SPI_DATA_BYTES*8,
            COUNTER_WIDTH           =>  BIT_COUNTER_WIDTH,
            MISO_DETECTOR_SAMPLES   => MISO_DETECTOR_SAMPLES
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,

            -- R/W
            WRITE                   => write_sig,

            -- upstream
            READY_OUT               => spi_ready_sig,
            VALID_IN                => rx_valid_sig,

            -- downstream
            READY_IN                => '1',
            VALID_OUT               => spi_valid_sig,

            -- ADDR & DATA
            ADDR                    => spi_addr_sig,
            DATA_IN                 => spi_in_sig,
            DATA_OUT                => spi_out_sig,

            -- SPI
            SCK_HALF_PERIOD         => SCK_HALF_PERIOD,
            MISO                    => MISO,
            MOSI                    => MOSI,
            SCK                     => SCK,
            CS                      => CS,
            TRISTATE_EN             => TRISTATE_EN
        );

    VERIFY_ADDR     <= verify_out_sig(SPI_ADDR_BYTES*8+SPI_DATA_BYTES*8-1 downto SPI_DATA_BYTES*8);
    VERIFY_DATA     <= reg_out_sig(SPI_DATA_BYTES*8-1 downto 0);
    ACTUAL_DATA     <= spi_out_sig;

end Behavioral;

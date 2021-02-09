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
        ADDR_BYTES                  : positive := 2;
        DATA_BYTES		              : positive := 1;
        HEADER_BYTES		            : positive := 2;
        SCK_HALF_PERIOD_WIDTH       : positive := 8;
        BIT_COUNTER_WIDTH           : positive := 8;
        MISO_DETECTOR_SAMPLES       : positive := 16
    );
    port (
        CLK                         : in STD_LOGIC;
        RST                         : in STD_LOGIC;

        TO_SPI_HEADER               : in STD_LOGIC_VECTOR (HEADER_BYTES*8-1 downto 0);
        FROM_SPI_HEADER             : in STD_LOGIC_VECTOR (HEADER_BYTES*8-1 downto 0);
        RW_BYTE                     : in STD_LOGIC_VECTOR (7 downto 0);

        SCK_HALF_PERIOD	            : in STD_LOGIC_VECTOR (SCK_HALF_PERIOD_WIDTH-1 downto 0);

        CS                          : out STD_LOGIC;
        SCK                         : out STD_LOGIC;
        MISO                        : in STD_LOGIC;
        MOSI                        : out STD_LOGIC;
        TRISTATE_EN                 : out STD_LOGIC
    );
end SPISerial;

architecture Behavioral of SPISerial is

    signal rx_valid_sig        : std_logic;
    signal spi_ready_sig        : std_logic;
    signal spi_valid_sig        : std_logic;
    signal ready_to_verify_sig  : std_logic;

    signal config_select_sig    : std_logic;
    signal counter_en_sig       : std_logic;
    signal counter_rst_sig      : std_logic;
    signal counter_rst_fsm_sig  : std_logic;
    signal retry_en_sig         : std_logic;
    signal retry_rst_sig        : std_logic;
    signal retry_rst_fsm_sig    : std_logic;
    signal verified_data_sig    : std_logic;
    signal config_done_sig      : std_logic;
    signal verify_done_sig      : std_logic;
    signal retry_sig            : std_logic;
    signal write_sig            : std_logic;

    signal count_sig            : std_logic_vector(COUNTER_WIDTH-1 downto 0);
    signal en_config_sig        : std_logic;
    signal en_verify_sig        : std_logic;
    signal config_out_sig       : std_logic_vector(ADDR_WIDTH+DATA_WIDTH-1 downto 0);
    signal verify_out_sig       : std_logic_vector(ADDR_WIDTH+DATA_WIDTH-1 downto 0);
    signal reg_out_sig          : std_logic_vector(ADDR_WIDTH+DATA_WIDTH-1 downto 0);

    signal spi_out_sig          : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    telemetry: entity work.PacketSerialFullDuplex
        -- Serial baud rate is clk_freq/100
        generic map (
            RX_HEADER_BYTES         => HEADER_BYTES,
            RX_DATA_BYTES           => ADDR_BYTES + DATA_BYTES,
            TX_HEADER_BYTES         => HEADER_BYTES,
            TX_DATA_BYTES           => ADDR_BYTES + DATA_BYTES,
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
            RX_HEADER		        => TO_SPI_HEADER,
            RX_DATA  		        => rx_data_sig,

            -- TX data
            VALID_IN                => spi_valid_sig,
            TX_HEADER		        => FROM_SPI_HEADER,
            TX_DATA  		        => spi_out_sig
        );

    rx_data_reg: entity work.Reg1D
        generic map (
            LENGTH              =>  (ADDR_BYTES + DATA_BYTES) * 8
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,

            PAR_EN              => rx_valid_sig,
            PAR_IN              => rx_data_sig,
            PAR_OUT             => rx_data_reg_sig
        );

    reg_out_sig         <= config_out_sig when (config_select_sig = '1') else verify_out_sig;
    verified_data_sig   <= '1' when (verify_out_sig(DATA_WIDTH-1 downto 0) = spi_out_sig) else '0';

    SPIMaster_module: entity work.SPIMaster
        generic map (
            SCK_HALF_PERIOD_WIDTH   =>  SCK_HALF_PERIOD_WIDTH,
            ADDR_WIDTH              =>  ADDR_WIDTH,
            DATA_WIDTH              =>  DATA_WIDTH,
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
            READY_IN                => ready_to_verify_sig,
            VALID_OUT               => spi_valid_sig,

            -- ADDR & DATA
            ADDR                    => reg_out_sig(ADDR_BYTES*8+DATA_BYTES*8-1 downto DATA_BYTES*8),
            DATA_IN                 => reg_out_sig(DATA_BYTES*8-1 downto 0),
            DATA_OUT                => spi_out_sig,

            -- SPI
            SCK_HALF_PERIOD         => SCK_HALF_PERIOD,
            MISO                    => MISO,
            MOSI                    => MOSI,
            SCK                     => SCK,
            CS                      => CS,
            TRISTATE_EN             => TRISTATE_EN
        );

    VERIFY_ADDR     <= verify_out_sig(ADDR_WIDTH+DATA_WIDTH-1 downto DATA_WIDTH);
    VERIFY_DATA     <= reg_out_sig(DATA_WIDTH-1 downto 0);
    ACTUAL_DATA     <= spi_out_sig;

end Behavioral;

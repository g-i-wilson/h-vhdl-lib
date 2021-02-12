library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MemoryMapPacketSerial is
    generic (
        -- packet header
        HEADER_BYTES		        : positive := 2;
        -- packet data (contains SPI_ADDR, CONTROL, SPI_DATA)
        TRANSACTION_ID_BYTES        : positive := 1;
        MEM_ADDR_BYTES              : positive := 2;
        MEM_DATA_BYTES		        : positive := 1
    );
    port (
        CLK                         : in STD_LOGIC;
        RST                         : in STD_LOGIC;

        -- serial I/O pins
        RX                          : in STD_LOGIC;
        TX                          : out STD_LOGIC;
        
        -- packet ID headers
        READ_HEADER                 : in STD_LOGIC_VECTOR (HEADER_BYTES*8-1 downto 0); -- packet containing ADDRESS bytes
        WRITE_HEADER                : in STD_LOGIC_VECTOR (HEADER_BYTES*8-1 downto 0); -- packet containing ADDRESS & DATA bytes
        RESPONSE_HEADER             : in STD_LOGIC_VECTOR (HEADER_BYTES*8-1 downto 0); -- packet containing DATA bytes

        -- receiving from memory
        VALID_IN                    : in STD_LOGIC;
        READY_OUT                   : out STD_LOGIC;
        
        -- sending to memory
        VALID_OUT                   : out STD_LOGIC;
        READY_IN                    : in STD_LOGIC
    );
end MemoryMapPacketSerial;

architecture Behavioral of MemoryMapPacketSerial is

    signal rx_valid_sig         : std_logic;
    signal MEM_ready_sig        : std_logic;
    signal MEM_valid_sig        : std_logic;

    signal serial_alarm_sig     : std_logic_vector(1 downto 0);

    signal write_sig            : std_logic;

    signal MEM_in_sig           : std_logic_vector((MEM_DATA_BYTES)*8-1 downto 0);
    signal MEM_out_sig          : std_logic_vector((MEM_DATA_BYTES)*8-1 downto 0);
    
    signal rx_data_sig          : std_logic_vector((MEM_CTL_BYTES+MEM_ADDR_BYTES+MEM_DATA_BYTES)*8-1 downto 0);
    signal rx_data_reg_sig      : std_logic_vector((MEM_CTL_BYTES+MEM_ADDR_BYTES+MEM_DATA_BYTES)*8-1 downto 0);
    signal tx_data_sig          : std_logic_vector((MEM_CTL_BYTES+MEM_ADDR_BYTES+MEM_DATA_BYTES)*8-1 downto 0);

begin

    telemetry: entity work.PacketSerialFullDuplex
        -- Serial baud rate is clk_freq/100
        generic map (
            RX_HEADER_BYTES         => HEADER_BYTES,
            RX_DATA_BYTES           => MEM_ADDR_BYTES + MEM_CTL_BYTES + MEM_DATA_BYTES,
            TX_HEADER_BYTES         => HEADER_BYTES,
            TX_DATA_BYTES           => MEM_ADDR_BYTES                 + MEM_DATA_BYTES,
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
            VALID_IN                => MEM_valid_sig,
            TX_HEADER		        => TX_HEADER,
            TX_DATA  		        => tx_data_sig
        );

    rx_data_reg: entity work.Reg1D
        generic map (
            LENGTH              =>  (MEM_ADDR_BYTES + MEM_CTL_BYTES + MEM_DATA_BYTES) * 8
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,

            PAR_EN              => rx_valid_sig,
            PAR_IN              => rx_data_sig,
            PAR_OUT             => rx_data_reg_sig
        );

    -- map addr from input packet to output packet
    MEM_ctl_sig     <= rx_data_reg_sig((MEM_CTL_BYTES + MEM_ADDR_BYTES + MEM_DATA_BYTES)*8-1 downto (MEM_ADDR_BYTES + MEM_DATA_BYTES)*8);
    MEM_addr_sig    <= rx_data_reg_sig((                MEM_ADDR_BYTES + MEM_DATA_BYTES)*8   downto (                 MEM_DATA_BYTES)*8);
    MEM_in_sig      <= rx_data_reg_sig((                                 MEM_DATA_BYTES)*8-1 downto                                   0);
    
    -- write indication when the control byte == 'w'
    write_sig <= '1' when MEM_ctl_sig = x"77" else '0';
    
    -- SPI addr_sig & SPI output
    tx_data_sig     <= MEM_addr_sig & MEM_out_sig;
    
    SPIMaster_module: entity work.SPIMaster
        generic map (
            SCK_HALF_PERIOD_WIDTH   =>  SCK_HALF_PERIOD_WIDTH,
            ADDR_WIDTH              =>  MEM_ADDR_BYTES*8,
            DATA_WIDTH              =>  MEM_DATA_BYTES*8,
            COUNTER_WIDTH           =>  BIT_COUNTER_WIDTH,
            MISO_DETECTOR_SAMPLES   => MISO_DETECTOR_SAMPLES
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,

            -- R/W
            WRITE                   => write_sig,

            -- upstream
            READY_OUT               => MEM_ready_sig,
            VALID_IN                => rx_valid_sig,

            -- downstream
            READY_IN                => '1',
            VALID_OUT               => MEM_valid_sig,

            -- ADDR & DATA
            ADDR                    => MEM_addr_sig,
            DATA_IN                 => MEM_in_sig,
            DATA_OUT                => MEM_out_sig,

            -- SPI
            SCK_HALF_PERIOD         => SCK_HALF_PERIOD,
            MISO                    => MISO,
            MOSI                    => MOSI,
            SCK                     => SCK,
            CS                      => CS,
            TRISTATE_EN             => TRISTATE_EN
        );

end Behavioral;

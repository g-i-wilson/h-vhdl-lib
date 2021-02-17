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

        -- serial
        RX                          : in STD_LOGIC;
        TX                          : out STD_LOGIC;
        
        -- packet
        READ_HEADER                 : in STD_LOGIC_VECTOR (HEADER_BYTES*8-1 downto 0); -- packet containing TRANSACTION_ID & ADDRESS bytes
        WRITE_HEADER                : in STD_LOGIC_VECTOR (HEADER_BYTES*8-1 downto 0); -- packet containing TRANSACTION_ID & ADDRESS & DATA bytes
        RESPONSE_HEADER             : in STD_LOGIC_VECTOR (HEADER_BYTES*8-1 downto 0); -- packet containing TRANSACTION_ID & ADDRESS & DATA bytes

        -- to memory
        MEM_WRITE                   : out STD_LOGIC; -- 1:WRITE, 0:READ
        MEM_ADDR_VALID              : out STD_LOGIC;
        MEM_ADDR                    : out STD_LOGIC_VECTOR (MEM_ADDR_BYTES*8-1 downto 0);
        MEM_DATA_OUT                : out STD_LOGIC_VECTOR (MEM_DATA_BYTES*8-1 downto 0); -- only applicable for WRITE

        -- from memory
        MEM_DATA_VALID              : in STD_LOGIC;
        MEM_DATA_IN                 : in STD_LOGIC_VECTOR (MEM_DATA_BYTES*8-1 downto 0)
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

    SerialRx_module: entity work.SerialRx
        generic map (
            SAMPLE_PERIOD_WIDTH 	=> 1,
            SAMPLE_PERIOD 			=> 1,
            DETECTOR_PERIOD_WIDTH 	=> 4,
            DETECTOR_PERIOD 		=> 16, -- sample detector MA filter
            DETECTOR_LOGIC_HIGH 	=> 12, -- 12..15 is high
            DETECTOR_LOGIC_LOW 		=> 3,  -- 0..3 is low
            BIT_TIMER_WIDTH 		=> 16, -- 868 == 0x0364
            BIT_TIMER_PERIOD 		=> BIT_PERIOD, -- clk_freq/SAMPLE_PERIOD/BIT_PERIOD
            VALID_LAG 				=> BIT_PERIOD/2  -- when to start looking for a VALID signal
        )
        port map (
            CLK 					=> CLK,
            EN 						=> '1',
            RST 					=> RST,
            RX 						=> SERIAL_RX,
            VALID 					=> serial_rx_valid_sig,
            DATA 					=> serial_rx_data_sig,
            ALARM 					=> rx_alarm_sig
        );
        
    RX_ALARM <= rx_alarm_sig;
    
    entity PacketRxBuffered is
        generic (
            SYMBOL_WIDTH            : positive := 8; -- typically a BYTE
            HEADER_SYMBOLS          : positive := 2;
            DATA_SYMBOLS            : positive := 4
        );
        port (
            CLK                     : in std_logic;
            RST                     : in std_logic;
            HEADER                  : in std_logic_vector(SYMBOL_WIDTH*HEADER_SYMBOLS-1 downto 0);
            
            -- upstream
            SYMBOL_IN               : in std_logic_vector(SYMBOL_WIDTH-1 downto 0);
            VALID_IN                : in std_logic;
            READY_OUT               : out std_logic;
            
            -- downstream
            DATA_OUT              	: out std_logic_vector(SYMBOL_WIDTH*DATA_SYMBOLS-1 downto 0);
            VALID_OUT               : out std_logic;
            READY_IN                : in std_logic
        );
    
    entity PacketTxBuffered is
        generic (
            SYMBOL_WIDTH            : positive := 8; -- typically a BYTE
            HEADER_SYMBOLS          : positive := 2;
            DATA_SYMBOLS            : positive := 4
        );
        port (
            CLK                     : in std_logic;
            RST                     : in std_logic;
            HEADER                  : in std_logic_vector(SYMBOL_WIDTH*HEADER_SYMBOLS-1 downto 0);
            
            -- upstream
            DATA_IN                 : in std_logic_vector(SYMBOL_WIDTH*DATA_SYMBOLS-1 downto 0);
            VALID_IN                : in std_logic;
            READY_OUT               : out std_logic;
            
            -- downstream
            SYMBOL_OUT              : out std_logic_vector(SYMBOL_WIDTH-1 downto 0);
            VALID_OUT               : out std_logic;
            READY_IN                : in std_logic
        );



end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


entity PacketSerialRx is
    generic (
        SYMBOL_WIDTH            : positive := 8; -- typically a BYTE
        DATA_SYMBOLS            : positive := 4; -- DATA_SYMBOLS does not include the last checksum symbol
        HEADER_SYMBOLS          : positive := 2;
        
        SAMPLE_PERIOD_WIDTH 	: positive := 1;
        SAMPLE_PERIOD 			: positive := 1;
        DETECTOR_PERIOD_WIDTH 	: positive := 4;
        DETECTOR_PERIOD 		: positive := 16; -- sample detector MA filter
        DETECTOR_LOGIC_HIGH 	: positive := 12; -- 12..15 is high
        DETECTOR_LOGIC_LOW 		: positive := 3;  -- 0..3 is low
        BIT_TIMER_WIDTH 		: positive := 8;
        BIT_TIMER_PERIOD 		: positive := 100; -- clk_freq/sample_period/100
        VALID_LAG 				: positive := 50   -- when to start looking for a VALID signal
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;

        HEADER_IN               : in std_logic_vector(SYMBOL_WIDTH*HEADER_SYMBOLS-1 downto 0);

        VALID_OUT             	: out std_logic;
        DATA_OUT              	: out std_logic_vector(SYMBOL_WIDTH*DATA_SYMBOLS-1 downto 0);

        SERIAL_RX               : in std_logic;
        SERIAL_ALARM			: out std_logic_vector(1 downto 0)
    );
end PacketSerialRx;


architecture Behavioral of PacketSerialRx is

  signal packet_valid_sig       : std_logic;
  signal packet_data_sig        : std_logic_vector(SYMBOL_WIDTH*DATA_SYMBOLS-1 downto 0);

  signal serial_valid_sig       : std_logic;
  signal serial_data_sig        : std_logic_vector(SYMBOL_WIDTH-1 downto 0);

begin    

    SerialRx_module: entity work.SerialRx
        generic map (
            SAMPLE_PERIOD_WIDTH 	=> SAMPLE_PERIOD_WIDTH,
            SAMPLE_PERIOD 			=> SAMPLE_PERIOD,
            DETECTOR_PERIOD_WIDTH 	=> DETECTOR_PERIOD_WIDTH,
            DETECTOR_PERIOD 		=> DETECTOR_PERIOD,
            DETECTOR_LOGIC_HIGH 	=> DETECTOR_LOGIC_HIGH,
            DETECTOR_LOGIC_LOW 		=> DETECTOR_LOGIC_LOW,
            BIT_TIMER_WIDTH 		=> BIT_TIMER_WIDTH,
            BIT_TIMER_PERIOD 		=> BIT_TIMER_PERIOD,
            VALID_LAG 				=> VALID_LAG
        )
        port map (
            CLK 					=> CLK,
            EN 						=> '1',
            RST 					=> RST,
            RX 						=> SERIAL_RX,
            VALID 					=> serial_valid_sig,
            DATA 					=> serial_data_sig,
            ALARM 					=> SERIAL_ALARM
        );
    

    PacketRx_module: entity work.PacketRx
        generic map (
            SYMBOL_WIDTH        => SYMBOL_WIDTH,
            DATA_SYMBOLS      	=> DATA_SYMBOLS,
            HEADER_SYMBOLS      => HEADER_SYMBOLS
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            HEADER_IN           => x"0102",
            SYMBOL_IN           => serial_data_sig,

            VALID_IN            => serial_valid_sig,
            READY_OUT           => open,
            VALID_OUT           => VALID_OUT,
           	READY_IN            => '1',
        
            DATA_OUT            => DATA_OUT
        );

end Behavioral;

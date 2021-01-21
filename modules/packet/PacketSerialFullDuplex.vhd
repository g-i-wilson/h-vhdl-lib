library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


entity PacketSerialFullDuplex is
    -- Serial baud rate is clk_freq/100
    generic (
        RX_HEADER_BYTES         : positive := 2;
        RX_DATA_BYTES           : positive := 8;
        TX_HEADER_BYTES         : positive := 2;
        TX_DATA_BYTES           : positive := 8;
        BIT_PERIOD              : positive := 868 -- default is 115200bps at 100MHz clock
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;
        
        SERIAL_RX               : in std_logic;
        SERIAL_TX               : out std_logic;
        RX_ALARM                : out std_logic_vector(1 downto 0);

		-- RX data
        VALID_OUT               : out std_logic;
        RX_HEADER		        : in std_logic_vector(RX_HEADER_BYTES*8-1 downto 0);
        RX_DATA  		        : out std_logic_vector(RX_DATA_BYTES*8-1 downto 0);
        
		-- TX data
        VALID_IN                : in std_logic;
        TX_HEADER		        : in std_logic_vector(TX_HEADER_BYTES*8-1 downto 0);
        TX_DATA  		        : in std_logic_vector(TX_DATA_BYTES*8-1 downto 0)
    );
end PacketSerialFullDuplex;


architecture Behavioral of PacketSerialFullDuplex is

	-- RX signals
  signal packet_rx_data_sig     : std_logic_vector(RX_DATA_BYTES*8-1 downto 0);
  signal serial_rx_valid_sig    : std_logic;
  signal serial_rx_data_sig     : std_logic_vector(7 downto 0);
  signal rx_header_sig          : std_logic_vector(RX_HEADER_BYTES*8-1 downto 0);
  signal rx_alarm_sig           : std_logic_vector(1 downto 0);

	-- TX signals
  signal fifo_tx_not_valid_sig  : std_logic;
  signal fifo_tx_valid_sig      : std_logic;
  signal packet_tx_ready_sig    : std_logic;
  signal packet_tx_valid_sig    : std_logic;
  signal uart_tx_ready_sig      : std_logic;
  signal fifo_tx_out_sig        : std_logic_vector(TX_DATA_BYTES*8-1 downto 0);
  signal packet_tx_data_sig     : std_logic_vector((TX_DATA_BYTES+TX_HEADER_BYTES)*8-1 downto 0);  -- TX data includes header
  signal packet_tx_symbol_sig   : std_logic_vector(7 downto 0);
  signal tx_header_sig          : std_logic_vector(TX_HEADER_BYTES*8-1 downto 0);


begin    

    ----------------------------------------------
    -- RX
    ----------------------------------------------
    
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
    
    PacketRx_module: entity work.PacketRx
        generic map (
            SYMBOL_WIDTH        => 8,
            DATA_SYMBOLS      	=> 8,
            HEADER_SYMBOLS      => 2
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            HEADER_IN           => RX_HEADER,
            SYMBOL_IN           => serial_rx_data_sig,

            VALID_IN            => serial_rx_valid_sig,
            READY_OUT           => open,
            VALID_OUT           => VALID_OUT,
           	READY_IN            => '1',
        
            DATA_OUT            => RX_DATA
        );


    ----------------------------------------------
    -- TX
    ----------------------------------------------

    FIFO_Tx_module : FIFO_SYNC_MACRO
        generic map (
--            DEVICE              => "7SERIES",               -- Target Device: "VIRTEX5, "VIRTEX6", "7SERIES" 
--            ALMOST_FULL_OFFSET  => X"0080",                 -- Sets almost full threshold
--            ALMOST_EMPTY_OFFSET => X"0080",                 -- Sets the almost empty threshold
            DATA_WIDTH          => TX_DATA_BYTES*8,         -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
            FIFO_SIZE           => "36Kb"                   -- Target BRAM, "18Kb" or "36Kb" 
        )
        port map (
            CLK                 => CLK,                     -- 1-bit input clock
            RST                 => RST,                     -- 1-bit input reset
            -- input path
            DI                  => TX_DATA,                 -- Input data, width defined by DATA_WIDTH parameter
            WREN                => VALID_IN,                -- 1-bit input write enable
            -- output path
            DO                  => fifo_tx_out_sig,         -- Output data, width defined by DATA_WIDTH parameter
            RDEN                => packet_tx_ready_sig,       -- 1-bit input read enable
            EMPTY               => fifo_tx_not_valid_sig    -- 1-bit output empty
        );
        
    process (CLK) begin
        if rising_edge(CLK) then
            if packet_tx_ready_sig='1' then
                fifo_tx_valid_sig <= not fifo_tx_not_valid_sig;
            end if;
        end if;
    end process;
    
    packet_tx_data_sig <= TX_HEADER & fifo_tx_out_sig;

    PacketTx_module: entity work.PacketTx
        generic map (
            SYMBOL_WIDTH        => 8,
            PACKET_SYMBOLS      => 8+2
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            PACKET_IN           => packet_tx_data_sig,

            VALID_IN            => fifo_tx_valid_sig,            
            READY_OUT           => packet_tx_ready_sig,
            VALID_OUT           => packet_tx_valid_sig,
            READY_IN            => uart_tx_ready_sig,
            
            SYMBOL_OUT          => packet_tx_symbol_sig
        );
    
    TX_module: entity work.SerialTx
        port map (
            -- inputs
            CLK                 => CLK,
            EN                  => '1',
            RST                 => RST,
            BIT_TIMER_PERIOD    => std_logic_vector(to_unsigned(BIT_PERIOD-1, 16)), -- x"0363" or 867, 100MHz/(867+1) = 115200 Hz
            VALID               => packet_tx_valid_sig,
            DATA                => packet_tx_symbol_sig,
            -- outputs
            READY               => uart_tx_ready_sig,
            TX                  => SERIAL_TX
        );

--    ILA : entity work.ila_PacketSerialFullDuplex
--    port map (
--        clk             => CLK,
--        probe0(0)       => VALID_IN,
--        probe1          => TX_DATA,
--        probe2(0)       => fifo_tx_valid_sig,
--        probe3          => fifo_tx_out_sig,
--        probe4(0)       => packet_tx_ready_sig,
--        probe5          => rx_alarm_sig
--    );


end Behavioral;

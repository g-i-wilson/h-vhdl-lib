library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


entity FIFOPacketSerialTx is
    generic (
        SYMBOL_WIDTH            : positive := 8; -- typically a BYTE
        PACKET_SYMBOLS          : positive := 4; -- PACKET_SYMBOLS does not include the last checksum symbol
        HEADER_SYMBOLS          : positive := 2
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;

        VALID_IN                : in std_logic;
        HEADER_IN               : in std_logic_vector(SYMBOL_WIDTH*HEADER_SYMBOLS-1 downto 0);
        DATA_IN                 : in std_logic_vector(SYMBOL_WIDTH*PACKET_SYMBOLS-1 downto 0);

        SERIAL_PERIOD           : in std_logic_vector(15 downto 0);
        SERIAL_TX               : out std_logic
    );
end FIFOPacketSerialTx;


architecture Behavioral of FIFOPacketSerialTx is

  signal fifo_tx_ready_sig            : std_logic;
  signal fifo_tx_not_valid_sig            : std_logic;
  signal fifo_tx_valid_sig            : std_logic;
  signal packet_tx_ready_sig            : std_logic;
  signal packet_tx_valid_sig            : std_logic;
  signal uart_tx_ready_sig            : std_logic;

  signal fifo_tx_data_sig          : std_logic_vector(SYMBOL_WIDTH*PACKET_SYMBOLS-1 downto 0);
  signal packet_tx_data_sig          : std_logic_vector(SYMBOL_WIDTH*(PACKET_SYMBOLS+HEADER_SYMBOLS)-1 downto 0);
  signal packet_tx_symbol_sig          : std_logic_vector(SYMBOL_WIDTH-1 downto 0);

begin    

    FIFO_Tx_module : FIFO_SYNC_MACRO
    generic map (
--        DEVICE              => "7SERIES",             -- Target Device: "VIRTEX5, "VIRTEX6", "7SERIES" 
--        ALMOST_FULL_OFFSET  => X"0080",               -- Sets almost full threshold
--        ALMOST_EMPTY_OFFSET => X"0080",               -- Sets the almost empty threshold
        DATA_WIDTH          => 32                    -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
--        FIFO_SIZE           => "18Kb"               -- Target BRAM, "18Kb" or "36Kb" 
    )
    port map (
        CLK                 => CLK,                 -- 1-bit input clock
        RST                 => RST,                 -- 1-bit input reset
        -- input path
        DI                  => DATA_IN,        -- Input data, width defined by DATA_WIDTH parameter
        WREN                => VALID_IN,       -- 1-bit input write enable
        -- output path
        DO                  => fifo_tx_data_sig,       -- Output data, width defined by DATA_WIDTH parameter
        RDEN                => fifo_tx_ready_sig,        -- 1-bit input read enable
        EMPTY               => fifo_tx_not_valid_sig   -- 1-bit output empty
    );
    
    fifo_tx_valid_sig <= not fifo_tx_not_valid_sig;
    packet_tx_data_sig <= HEADER_IN & fifo_tx_data_sig;

    PacketTx_module: entity work.PacketTx
        generic map (
            SYMBOL_WIDTH        => SYMBOL_WIDTH,
            PACKET_SYMBOLS      => PACKET_SYMBOLS + HEADER_SYMBOLS
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
            BIT_TIMER_PERIOD    => SERIAL_PERIOD,
            VALID               => packet_tx_valid_sig,
            DATA                => packet_tx_symbol_sig,
            -- outputs
            READY               => uart_tx_ready_sig,
            TX                  => SERIAL_TX
        );

end Behavioral;

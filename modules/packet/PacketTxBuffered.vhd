library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


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
end PacketTxBuffered;


architecture Behavioral of PacketTxBuffered is

  signal fifo_tx_data_sig               : std_logic_vector(SYMBOL_WIDTH*DATA_SYMBOLS-1 downto 0);
  signal fifo_tx_valid_sig              : std_logic;
  signal packet_tx_ready_sig            : std_logic;

  signal packet_tx_sig                  : std_logic_vector(SYMBOL_WIDTH*(HEADER_SYMBOLS+DATA_SYMBOLS)-1 downto 0);

begin    

    FIFO_module: entity work.SimpleFIFO
          generic map (
              DATA_WIDTH              => SYMBOL_WIDTH*DATA_SYMBOLS
          )
          port map (
              CLK                     => CLK,
              RST                     => RST,
              
              -- upstream
              DATA_IN					        => DATA_IN,
              VALID_IN                => VALID_IN,
              READY_OUT               => READY_OUT,
              
              -- downstream
              DATA_OUT				  => fifo_tx_data_sig,
              VALID_OUT               => fifo_tx_valid_sig,
              READY_IN                => packet_tx_ready_sig
              
          );

    packet_tx_sig <= HEADER & fifo_tx_data_sig;

    PacketTx_module: entity work.PacketTx
        generic map (
            SYMBOL_WIDTH        => SYMBOL_WIDTH,
            PACKET_SYMBOLS      => HEADER_SYMBOLS + DATA_SYMBOLS
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            PACKET_IN           => packet_tx_sig,

            VALID_IN            => fifo_tx_valid_sig,            
            READY_OUT           => packet_tx_ready_sig,
            
            VALID_OUT           => VALID_OUT,
            READY_IN            => READY_IN,
            
            SYMBOL_OUT          => SYMBOL_OUT
        );
    

end Behavioral;

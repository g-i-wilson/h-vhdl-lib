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

  signal data_frame_sig             : std_logic_vector(SYMBOL_WIDTH*DATA_SYMBOLS-1 downto 0);
  signal fifo_valid_sig             : std_logic;
  signal packet_ready_sig           : std_logic;
  signal packet_sig                 : std_logic_vector(SYMBOL_WIDTH*(HEADER_SYMBOLS+DATA_SYMBOLS)-1 downto 0);

begin

    FIFO_module: entity work.SimpleFIFO
          generic map (
              DATA_WIDTH                => SYMBOL_WIDTH*DATA_SYMBOLS
          )
          port map (
              CLK                       => CLK,
              RST                       => RST,
              
              -- upstream data frame
              DATA_IN                   => DATA_IN,
              VALID_IN                  => VALID_IN,
              READY_OUT                 => READY_OUT,
              
              -- downstream data frame
              DATA_OUT                  => data_frame_sig,
              VALID_OUT                 => fifo_valid_sig,
              READY_IN                  => packet_ready_sig
              
          );

    packet_sig <= HEADER & data_frame_sig;

    PacketTx_module: entity work.PacketTx
        generic map (
            SYMBOL_WIDTH        => SYMBOL_WIDTH,
            PACKET_SYMBOLS      => HEADER_SYMBOLS + DATA_SYMBOLS
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            -- upstream packet (header & data-frame)
            PACKET_IN           => packet_sig,
            VALID_IN            => fifo_valid_sig,            
            READY_OUT           => packet_ready_sig,
            
            -- downstream symbol
            SYMBOL_OUT          => SYMBOL_OUT,
            VALID_OUT           => VALID_OUT,
            READY_IN            => READY_IN          
        );
    

end Behavioral;

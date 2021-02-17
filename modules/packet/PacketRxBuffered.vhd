library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


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
end PacketRxBuffered;


architecture Behavioral of PacketRxBuffered is

  signal data_frame_sig                 : std_logic_vector(SYMBOL_WIDTH*DATA_SYMBOLS-1 downto 0);
  signal packet_valid_sig               : std_logic;
  signal fifo_ready_sig                 : std_logic;

begin

    PacketRx_module: entity work.PacketRx
        generic map (
            SYMBOL_WIDTH        => SYMBOL_WIDTH,
            HEADER_SYMBOLS      => HEADER_SYMBOLS,
            DATA_SYMBOLS      	=> DATA_SYMBOLS
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,            
            HEADER_IN           => HEADER,

            -- upstream symbol
            SYMBOL_IN           => SYMBOL_IN,
            VALID_IN            => VALID_IN,
            READY_OUT           => READY_OUT,

            -- downstream data frame
            DATA_OUT            => data_frame_sig,
            VALID_OUT           => packet_valid_sig,
           	READY_IN            => fifo_ready_sig
        );

    FIFO_module: entity work.SimpleFIFO
          generic map (
              DATA_WIDTH                => SYMBOL_WIDTH*DATA_SYMBOLS
          )
          port map (
              CLK                       => CLK,
              RST                       => RST,
              
              -- upstream data frame
              DATA_IN                   => data_frame_sig,
              VALID_IN                  => packet_valid_sig,
              READY_OUT                 => fifo_ready_sig,
              
              -- downstream data frame
              DATA_OUT                  => DATA_OUT,
              VALID_OUT                 => VALID_OUT,
              READY_IN                  => READY_IN
              
          );


end Behavioral;

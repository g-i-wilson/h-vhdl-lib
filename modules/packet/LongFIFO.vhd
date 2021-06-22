library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


entity LongFIFO is
    generic (
        DATA_WIDTH              : positive := 8;
        FIFO_SEGMENTS           : positive := 4 -- 36kB each segment
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;
        
        -- upstream
        DATA_IN					: in std_logic_vector(DATA_WIDTH-1 downto 0);
        VALID_IN                : in STD_LOGIC;
        READY_OUT               : out STD_LOGIC;
        
        -- downstream
        DATA_OUT				: out std_logic_vector(DATA_WIDTH-1 downto 0);
        VALID_OUT               : out STD_LOGIC;
        READY_IN                : in STD_LOGIC
        
    );
end LongFIFO;


architecture Behavioral of LongFIFO is

  -- provides parallel signals between each FIFO
  signal data_interconnect_sig : std_logic_vector((DATA_WIDTH*(FIFO_SEGMENTS-1))-1 downto 0);
  signal valid_interconnect_sig : std_logic_vector((FIFO_SEGMENTS-1)-1 downto 0);
  signal ready_interconnect_sig : std_logic_vector((FIFO_SEGMENTS-1)-1 downto 0);

  begin
        
    gen_first: if (FIFO_SEGMENTS > 1) generate
        first_FIFO: entity work.SimpleFIFO
          generic map (
              DATA_WIDTH                => DATA_WIDTH
          )
          port map (
              CLK                       => CLK,
              RST                       => RST,
              
              -- upstream data frame
              DATA_IN                   => DATA_IN,
              VALID_IN                  => VALID_IN,
              READY_OUT                 => READY_OUT,
              
              -- downstream data frame
              DATA_OUT                  => data_interconnect_sig(DATA_WIDTH-1 downto 0),
              VALID_OUT                 => valid_interconnect_sig(0),
              READY_IN                  => ready_interconnect_sig(0)
              
          );
    end generate gen_first;

    gen_middle : for i in 0 to (FIFO_SEGMENTS-3) generate -- LENGTH 5 segments is: in,0,1,2,out
        middle_FIFO: entity work.SimpleFIFO
          generic map (
              DATA_WIDTH                => DATA_WIDTH
          )
          port map (
              CLK                       => CLK,
              RST                       => RST,
              
              -- upstream data frame
              DATA_IN                   => data_interconnect_sig  ((i+1)*DATA_WIDTH -1 downto (i  )*DATA_WIDTH),
              VALID_IN                  => valid_interconnect_sig ( i   ),
              READY_OUT                 => ready_interconnect_sig ( i   ),
              
              -- downstream data frame
              DATA_OUT                  => data_interconnect_sig  ((i+2)*DATA_WIDTH -1 downto (i+1)*DATA_WIDTH),
              VALID_OUT                 => valid_interconnect_sig ( i+1 ),
              READY_IN                  => ready_interconnect_sig ( i+1 )
              
          );
    end generate gen_middle;

    gen_last: if (FIFO_SEGMENTS >= 2) generate
        last_FIFO: entity work.SimpleFIFO
          generic map (
              DATA_WIDTH                => DATA_WIDTH
          )
          port map (
              CLK                       => CLK,
              RST                       => RST,
              
              -- upstream data frame
              DATA_IN                   => data_interconnect_sig  ((FIFO_SEGMENTS-1)*DATA_WIDTH -1 downto (FIFO_SEGMENTS-2)*DATA_WIDTH),
              VALID_IN                  => valid_interconnect_sig ((FIFO_SEGMENTS-1)            -1),
              READY_OUT                 => ready_interconnect_sig ((FIFO_SEGMENTS-1)            -1),
              
              -- downstream data frame
              DATA_OUT                  => DATA_OUT,
              VALID_OUT                 => VALID_OUT,
              READY_IN                  => READY_IN
              
          );
    end generate gen_last;

end Behavioral;

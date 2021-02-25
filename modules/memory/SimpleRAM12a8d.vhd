library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


entity SimpleRAM12a8d is
    port (
        CLK                         : in STD_LOGIC;
        RST                         : in STD_LOGIC;
        
        ADDR                        : in STD_LOGIC_VECTOR(11 downto 0);
        WRITE                       : in STD_LOGIC;

        DATA_IN                     : in STD_LOGIC_VECTOR(7 downto 0);
        DATA_OUT                    : out STD_LOGIC_VECTOR(7 downto 0);
        
        VALID_IN                    : in STD_LOGIC;
        READY_OUT                   : out STD_LOGIC;
        
        VALID_OUT                   : out STD_LOGIC;
        READY_IN                    : in STD_LOGIC
    );
end SimpleRAM12a8d;

architecture Behavioral of SimpleRAM12a8d is

    signal ready_out_sig    : std_logic;
    signal valid_out_sig    : std_logic;
    signal ram_en_sig       : std_logic;
    signal ram_regce_sig    : std_logic;
    
begin

    SimpleRAMFSM_module: entity work.SimpleRAMFSM
        port map ( 
            CLK                         => CLK,
            RST                         => RST,
            
            WRITE                       => WRITE,
    
            VALID_IN                    => VALID_IN,
            READY_OUT                   => ready_out_sig,
            
            VALID_OUT                   => valid_out_sig,
            READY_IN                    => READY_IN
        );
        
    VALID_OUT       <= valid_out_sig;
    
    READY_OUT       <= ready_out_sig;
    
    ram_en_sig      <= ready_out_sig and VALID_IN;
    ram_regce_sig   <= ready_out_sig and VALID_IN and not WRITE;


   -- BRAM_SINGLE_MACRO: Single Port RAM
   --                    Artix-7
   -- Xilinx HDL Language Template, version 2020.1

   -- Note -  This Unimacro model assumes the port directions to be "downto". 
   --         Simulation of this model with "to" in the port directions could lead to erroneous results.

   ---------------------------------------------------------------------
   --  READ_WIDTH | BRAM_SIZE | READ Depth  | ADDR Width |            --
   -- WRITE_WIDTH |           | WRITE Depth |            |  WE Width  --
   -- ============|===========|=============|============|============--
   --    37-72    |  "36Kb"   |      512    |    9-bit   |    8-bit   --
   --    19-36    |  "36Kb"   |     1024    |   10-bit   |    4-bit   --
   --    19-36    |  "18Kb"   |      512    |    9-bit   |    4-bit   --
   --    10-18    |  "36Kb"   |     2048    |   11-bit   |    2-bit   --
   --    10-18    |  "18Kb"   |     1024    |   10-bit   |    2-bit   --
   --     5-9     |  "36Kb"   |     4096    |   12-bit   |    1-bit   --
   --     5-9     |  "18Kb"   |     2048    |   11-bit   |    1-bit   --
   --     3-4     |  "36Kb"   |     8192    |   13-bit   |    1-bit   --
   --     3-4     |  "18Kb"   |     4096    |   12-bit   |    1-bit   --
   --       2     |  "36Kb"   |    16384    |   14-bit   |    1-bit   --
   --       2     |  "18Kb"   |     8192    |   13-bit   |    1-bit   --
   --       1     |  "36Kb"   |    32768    |   15-bit   |    1-bit   --
   --       1     |  "18Kb"   |    16384    |   14-bit   |    1-bit   --
   ---------------------------------------------------------------------

   BRAM_SINGLE_MACRO_inst : BRAM_SINGLE_MACRO
       generic map (
          BRAM_SIZE         => "36Kb",                      -- Target BRAM, "18Kb" or "36Kb" 
          --DEVICE            => "7SERIES",                   -- Target Device: "VIRTEX5", "7SERIES", "VIRTEX6, "SPARTAN6" 
          --DO_REG            => 0,                           -- Optional output register (0 or 1)
          --INIT              => X"000000000000000000",       --  Initial values on output port
          --INIT_FILE         => "NONE",
          WRITE_WIDTH       => 8,                           -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
          READ_WIDTH        => 8,                           -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
          --SRVAL             => X"000000000000000000",       -- Set/Reset value for port output
          WRITE_MODE        => "WRITE_FIRST"                -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE" 
       )
       port map (
          DO                => DATA_OUT,                    -- Output data, width defined by READ_WIDTH parameter
          ADDR              => ADDR,                        -- Input address, width defined by read/write port depth
          CLK               => CLK,                         -- 1-bit input clock
          DI                => DATA_IN,                     -- Input data port, width defined by WRITE_WIDTH parameter
          EN                => ram_en_sig,                  -- 1-bit input RAM enable
          REGCE             => ram_regce_sig,               -- 1-bit input output register enable
          RST               => RST,                         -- 1-bit input reset
          WE(0)             => WRITE                        -- Input write enable, width defined by write port depth
       );

end Behavioral;

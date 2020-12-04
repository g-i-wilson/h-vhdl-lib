----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/07/2020 02:09:24 PM
-- Design Name: 
-- Module Name: adc_simple - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity adc_simple is
    generic (
        sample_rate_width : positive := 16
    );
    port (
        clk : in STD_LOGIC;
        en : in STD_LOGIC;
        rst : in STD_LOGIC;
        sample_rate : in STD_LOGIC_VECTOR (sample_rate_width-1 downto 0);
        data : out STD_LOGIC_VECTOR (11 downto 0)
    );
end adc_simple;

architecture Behavioral of adc_simple is

begin


   XADC_inst : XADC
   generic map (
      -- INIT_40 - INIT_42: XADC configuration registers
      INIT_40 => X"0000",
      INIT_41 => X"0000",
      INIT_42 => X"0800",
      -- INIT_48 - INIT_4F: Sequence Registers
      INIT_48 => X"0000",
      INIT_49 => X"0000",
      INIT_4A => X"0000",
      INIT_4B => X"0000",
      INIT_4C => X"0000",
      INIT_4D => X"0000",
      INIT_4F => X"0000",
      INIT_4E => X"0000",                 -- Sequence register 6
      -- INIT_50 - INIT_58, INIT5C: Alarm Limit Registers
      INIT_50 => X"0000",
      INIT_51 => X"0000",
      INIT_52 => X"0000",
      INIT_53 => X"0000",
      INIT_54 => X"0000",
      INIT_55 => X"0000",
      INIT_56 => X"0000",
      INIT_57 => X"0000",
      INIT_58 => X"0000",
      INIT_5C => X"0000",
      -- Simulation attributes: Set for proper simulation behavior
      SIM_DEVICE => "7SERIES",            -- Select target device (values)
      SIM_MONITOR_FILE => "design.txt"  -- Analog simulation data file name
   )
   port map (
      -- ALARMS: 8-bit (each) output: ALM, OT
      ALM => ALM,                   -- 8-bit output: Output alarm for temp, Vccint, Vccaux and Vccbram
      OT => OT,                     -- 1-bit output: Over-Temperature alarm
      -- Dynamic Reconfiguration Port (DRP): 16-bit (each) output: Dynamic Reconfiguration Ports
      DO => DO,                     -- 16-bit output: DRP output data bus
      DRDY => DRDY,                 -- 1-bit output: DRP data ready
      -- STATUS: 1-bit (each) output: XADC status ports
      BUSY => BUSY,                 -- 1-bit output: ADC busy output
      CHANNEL => CHANNEL,           -- 5-bit output: Channel selection outputs
      EOC => EOC,                   -- 1-bit output: End of Conversion
      EOS => EOS,                   -- 1-bit output: End of Sequence
      JTAGBUSY => JTAGBUSY,         -- 1-bit output: JTAG DRP transaction in progress output
      JTAGLOCKED => JTAGLOCKED,     -- 1-bit output: JTAG requested DRP port lock
      JTAGMODIFIED => JTAGMODIFIED, -- 1-bit output: JTAG Write to the DRP has occurred
      MUXADDR => MUXADDR,           -- 5-bit output: External MUX channel decode
      -- Auxiliary Analog-Input Pairs: 16-bit (each) input: VAUXP[15:0], VAUXN[15:0]
      VAUXN => VAUXN,               -- 16-bit input: N-side auxiliary analog input
      VAUXP => VAUXP,               -- 16-bit input: P-side auxiliary analog input
      -- CONTROL and CLOCK: 1-bit (each) input: Reset, conversion start and clock inputs
      CONVST => CONVST,             -- 1-bit input: Convert start input
      CONVSTCLK => CONVSTCLK,       -- 1-bit input: Convert start input
      RESET => RESET,               -- 1-bit input: Active-high reset
      -- Dedicated Analog Input Pair: 1-bit (each) input: VP/VN
      VN => VN,                     -- 1-bit input: N-side analog input
      VP => VP,                     -- 1-bit input: P-side analog input
      -- Dynamic Reconfiguration Port (DRP): 7-bit (each) input: Dynamic Reconfiguration Ports
      DADDR => DADDR,               -- 7-bit input: DRP address bus
      DCLK => DCLK,                 -- 1-bit input: DRP clock
      DEN => DEN,                   -- 1-bit input: DRP enable signal
      DI => DI,                     -- 16-bit input: DRP input data bus
      DWE => DWE                    -- 1-bit input: DRP write enable
   );




end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/29/2020 03:40:55 PM
-- Design Name: 
-- Module Name: test_fun_gen - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity test_fun_gen is
    port ( 
        clk : in STD_LOGIC;
        JXADC : out STD_LOGIC_VECTOR (7 downto 0)
    );
end test_fun_gen;


architecture Behavioral of test_fun_gen is

    -- FPGA clocking only; disable for simulation
    signal mmcm_clk : std_logic;
    signal clkfb_loopback : std_logic;
    signal lock_sig : std_logic;
    signal out_sig : std_logic_vector(0 downto 0);
    
    signal rst, en_sig : std_logic;

    signal sw_sig : std_logic_vector(15 downto 0);
    signal sample_period_sig : std_logic_vector(15 downto 0);
    signal half_period_sig : std_logic_vector(31 downto 0);


begin

--    sample_period_sig <= x"C350";
--    half_period_const_sig <= x"0008";
    
    rst <= not lock_sig;
    
    JXADC(3 downto 2) <= out_sig(0 downto 0) & not out_sig(0 downto 0);
    
    test_vals0: entity work.test_values
    generic map (
        in_width => 32,
        period_width => 32
    )
    port map (
           clk => mmcm_clk,
           rst => rst,
           period => x"17D78400", -- 100MHz/0.25Hz
           start_val => x"0000C350",
           mult_val => x"00000002",
           test_out => half_period_sig
    );

    

    fun0: entity work.fun_gen
    generic map (
        half_period_width => 32,
        sample_period_width => 16,
        pdm_period_width => 8,
        pdm_out_width => 1
    )
    port map (
        clk => mmcm_clk,
        en => '1',
        rst => rst,
        half_period => half_period_sig,
        sample_period => x"30D4",
        pdm_period => x"64",
        pdm_out => out_sig(0 downto 0),
        conv_pattern => x"020913202C363D403D362C20130902" -- approximates a sin wive
    );

   MMCME2_BASE_inst : MMCME2_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F => 10.0,    -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD => 10.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT1_DIVIDE => 10,
      CLKOUT2_DIVIDE => 1,
      CLKOUT3_DIVIDE => 1,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      CLKOUT6_DIVIDE => 1,
      CLKOUT0_DIVIDE_F => 1.0,   -- Divide amount for CLKOUT0 (1.000-128.000).
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      CLKOUT6_PHASE => 0.0,
      CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      DIVCLK_DIVIDE => 1,        -- Master division value (1-106)
      REF_JITTER1 => 0.0,        -- Reference input jitter in UI (0.000-0.999).
      STARTUP_WAIT => FALSE      -- Delays DONE until MMCM is locked (FALSE, TRUE)
   )
   port map (
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => clkfb_loopback,
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT1 => mmcm_clk,     -- 1-bit output: CLKOUT1
      -- Status Ports: 1-bit (each) output: MMCM status ports
      LOCKED => lock_sig,       -- 1-bit output: LOCK
      -- Clock Inputs: 1-bit (each) input: Clock input
      CLKIN1 => clk,       -- 1-bit input: Clock
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN => '0',       -- 1-bit input: Power-down
      RST => '0',             -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => clkfb_loopback      -- 1-bit input: Feedback clock
   );



end Behavioral;

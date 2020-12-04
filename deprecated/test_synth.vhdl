----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2020 12:47:15 PM
-- Design Name: 
-- Module Name: test_synth - Behavioral
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity test_synth is
    port (
        clk : in std_logic;
        sw : in STD_LOGIC_VECTOR (15 downto 0);
        led : out STD_LOGIC_VECTOR (15 downto 0)

        -- debug outputs for simulation only
--        ;
--        shift_reg_debug : out std_logic_vector (27 downto 0);
--        mult_reg_debug : out std_logic_vector (63 downto 0);
--        encoded_debug : out std_logic_vector (3 downto 0);
--        filtered_debug : out std_logic_vector (19 downto 0)
    );
end test_synth;



architecture Behavioral of test_synth is

    
    -- FPGA clocking only; disable for simulation
    signal mmcm_clk : std_logic;
    signal clkfb_loopback : std_logic;
    signal lock_sig : std_logic;
    
    signal rst, en_sig : std_logic;
    signal sw_sig : std_logic_vector (15 downto 0);
    signal encoder_sig : std_logic_vector (3 downto 0);
    signal filter_in_sig : std_logic_vector (7 downto 0);
    signal filter_out_sig : std_logic_vector (19 downto 0);
    signal pdm_in_sig : std_logic_vector (12 downto 0);
    signal pdm_out_sig : std_logic_vector (3 downto 0);
    signal decoder_sig : std_logic_vector (15 downto 0);

begin

--   filtered_debug <= filter_out_sig; -- simulation debug only
--   encoded_debug <= encoder_sig; -- simulation debug only

   rst <= '0';
   
   filter_in_sig <= "0000" & encoder_sig;
   pdm_in_sig <= filter_out_sig(12 downto 0);

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

   clk_div : entity work.clk_div_generic
        generic map (
            period_width => 28
--            period_width => 8 -- simulation debug only
        )
        port map (
            period => x"1312D00", -- 100MHz/5Hz
--            period => x"0F", -- simulation debug only
            clk => mmcm_clk,
--            clk => clk, -- simulation debug only
            en => '1',
            rst => rst,
            en_out => en_sig
        );
        
    reg_sw : entity work.reg_generic
        generic map (
            reg_len => 16
        )
        port map (
            clk => mmcm_clk,
--            clk => clk, -- simulation debug only
            en => '1',
            rst => rst,
            reg_in => sw,
            reg_out => sw_sig
        );


    encode : entity work.encoder
        port map (
            level_in => sw_sig,
            nibble_out => encoder_sig,
            en => '1'
        );
    
    filter : entity work.shift_mult_generic
        generic map (
            length => 15,
            width => 8,
            padding => 4
        )
        port map (
            shift_in => filter_in_sig,
            sum_out => filter_out_sig,
            clk => mmcm_clk,
--            clk => clk, -- simulation debug only
            en => en_sig,
            rst => rst,
            coef_in => x"020913202C363D403D362C20130902"
--            par_out => shift_reg_debug,
--            mult_out => mult_reg_debug
        );
        
    PDM: entity work.pdm_generic
        generic map (
            input_width => 13,
            output_width => 4,
            pulse_count_width => 20
--            pulse_count_width => 4 -- simulation debug only
        )
        port map (
            input => pdm_in_sig,
            output => pdm_out_sig,
            pulse_length => x"186A0", -- 100MHz/1kHz
--            pulse_length => x"1", -- simulation debug only
            clk => mmcm_clk,
--            clk => clk, -- simulation debug only
            en => '1',
            rst => rst
        );
    
    
    decode : entity work.decoder
        port map (
            nibble_in => pdm_out_sig,
            level_out => decoder_sig,
            en => '1'
        );
        
    reg_led : entity work.reg_generic
        generic map (
            reg_len => 16
        )
        port map (
            clk => mmcm_clk,
--            clk => clk, -- simulation debug only
            en => '1',
            rst => rst,
            reg_in => decoder_sig,
            reg_out => led
        );


end Behavioral;

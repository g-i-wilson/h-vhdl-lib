----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/05/2020 08:49:32 AM
-- Design Name: 
-- Module Name: diff_out_test - Behavioral
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

entity diff_out_test is
    port (
        clk : in STD_LOGIC;
        XA1_P, XA1_N, XA4_P, XA4_N : out STD_LOGIC;
        led_0 : out STD_LOGIC
    );
end diff_out_test;

architecture Behavioral of diff_out_test is

    -- FPGA clocking only; disable for simulation
    signal mmcm_clk : std_logic;
    signal clkfb_loopback : std_logic;
    signal lock_sig : std_logic;
    signal fast_sig, slow_sig : std_logic_vector(0 downto 0);
    
    signal rst : std_logic;

    signal led_sig : std_logic;


begin

    rst <= not lock_sig;
    
    led_0 <= led_sig;
    
    XA4_P <= slow_sig(0);
    XA4_N <= not slow_sig(0);
    
    XA1_P <= fast_sig(0);
    XA1_N <= not fast_sig(0);

--    process (mmcm_clk) begin
--        if rising_edge(mmcm_clk) then
--            if (rst = '1') then
--                fast_sig <= '0';
--            else
--                fast_sig <= not fast_sig;
--            end if;
--        end if;
--    end process;
    

    
--    slow_sq: entity work.square_wave_gen
--    generic map (
--        half_period_width => 16
--    )
--    port map (
--        clk => mmcm_clk,
--        en => '1',
--        rst => rst,
--        half_period => x"36B0",
--        sq_out => slow_sig
--    );

      low_freq: entity work.fun_gen_sr
      generic map (
        sample_period_width => 20,
        pdm_period_width => 12,
        pattern_width => 16,
        pattern_length => 64
      )
      port map (
        clk => clk,
        rst => rst,
        repeat_pattern =>
                            x"3FFF" &
                            x"4644" &
                            x"4C7B" &
                            x"5292" &
                            x"587C" &
                            x"5E29" &
                            x"638C" &
                            x"6898" &
                            x"6D3F" &
                            x"7177" &
                            x"7534" &
                            x"786F" &
                            x"7B1E" &
                            x"7D3C" &
                            x"7EC3" &
                            x"7FAF" &
                            x"7FFE" &
                            x"7FAF" &
                            x"7EC3" &
                            x"7D3C" &
                            x"7B1E" &
                            x"786F" &
                            x"7534" &
                            x"7177" &
                            x"6D3F" &
                            x"6898" &
                            x"638C" &
                            x"5E29" &
                            x"587C" &
                            x"5292" &
                            x"4C7B" &
                            x"4644" &
                            x"3FFF" &
                            x"39B9" &
                            x"3382" &
                            x"2D6B" &
                            x"2781" &
                            x"21D4" &
                            x"1C71" &
                            x"1765" &
                            x"12BE" &
                            x"0E86" &
                            x"0AC9" &
                            x"078E" &
                            x"04DF" &
                            x"02C1" &
                            x"013A" &
                            x"004E" &
                            x"0000" &
                            x"004E" &
                            x"013A" &
                            x"02C1" &
                            x"04DF" &
                            x"078E" &
                            x"0AC9" &
                            x"0E86" &
                            x"12BE" &
                            x"1765" &
                            x"1C71" &
                            x"21D4" &
                            x"2781" &
                            x"2D6B" &
                            x"3382" &
                            x"39B9",
        sample_period => x"445C0",
        pdm_period => x"AF0",
        pdm_out => slow_sig
      );

    low_freq_led: entity work.square_wave_gen
        generic map (
            half_period_width => 28
        )
        port map (
            clk => mmcm_clk,
            rst => rst,
            half_period => x"1AB3F00",
            sq_out => led_sig
        );


--    led_sq: entity work.square_wave_gen
--    generic map (
--        half_period_width => 28
--    )
--    port map (
--        clk => mmcm_clk,
--        en => '1',
--        rst => rst,
--        half_period => x"42C1D80",
--        sq_out => led_sig
--    );

      high_freq: entity work.fun_gen_sr
      generic map (
        sample_period_width => 8,
        pdm_period_width => 4,
        pattern_length => 8,
        pattern_width => 16
      )
      port map (
        clk => mmcm_clk,
        rst => rst,
        sample_period => x"10",
        pdm_period => x"1",
        repeat_pattern =>   x"3FFF" &
                            x"6D3F" &
                            x"7FFE" &
                            x"6D3F" &
                            x"3FFF" &
                            x"12BE" &
                            x"0000" &
                            x"12BE" ,
       pdm_out => fast_sig
      );


    
   
--   fast_OBUFDS : OBUFDS
--   generic map (
--      IOSTANDARD => "LVCMOS25", -- Specify the output I/O standard
--      SLEW => "FAST" -- Specify the output slew rate
--   )          
--   port map (
--      O => XA1_P,     -- Diff_p output (connect directly to top-level port)
--      OB => XA1_N,   -- Diff_n output (connect directly to top-level port)
--      I => fast_sig      -- Buffer input 
--   );
    
--   slow_OBUFDS : OBUFDS
--   generic map (
--      IOSTANDARD => "LVCMOS25", -- Specify the output I/O standard
--      SLEW => "SLOW" -- Specify the output slew rate
--   )          
--   port map (
--      O => XA3_P,     -- Diff_p output (connect directly to top-level port)
--      OB => XA3_N,   -- Diff_n output (connect directly to top-level port)
--      I => slow_sig      -- Buffer input 
--   );


   MMCME2_BASE_inst : MMCME2_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F => 11.2,    -- 100MHz*11.2=1.12GHz-- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD => 10.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT1_DIVIDE => 4,         -- 1.12GHz/4=280MHz
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

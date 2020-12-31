library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity SimpleMMCM2 is
  generic (
    CLKIN_PERIOD              : real := 10.000;
    PLL_MUL                   : real := 10.0;
    PLL_DIV                   : positive := 10;
    FB_BUFG                   : boolean := TRUE
  );
  port (
    RST_IN                    : in std_logic := '0';
    CLK_IN                    : in std_logic;

    RST_OUT                   : out std_logic;
    CLK_OUT                   : out std_logic
  );
end SimpleMMCM2;


architecture Behavioral of SimpleMMCM2 is

  signal mmcm_clk_sig         : std_logic;
  signal mmcm_fb_out          : std_logic;
  signal mmcm_fb_in           : std_logic;
  signal mmcm_locked_sig      : std_logic;

  signal rst_in_sig           : std_logic := '1';
  signal rst_out_sig          : std_logic := '1';
  signal clk_out_sig          : std_logic;

begin

  ------------------------------------------------
  -- CLK -> MMCM
  ------------------------------------------------
   MMCME2_BASE_inst : MMCME2_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F => PLL_MUL,    -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD => CLKIN_PERIOD,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT1_DIVIDE => PLL_DIV,
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
    -- Clock Outputs outputs: User configurable clock outputs
    CLKOUT1 => mmcm_clk_sig,          -- 1-bit output: CLKOUT1
    -- Feedback outputs: Clock feedback ports
    CLKFBOUT => mmcm_fb_out,          -- 1-bit output: Feedback clock
    -- Status Ports outputs: MMCM status ports
    LOCKED => mmcm_locked_sig,        -- 1-bit output: LOCK
    -- Clock Inputs inputs: Clock input
    CLKIN1 => CLK_IN,                 -- 1-bit input: Clock
    -- Control Ports inputs: MMCM control ports
    PWRDWN => '0',                    -- 1-bit input: Power-down
    RST => RST_IN,                    -- 1-bit input: Reset
    -- Feedback inputs: Clock feedback ports
    CLKFBIN => mmcm_fb_in             -- 1-bit input: Feedback clock
  );

  gen_BUFG : if (FB_BUFG) generate
    BUFG_mmcm_loopback : BUFG
    port map (
      O => mmcm_fb_in,                  -- 1-bit output: Clock output.
      I => mmcm_fb_out                  -- 1-bit input: Clock input.
    );
  end generate gen_BUFG;

  gen_bypass : if (not FB_BUFG) generate
    mmcm_fb_in <= mmcm_fb_out;
  end generate gen_bypass;

  ------------------------------------------------
  -- MMCM -> CLK_OUT
  ------------------------------------------------
  BUFG_clk_out : BUFG
  port map (
    I => mmcm_clk_sig,              -- 1-bit output: Clock output.
    O => clk_out_sig                -- 1-bit input: Clock input.
  );

  CLK_OUT <= clk_out_sig;


  ------------------------------------------------
  -- not LOCKED -> RST_OUT
  ------------------------------------------------

  rst_in_sig <= mmcm_locked_sig;

  -- Synchronizer register starts by default as all 0s
  sync_rst : entity work.Synchronizer
  generic map (
    SYNC_LENGTH          => 3
  )
  port map (
    RST             => '0',
    CLK             => clk_out_sig,
    SIG_IN        	=> rst_in_sig,
    SIG_OUT         => rst_out_sig
  );
  
  RST_OUT <= not rst_out_sig;

end Behavioral;

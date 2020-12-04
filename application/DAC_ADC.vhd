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

entity DAC_ADC is
    port (
        CLK : in STD_LOGIC;
        
        XA1_P : in STD_LOGIC;
        XA1_N : out STD_LOGIC;
        
        XA4_P : out STD_LOGIC;
        XA4_N : out STD_LOGIC;
        
        led : out STD_LOGIC_VECTOR(15 downto 0)
    );
end DAC_ADC;

architecture Behavioral of DAC_ADC is

    signal mmcm_clk : std_logic;
    signal mmcm_rst : std_logic;

    signal dac_out : std_logic;
    
    signal adc_out : std_logic;
    signal adc_sample_en : std_logic;
    signal wave_in_sig : std_logic_vector(7 downto 0);
    signal filter_out_sig : std_logic_vector(19 downto 0);
    
    signal led_sig : std_logic;

begin

    mmcm0: entity work.SimpleMMCM2
      generic map (
        CLKIN_PERIOD              => 10.000,
        PLL_MUL                   => 10.0,
        PLL_DIV                   => 10,
        FB_BUFG                   => FALSE
      )
      port map (
        RST_IN                    => '0',
        CLK_IN                    => CLK,
    
        RST_OUT                   => mmcm_rst,
        CLK_OUT                   => mmcm_clk
      );
    
    led_blink: entity work.square_wave_gen
        generic map (
            half_period_width => 28
        )
        port map (
            clk => CLK,
            en => '1',
            rst => mmcm_rst,
            half_period => x"2FAF080",
            sq_out => led_sig
        );
      
   clk_div : entity work.clk_div_generic
        generic map (
            period_width    => 8
        )
        port map (
            PERIOD          => x"64",   -- 100MHz/1MHz to hex
            CLK             => mmcm_clk,
            EN              => '1',
            RST             => mmcm_rst,
            EN_OUT          => adc_sample_en
        );


    adc: entity work.ADC1Bit
      port map (
        CLK                     => mmcm_clk,
        EN                      => adc_sample_en,
        RST                     => mmcm_rst,
        CMP_IN                  => XA1_P,
        INV_OUT                 => XA1_N,
        PDM_OUT                 => adc_out
    );
    
    wave_in_sig(7) <= '0';
    wave_in_sig(6 downto 0) <= (others => adc_out);
    
    filter : entity work.shift_mult_generic
        generic map (
            length => 15,
            width => 8,
            padding => 4
        )
        port map (
            shift_in => wave_in_sig,
            sum_out => filter_out_sig,
            clk => mmcm_clk,
            en => adc_sample_en,
            rst => mmcm_rst,
            coef_in => x"020913202C363D403D362C20130902"
        );
        
    dac: entity work.pdm_generic
        generic map (
            input_width         => 20,
            output_width        => 1,
            pulse_count_width   => 4
        )
        port map (
            input               => filter_out_sig,
            output(0)           => dac_out,
            pulse_length        => x"A",  -- 100MHz/10MHz to hex
            clk                 => mmcm_clk,
            en                  => '1',
            rst                 => mmcm_rst
        );
        
     XA4_P <= dac_out;
     XA4_N <= not dac_out;

    led <= filter_out_sig(14 downto 0) & led_sig;

end Behavioral;

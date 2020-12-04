----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/27/2020 10:54:27 AM
-- Design Name: 
-- Module Name: sin_wave_gen - Behavioral
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity fun_gen_sr is
    generic (
        sample_period_width : integer := 8; -- vector size to hold units of clock cycles
        pdm_period_width : integer := 4; -- vector size to hold units of clock cycles
        pdm_out_width : integer := 1; -- n-bit DAC
        phase_lag : integer := 0; -- lag/period * 2 * pi
        phase_bit : integer := 0; -- square wave to start as either 1 or 0
        pattern_width : integer;
        pattern_length : integer
    );
    port (
        repeat_pattern : in STD_LOGIC_VECTOR ((pattern_width*pattern_length)-1 downto 0);
        sample_period :  in STD_LOGIC_VECTOR (sample_period_width-1 downto 0); -- units of clock cycles
        pdm_period :  in STD_LOGIC_VECTOR (pdm_period_width-1 downto 0); -- units of clock cycles
        clk : in std_logic;
        en : in std_logic := '1';
        rst : in std_logic;

        pdm_out : out STD_LOGIC_VECTOR (pdm_out_width-1 downto 0);
        pattern_out : out STD_LOGIC_VECTOR (pattern_width-1 downto 0);
        sample_en_out : out std_logic
    );
end fun_gen_sr;



architecture Behavioral of fun_gen_sr is

    signal loopback_sig : std_logic_vector(pattern_width-1 downto 0);
    signal sample_en, pdm_en : std_logic;

begin        
    
    sample_rate : entity work.clk_div_generic
        generic map (
            period_width => sample_period_width
        )
        port map (
            period => sample_period,
            clk => clk,
            en => en,
            rst => rst,
            en_out => sample_en
        );
        
    sample_en_out <= sample_en;
    
    shift_reg : entity work.reg2D
        generic map (
          length => pattern_length,
          width => pattern_width
        )
        port map (
          clk      => clk,
          rst      => rst,

          par_en   => sample_en,

          default_state => repeat_pattern,

          par_in     => loopback_sig,
          par_out    => loopback_sig
        );
        
    pattern_out <= loopback_sig;

    PDM: entity work.pdm_generic
        generic map (
            input_width => pattern_width,
            output_width => pdm_out_width,
            pulse_count_width => pdm_period_width
        )
        port map (
            input => loopback_sig,
            output => pdm_out,
            pulse_length => pdm_period,
            clk => clk,
            en => en,
            rst => rst
        );


end Behavioral;

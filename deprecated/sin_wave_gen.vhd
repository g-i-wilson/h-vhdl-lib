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

entity sin_wave_gen is
    generic (
        half_period_width : integer; -- units of clock cycles
        sample_period_width : integer; -- units of clock cycles
        pdm_period_width : integer; -- units of clock cycles
        pdm_out_width : integer -- n-bit DAC
    );
    port (
        half_period : in STD_LOGIC_VECTOR (half_period_width-1 downto 0); -- units of clock cycles (must be a multiple of sample_period)
        sample_period :  in STD_LOGIC_VECTOR (sample_period_width-1 downto 0); -- units of clock cycles
        pdm_period :  in STD_LOGIC_VECTOR (pdm_period_width-1 downto 0); -- units of clock cycles
        pdm_out : out STD_LOGIC_VECTOR (pdm_out_width-1 downto 0);
        sq_out_debug : out STD_LOGIC_VECTOR (7 downto 0);
        filter_out_debug : out STD_LOGIC_VECTOR (19 downto 0);
        clk : in std_logic;
        en : in std_logic;
        rst : in std_logic
    );
end sin_wave_gen;



architecture Behavioral of sin_wave_gen is

    signal wave_in_sig : std_logic_vector(7 downto 0) := (others=>'0');
    signal filter_out_sig : std_logic_vector(19 downto 0) := (others=>'0');
    signal sq_sig, sample_en, pdm_en : std_logic;

begin

    
    
--    wave_in_sig <= "00" & sq_sig & sq_sig & sq_sig & sq_sig & sq_sig & sq_sig;
    wave_in_sig <= '0' & sq_sig & sq_sig & sq_sig & sq_sig & sq_sig & sq_sig & sq_sig;
--    wave_in_sig(0) <= not sq_sig; -- +/-1
--    wave_in_sig(7 downto 1) <= (others => sq_sig); -- sign bits (2s compliment)

    
    sq_out_debug <= wave_in_sig;
    filter_out_debug <= filter_out_sig;

    square_wave: entity work.square_wave_gen
        generic map (
            half_period_width => half_period_width
        )
        port map (
            clk => clk,
            en => en,
            rst => rst,
            half_period => half_period,
            sq_out => sq_sig
        );
        
    
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
    
    
    filter : entity work.shift_mult_generic
        generic map (
            length => 15,
            width => 8,
            padding => 4
        )
        port map (
            shift_in => wave_in_sig,
            sum_out => filter_out_sig,
            clk => clk,
            en => sample_en,
            rst => rst,
            coef_in => x"020913202C363D403D362C20130902"
--            par_out => shift_reg_debug,
--            mult_out => mult_reg_debug
        );
        
    PDM: entity work.pdm_generic
        generic map (
            input_width => 17,
            output_width => pdm_out_width,
            pulse_count_width => pdm_period_width
        )
        port map (
            input => filter_out_sig(16 downto 0),
            output => pdm_out,
            pulse_length => pdm_period,
            clk => clk,
            en => en,
            rst => rst
        );


end Behavioral;

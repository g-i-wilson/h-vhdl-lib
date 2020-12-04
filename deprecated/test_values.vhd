----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/30/2020 04:02:57 PM
-- Design Name: 
-- Module Name: test_values - Behavioral
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

entity test_values is
    generic (
        in_width: integer;
        period_width : integer;
        rst_count_width : integer := 4
    );
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC := '1';
           rst : in STD_LOGIC;
           period : in STD_LOGIC_VECTOR (period_width-1 downto 0);
           start_val, mult_val : in STD_LOGIC_VECTOR (in_width-1 downto 0);
           test_out : out STD_LOGIC_VECTOR (in_width-1 downto 0);
           rst_count : in STD_LOGIC_VECTOR (rst_count_width-1 downto 0) := x"8"
    );
end test_values;

architecture Behavioral of test_values is

    signal reg_out : std_logic_vector(in_width-1 downto 0);
    signal mult_out : std_logic_vector(in_width*2-1 downto 0);
    signal en_next, rst_test, rst_reg  : std_logic;

begin


    test_out <= reg_out;
    rst_reg <= rst or rst_test;
    

    mult0: entity work.mult_generic
    generic map (
        in_len => in_width
    )
    port map (
        in_a => mult_val,
        in_b => reg_out,
        mult_out => mult_out
    );
    
    
    incr_div: entity work.clk_div_generic
    generic map (
        period_width => period_width
    )
    port map (
        period => period,
        clk => clk,
        en => en,
        rst => rst,
        
        en_out => en_next
    );
    
    rst_div: entity work.clk_div_generic
    generic map (
        period_width => rst_count_width
    )
    port map (
        period => rst_count,
        clk => clk,
        en => en_next,
        rst => rst,
        
        en_out => rst_test
    );
    
    
    reg0: entity work.Reg1D
    generic map (
        length => in_width
    )
    port map (
        clk => clk,
        rst => rst_reg,
        par_en => en_next,
        default_state => start_val,
        
        par_in => mult_out(in_width-1 downto 0),
        par_out => reg_out
    );


end Behavioral;

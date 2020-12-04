----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2020 10:25:39 AM
-- Design Name: 
-- Module Name: reg_mult_generic - Behavioral
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

entity reg_mult_generic is
    generic (
        width : integer;
        padding: integer
    );
    port (
        -- data stream value from previous link in shift register
        reg_in   : in STD_LOGIC_VECTOR    (width-1 downto 0);
        -- data value will be multiplied by this coef (might be a constant)
        coef_in  : in STD_LOGIC_VECTOR    (width-1 downto 0);
        -- unchanged data value to send to next link
        reg_out  : out STD_LOGIC_VECTOR   (width-1 downto 0);
        -- clk, en, rst
        clk      : in STD_LOGIC;
        en       : in STD_LOGIC;
        rst      : in STD_LOGIC;
        -- data*coef output (mainly for debugging purposes)
        mult_out : out STD_LOGIC_VECTOR   (width*2-1 downto 0);
        -- sum from previous link (padding to prevent overflow)
        sum_in   : in STD_LOGIC_VECTOR    (width*2+padding-1 downto 0);
        -- sum + data*coef to send to next link
        sum_out  : out STD_LOGIC_VECTOR   (width*2+padding-1 downto 0)
    );
end reg_mult_generic;



architecture Behavioral of reg_mult_generic is

component mult_generic
    generic (
        in_len : integer
    );
    port (
        in_a : in STD_LOGIC_VECTOR (in_len-1 downto 0);
        in_b : in STD_LOGIC_VECTOR (in_len-1 downto 0);
        mult_out : out STD_LOGIC_VECTOR ((in_len*2)-1 downto 0)
    );
end component;

component reg_generic
  generic (
    reg_len : integer
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    en : in std_logic;
 
    reg_in : in std_logic_vector(reg_len-1 downto 0);
    reg_out : out std_logic_vector(reg_len-1 downto 0)
  );
end component;

signal mult_out_sig : std_logic_vector(width*2-1 downto 0);
signal sum_out_sig : std_logic_vector(width*2+padding-1 downto 0);

begin
    
    -- add the product (padded) to the previous incoming sum
    sum_out_sig <= std_logic_vector(
        resize( signed(mult_out_sig) , mult_out_sig'LENGTH  +padding ) +
        signed(sum_in)
    );

    -- pass-through register
    reg0 : reg_generic
        generic map (
            reg_len => width
        )
        port map (
            clk => clk,
            en => en, -- only enabled for samples
            rst => rst,
            reg_in => reg_in,
            reg_out => reg_out
        );
        
    -- multiplication register
    reg1 : reg_generic
        generic map (
            reg_len => width*2
        )
        port map (
            clk => clk,
            en => '1', -- essentially part of the "sum pipeline" (see below)
            rst => rst,
            reg_in => mult_out_sig,
            reg_out => mult_out
        );
        
    -- sum register
    reg2 : reg_generic
        generic map (
            reg_len => width*2+padding
        )
        port map (
            clk => clk,
            en => '1', -- "sum pipeline" is always clocking (approximates a pass-thru)
            rst => rst,
            reg_in => sum_out_sig,
            reg_out => sum_out
        );


    -- multiplier
    mult1 : mult_generic
        generic map (
            in_len => width
        )
        port map (
            in_a => reg_in,
            in_b => coef_in,
            mult_out => mult_out_sig
        );

end Behavioral;

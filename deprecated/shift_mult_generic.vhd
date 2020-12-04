----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2020 10:01:33 AM
-- Design Name: 
-- Module Name: shift_mult_generic - Behavioral
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift_mult_generic is
    generic (
        length : integer;
        width : integer;
        padding : integer
    );
    port (
        shift_in : in STD_LOGIC_VECTOR (width-1 downto 0);
        shift_out : out STD_LOGIC_VECTOR (width-1 downto 0);
        sum_out : out STD_LOGIC_VECTOR (width*2+padding-1 downto 0);
        clk : in STD_LOGIC;
        en : in STD_LOGIC;
        rst : in STD_LOGIC;
        par_out : out STD_LOGIC_VECTOR ((width*(length-1))-1 downto 0);
        coef_in : in STD_LOGIC_VECTOR (width*length-1 downto 0);
        mult_out : out STD_LOGIC_VECTOR (width*2*length-1 downto 0)
    );
end shift_mult_generic;



architecture Behavioral of shift_mult_generic is

component reg_mult_generic
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


signal all_reg_sig : std_logic_vector((width*(length-1))-1 downto 0);
-- provides all signals "between" each register, so width*(length-1)

signal all_sum_sig : std_logic_vector(((width*2+padding)*(length-1))-1 downto 0);

--signal sum_out_comb : std_logic_vector (width*2+padding-1 downto 0);


begin

    first_reg : reg_mult_generic
        generic map (width, padding)
        port map (
            clk      => clk,
            en       => en,
            rst      => rst,
            reg_in   => shift_in,
            reg_out  => all_reg_sig  ( width-1           downto 0 ),
            coef_in  => coef_in      ( width-1           downto 0 ),
            mult_out => mult_out     ( width*2-1         downto 0 ),
            sum_in   => (others=>'0'), -- constant 0
            sum_out  => all_sum_sig  ( width*2+padding-1 downto 0 )
        );
        
    gen_middle : for i in 0 to (length-3) generate -- length 5 regs is: in,0,1,2,out
        middle_reg : reg_mult_generic
            generic map (width, padding)
            port map (
                clk      => clk,
                en       => en,
                rst      => rst,
                reg_in   => all_reg_sig (  i    *width             +(width-1)           downto  i    *width             ),
                reg_out  => all_reg_sig ( (i+1) *width             +(width-1)           downto (i+1) *width             ),
                coef_in  => coef_in     ( (i+1) *width             +(width-1)           downto (i+1) *width             ),
                mult_out => mult_out    ( (i+1) *width*2           +(width*2-1)         downto (i+1) *width*2           ),
                sum_in   => all_sum_sig (  i    *(width*2+padding) +(width*2+padding-1) downto  i    *(width*2+padding) ),
                sum_out  => all_sum_sig ( (i+1) *(width*2+padding) +(width*2+padding-1) downto (i+1) *(width*2+padding) )
            );
    end generate gen_middle;
    
    last_reg : reg_mult_generic
        generic map (width, padding)
        port map (
            clk      => clk,
            en       => en,
            rst      => rst,
            reg_in   => all_reg_sig  ( all_reg_sig'high  downto all_reg_sig'high -(width-1)           ),
            reg_out  => shift_out,
            coef_in  => coef_in      ( coef_in'high      downto coef_in'high     -(width-1)           ),
            mult_out => mult_out     ( mult_out'high     downto mult_out'high    -(width*2-1)         ),
            sum_in   => all_sum_sig  ( all_sum_sig'high  downto all_sum_sig'high -(width*2+padding-1) ),
            sum_out  => sum_out
        );

    par_out <= all_reg_sig;
    
--    sum_reg : reg_generic
--        generic map (
--            reg_len => width*2+padding
--        )
--        port map (
--            clk => clk,
--            en => en,
--            rst => rst,
--            reg_in => sum_out_comb,
--            reg_out => sum_out
--        );
    
end Behavioral;

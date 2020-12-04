----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/21/2020 05:07:34 PM
-- Design Name: 
-- Module Name: diff_accum - Behavioral
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

entity diff_accum is
    generic (
        in_width : integer;
        sum_width : integer
    );
    port ( in_a : in STD_LOGIC_VECTOR (in_width-1 downto 0);
           in_b : in STD_LOGIC_VECTOR (in_width-1 downto 0);
           diff_sum : out STD_LOGIC_VECTOR (sum_width-1 downto 0);
           pos_sign : out STD_LOGIC;
           clk : in STD_LOGIC;
           en : in STD_LOGIC;
           rst : in STD_LOGIC
    );
end diff_accum;

architecture Behavioral of diff_accum is

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

    signal
        diff_sig
        : std_logic_vector(in_width-1 downto 0);
    signal
        diff_resized_sig,
        sum_sig,
        sum_reg_sig
        : std_logic_vector(sum_width-1 downto 0);

begin

    adder : reg_generic
        generic map (
            reg_len => sum_width
        )
        port map (
            clk => clk,
            en => en,
            rst => rst,
            reg_in => sum_sig,
            reg_out => sum_reg_sig
        );
        
   
    diff_sig <= std_logic_vector( signed(in_a) - signed(in_b) );

    sum_sig <= std_logic_vector( resize(signed(diff_sig),sum_width) + signed(sum_reg_sig) );
    
    diff_sum <= sum_reg_sig;
    
    process (sum_reg_sig) begin
        if (signed(sum_reg_sig) > 0) then
            pos_sign <= '1';
        else
            pos_sign <= '0';
        end if;
    end process;


end Behavioral;

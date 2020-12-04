----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2020 10:49:50 AM
-- Design Name: 
-- Module Name: reg_mult_generic_tb - Behavioral
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

entity reg_mult_generic_tb is
--  Port ( );
end reg_mult_generic_tb;



architecture Behavioral of reg_mult_generic_tb is

component reg_mult_generic
    generic (
        width : integer;
        padding: integer
    );
    port (
        reg_in : in STD_LOGIC_VECTOR (width-1 downto 0);
        coef_in : in STD_LOGIC_VECTOR (width-1 downto 0);
        reg_out : out STD_LOGIC_VECTOR (width-1 downto 0);
        clk : in STD_LOGIC;
        en : in STD_LOGIC;
        rst : in STD_LOGIC;
        mult_out : out STD_LOGIC_VECTOR (width*2-1 downto 0);
        sum_in : in STD_LOGIC_VECTOR (padding+width*2-1 downto 0);
        sum_out : out STD_LOGIC_VECTOR (padding+width*2-1 downto 0)
    );
end component;

signal test_clk, test_rst, test_en : std_logic;
signal test_in, test_out, test_coef : std_logic_vector(3 downto 0);
signal test_mult : std_logic_vector(7 downto 0);
signal test_sum_in, test_sum_out : std_logic_vector(11 downto 0);

begin

    u1 : reg_mult_generic
        generic map (
            width => 4,
            padding => 4
        )
        port map (
            reg_in => test_in,
            coef_in => test_coef,
            reg_out => test_out,
            clk => test_clk,
            en => test_en,
            rst => test_rst,
            mult_out => test_mult,
            sum_in => test_sum_in,
            sum_out => test_sum_out
        );

    process
    begin
    
        -- initial
        test_clk <= '0';
        test_rst <= '0';
        test_en <= '1';
        test_coef <= x"2";
        test_in <= x"1";
        test_sum_in <= x"aa0";
        
        -- clock edge
        wait for 100ns;
        test_clk <= '1';
        wait for 100ns;
        test_clk <= '0';
        
        test_clk <= '0';
        test_rst <= '0';
        test_en <= '1';
        test_coef <= x"2";
        test_in <= x"2";
        test_sum_in <= x"aa0";
        
        -- clock edge
        wait for 100ns;
        test_clk <= '1';
        wait for 100ns;
        test_clk <= '0';
        
        test_clk <= '0';
        test_rst <= '0';
        test_en <= '1';
        test_coef <= x"2";
        test_in <= x"3";
        test_sum_in <= x"aa0";
        
        -- clock edge
        wait for 100ns;
        test_clk <= '1';
        wait for 100ns;
        test_clk <= '0';
        
        test_clk <= '0';
        test_rst <= '0';
        test_en <= '1';
        test_coef <= x"2";
        test_in <= x"4";
        test_sum_in <= x"aa0";
        
        -- done
        wait for 100us;
        
    end process;

end Behavioral;

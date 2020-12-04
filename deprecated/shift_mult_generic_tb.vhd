----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/07/2020 01:44:41 PM
-- Design Name: 
-- Module Name: shift_mult_generic_tb - Behavioral
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

entity shift_mult_generic_tb is
--  Port ( );
end shift_mult_generic_tb;

architecture Behavioral of shift_mult_generic_tb is

component shift_mult_generic
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
end component;

signal test_clk, test_rst, test_en : std_logic;
signal test_in, test_out : std_logic_vector(3 downto 0);
signal test_sum_out : std_logic_vector(11 downto 0);
signal test_coef_in : std_logic_vector (11 downto 0);
signal test_mult_out : std_logic_vector (23 downto 0);

begin

    u1 : shift_mult_generic
        generic map (
            length => 3,
            width => 4,
            padding => 4
        )
        port map (
            shift_in => test_in,
            shift_out => test_out,
            sum_out => test_sum_out,
            clk => test_clk,
            en => test_en,
            rst => test_rst,
            coef_in => test_coef_in,
            mult_out => test_mult_out
        );

    process
    begin
    
        -- initial
        test_clk <= '0';
        test_rst <= '1';
        test_en <= '1';
        test_coef_in <= x"222";
        test_in <= x"1";
        
        -- clock edge
        wait for 50ns;
        test_clk <= '1';
        wait for 50ns;
        test_clk <= '0';
        
        test_clk <= '0';
        test_rst <= '0';
        test_en <= '1';
        test_coef_in <= x"222";
        test_in <= x"2";
        
        -- clock edge
        wait for 50ns;
        test_clk <= '1';
        wait for 50ns;
        test_clk <= '0';
        
        test_clk <= '0';
        test_rst <= '0';
        test_en <= '1';
        test_coef_in <= x"222";
        test_in <= x"3";
        
        -- clock edge
        wait for 50ns;
        test_clk <= '1';
        wait for 50ns;
        test_clk <= '0';
        
        test_clk <= '0';
        test_rst <= '0';
        test_en <= '1';
        test_coef_in <= x"222";
        test_in <= x"4";
        
        -- clock edge
        wait for 50ns;
        test_clk <= '1';
        wait for 50ns;
        test_clk <= '0';
        
        test_clk <= '0';
        test_rst <= '0';
        test_en <= '1';
        test_coef_in <= x"222";
        test_in <= x"5";
        
        -- clock edge
        wait for 50ns;
        test_clk <= '1';
        wait for 50ns;
        test_clk <= '0';
        
        test_clk <= '0';
        test_rst <= '0';
        test_en <= '0';
        test_coef_in <= x"222";
        test_in <= x"6";
        
        -- clock edge
        wait for 50ns;
        test_clk <= '1';
        wait for 50ns;
        test_clk <= '0';
        
        test_clk <= '0';
        test_rst <= '1';
        test_en <= '0';
        test_coef_in <= x"222";
        test_in <= x"7";
        
        -- clock edge
        wait for 50ns;
        test_clk <= '1';
        wait for 50ns;
        test_clk <= '0';
        
        -- done
        wait for 100us;
        
    end process;

end Behavioral;

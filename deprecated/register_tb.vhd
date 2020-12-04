----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/06/2020 03:52:49 PM
-- Design Name: 
-- Module Name: register_tb - Behavioral
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

entity register_tb is
--  Port ( );
end register_tb;

architecture Behavioral of register_tb is

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

signal test_clk : std_logic;
signal test_rst : std_logic;
signal test_en : std_logic;
signal test_in : std_logic_vector(3 downto 0);
signal test_out : std_logic_vector(3 downto 0);

begin

    reg_1 : reg_generic
        generic map (
            reg_len => 4
        )
        port map (
            clk => test_clk,
            rst => test_rst,
            en => test_en,
            reg_in => test_in,
            reg_out => test_out
        );
    
    process
    begin
        test_clk <= '0';
        test_rst <= '0';
        test_en <= '0';
        test_in <= "1001";
        wait for 100ns;
        test_clk <= '1';
        wait for 100ns;
        test_clk <= '0';
        test_in <= "0011";
        test_en <= '1';
        wait for 100ns;
        test_clk <= '1';
        wait for 100ns;
        test_clk <= '0';
        test_rst <= '1';
        wait for 100ns;
        test_clk <= '1';
        wait for 100ns;
    end process;

end Behavioral;

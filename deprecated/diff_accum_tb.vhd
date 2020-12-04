----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/22/2020 08:15:52 AM
-- Design Name: 
-- Module Name: shorten_tb - Behavioral
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

entity diff_accum_tb is
--  Port ( );
end diff_accum_tb;

architecture Behavioral of diff_accum_tb is

    component diff_accum
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
    end component;
    
    signal
        test_in_a,
        test_in_b
        : std_logic_vector(7 downto 0);
    signal
        test_diff_sum
        : std_logic_vector(11 downto 0);
    signal
        test_pos_sign,
        test_clk,
        test_en,
        test_rst
        : std_logic;


begin


    error_function : diff_accum
        generic map (
            in_width => 8,
            sum_width => 12
        )
        port map (
            in_a => test_in_a,
            in_b => test_in_b,
            diff_sum => test_diff_sum,
            pos_sign => test_pos_sign,
            clk => test_clk,
            en => test_en,
            rst => test_rst
        );

    process
    begin
    
        -- initial
        test_en <= '1';
        test_rst <= '1';
        test_in_a <= x"10";
        test_in_b <= x"0E";
        
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';

        test_en <= '1';
        test_rst <= '0';

        for a in 0 to 5 loop
        
            -- change inputs
            test_in_a <= std_logic_vector(signed(test_in_a) - to_signed(a, 8));
            
        
            -- just clock for a while
            for b in 0 to 2 loop
                -- clock edge
                wait for 5ns;
                test_clk <= '1';
                wait for 5ns;
                test_clk <= '0';
                
            end loop;
        end loop;

    end process;


end Behavioral;

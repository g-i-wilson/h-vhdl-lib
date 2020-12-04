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

entity shorten_tb is
--  Port ( );
end shorten_tb;

architecture Behavioral of shorten_tb is

    component shorten
        generic (
            width : integer;
            places : integer
        );
        port ( 
            input : in STD_LOGIC_VECTOR (width-1 downto 0);
            output : out STD_LOGIC_VECTOR (width-1 downto 0);
            round_up : in STD_LOGIC;
            clk : in STD_LOGIC;
            en : in STD_LOGIC;
            rst : in STD_LOGIC
        );
    end component;
    
    signal
        test_input,
        test_output
        : std_logic_vector(7 downto 0);
    signal
        test_round_up,
        test_clk,
        test_en,
        test_rst
        : std_logic;


begin

    u0 : shorten
        generic map (
            width => 8,
            places => 4
        )
        port map ( 
            input => test_input,
            output => test_output,
            round_up => test_round_up,
            clk => test_clk,
            en => test_en,
            rst => test_rst
        );

    process
    begin
    
        -- initial
        test_en <= '1';
        test_rst <= '1';
        test_input <= x"49";
        
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

        for a in 0 to 9 loop
        
            -- change inputs
            test_input <= std_logic_vector(signed(test_input) - to_signed(a, 8));
            test_round_up <= '0';
        
            -- just clock for a while
            for b in 0 to 2 loop
                -- clock edge
                wait for 5ns;
                test_clk <= '1';
                wait for 5ns;
                test_clk <= '0';
                
            end loop;
            
            test_round_up <= '1';
            
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

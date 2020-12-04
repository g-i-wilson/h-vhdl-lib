----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/21/2020 02:44:26 PM
-- Design Name: 
-- Module Name: pdm_generic_tb - Behavioral
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

entity pdm_generic_tb is
--  Port ( );
end pdm_generic_tb;



architecture Behavioral of pdm_generic_tb is

component pdm_generic
    generic (
        input_width : integer;
        output_width : integer;
        pulse_count_width : integer
    );
    port (
        input : in STD_LOGIC_VECTOR (input_width-1 downto 0);
        output : out STD_LOGIC_VECTOR (output_width-1 downto 0);
        error : out STD_LOGIC_VECTOR (1+pulse_count_width+(input_width-output_width)-1 downto 0);
        error_sign : out std_logic;
        pulse_length : in STD_LOGIC_VECTOR (pulse_count_width-1 downto 0);
        pulse_count : out STD_LOGIC_VECTOR (pulse_count_width-1 downto 0);
        pulse_en : out std_logic;
        clk : in STD_LOGIC;
        en : in STD_LOGIC;
        rst : in STD_LOGIC
    );
end component;

signal test_input : STD_LOGIC_VECTOR (7 downto 0);
signal test_output : STD_LOGIC_VECTOR (1 downto 0);
signal test_error : STD_LOGIC_VECTOR (8 downto 0);
signal test_pulse_length, test_pulse_count : STD_LOGIC_VECTOR (1 downto 0);
signal test_clk, test_en, test_rst, test_sign, test_pulse_en : STD_LOGIC;

begin


    u0: pdm_generic
    generic map (
        input_width => 8,
        output_width => 2,
        pulse_count_width => 2
    )
    port map (
        input => test_input,
        output => test_output,
        pulse_length => test_pulse_length,
        pulse_count => test_pulse_count,
        pulse_en => test_pulse_en,
        error => test_error,
        error_sign => test_sign,
        clk => test_clk,
        en => test_en,
        rst => test_rst
    );



    process
    begin
    
        -- initial
        test_en <= '1';
        test_rst <= '1';
        test_pulse_length <= "11";
        
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

        for a in 0 to 127 loop
        
            -- change inputs
            test_input <= std_logic_vector(to_signed(a, 8));
            
        
            -- just clock for a while
            for b in 0 to 15 loop
                -- clock edge
                wait for 5ns;
                test_clk <= '1';
                wait for 5ns;
                test_clk <= '0';
                
            end loop;
        end loop;

    end process;



end Behavioral;

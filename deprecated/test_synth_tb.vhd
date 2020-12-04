----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/12/2020 02:16:34 PM
-- Design Name: 
-- Module Name: test_synth_tb - Behavioral
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

entity test_synth_tb is
--  Port ( );
end test_synth_tb;



architecture Behavioral of test_synth_tb is

component test_synth
    port (
        clk : in std_logic;
        sw : in STD_LOGIC_VECTOR (15 downto 0);
        led : out STD_LOGIC_VECTOR (15 downto 0);
--        shift_reg_debug : out std_logic_vector (27 downto 0);
--        mult_reg_debug : out std_logic_vector (63 downto 0);
        encoded_debug : out std_logic_vector (3 downto 0);
        filtered_debug : out std_logic_vector (19 downto 0)
    );
end component;

signal test_clk : std_logic;
signal test_sw, test_led : std_logic_vector(15 downto 0);
signal test_shift : std_logic_vector (27 downto 0);
signal test_mult : std_logic_vector (63 downto 0);
signal test_filtered : std_logic_vector (19 downto 0);
signal test_encoded : std_logic_vector (3 downto 0);

begin

    test0: test_synth
    port map (
        clk => test_clk,
        sw => test_sw,
        led => test_led,
--        shift_reg_debug => test_shift,
--        mult_reg_debug => test_mult,
        filtered_debug => test_filtered,
        encoded_debug => test_encoded
    );
    
    process
    
        variable a_sw : integer := 1;
        
    begin
    
        -- initial
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;

        for a in 0 to 7 loop
        
            -- change inputs
            a_sw := a_sw*2;
            test_sw <= std_logic_vector(to_signed(a_sw, 16));
            
        
            -- just clock for a while
            for b in 0 to 48 loop
                -- clock edge
                wait for 5ns;
                test_clk <= '1';
                wait for 5ns;
                test_clk <= '0';
                
            end loop;
        end loop;

    end process;


end Behavioral;

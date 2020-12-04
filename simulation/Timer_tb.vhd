----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/24/2020 10:09:10 AM
-- Design Name: 
-- Module Name: Timer_tb - Behavioral
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

entity Timer_tb is
--  Port ( );
end Timer_tb;

architecture Behavioral of Timer_tb is

signal test_clk, test_rst, test_done0, test_done1, test_done2, test_done3, test_done4, test_done5 : std_logic;
signal test_start0, test_start1, test_end0, test_end1, test_count0, test_count1, test_count3, test_count4, test_count5 : std_logic_vector(3 downto 0);
signal test_count2 : std_logic_vector(2 downto 0);

begin

    timer0: entity work.Timer
        generic map (
            WIDTH => 4
        )
        port map (
            -- inputs
            CLK             => test_clk,
            EN              => '1',
            RST             => test_rst,
            COUNT_START     => test_start0,
            COUNT_END       => test_end0,
            -- outputs
            DONE            => test_done0,
            COUNT           => test_count0
       );

    timer1: entity work.Timer
        generic map (
            WIDTH => 4,
            COUNT_UP => FALSE
        )
        port map (
            -- inputs
            CLK             => test_clk,
            RST             => test_rst,
            COUNT_START     => test_start1,
            COUNT_END       => test_end1,
            -- outputs
            DONE            => test_done1,
            COUNT           => test_count1
       );

    timer2: entity work.Timer
        generic map (
            WIDTH => 3
        )
        port map (
            -- inputs
            CLK             => test_clk,
            RST             => test_done2,
            -- outputs
            DONE            => test_done2,
            COUNT           => test_count2
       );


    timer3: entity work.Timer
        generic map (
            WIDTH => 4
        )
        port map (
            -- inputs
            CLK             => test_clk,
            RST             => test_done3,
            COUNT_START     => test_start1,
            COUNT_END       => test_start1,
            -- outputs
            DONE            => test_done3,
            COUNT           => test_count3
       );


    timer4: entity work.Timer
        generic map (
            WIDTH => 4
        )
        port map (
            -- inputs
            CLK             => test_clk,
            RST             => test_done4,
            COUNT_START     => test_start0,
            COUNT_END       => test_end0,
            -- outputs
            DONE            => test_done4,
            COUNT           => test_count4
       );


    timer5: entity work.Timer
        generic map (
            WIDTH => 4
        )
        port map (
            -- inputs
            CLK             => test_clk,
            RST             => test_done5,
            COUNT_START     => test_start0,
            COUNT_END       => test_start0,
            -- outputs
            DONE            => test_done5,
            COUNT           => test_count5
       );

    process
    
    begin
        -- initial
        test_start0 <= x"3";
        test_end0 <= x"4";

        test_start1 <= x"4";
        test_end1 <= x"1";

        test_rst <= '1';
        
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        test_clk <= '1';
        wait for 5ns;
        test_clk <= '0';
        wait for 5ns;
        
        test_rst <= '0';
        
        for a in 0 to 255 loop
        
            -- just clock for a while
                wait for 5ns;
                test_clk <= '1';
                wait for 5ns;
                test_clk <= '0';
                
        end loop;

    end process;

end Behavioral;

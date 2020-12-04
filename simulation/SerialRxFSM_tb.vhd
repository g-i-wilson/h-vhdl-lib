----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/11/2020 07:59:41 AM
-- Design Name: 
-- Module Name: SerialRxFSM_tb - Behavioral
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

entity SerialRxFSM_tb is
--  Port ( );
end SerialRxFSM_tb;

architecture Behavioral of SerialRxFSM_tb is

    signal test_clk : std_logic;
    signal test_rst : std_logic;
    signal test_edge : std_logic;
    signal test_valid : std_logic;
    signal test_data : std_logic;
    signal test_timer : std_logic;
    signal test_count : std_logic_vector(4 downto 0);
    signal test_rst_timer : std_logic;
    signal test_rst_count : std_logic;
    signal test_shift_in_bit : std_logic;
    signal test_byte_complete : std_logic;
    signal test_data_bit_alarm : std_logic;
    signal test_stop_bit_alarm : std_logic;

begin


    test: entity work.SerialRxFSM
    port map (
        CLK => test_clk,
        RST => test_rst,
        EN => '1',
        EDGE_EVENT => test_edge,
        VALID => test_valid,
        DATA => test_data,
        TIMER => test_timer,
        COUNT => test_count,
        
        RST_TIMER => test_rst_timer,
        RST_COUNT => test_rst_count,
        SHIFT_IN_BIT => test_shift_in_bit,
        BYTE_COMPLETE => test_byte_complete,
        DATA_BIT_INVALID_ALARM => test_data_bit_alarm,
        STOP_BIT_INVALID_ALARM => test_stop_bit_alarm
    );


    process
    begin

        -- initial
        test_rst <= '1';
        test_data <= '0';

        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;

        test_rst <= '0';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;



        for a in 0 to 255 loop
          test_data <= '1';

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;
                
        

    end process;



end Behavioral;

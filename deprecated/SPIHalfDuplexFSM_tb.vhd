----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/23/2020 09:19:05 AM
-- Design Name: 
-- Module Name: SPIHalfDuplexFSM_tb - Behavioral
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

entity SPIHalfDuplexFSM_tb is
--  Port ( );
end SPIHalfDuplexFSM_tb;

architecture Behavioral of SPIHalfDuplexFSM_tb is

    signal test_CLK : std_logic;
    signal test_RST : std_logic;
    signal test_VALID_IN : std_logic;
    signal test_READY_IN : std_logic;
    signal test_WRITE_DONE : std_logic;
    signal test_READ_DONE : std_logic;
    signal test_BYTE_DONE : std_logic;
    signal test_SCK_EDGE_EN : std_logic;
    
    signal test_READY_OUT : std_logic;
    signal test_VALID_OUT : std_logic;
    signal test_READ_EN : std_logic;
    signal test_TIMER_EN : std_logic;
    signal test_TIMER_RST : std_logic;
    signal test_TRISTATE_EN : std_logic;
    signal test_LOAD_WRITE_LEN : std_logic;
    signal test_LOAD_READ_LEN : std_logic;
    signal test_LOAD_DATA_IN : std_logic;
    signal test_LOAD_DATA_OUT : std_logic;
    signal test_SHIFT_DATA : std_logic;
    signal test_CS : std_logic;
    signal test_SCK : std_logic;


begin

    test0: entity work.SPIHalfDuplexFSM
        port map ( 
            CLK => test_CLK,
            RST => test_RST,
            VALID_IN => test_VALID_IN,
            READY_IN => test_READY_IN,
            WRITE_DONE => test_WRITE_DONE,
            READ_DONE => test_READ_DONE,
            BYTE_DONE => test_BYTE_DONE,
            SCK_EDGE_EN => test_SCK_EDGE_EN,
            
            READY_OUT => test_READY_OUT,
            VALID_OUT => test_VALID_OUT,
            READ_EN => test_READ_EN,
            TIMER_EN => test_TIMER_EN,
            TIMER_RST => test_TIMER_RST,
            TRISTATE_EN => test_TRISTATE_EN,
            LOAD_WRITE_LEN => test_LOAD_WRITE_LEN,
            LOAD_READ_LEN => test_LOAD_READ_LEN,
            LOAD_DATA_IN => test_LOAD_DATA_IN,
            LOAD_DATA_OUT => test_LOAD_DATA_OUT,
            SHIFT_DATA => test_SHIFT_DATA,
            CS => test_CS,
            SCK => test_SCK
        );





end Behavioral;

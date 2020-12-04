----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/20/2020 10:15:10 AM
-- Design Name: 
-- Module Name: SerialTxFSM - Behavioral
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

entity SerialTxFSM is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           EN : in STD_LOGIC;
           VALID : in STD_LOGIC;
           BIT_EN : in STD_LOGIC;
           BYTE_EN : in STD_LOGIC;

           READY : out STD_LOGIC;
           LOAD : out STD_LOGIC;
           SHIFT : out STD_LOGIC
    );
end SerialTxFSM;

architecture Behavioral of SerialTxFSM is

  type state_type is (
    READY_STATE,
    LOAD_STATE,
    BIT_WAIT_STATE,
    SHIFT_STATE,
    DEBUG_STATE
  );

  signal current_state        : state_type := READY_STATE;
  signal next_state           : state_type := READY_STATE;
  
begin

  FSM_state_register: process (CLK) begin
    if rising_edge(CLK) then
      if (RST = '1') then
        current_state <= READY_STATE;
      elsif (EN = '1') then
        current_state <= next_state;
      else
        current_state <= current_state;
      end if;
    end if;
  end process;


    FSM_next_state_logic: process (current_state, BIT_EN, BYTE_EN, VALID) begin
    
--        next_state <= READY_STATE;
        next_state <= current_state;
        
        if current_state = READY_STATE then
            if (VALID = '1') then
                next_state <= LOAD_STATE;
            end if;
            
        elsif current_state = LOAD_STATE then
            next_state <= BIT_WAIT_STATE;
            
        elsif current_state = BIT_WAIT_STATE then
            if (BIT_EN = '1' and BYTE_EN = '0') then
                next_state <= SHIFT_STATE;
            elsif (BIT_EN = '1' and BYTE_EN = '1') then
                next_state <= READY_STATE;
--            elsif (BIT_EN = '1' and BYTE_EN = '1' and VALID = '1') then
--                next_state <= LOAD_STATE;
            end if;
--               next_state <= DEBUG_STATE;
            
        elsif current_state = SHIFT_STATE then
            next_state <= BIT_WAIT_STATE;
        end if;
        
    end process;


  FSM_output_logic: process (current_state) begin
  
    -- defaults
   READY <= '0';
   LOAD <= '0';
   SHIFT <= '0';
    
    if (current_state = READY_STATE) then
        READY <= '1';
    elsif (current_state = LOAD_STATE) then
        LOAD <= '1';
    elsif (current_state = SHIFT_STATE) then
        SHIFT <= '1';
    end if;

  end process;

end Behavioral;

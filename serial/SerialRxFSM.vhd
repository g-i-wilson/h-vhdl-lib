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

entity SerialRxFSM is
    Port ( CLK              : in STD_LOGIC;
           RST              : in STD_LOGIC;
           EN               : in STD_LOGIC;
           EDGE_EVENT       : in STD_LOGIC;
           VALID_IN         : in STD_LOGIC;
           DATA             : in STD_LOGIC;
           TIMER            : in STD_LOGIC;
           COUNT            : in STD_LOGIC_VECTOR (4 downto 0); -- 5 bits

           COUNT_BREAK      : out STD_LOGIC;
           COUNT_BIT        : out STD_LOGIC;
           RST_COUNT        : out STD_LOGIC;
           RST_TIMER        : out STD_LOGIC;
           SHIFT_IN_BIT     : out STD_LOGIC;
           VALID_OUT        : out STD_LOGIC;
           DATA_BIT_INVALID_ALARM    : out STD_LOGIC;
           STOP_BIT_INVALID_ALARM    : out STD_LOGIC           
    );
end SerialRxFSM;

architecture Behavioral of SerialRxFSM is

  type state_type is (
    INIT_STATE,
    BREAK_STATE,
    START_WAIT_STATE,
    RST_TIMER_STATE,
    DATA_VALID_WAIT_STATE,
    DATA_WAIT_STATE,
    DATA_BIT_STATE,
    STOP_WAIT_STATE,
    STOP_BIT_STATE,
    VALID_OUT_STATE,
    DATA_BIT_INVALID_ALARM_STATE,
    STOP_BIT_INVALID_ALARM_STATE
  );

  signal current_state        : state_type := INIT_STATE;
  signal next_state           : state_type := INIT_STATE;
  
begin

  FSM_state_register: process (CLK) begin
    if rising_edge(CLK) then
      if (RST = '1') then
        current_state <= INIT_STATE;
      elsif (EN = '1') then
        current_state <= next_state;
      else
        current_state <= current_state;
      end if;
    end if;
  end process;


    FSM_next_state_logic: process (current_state, EDGE_EVENT, VALID_IN, DATA, TIMER, COUNT) begin
    
        next_state <= current_state;
        
        if current_state = INIT_STATE then
            if (VALID_IN = '1' and DATA = '1') then
                next_state <= BREAK_STATE;
            end if;
            
        elsif current_state = BREAK_STATE then
            if (DATA = '1' and COUNT = "10100") then -- COUNT = 20
                next_state <= START_WAIT_STATE;
            elsif (DATA = '0') then
                next_state <= INIT_STATE;
            end if;
            
        elsif current_state = START_WAIT_STATE then
            if (EDGE_EVENT = '1' and DATA = '0') then
                next_state <= DATA_WAIT_STATE;
            end if;
            
        elsif current_state = DATA_WAIT_STATE then
            if (EDGE_EVENT = '1') then
                next_state <= RST_TIMER_STATE;
            elsif (TIMER = '1' and VALID_IN = '1') then
                next_state <= DATA_BIT_STATE;
            elsif (TIMER = '1') then
                next_state <= DATA_VALID_WAIT_STATE;
            end if;
            
        elsif current_state = RST_TIMER_STATE then
            next_state <= DATA_BIT_STATE;
            
       elsif current_state = DATA_VALID_WAIT_STATE then
            if (VALID_IN = '1') then
                next_state <= DATA_BIT_STATE;
            elsif (TIMER = '1') then
                next_state <= DATA_BIT_INVALID_ALARM_STATE;
            end if;
            
       elsif current_state = DATA_BIT_STATE then
            if (COUNT = "00111") then -- COUNT = 7
                next_state <= STOP_WAIT_STATE;
            else
                next_state <= DATA_WAIT_STATE;
            end if;
            
       elsif current_state = STOP_WAIT_STATE then
            if (EDGE_EVENT = '1' or TIMER = '1') then
                if (DATA = '1') then
                    next_state <= VALID_OUT_STATE;
                else
                    next_state <= STOP_BIT_INVALID_ALARM_STATE;
                end if;
            end if;
            
       elsif current_state = VALID_OUT_STATE then
            next_state <= START_WAIT_STATE;
            
       elsif current_state = DATA_BIT_INVALID_ALARM_STATE then
            next_state <= INIT_STATE;

       elsif current_state = STOP_BIT_INVALID_ALARM_STATE then
            next_state <= INIT_STATE;

        end if;
        
    end process;


  FSM_output_logic: process (current_state) begin
  
    -- defaults
   RST_TIMER <= '0';
   RST_COUNT <= '0';
   COUNT_BREAK <= '0';
   COUNT_BIT <= '0';
   SHIFT_IN_BIT <= '0';
   VALID_OUT <= '0';
   DATA_BIT_INVALID_ALARM <= '0';
   STOP_BIT_INVALID_ALARM <= '0';
    
    if (current_state = INIT_STATE) then
        RST_TIMER <= '1';
        RST_COUNT <= '1';
    elsif (current_state = BREAK_STATE) then
        COUNT_BREAK <= '1';
    elsif (current_state = START_WAIT_STATE) then
        RST_TIMER <= '1';
        RST_COUNT <= '1';
    elsif (current_state = RST_TIMER_STATE) then
        RST_TIMER <= '1';
    elsif (current_state = DATA_BIT_STATE) then
        SHIFT_IN_BIT <= '1';
        COUNT_BIT <= '1';
    elsif (current_state = VALID_OUT_STATE) then
        VALID_OUT <= '1';
    elsif (current_state = DATA_BIT_INVALID_ALARM_STATE) then
        DATA_BIT_INVALID_ALARM <= '1';
    elsif (current_state = STOP_BIT_INVALID_ALARM_STATE) then
        STOP_BIT_INVALID_ALARM <= '1';
    end if;

  end process;

end Behavioral;

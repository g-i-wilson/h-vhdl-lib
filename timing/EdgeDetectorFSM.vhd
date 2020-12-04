----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/21/2020 10:48:03 AM
-- Design Name: 
-- Module Name: EdgeDetectorFSM - Behavioral
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

entity EdgeDetectorFSM is
    generic (
        SUM_WIDTH           : positive := 4;
        LOGIC_HIGH          : positive := 13;
        LOGIC_LOW           : positive := 2
    );
    Port ( CLK              : in STD_LOGIC;
           EN               : in STD_LOGIC := '1';
           RST              : in STD_LOGIC;
           SUM_IN           : in STD_LOGIC_VECTOR (SUM_WIDTH-1 downto 0);
           EDGE_EVENT       : out STD_LOGIC;
           VALID            : out STD_LOGIC;
           DATA             : out STD_LOGIC
    );
end EdgeDetectorFSM;

architecture Behavioral of EdgeDetectorFSM is

  type state_type is (
    INIT,
    VALID_HIGH,
    VALID_LOW,
    FALLING,
    FALLEN,
    RISING,
    RISEN
  );

  signal current_state        : state_type := INIT;
  signal next_state           : state_type := INIT;

begin


  FSM_register: process (CLK) begin
    if rising_edge(CLK) then
      if (RST = '1') then
        current_state <= INIT;
      elsif (EN = '1') then
        current_state <= next_state;
      else
        current_state <= current_state;
      end if;
    end if;
  end process;


  FSM_next_state_logic: process (current_state, SUM_IN) begin
    -- default
    next_state <= current_state;

    if (current_state = INIT) then
      if (unsigned(SUM_IN) >= LOGIC_HIGH) then
        next_state <= VALID_HIGH;
      elsif (unsigned(SUM_IN) <= LOGIC_LOW) then
        next_state <= VALID_LOW;
      end if;

    elsif (current_state = VALID_HIGH) then
      if (unsigned(SUM_IN) < LOGIC_HIGH) then
        next_state <= FALLING;
      end if;

    elsif (current_state = FALLING) then
      if (unsigned(SUM_IN) <= LOGIC_LOW) then
        next_state <= FALLEN;
      elsif (unsigned(SUM_IN) >= LOGIC_HIGH) then
        next_state <= VALID_HIGH;
      end if;

    elsif (current_state = FALLEN) then
      next_state <= VALID_LOW;

    elsif (current_state = VALID_LOW) then
      if (unsigned(SUM_IN) > LOGIC_LOW) then
        next_state <= RISING;
      end if;

    elsif (current_state = RISING) then
      if (unsigned(SUM_IN) >= LOGIC_HIGH) then
        next_state <= RISEN;
      elsif (unsigned(SUM_IN) <= LOGIC_LOW) then
        next_state <= VALID_LOW;
      end if;

    elsif (current_state = RISEN) then
      next_state <= VALID_HIGH;

    else
      next_state <= INIT;
    end if;


  end process;


  FSM_output_logic: process (current_state) begin
    -- begin with assumption output signals will be '0'
    EDGE_EVENT <= '0';
    VALID <= '0';
    DATA <= '0';

    if (current_state = INIT) then
        -- NOTHING YET
        
    elsif (current_state = VALID_HIGH) then
      VALID <= '1';
      DATA <= '1';

    elsif (current_state = FALLING) then
      DATA <= '1';

    elsif (current_state = FALLEN) then
      EDGE_EVENT <= '1';
      VALID <= '1';
      -- DATA 0

    elsif (current_state = VALID_LOW) then
      VALID <= '1';
      -- DATA 0

    elsif (current_state = RISING) then
        -- DATA 0
        
    elsif (current_state = RISEN) then
      EDGE_EVENT <= '1';
      VALID <= '1';
      DATA <= '1';
      
    end if;


  end process;


end Behavioral;

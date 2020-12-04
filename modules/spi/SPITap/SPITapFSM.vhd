library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPITapFSM is
    port ( 
        CLK                 : in STD_LOGIC;
        RST                 : in STD_LOGIC;
        BYTE_DONE           : in STD_LOGIC;
        CS                  : in STD_LOGIC;
        SCK                 : in STD_LOGIC;
        
        VALID               : out STD_LOGIC;
        BIT_COUNT_EN        : out STD_LOGIC;
        BIT_COUNT_RST       : out STD_LOGIC;
        SHIFT_DATA          : out STD_LOGIC;
        START               : out STD_LOGIC;
        UNEXPECTED_END      : out STD_LOGIC
    );
end SPITapFSM;

architecture Behavioral of SPITapFSM is

  type state_type is (
      INIT_STATE,
      CS_H_STATE,
      SPI_START_STATE,
      CS_L_STATE,
      SCK_L_STATE,
      READ_BIT_STATE,
      SCK_H_STATE,
      VALID_STATE,
      BYTE_DONE_H_STATE,
      BYTE_DONE_L_STATE,
      SPI_UNEXPECTED_END_STATE
    );

    signal current_state        : state_type := INIT_STATE;
    signal next_state           : state_type := INIT_STATE;

begin

    FSM_state_register: process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                current_state <= INIT_STATE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;


    FSM_next_state_logic: process (current_state, BYTE_DONE, CS, SCK) begin
  
        next_state <= current_state;
        
        -- INIT states
          
        if current_state = INIT_STATE then
            if (CS = '1') then
                next_state <= CS_H_STATE;
            end if;
    
        elsif current_state = CS_H_STATE then
            if (CS = '0') then
                next_state <= SPI_START_STATE;
            end if;
    
        elsif current_state = SPI_START_STATE then
            next_state <= CS_L_STATE;
    
        elsif current_state = CS_L_STATE then
            if (SCK = '0') then
                next_state <= SCK_L_STATE;
            elsif (CS = '1') then
                next_state <= SPI_UNEXPECTED_END_STATE;
            end if;
    
        elsif current_state = SCK_L_STATE then
            if (SCK = '1') then
                next_state <= READ_BIT_STATE;
            elsif (CS = '1') then
                next_state <= SPI_UNEXPECTED_END_STATE;
            end if;
              
        elsif current_state = READ_BIT_STATE then
            if (BYTE_DONE = '1') then
                next_state <= VALID_STATE;
            else
                next_state <= SCK_H_STATE;
            end if;
              
        elsif current_state = SCK_H_STATE then
            if (SCK = '0') then
                next_state <= SCK_L_STATE;
            elsif (CS = '1') then
                next_state <= SPI_UNEXPECTED_END_STATE;
            end if;
                            
        elsif current_state = VALID_STATE then
            next_state <= BYTE_DONE_H_STATE;
                            
        elsif current_state = BYTE_DONE_H_STATE then
            if (SCK = '0') then
                next_state <= BYTE_DONE_L_STATE;
            elsif (CS = '1') then
                next_state <= CS_H_STATE;
            end if;
            
        elsif current_state = BYTE_DONE_L_STATE then
            if (SCK = '1') then
                next_state <= READ_BIT_STATE;
            elsif (CS = '1') then
                next_state <= CS_H_STATE;
            end if;
            
        elsif current_state = SPI_UNEXPECTED_END_STATE then
            next_state <= CS_H_STATE;
                            
        end if;
      
    end process;


    FSM_output_logic: process (current_state) begin
    
        -- defaults
            VALID               <= '0';
            BIT_COUNT_EN        <= '0';
            BIT_COUNT_RST       <= '0';
            SHIFT_DATA          <= '0';
            START               <= '0';
            UNEXPECTED_END      <= '0';
    
    
        if current_state = CS_H_STATE then
            BIT_COUNT_RST       <= '1';
            
        elsif current_state = SPI_START_STATE then
            START               <= '1';
            
        elsif current_state = READ_BIT_STATE then
            SHIFT_DATA          <= '1';
            BIT_COUNT_EN        <= '1';
            
        elsif current_state = VALID_STATE then
            VALID               <= '1';
       
        elsif current_state = BYTE_DONE_H_STATE then
            BIT_COUNT_RST       <= '1';
            
        elsif current_state = SPI_UNEXPECTED_END_STATE then
            UNEXPECTED_END      <= '1';
        
        end if;
    
    end process;

end Behavioral;

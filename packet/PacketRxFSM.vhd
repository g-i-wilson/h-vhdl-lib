library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity PacketRxFSM is
    port (
        CLK                 : in STD_LOGIC;
        RST                 : in STD_LOGIC;
        
        READY_OUT           : out STD_LOGIC;
        VALID_IN            : in STD_LOGIC;
        
        READY_IN            : in STD_LOGIC;
        VALID_OUT           : out STD_LOGIC;
        
        PACKET_COMPLETE     : in STD_LOGIC
    );
end PacketRxFSM;

architecture Behavioral of PacketRxFSM is

    type state_type is (
        READY_OUT_STATE,
        CHECK_PACKET_STATE,
        VALID_OUT_STATE
    );
    
    signal current_state        : state_type := READY_OUT_STATE;
    signal next_state           : state_type := READY_OUT_STATE;
  
begin

    FSM_state_register: process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                current_state <= READY_OUT_STATE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;


    FSM_next_state_logic: process (current_state, VALID_IN, READY_IN, PACKET_COMPLETE) begin
    
        next_state <= current_state;
        
        case current_state is
        
            when READY_OUT_STATE =>
                if (VALID_IN = '1') then
                    next_state <= CHECK_PACKET_STATE;
                end if;
                
            when CHECK_PACKET_STATE =>
                if (PACKET_COMPLETE = '1') then
                    next_state <= VALID_OUT_STATE;
                else
                    next_state <= READY_OUT_STATE;
                end if;
                
            when VALID_OUT_STATE =>
                if (READY_IN = '1') then
                    next_state <= READY_OUT_STATE;
                end if;
                                
            when others =>
                next_state <= READY_OUT_STATE;
                
        end case;
        
    end process;


  FSM_output_logic: process (current_state) begin
  
    -- defaults
    READY_OUT           <= '0';
    VALID_OUT           <= '0';
    
    case current_state is
        when READY_OUT_STATE         =>
            READY_OUT           <= '1';
        when VALID_OUT_STATE        =>
            VALID_OUT           <= '1';
        when others =>
            -- nothing
    end case;

  end process;

end Behavioral;
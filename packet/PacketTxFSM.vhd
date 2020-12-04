library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity PacketTxFSM is
    port (
        CLK                 : in STD_LOGIC;
        RST                 : in STD_LOGIC;
        
        READY_OUT           : out STD_LOGIC;
        VALID_IN            : in STD_LOGIC;
        
        READY_IN            : in STD_LOGIC;
        VALID_OUT           : out STD_LOGIC;
        
        TIMER_DONE          : in STD_LOGIC;
        TIMER_EN            : out STD_LOGIC;
        TIMER_RST           : out STD_LOGIC;

        OUT_REG_LOAD        : out STD_LOGIC;
        OUT_REG_SHIFT       : out STD_LOGIC;
        
        CHECKSUM_EN         : out STD_LOGIC;
        CHECKSUM_SEL        : out STD_LOGIC;
        CHECKSUM_RST        : out STD_LOGIC
    );
end PacketTxFSM;

architecture Behavioral of PacketTxFSM is

    type state_type is (
        READY_OUT_STATE,
        LOAD_REG_STATE,
        VALID_SYMBOL_STATE,
        SHIFT_REG_STATE,
        LAST_SUM_STATE,
        VALID_CHECKSUM_STATE
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


    FSM_next_state_logic: process (current_state, VALID_IN, READY_IN, TIMER_DONE) begin
    
        next_state <= current_state;
        
        case current_state is
        
            when READY_OUT_STATE =>
                if (VALID_IN = '1') then
                    next_state <= LOAD_REG_STATE;
                end if;
                
            when LOAD_REG_STATE =>
                next_state <= VALID_SYMBOL_STATE;
                
            when VALID_SYMBOL_STATE =>
                if (READY_IN = '1') then
                    if (TIMER_DONE = '1') then
                        next_state <= LAST_SUM_STATE;
                    else
                        next_state <= SHIFT_REG_STATE;
                    end if;
                end if;
                
            when SHIFT_REG_STATE =>
                next_state <= VALID_SYMBOL_STATE;
                
            when LAST_SUM_STATE =>
                next_state <= VALID_CHECKSUM_STATE;
                
            when VALID_CHECKSUM_STATE =>
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
    TIMER_EN            <= '0';
    TIMER_RST           <= '0';
    OUT_REG_LOAD        <= '0';
    OUT_REG_SHIFT       <= '0';
    CHECKSUM_EN         <= '0';
    CHECKSUM_SEL        <= '0';
    CHECKSUM_RST        <= '0';
    
    case current_state is
        when READY_OUT_STATE        =>
            READY_OUT           <= '1';
            TIMER_RST           <= '1';
            CHECKSUM_RST        <= '1';
        when LOAD_REG_STATE         =>
            OUT_REG_LOAD        <= '1';
        when VALID_SYMBOL_STATE     =>
            VALID_OUT           <= '1';
        when SHIFT_REG_STATE        =>
            OUT_REG_SHIFT       <= '1';
            TIMER_EN            <= '1';
            CHECKSUM_EN         <= '1';
        when LAST_SUM_STATE         =>
            CHECKSUM_EN         <= '1';
        when VALID_CHECKSUM_STATE   =>
            CHECKSUM_SEL        <= '1';
            VALID_OUT           <= '1';
        when others =>
            -- nothing
    end case;

  end process;

end Behavioral;

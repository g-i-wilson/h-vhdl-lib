library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SimpleFIFOFSM is
    port (
        CLK         : in std_logic;
        RST         : in std_logic;
                
        TIMER_DONE  : in std_logic;
        TIMER_RST   : out std_logic;
        
        MEM_EN      : out std_logic;
        MEM_RST     : out std_logic
    );
end SimpleFIFOFSM;

architecture Behavioral of SimpleFIFOFSM is

    type state_type is (
--        PRE0_RST_STATE,
--        PRE1_RST_STATE,
        RST_STATE,
        POST0_RST_STATE,
        POST1_RST_STATE,
        ENABLE_STATE
    );
    
--    signal current_state    : state_type := PRE0_RST_STATE;
--    signal next_state       : state_type := PRE0_RST_STATE;
    signal current_state    : state_type := RST_STATE;
    signal next_state       : state_type := RST_STATE;
  
begin

    FSM_state_register: process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
--                current_state <= PRE0_RST_STATE;
                current_state <= RST_STATE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;


    FSM_next_state_logic: process (current_state, TIMER_DONE) begin
    
        next_state <= current_state;
        
        case current_state is
        
--            when PRE0_RST_STATE =>
--                if (TIMER_DONE = '1') then
--                    next_state <= PRE1_RST_STATE;
--                end if;
                
--            when PRE1_RST_STATE =>
--                next_state <= RST_STATE;
                
            when RST_STATE =>
                if (TIMER_DONE = '1') then
                    next_state <= POST0_RST_STATE;
                end if;
                
            when POST0_RST_STATE =>
                next_state <= POST1_RST_STATE;
                
            when POST1_RST_STATE =>
                next_state <= ENABLE_STATE;
                
            when ENABLE_STATE =>
                -- do nothing; wait for RST to return this FSM to the PRE0_RST_STATE
                                                                
            when others =>
--                next_state <= PRE0_RST_STATE;
                next_state <= RST_STATE;
                
        end case;
        
    end process;


  FSM_output_logic: process (current_state) begin
  
    -- defaults
    TIMER_RST           <= '0';
    MEM_EN              <= '0';
    MEM_RST             <= '0';
        
    case current_state is
--        when PRE0_RST_STATE     =>
--            -- default
--        when PRE1_RST_STATE     =>
--            TIMER_RST           <= '1';
        when RST_STATE          =>
            MEM_RST             <= '1';
        when POST0_RST_STATE     =>
            -- default
        when POST1_RST_STATE     =>
            -- default
        when ENABLE_STATE       =>
            MEM_EN              <= '1';
        when others             =>
            -- nothing
    end case;

  end process;

end Behavioral;

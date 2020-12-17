library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FreqBurstFSM is
    port ( 
        CLK             : in STD_LOGIC;
        RST             : in STD_LOGIC;
        
        VALID_IN        : in STD_LOGIC;

        TIMER_MODE_PRE  : out STD_LOGIC;
        TIMER_MODE_STEP : out STD_LOGIC;
        TIMER_MODE_POST : out STD_LOGIC;
        TIMER_EN        : out STD_LOGIC;
        TIMER_RST       : out STD_LOGIC;
        TIMER_DONE      : in STD_LOGIC;
        
        FREQ_RST        : out STD_LOGIC;
        FREQ_EN         : out STD_LOGIC;
        FREQ_DONE       : in STD_LOGIC;
        ZERO_STEP_TIME  : in STD_LOGIC;
        
        CYCLE_RST       : out STD_LOGIC;
        CYCLE_EN        : out STD_LOGIC;
        CYCLE_DONE      : in STD_LOGIC;

        SAMPLE_RST      : out STD_LOGIC;
        SAMPLE_EN       : out STD_LOGIC;
        
        -- debug
        STATE           : out STD_LOGIC_VECTOR(3 downto 0)
    );
end FreqBurstFSM;

architecture Behavioral of FreqBurstFSM is

constant VALID_IN_WAIT_STATE        : std_logic_vector(3 downto 0) := x"0";
constant PRE_INIT_STATE             : std_logic_vector(3 downto 0) := x"1";
constant PRE_STATE                  : std_logic_vector(3 downto 0) := x"2";
constant STEP_INIT_STATE            : std_logic_vector(3 downto 0) := x"3";
constant STEP_WAIT_STATE            : std_logic_vector(3 downto 0) := x"4";
constant STEP_INCR_STATE            : std_logic_vector(3 downto 0) := x"5";
constant POST_INIT_STATE            : std_logic_vector(3 downto 0) := x"6";
constant POST_STATE                 : std_logic_vector(3 downto 0) := x"7";

signal current_state                : std_logic_vector(3 downto 0) := PRE_INIT_STATE;
signal next_state                   : std_logic_vector(3 downto 0) := PRE_INIT_STATE;


begin

    FSM_state_register: process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                current_state <= PRE_INIT_STATE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;
    
    
    STATE <= current_state;


    FSM_next_state_logic: process (
        current_state,
        VALID_IN,
        TIMER_DONE,
        FREQ_DONE,
        CYCLE_DONE,
        ZERO_STEP_TIME
    ) begin
  
        next_state <= current_state;
        
        case current_state is
        
            when PRE_INIT_STATE =>
                if (VALID_IN = '1') then
                    next_state <= PRE_INIT_STATE;
                end if;
        
            when PRE_INIT_STATE =>
                next_state <= PRE_STATE;
        
            when PRE_STATE =>
                if (TIMER_DONE = '1') then
                    if (ZERO_STEP_TIME = '1') then
                        next_state <= POST_INIT_STATE;
                    else
                        next_state <= STEP_INIT_STATE;
                    end if;
                end if;
                  
            when STEP_INIT_STATE =>
                next_state <= STEP_WAIT_STATE;
                  
            when STEP_WAIT_STATE =>
                if (TIMER_DONE = '1') then
                    if (FREQ_DONE = '1') then
                        next_state <= POST_INIT_STATE;
                    else
                        next_state <= STEP_INCR_STATE;
                    end if;
                end if;
                  
            when STEP_INCR_STATE =>
                next_state <= STEP_WAIT_STATE;
                  
            when POST_INIT_STATE =>
                next_state <= POST_STATE;
                  
            when POST_STATE =>
                if (TIMER_DONE = '1') then
                    if (CYCLE_DONE = '1') then
                        next_state <= VALID_IN_WAIT_STATE;
                    else
                        next_state <= PRE_INIT_STATE;
                    end if;
                end if;
                                                      
            when others =>
                next_state <= VALID_IN_WAIT_STATE;         
        end case;
          
    end process;


FSM_output_logic: process (current_state) begin

    -- defaults
        READY_OUT           <= '0';
        VALID_OUT           <= '0';
        SCK_RST             <= '0';
        COUNTER_EN          <= '0';
        COUNTER_RST         <= '0';
        SHIFT_IN_REG        <= '0';
        SHIFT_OUT_REG       <= '0';
        TRISTATE_EN         <= '1';
        CS                  <= '0';
        SCK                 <= '0';

    case current_state is

        -- INIT states
        when READY_OUT_STATE        =>
            READY_OUT       <= '1';
            CS              <= '1';
            SCK_RST         <= '1';
            COUNTER_RST     <= '1';
        when INIT_CS_H_WAIT_STATE   =>
            CS              <= '1';
            
        -- WRITE states
        when W_L_WAIT_STATE         =>
            TRISTATE_EN     <= '0';
        when W_H_WAIT_STATE         =>
            SCK             <= '1';
            TRISTATE_EN     <= '0';
        when W_H_SHIFT_IN_STATE     =>
            SCK             <= '1';
            SHIFT_IN_REG    <= '1';
            TRISTATE_EN     <= '0';
            COUNTER_EN      <= '1';
            
        -- READ states
        when R_L_WAIT_STATE         =>
        when R_H_WAIT_STATE         =>
            SCK             <= '1';
        when R_H_SHIFT_OUT_STATE    =>
            SCK             <= '1';
            SHIFT_OUT_REG   <= '1';
            COUNTER_EN      <= '1';
            
        -- FINAL states
        when CS_L_WAIT_STATE_0      =>
            SCK             <= '1';
        when CS_L_WAIT_STATE_1      =>
            SCK             <= '1';
        when CS_H_WAIT_STATE_0      =>
            SCK             <= '1';
            CS              <= '1';
        when CS_H_WAIT_STATE_1      =>
            SCK             <= '1';
            CS              <= '1';
        when R_VALID_OUT_STATE      =>
            VALID_OUT       <= '1';
            CS              <= '1';
        
        when others =>
            -- default
    end case;

end process;

end Behavioral;

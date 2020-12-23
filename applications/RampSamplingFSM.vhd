library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RampSamplingFSM is
    port ( 
        CLK             : in STD_LOGIC;
        RST             : in STD_LOGIC;
        
        READY_OUT       : out STD_LOGIC;
        VALID_IN        : in STD_LOGIC;

        SAMPLE_IN       : in STD_LOGIC;

        SEGMENT         : out STD_LOGIC_VECTOR(1 downto 0); -- gray-code output to select segment of the frequency burst cycle

        ZERO_PRE        : in STD_LOGIC;
        ZERO_STEP       : in STD_LOGIC;
        ZERO_POST       : in STD_LOGIC;
        TIMER_EN        : out STD_LOGIC;
        TIMER_RST       : out STD_LOGIC;
        TIMER_DONE      : in STD_LOGIC;
        
        FREQ_RST        : out STD_LOGIC;
        FREQ_EN         : out STD_LOGIC;
        FREQ_DONE       : in STD_LOGIC;
        
        CYCLE_RST       : out STD_LOGIC;
        CYCLE_EN        : out STD_LOGIC;
        CYCLE_DONE      : in STD_LOGIC;

        SAMPLE_RST      : out STD_LOGIC;
        SAMPLE_EN       : out STD_LOGIC;
        
        -- debug
        STATE           : out STD_LOGIC_VECTOR(3 downto 0)
    );
end RampSamplingFSM;

architecture Behavioral of RampSamplingFSM is

constant READY_OUT_STATE            : std_logic_vector(3 downto 0) := x"0";
constant CYCLE_RST_STATE            : std_logic_vector(3 downto 0) := x"1";
constant SAMPLE_SYNC_STATE          : std_logic_vector(3 downto 0) := x"2";
constant PRE_INIT_STATE             : std_logic_vector(3 downto 0) := x"3";
constant PRE_STATE                  : std_logic_vector(3 downto 0) := x"4";
constant STEP_INIT_STATE            : std_logic_vector(3 downto 0) := x"5";
constant STEP_STATE                 : std_logic_vector(3 downto 0) := x"6";
constant POST_INIT_STATE            : std_logic_vector(3 downto 0) := x"7";
constant POST_STATE                 : std_logic_vector(3 downto 0) := x"8";

signal current_state                : std_logic_vector(3 downto 0) := READY_OUT_STATE;
signal next_state                   : std_logic_vector(3 downto 0) := READY_OUT_STATE;


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
    
    
    STATE <= current_state;


    FSM_next_state_logic: process (
        current_state,
        VALID_IN,
        TIMER_DONE,
        FREQ_DONE,
        CYCLE_DONE,
        ZERO_PRE,
        ZERO_STEP,
        ZERO_POST,
        SAMPLE_IN
    ) begin
  
        next_state <= current_state;
        
        case current_state is
        
            when READY_OUT_STATE =>
                if (VALID_IN = '1') then
                    next_state <= CYCLE_RST_STATE;
                end if;
        
            when CYCLE_RST_STATE =>
                next_state <= SAMPLE_SYNC_STATE;
        
            when SAMPLE_SYNC_STATE =>
                if (SAMPLE_IN = '1') then
                    next_state <= PRE_INIT_STATE;
                end if;
        
            when PRE_INIT_STATE =>
                if (ZERO_PRE = '1') then
                    next_state <= STEP_INIT_STATE;
                else
                    next_state <= PRE_STATE;
                end if;
        
            when PRE_STATE =>
                if (TIMER_DONE = '1') then
                    if (ZERO_STEP = '1') then
                        next_state <= POST_INIT_STATE;
                    else
                        next_state <= STEP_INIT_STATE;
                    end if;
                end if;
                  
            when STEP_INIT_STATE =>
                if (ZERO_STEP = '1') then
                    next_state <= POST_INIT_STATE;
                else
                    next_state <= STEP_STATE;
                end if;
                  
            when STEP_STATE =>
                if (TIMER_DONE = '1') then
                    if (FREQ_DONE = '1') then
                        next_state <= POST_INIT_STATE;
                    else
                        next_state <= STEP_INIT_STATE;
                    end if;
                end if;
                  
            when POST_INIT_STATE =>
                if (ZERO_POST = '1') then
                    if (CYCLE_DONE = '1') then
                        next_state <= READY_OUT_STATE;
                    else
                        next_state <= SAMPLE_SYNC_STATE;
                    end if;
                else
                    next_state <= POST_STATE;
                end if;
                  
            when POST_STATE =>
                if (TIMER_DONE = '1') then
                    if (CYCLE_DONE = '1') then
                        next_state <= READY_OUT_STATE;
                    else
                        next_state <= SAMPLE_SYNC_STATE;
                    end if;
                end if;
                                                      
            when others =>
                next_state <= READY_OUT_STATE;         
        end case;
          
    end process;


    FSM_output_logic: process (current_state) begin
    
        -- defaults
        READY_OUT       <= '0';
        SEGMENT         <= "00";
        TIMER_EN        <= '0';
        TIMER_RST       <= '0';
        FREQ_RST        <= '0';
        FREQ_EN         <= '0';
        CYCLE_RST       <= '0';
        CYCLE_EN        <= '0';
        SAMPLE_RST      <= '0';
        SAMPLE_EN       <= '0';
    
        case current_state is
        
            when READY_OUT_STATE        =>
                READY_OUT       <= '1';
                SEGMENT         <= "00";
            when CYCLE_RST_STATE        =>
                SEGMENT         <= "01";
                CYCLE_RST       <= '1';
            when SAMPLE_SYNC_STATE      =>
                SEGMENT         <= "01";
                SAMPLE_RST      <= '1';
            when PRE_INIT_STATE         =>
                SEGMENT         <= "01";
                CYCLE_EN        <= '1';
                FREQ_RST        <= '1';
                TIMER_RST       <= '1';
            when PRE_STATE              =>
                SEGMENT         <= "01";
                TIMER_EN        <= '1';
                SAMPLE_EN       <= '1';
            when STEP_INIT_STATE        =>
                SEGMENT         <= "11";
                TIMER_RST       <= '1';                  
                FREQ_EN         <= '1';
            when STEP_STATE             =>
                SEGMENT         <= "11";
                TIMER_EN        <= '1';                  
                SAMPLE_EN       <= '1';
            when POST_INIT_STATE        =>
                SEGMENT         <= "10";
                TIMER_RST       <= '1';                  
            when POST_STATE             =>
                SEGMENT         <= "10";
                TIMER_EN        <= '1';                  
                SAMPLE_EN       <= '1';
            when others                 =>
                -- defaults
        end case;
    
    end process;

end Behavioral;

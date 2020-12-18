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

        SAMPLE          : in STD_LOGIC;

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

constant VALID_IN_STATE             : std_logic_vector(3 downto 0) := x"0";
constant SAMPLE_SYNC_STATE          : std_logic_vector(3 downto 0) := x"1";
constant PRE_INIT_STATE             : std_logic_vector(3 downto 0) := x"2";
constant PRE_STATE                  : std_logic_vector(3 downto 0) := x"3";
constant STEP_INIT_STATE            : std_logic_vector(3 downto 0) := x"4";
constant STEP_STATE                 : std_logic_vector(3 downto 0) := x"5";
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
        ZERO_STEP_TIME,
        SAMPLE
    ) begin
  
        next_state <= current_state;
        
        case current_state is
        
            when VALID_IN_STATE =>
                if (VALID_IN = '1') then
                    next_state <= SAMPLE_SYNC_STATE;
                end if;
        
            when SAMPLE_SYNC_STATE =>
                if (SAMPLE = '1') then
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
                next_state <= STEP_STATE;
                  
            when STEP_STATE =>
                if (TIMER_DONE = '1') then
                    if (FREQ_DONE = '1') then
                        next_state <= POST_INIT_STATE;
                    else
                        next_state <= STEP_INIT_STATE;
                    end if;
                end if;
                  
            when POST_INIT_STATE =>
                next_state <= POST_STATE;
                  
            when POST_STATE =>
                if (TIMER_DONE = '1') then
                    if (CYCLE_DONE = '1') then
                        next_state <= VALID_IN_STATE;
                    else
                        next_state <= SAMPLE_SYNC_STATE;
                    end if;
                end if;
                                                      
            when others =>
                next_state <= VALID_IN_STATE;         
        end case;
          
    end process;


    FSM_output_logic: process (current_state) begin
    
        -- defaults
        TIMER_MODE_PRE  <= '0';
        TIMER_MODE_STEP <= '0';
        TIMER_MODE_POST <= '0';
        TIMER_EN        <= '0';
        TIMER_RST       <= '0';
        FREQ_RST        <= '0';
        FREQ_EN         <= '0';
        CYCLE_RST       <= '0';
        CYCLE_EN        <= '0';
        SAMPLE_RST      <= '0';
        SAMPLE_EN       <= '0';
    
        case current_state is
        
            when VALID_IN_STATE         =>
                CYCLE_RST       <= '1';
            when SAMPLE_SYNC_STATE      =>
                SAMPLE_RST      <= '1';
            when PRE_INIT_STATE         =>
                CYCLE_EN        <= '1';
                FREQ_RST        <= '1';
                TIMER_MODE_PRE  <= '1';
                TIMER_RST       <= '1';
            when PRE_STATE              =>
                TIMER_MODE_PRE  <= '1';
                TIMER_EN        <= '1';
                SAMPLE_EN       <= '1';
            when STEP_INIT_STATE        =>
                TIMER_MODE_STEP <= '1';
                TIMER_RST       <= '1';                  
                FREQ_EN         <= '1';
            when STEP_STATE             =>
                TIMER_MODE_STEP <= '1';
                TIMER_EN        <= '1';                  
                SAMPLE_EN       <= '1';
            when POST_INIT_STATE        =>
                TIMER_MODE_POST <= '1';
                TIMER_RST       <= '1';                  
            when POST_STATE             =>
                TIMER_MODE_POST <= '1';
                TIMER_EN        <= '1';                  
                SAMPLE_EN       <= '1';
            when others                 =>
                -- defaults
        end case;
    
    end process;

end Behavioral;

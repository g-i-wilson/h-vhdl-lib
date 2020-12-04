library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPITransactionFSM is
    port ( 
        CLK             : in STD_LOGIC;
        RST             : in STD_LOGIC;
        
        VALID_IN        : in STD_LOGIC;
        READY_OUT       : out STD_LOGIC;

        VALID_OUT       : out STD_LOGIC;
        READY_IN        : in STD_LOGIC;

        WRITE           : in STD_LOGIC := '0';

        SCK_EDGE        : in STD_LOGIC;
        SCK_RST         : out STD_LOGIC;

        COUNTER_EN      : out STD_LOGIC;
        ADDR_DONE       : in STD_LOGIC;
        DATA_DONE       : in STD_LOGIC;
        COUNTER_RST     : out STD_LOGIC;
        
        SHIFT_IN_REG    : out STD_LOGIC;
        SHIFT_OUT_REG   : out STD_LOGIC;

        TRISTATE_EN     : out STD_LOGIC;

        CS              : out STD_LOGIC;
        SCK             : out STD_LOGIC;
        
        -- debug
        STATE           : out STD_LOGIC_VECTOR(3 downto 0)
    );
end SPITransactionFSM;

architecture Behavioral of SPITransactionFSM is

-- CS high, READY_OUT high... waiting for VALID_IN
constant READY_OUT_STATE            : std_logic_vector(3 downto 0) := x"0";
-- set CLK L and wait for half-period
constant INIT_CS_H_WAIT_STATE       : std_logic_vector(3 downto 0) := x"1";
-- (DATA_IN is a "don't care" if in READ mode)

-- CS H -> L
-- WRITE used for both ADDR and DATA_IN
constant W_L_WAIT_STATE             : std_logic_vector(3 downto 0) := x"2";
constant W_H_WAIT_STATE             : std_logic_vector(3 downto 0) := x"3";
constant W_H_SHIFT_IN_STATE         : std_logic_vector(3 downto 0) := x"4";
-- if not WRITE bit, go to R_L_WAIT_STATE at ADDR_DONE signal; otherwise keep looping back to W_L_WAIT_STATE until DATA_DONE signal & jump to 

-- if not WRITE bit, switches to READ mode after writing ADDR
constant R_L_WAIT_STATE             : std_logic_vector(3 downto 0) := x"5";
constant R_H_WAIT_STATE             : std_logic_vector(3 downto 0) := x"6";
constant R_H_SHIFT_OUT_STATE        : std_logic_vector(3 downto 0) := x"7";
-- if not DATA_DONE signal, keep looping back to the R_L_WAIT_STATE

-- For some chips, CS must stay low for one more full clock cycle
constant CS_L_WAIT_STATE_0          : std_logic_vector(3 downto 0) := x"8";
constant CS_L_WAIT_STATE_1          : std_logic_vector(3 downto 0) := x"9";

-- Set CS line high for at least one full clock cycle
-- CS L -> H
constant CS_H_WAIT_STATE_0          : std_logic_vector(3 downto 0) := x"a";
constant CS_H_WAIT_STATE_1          : std_logic_vector(3 downto 0) := x"b";

-- if WRITE bit, skip R_VALID_OUT_STATE and go directly to READY_OUT_STATE
-- wait for the READY_IN signal (CS high)
constant R_VALID_OUT_STATE          : std_logic_vector(3 downto 0) := x"c";


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
        WRITE,
        VALID_IN,
        READY_IN,
        SCK_EDGE,
        ADDR_DONE,
        DATA_DONE
    ) begin
  
        next_state <= current_state;
        
        case current_state is
        
            -- INIT states
    
            when READY_OUT_STATE =>
                if (VALID_IN = '1') then
                    next_state <= INIT_CS_H_WAIT_STATE;
                end if;
        
            when INIT_CS_H_WAIT_STATE =>
                if (SCK_EDGE = '1') then
                    next_state <= W_L_WAIT_STATE;
                end if;
                  
            -- WRITE states
                              
            when W_L_WAIT_STATE =>
                if (SCK_EDGE = '1') then
                    next_state <= W_H_WAIT_STATE;
                end if;
                  
            when W_H_WAIT_STATE =>
                if (SCK_EDGE = '1') then
                    next_state <= W_H_SHIFT_IN_STATE;
                end if;
                  
            when W_H_SHIFT_IN_STATE =>
                if (WRITE = '0' and ADDR_DONE = '1') then
                    next_state <= R_L_WAIT_STATE;
                elsif (WRITE = '1' and DATA_DONE = '1') then
                    next_state <= CS_L_WAIT_STATE_0;
                else
                    next_state <= W_L_WAIT_STATE;
                end if;
                  
            -- READ states
                              
            when R_L_WAIT_STATE =>
                if (SCK_EDGE = '1') then
                    next_state <= R_H_WAIT_STATE;
                end if;
                  
            when R_H_WAIT_STATE =>
                if (SCK_EDGE = '1') then
                    next_state <= R_H_SHIFT_OUT_STATE;
                end if;
                
            when R_H_SHIFT_OUT_STATE =>
                if (DATA_DONE = '1') then
                    next_state <= CS_L_WAIT_STATE_0;
                else
                    next_state <= R_L_WAIT_STATE;
                end if;
                  
            -- FINAL states
            
            when CS_L_WAIT_STATE_0 =>
                if (SCK_EDGE = '1') then
                    next_state <= CS_L_WAIT_STATE_1;
                end if;
                  
            when CS_L_WAIT_STATE_1 =>
                if (SCK_EDGE = '1') then
                    next_state <= CS_H_WAIT_STATE_0;
                end if;
                  
            when CS_H_WAIT_STATE_0 =>
                if (SCK_EDGE = '1') then
                    next_state <= CS_H_WAIT_STATE_1;
                end if;
                  
            when CS_H_WAIT_STATE_1 =>
                if (SCK_EDGE = '1') then
                    if (WRITE = '1') then
                        next_state <= READY_OUT_STATE;
                    else
                        next_state <= R_VALID_OUT_STATE;
                    end if;
                end if;
                
            when R_VALID_OUT_STATE =>
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

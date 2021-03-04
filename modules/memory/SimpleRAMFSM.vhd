library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SimpleRAMFSM is
    port ( 
        CLK                         : in STD_LOGIC;
        RST                         : in STD_LOGIC;
        
        WRITE                       : in STD_LOGIC;

        VALID_IN                    : in STD_LOGIC;
        READY_OUT                   : out STD_LOGIC;
        
        VALID_OUT                   : out STD_LOGIC;
        READY_IN                    : in STD_LOGIC;
        
        -- debug
        STATE                       : out STD_LOGIC_VECTOR(3 downto 0)
    );
end SimpleRAMFSM;

architecture Behavioral of SimpleRAMFSM is

constant READY_OUT_STATE            : std_logic_vector(3 downto 0) := x"0";
constant VALID_OUT_STATE            : std_logic_vector(3 downto 0) := x"1";


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
        WRITE,
        VALID_IN,
        READY_IN
    ) begin
  
        next_state <= current_state; -- default
        
        case current_state is
        
            when READY_OUT_STATE => -- stays in the READY_OUT_STATE during a WRITE
                if (VALID_IN = '1' and WRITE='0') then
                    next_state <= VALID_OUT_STATE;
                end if;
                  
            when VALID_OUT_STATE => -- only happens in a READ
                if (READY_IN='1') then
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

        when READY_OUT_STATE        =>
        READY_OUT           <= '1';
            
        when VALID_OUT_STATE        =>
        VALID_OUT           <= '1';
                    
        when others =>
            -- default
    end case;

end process;

end Behavioral;

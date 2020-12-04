library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPIConfigureFSM is
    port ( 
        CLK             : in STD_LOGIC;
        RST             : in STD_LOGIC;

        SPI_READY       : in STD_LOGIC;
        SPI_VALID       : in STD_LOGIC;        
        VERIFIED_DATA   : in STD_LOGIC;
        CONFIG_DONE     : in STD_LOGIC;
        VERIFY_DONE     : in STD_LOGIC;
        ALLOW_RETRY		: in STD_LOGIC;
        RETRY		    : in STD_LOGIC;
        
        EN_CONFIG       : out STD_LOGIC;
        EN_VERIFY       : out STD_LOGIC;
        REG_VALID       : out STD_LOGIC;
        READY_TO_VERIFY : out STD_LOGIC;
        CONFIG_SELECT   : out STD_LOGIC;
        COUNTER_EN      : out STD_LOGIC;
        COUNTER_RST     : out STD_LOGIC;
        RETRY_EN        : out STD_LOGIC;
        RETRY_RST       : out STD_LOGIC;
        VERIFY_FAIL     : out STD_LOGIC;
        VERIFY_PASS     : out STD_LOGIC;
        WRITE           : out STD_LOGIC;
        
        -- debug
        STATE           : out STD_LOGIC_VECTOR(3 downto 0)
    );
end SPIConfigureFSM;

architecture Behavioral of SPIConfigureFSM is

constant CONFIG_VALID_STATE         : std_logic_vector(3 downto 0) := x"0";
constant EN_CONFIG_STATE            : std_logic_vector(3 downto 0) := x"1";
constant CONFIG_DONE_STATE          : std_logic_vector(3 downto 0) := x"2";
constant VERIFY_VALID_STATE         : std_logic_vector(3 downto 0) := x"3";
constant VERIFY_READY_STATE         : std_logic_vector(3 downto 0) := x"4";
constant EN_VERIFY_STATE            : std_logic_vector(3 downto 0) := x"5";
constant VERIFY_FAIL_STATE          : std_logic_vector(3 downto 0) := x"6";
constant RETRY_STATE                : std_logic_vector(3 downto 0) := x"7";
constant VERIFY_PASS_STATE          : std_logic_vector(3 downto 0) := x"8";



signal current_state                : std_logic_vector(3 downto 0) := CONFIG_VALID_STATE;
signal next_state                   : std_logic_vector(3 downto 0) := CONFIG_VALID_STATE;


begin

    FSM_state_register: process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                current_state <= CONFIG_VALID_STATE;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;
    
    
    STATE <= current_state;


    FSM_next_state_logic: process (
        current_state,
        SPI_READY,
        SPI_VALID,     
        VERIFIED_DATA,
        CONFIG_DONE,
        VERIFY_DONE,
        RETRY
    ) begin
  
        next_state <= current_state;
        
        case current_state is
        
            when CONFIG_VALID_STATE =>
                if (SPI_READY = '1') then
                    next_state <= EN_CONFIG_STATE;
                end if;
                  
            when EN_CONFIG_STATE =>
                if (CONFIG_DONE = '1') then
                    next_state <= CONFIG_DONE_STATE;
                else
                    next_state <= CONFIG_VALID_STATE;
                end if;
        
            when CONFIG_DONE_STATE =>
                if (SPI_READY = '1') then
                    next_state <= VERIFY_VALID_STATE;
                end if;
                  
            when VERIFY_VALID_STATE =>
                if (SPI_VALID = '1') then
                    next_state <= VERIFY_READY_STATE;
                end if;
                  
            when VERIFY_READY_STATE =>
                if (VERIFIED_DATA = '1') then
                    if (VERIFY_DONE = '1') then
                        next_state <= VERIFY_PASS_STATE;
                    else
                        next_state <= EN_VERIFY_STATE;
                    end if;
                else
                    next_state <= VERIFY_FAIL_STATE;
                end if;
                              
            when EN_VERIFY_STATE =>
                next_state <= VERIFY_VALID_STATE;
        
            when VERIFY_PASS_STATE =>
                -- do nothing; requires a RST to leave this state
                                                      
            when VERIFY_FAIL_STATE =>
                if (ALLOW_RETRY = '1') then
                    next_state <= RETRY_STATE;
                end if;
                                                      
            when RETRY_STATE =>
                if (RETRY = '1') then
                    next_state <= CONFIG_VALID_STATE;
                end if;
                                                      
            when others =>
                next_state <= VERIFY_FAIL_STATE;  
                       
        end case;
          
    end process;


FSM_output_logic: process (current_state) begin

    -- defaults
        EN_CONFIG           <= '0';
        EN_VERIFY           <= '0';
        REG_VALID           <= '0';
        READY_TO_VERIFY     <= '0';
        CONFIG_SELECT       <= '0';
        COUNTER_EN          <= '0';
        COUNTER_RST         <= '0';
        RETRY_EN            <= '0';
        RETRY_RST           <= '0';
        VERIFY_FAIL         <= '0';
        VERIFY_PASS         <= '0';
        WRITE               <= '0';

    case current_state is

        when CONFIG_VALID_STATE     =>
        CONFIG_SELECT       <= '1';
        WRITE               <= '1';
        REG_VALID           <= '1';
            
        when EN_CONFIG_STATE        =>
        CONFIG_SELECT       <= '1';
        WRITE               <= '1';
        EN_CONFIG           <= '1';
        COUNTER_EN          <= '1';
            
        when CONFIG_DONE_STATE =>
        CONFIG_SELECT       <= '1';
        WRITE               <= '1';
        COUNTER_RST         <= '1';
        RETRY_RST           <= '1';
            
        when VERIFY_VALID_STATE     =>
        REG_VALID           <= '1';
            
        when VERIFY_READY_STATE     =>
        READY_TO_VERIFY     <= '1';

        when EN_VERIFY_STATE        =>
        EN_VERIFY           <= '1';
        COUNTER_EN          <= '1';
           
        when VERIFY_PASS_STATE      =>
        VERIFY_PASS         <= '1';
                    
        when VERIFY_FAIL_STATE      =>
        VERIFY_FAIL         <= '1';
                    
        when RETRY_STATE            =>
        RETRY_EN            <= '1';
        COUNTER_RST         <= '1';
            
        when others =>
            -- default
    end case;

end process;

end Behavioral;

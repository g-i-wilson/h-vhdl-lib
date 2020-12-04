library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


use IEEE.NUMERIC_STD.ALL;


entity Reg1DSymbols is
    generic (
        LENGTH          : positive := 4;
        SYMBOL_WIDTH    : positive := 8;
        BIG_ENDIAN      : boolean := FALSE
    );
    port (
        CLK             : in std_logic;
        RST             : in std_logic;
        
        SHIFT_EN        : in std_logic := '0';
        SHIFT_IN        : in std_logic_vector(SYMBOL_WIDTH-1 downto 0) := (others=>'0');
        
        PAR_EN          : in std_logic := '0';
        PAR_IN          : in std_logic_vector(LENGTH*SYMBOL_WIDTH-1 downto 0) := (others=>'0');
        
        DEFAULT_STATE   : in std_logic_vector(LENGTH*SYMBOL_WIDTH-1 downto 0) := (others=>'0');
        
        SHIFT_OUT       : out std_logic_vector(SYMBOL_WIDTH-1 downto 0);
        PAR_OUT         : out std_logic_vector(LENGTH*SYMBOL_WIDTH-1 downto 0)
    );
end;


architecture Behavioral of Reg1DSymbols is

    signal reg_state            : std_logic_vector(LENGTH*SYMBOL_WIDTH-1 downto 0);

begin

    PAR_OUT <= reg_state;

    process (reg_state) begin
        if (BIG_ENDIAN) then
            SHIFT_OUT <= reg_state(LENGTH*SYMBOL_WIDTH-1 downto (LENGTH-1)*SYMBOL_WIDTH);
        else
            SHIFT_OUT <= reg_state(SYMBOL_WIDTH-1 downto 0);
        end if;
    end process;

    process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                reg_state <= DEFAULT_STATE;
            elsif (SHIFT_EN = '1') then
                if (BIG_ENDIAN) then
                    reg_state <= reg_state((LENGTH-1)*SYMBOL_WIDTH-1 downto 0) & SHIFT_IN;
                else
                    reg_state <= SHIFT_IN & reg_state(LENGTH*SYMBOL_WIDTH-1 downto SYMBOL_WIDTH);
                end if;
            elsif (PAR_EN = '1') then
                reg_state <= PAR_IN;
            end if;
        end if;
    end process;
    
    
end Behavioral;

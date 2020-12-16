library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TimerBidirectional is
    generic (
        WIDTH               : positive := 3
    );
    port (
        -- inputs
        CLK                 : in STD_LOGIC;
        EN                  : in STD_LOGIC := '1';
        RST                 : in STD_LOGIC;
        COUNT_START         : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'0');
        COUNT_END           : in STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others=>'1');
        -- outputs
        DONE                : out STD_LOGIC;
        COUNT               : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
   );
end TimerBidirectional;

architecture Behavioral of TimerBidirectional is

    signal done_sig         : std_logic := '0';
    signal enable_count_sig : std_logic := '0';
    signal almost_done_sig  : std_logic := '0';
    signal count_in_sig     : std_logic_vector (WIDTH-1 downto 0) := (others=>'0');
    signal count_out_sig    : std_logic_vector (WIDTH-1 downto 0) := (others=>'0');

begin
    
    almost_done_sig <= '1' when (
        unsigned(count_in_sig) = unsigned(COUNT_END) or
        unsigned(COUNT_START) = unsigned(COUNT_END)
    ) else '0';
    
    enable_count_sig <= EN and (not done_sig);
    
    COUNT <= count_out_sig;
    DONE <= done_sig;

    process (COUNT_START, COUNT_END, count_out_sig) begin
        if (unsigned(COUNT_START) > unsigned(COUNT_END)) then
            count_in_sig <= std_logic_vector( unsigned(count_out_sig) - 1 );
        else
            count_in_sig <= std_logic_vector( unsigned(count_out_sig) + 1 );
        end if;
    end process;

    process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                count_out_sig <= COUNT_START;
            elsif (enable_count_sig = '1') then
                count_out_sig <= count_in_sig;
            else
                count_out_sig <= count_out_sig;
            end if;
        end if;
    end process;
    
    process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                done_sig <= almost_done_sig;
            elsif (enable_count_sig = '1') then
                done_sig <= almost_done_sig;
            else
                done_sig <= done_sig;
            end if;
        end if;
    end process;

end Behavioral;

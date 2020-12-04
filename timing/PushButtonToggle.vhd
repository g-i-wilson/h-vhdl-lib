library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity PushButtonToggle is
  port (
    RST                       : in std_logic;
    CLK                       : in std_logic;
    SIG_IN                    : in std_logic;

    SIG_OUT                   : out std_logic
  );
end PushButtonToggle;


architecture Behavioral of PushButtonToggle is

    signal edge_sig : std_logic;
    signal data_sig : std_logic;
    signal toggle_sig : std_logic;

begin


  rising_edge_detect: entity work.EdgeDetector
  generic map (
    SAMPLE_LENGTH             => 32,
    SUM_WIDTH                 => 5,
    LOGIC_HIGH                => 24,
    LOGIC_LOW                 => 8,
    SUM_START                 => 15
  )
  port map (
    RST                       => RST,
    CLK                       => CLK,

    SAMPLE                    => '1',
    SIG_IN                    => SIG_IN,

    EDGE_EVENT                => edge_sig,
    DATA                      => data_sig
  );
  
  ff: process (CLK) begin
      if rising_edge(CLK) then
        if (RST = '1') then
            toggle_sig <= '0';
        elsif (edge_sig = '1' and data_sig = '1') then
            toggle_sig <= not toggle_sig;
        else
            toggle_sig <= toggle_sig;
        end if;
      end if;
  end process;

  SIG_OUT <= toggle_sig;
    

end Behavioral;

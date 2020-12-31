library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Basys3Essentials is
    generic (
        SW_WIDTH                : positive := 16;
        SW_SAMPLE_LENGTH        : positive := 32;
        SW_SUM_WIDTH            : positive := 5;
        CLK_LED_PERIOD_WIDTH    : positive := 28
    );
    port (
        CLK_IN                  : in std_logic;
        CLK_OUT                 : out std_logic;
        CLK_LED                 : out std_logic;
        CLK_LED_PERIOD          : in std_logic_vector(CLK_LED_PERIOD_WIDTH-1 downto 0) := (others => '1');
        RST_MMCM                : in std_logic := '0';
        RST_IN                  : in std_logic := '0';
        RST_OUT                 : out std_logic;
        SW_IN                  	: in std_logic_vector(SW_WIDTH-1 downto 0) := (others => '0');
        SW_OUT                 	: out std_logic_vector(SW_WIDTH-1 downto 0)
    );
end Basys3Essentials;


architecture Behavioral of Basys3Essentials is

    signal clk_sig              : std_logic;
    
    signal rst_mmcm_sig         : std_logic := '1';
    signal rst_in_inv_sig       : std_logic := '0';
    signal rst_combined_sig     : std_logic := '1';
    signal rst_combined_inv_sig : std_logic := '0';
    
begin
		
    CLK_OUT <= clk_sig;
    
    rst_in_inv_sig <= not RST_IN;
    rst_combined_sig <= not rst_combined_inv_sig;
    
    RST_OUT <= rst_combined_sig;
    
    MCMM : entity work.SimpleMMCM2
        generic map (
            CLKIN_PERIOD        => 10.000,
            PLL_MUL             => 10.00,     -- 100MHz * 10.00 = 1GHZ
            PLL_DIV             => 10       -- 1GHz / 10 = 100MHz
        )
        port map (
            CLK_IN              => CLK_IN,
            CLK_OUT             => clk_sig,
            RST_IN              => RST_MMCM,
            RST_OUT             => rst_mmcm_sig
        );    

    debounce_RST : entity work.Synchronizer
        generic map (
            SYNC_LENGTH     => 3
        )
        port map (
            RST             => rst_mmcm_sig,
            CLK             => clk_sig,
            SIG_IN        	=> rst_in_inv_sig,
            SIG_OUT         => rst_combined_inv_sig
        );

    debounce_input_bank: entity work.ParEdgeDetector
        generic map (
            PAR_WIDTH                 => SW_WIDTH,
            SAMPLE_LENGTH             => SW_SAMPLE_LENGTH,
            SUM_WIDTH                 => 5,
            LOGIC_HIGH                => SW_SAMPLE_LENGTH*3/4,
            LOGIC_LOW                 => SW_SAMPLE_LENGTH*1/4,
            SUM_START                 => SW_SAMPLE_LENGTH/2
        )
        port map (
            RST                       => rst_mmcm_sig,
            CLK                       => clk_sig,
            
            SAMPLE                    => '1',
            SIG_IN                    => SW_IN,
            
            EDGE_EVENT                => open,
            DATA                      => SW_OUT
        );
        
    CLK_indicator : entity work.SquareWaveGenerator
        generic map (
            WIDTH           => CLK_LED_PERIOD_WIDTH
        )
        port map (
            CLK             => clk_sig,
            EN              => '1',
            RST             => rst_mmcm_sig,
            ON_PERIOD       => CLK_LED_PERIOD,
            OFF_PERIOD      => CLK_LED_PERIOD,
            INIT_ON_PERIOD  => CLK_LED_PERIOD,
            INIT_OFF_PERIOD => CLK_LED_PERIOD,
            EDGE_EVENT      => open,
            SQUARE_WAVE     => CLK_LED
        );


end Behavioral;

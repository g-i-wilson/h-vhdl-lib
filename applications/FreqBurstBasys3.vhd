library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity FreqBurstBasys3 is
    port (
        CLK                     : in std_logic;
        
        led                     : out std_logic_vector(15 downto 0);
        sw                      : in std_logic_vector(15 downto 0);
        
        btnL                    : in std_logic;
        btnR                    : in std_logic;

        JA_0                    : out std_logic;
        JA_1                    : out std_logic;
        JA_2                    : out std_logic;
        JA_3                    : out std_logic;
        
        JA_6                    : out std_logic;
        JA_7                    : in std_logic;
        
        XA1_P                   : in std_logic;
        XA1_N                   : out std_logic;
        XA2_P                   : in std_logic;
        XA2_N                   : out std_logic;
        
        RX                      : in std_logic;
        TX                      : out std_logic
    );
end FreqBurstBasys3;


architecture Behavioral of FreqBurstBasys3 is

    signal clk_sig                  : std_logic;
    signal rst_sig                  : std_logic;
    signal sw_sig                   : std_logic_vector(15 downto 0);

    
begin

    Basys3Essentials_module: entity work.Basys3Essentials
        generic map (
            SW_WIDTH                => 16,
            SW_SAMPLE_LENGTH        => 32,
            SW_SUM_WIDTH            => 5,
            CLK_LED_PERIOD_WIDTH    => 28
        )
        port map (
            CLK_IN                  => CLK,
            CLK_OUT                 => clk_sig,
            CLK_LED                 => led(0),
            CLK_LED_PERIOD          => x"2FAF080",
            RST_MMCM                => btnR,
            RST_IN                  => btnL,
            RST_OUT                 => rst_sig,
            SW_IN                  	=> sw,
            SW_OUT                 	=> sw_sig
    );

    led(1) <= rst_sig;
    
    JA_7 <= sw_sig(15);
    
    led(15) <= sw_sig(15);

    FreqBurst_module: entity work.FreqBurst
        generic map (
            -- Sample rate
            SAMPLE_PERIOD           => 99,   -- units of clock cycles (minus 1)
            SAMPLE_PERIOD_WIDTH     => 8,
            -- Serial rate
            SERIAL_RATE             => 99,   -- units of clock cycles (minus 1)
            -- RF freq (DAC)
            RF_FREQ_WIDTH           => 4,    -- width of output vlaues to DAC controlling RF freq
            -- RF div
            RF_DIV_PERIOD_WIDTH     => 8,    -- width of div-freq period (units of clock cycles)
            RF_DIV_MA_LENGTH        => 4,    -- number of samples in MA filter
            RF_DIV_MA_SUM_WIDTH     => 12,   -- width of div-freq MA sum
            RF_DIV_MA_SUM_SHIFT     => 2,    -- divide the MA sum by shifting
            -- cycles
            CYCLE_COUNT_WIDTH       => 8,    -- width of cycles-1 total & width of cycle count
            -- samples
            SAMPLE_COUNT_WIDTH      => 16,   -- width of samples-1 totals & width of sample counts
            -- I & Q (ADCs)
            ADC_WIDTH               => 16    -- width of I & Q data input from ADCs
        )
        port map (
            CLK                     => clk_sig,
            RST                     => rst_sig,
            -- RF freq (simple DAC)
            RF_FREQ(3)              => JA_0,
            RF_FREQ(2)              => JA_1,
            RF_FREQ(1)              => JA_2,
            RF_FREQ(0)              => JA_3,
            -- RF div
            RF_DIV                  => JA_7,        
            -- I & Q (simple delta-sigma ADCs)
            I_ADC_CMP               => XA1_P,
            I_ADC_INV               => XA1_N,
            Q_ADC_CMP               => XA2_P,
            Q_ADC_INV               => XA2_N,
            -- Serial IO
            RX                      => RX,
            TX                      => TX
        );

end Behavioral;

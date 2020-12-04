library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TestPacketTx is
    port (
        -- inputs
        CLK             : in STD_LOGIC;
        sw              : in STD_LOGIC_VECTOR (15 downto 0);
        -- outputs
        TX              : out STD_LOGIC;
        led             : out STD_LOGIC_VECTOR (15 downto 0)
    );
end TestPacketTx;

architecture Behavioral of TestPacketTx is

    signal clk_100MHz_sig : std_logic;
    signal rst_100MHz_sig : std_logic;
    signal clk_sig : std_logic;
    signal rst_sig : std_logic;
    signal ready_in_sig : std_logic;
    signal valid_out_sig : std_logic;
    signal valid_in_sig : std_logic;
    signal tx_data : std_logic_vector(7 downto 0);
    signal uart_period_sig : std_logic_vector(15 downto 0);
    signal sw_data_sig : std_logic_vector(15 downto 0);
    signal packet_in_sig : std_logic_vector(31 downto 0);
    
begin

    clk_100MHz_module : entity work.SimpleMMCM2
        generic map (
            CLKIN_PERIOD        => 10.000,
            PLL_MUL             => 10.00,     -- 100MHz * 10.00 = 1GHZ
            PLL_DIV             => 10       -- 1GHz / 10 = 100MHz
        )
        port map (
            CLK_IN              => CLK,
            RST_OUT             => rst_sig,
            CLK_OUT             => clk_sig
        );
    
    LED_blink : entity work.SquareWaveGenerator
        generic map (
            WIDTH           => 28
        )
        port map (
            CLK             => clk_sig,
            EN              => '1',
            RST             => rst_sig,
            ON_PERIOD       => x"2FAF080", -- period-1
            OFF_PERIOD      => x"2FAF080", -- period-1
            INIT_ON_PERIOD  => x"2FAF080", -- period-1
            INIT_OFF_PERIOD => x"2FAF080", -- period-1
            EDGE_EVENT      => open,
            SQUARE_WAVE     => led(0)
        );

    baud_config: entity work.ParEdgeDetector
        generic map (
            PAR_WIDTH                 => 16,
            SAMPLE_LENGTH             => 32,
            SUM_WIDTH                 => 5,
            LOGIC_HIGH                => 24,
            LOGIC_LOW                 => 8,
            SUM_START                 => 15
        )
        port map (
            RST                       => rst_sig,
            CLK                       => clk_sig,
            
            SAMPLE                    => '1',
            SIG_IN                    => sw,
            
            EDGE_EVENT                => open,
            DATA                      => sw_data_sig
        );


    bit_pulses : entity work.PulseGenerator
        generic map (
            WIDTH               => 28 
        )
        port map (
            -- inputs
            CLK                 => clk_sig,
            RST                 => rst_sig,
            EN                  => '1',
            PERIOD              => x"5F5E100", -- 100MHz/1Hz to hex
            INIT_PERIOD         => x"5F5E100",
            -- outputs
            PULSE               => valid_in_sig
        );

    uart_period_sig <= x"00" & sw_data_sig(7 downto 0);
    
    packet_in_sig <= x"010203" & sw_data_sig(15 downto 8);
    
    PacketTx_module: entity work.PacketTx
        generic map (
            SYMBOL_WIDTH        => 8,
            PACKET_SYMBOLS      => 4
        )
        port map (
            CLK                 => clk_sig,
            RST                 => rst_sig,
            
            READY_OUT           => open,
            VALID_IN            => valid_in_sig,
            
            READY_IN            => ready_in_sig,
            VALID_OUT           => valid_out_sig,
            
            PACKET_IN           => packet_in_sig,
            SYMBOL_OUT          => tx_data
        );

    Tx_module: entity work.SerialTx
        port map ( 
            -- inputs
            CLK => clk_sig,
            EN => '1',
            RST => rst_sig,
            BIT_TIMER_PERIOD => uart_period_sig,
            VALID => valid_out_sig,
            DATA => tx_data,
            -- outputs
            READY => ready_in_sig,
            TX => TX
        );
    
end Behavioral;

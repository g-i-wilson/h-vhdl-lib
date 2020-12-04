library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TestSPIConfigure is
    port (
        -- Tx/Rx
        CLK             : in STD_LOGIC;
        sw              : in STD_LOGIC_VECTOR (15 downto 0);
        RX              : in STD_LOGIC;
        TX              : out STD_LOGIC;
        led             : out STD_LOGIC_VECTOR (15 downto 0)
        
    );
end TestSPIConfigure;

architecture Behavioral of TestSPIConfigure is

    signal clk_100MHz_sig 	    : std_logic;
    signal rst_100MHz_sig 	    : std_logic;
    signal clk_sig 				: std_logic;
    signal rst_sig 				: std_logic;
    signal rst_mmcm_sig         : std_logic;
    signal ready_in_sig         : std_logic;
    signal valid_out_sig 		: std_logic;
    signal valid_in_sig 		: std_logic;
    signal tx_data_sig 			: std_logic_vector(7 downto 0);
    signal sw_data_sig 			: std_logic_vector(15 downto 0);
    signal packet_sig 			: std_logic_vector(47 downto 0);
    signal cs_sig 				: std_logic;
    signal sck_sig 				: std_logic;
    signal mosi_sig 			: std_logic;
    signal miso_sig 			: std_logic;
    signal tristate_en_sig 	    : std_logic;
    signal pass_sig 			: std_logic;
    signal fail_sig 			: std_logic;
    signal send_packet_sig	    : std_logic;
    signal retry_sig 			: std_logic;
    signal verify_addr_sig 	    : std_logic_vector(15 downto 0);
    signal verify_data_sig 	    : std_logic_vector(7 downto 0);
    signal actual_data_sig 	    : std_logic_vector(7 downto 0);
    
begin

    CLK_100MHz_module : entity work.SimpleMMCM2
        generic map (
            CLKIN_PERIOD        => 10.000,
            PLL_MUL             => 10.00,     -- 100MHz * 10.00 = 1GHZ
            PLL_DIV             => 10       -- 1GHz / 10 = 100MHz
        )
        port map (
            CLK_IN              => CLK,
            RST_OUT             => rst_mmcm_sig,
            CLK_OUT             => clk_sig
        );
        
    input_sw_bank: entity work.ParEdgeDetector
        generic map (
            PAR_WIDTH                 => 16,
            SAMPLE_LENGTH             => 32,
            SUM_WIDTH                 => 5,
            LOGIC_HIGH                => 24,
            LOGIC_LOW                 => 8,
            SUM_START                 => 15
        )
        port map (
            RST                       => rst_mmcm_sig,
            CLK                       => clk_sig,
            
            SAMPLE                    => '1',
            SIG_IN                    => sw,
            
            EDGE_EVENT                => open,
            DATA                      => sw_data_sig
        );

    rst_sig <= rst_mmcm_sig or sw_data_sig(0);
    led(0) <= rst_sig;
    
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
            SQUARE_WAVE     => led(1)
        );

    SPIConfigure_module: entity work.SPIConfigure
        generic map (
            ADDR_WIDTH                  => 16,
            DATA_WIDTH		            => 8,
            CONFIG_LENGTH               => 2,
            VERIFY_LENGTH               => 2,
            SCK_HALF_PERIOD_WIDTH       => 28,
            VERIFY_RETRY_PERIOD_WIDTH   => 28,
            COUNTER_WIDTH               => 8
        )
        port map (
            CLK                     => clk_sig,
            RST                     => rst_sig,
            CONFIG                  =>
                x"5500FF" &
                x"0055FF" ,
            VERIFY                  =>
                x"5500FF" &
                x"0055FF" ,
            SCK_HALF_PERIOD         => x"05F5E10",
            
            CS                      => led(15),
            SCK                     => led(14),
            MOSI                    => led(13),
            MISO                    => sw_data_sig(15),
            TRISTATE_EN             => led(11),
            
            VERIFY_PASS             => led(7),
            VERIFY_FAIL             => fail_sig,
            VERIFY_RETRY            => sw_data_sig(14),
            VERIFY_RETRY_PERIOD     => x"5F5E100",
            
            VERIFY_ADDR             => verify_addr_sig,
            VERIFY_DATA             => verify_data_sig,
            ACTUAL_DATA             => actual_data_sig
        );

    packet_sig <= x"AABB" & verify_addr_sig & verify_data_sig & actual_data_sig;

    send_packet_sig <= fail_sig and sw_data_sig(14);
    led(6) <= fail_sig;

    PacketTx_module: entity work.PacketTx
        generic map (
            SYMBOL_WIDTH        => 8,
            PACKET_SYMBOLS      => 6
        )
        port map (
            CLK                 => clk_sig,
            RST                 => rst_sig,
            
            READY_OUT           => led(3),
            VALID_IN            => send_packet_sig,
            
            READY_IN            => ready_in_sig,
            VALID_OUT           => valid_out_sig,
            
            PACKET_IN           => packet_sig,
            SYMBOL_OUT          => tx_data_sig
        );

    Tx_module: entity work.SerialTx
        port map ( 
            -- inputs
            CLK => clk_sig,
            EN => '1',
            RST => rst_sig,
            BIT_TIMER_PERIOD => x"0063",
            VALID => valid_out_sig,
            DATA => tx_data_sig,
            -- outputs
            READY => ready_in_sig,
            TX => TX
        );
    
end Behavioral;

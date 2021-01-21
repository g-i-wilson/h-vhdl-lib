library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity TestPacketSerialFullDuplex is
    port (
        CLK                     : in std_logic;
        
        sw                      : in std_logic_vector(15 downto 0);
        led                     : out std_logic_vector(15 downto 0);     
        btnL                    : in std_logic;
        btnR                    : in std_logic;

        RX                      : in std_logic;
        TX                      : out std_logic
    );
end TestPacketSerialFullDuplex;


architecture Behavioral of TestPacketSerialFullDuplex is

    signal serial_alarm_sig         : std_logic_vector(1 downto 0);
    signal rx_data_reg_sig          : std_logic_vector(8*8-1 downto 0);
    signal rx_data_sig              : std_logic_vector(8*8-1 downto 0);
    signal valid_out_sig            : std_logic;
    signal valid_in_sig             : std_logic;
    
    signal clk_sig                  : std_logic;
    signal rst_sig                  : std_logic;
    signal en_tx_sig                : std_logic;
    signal sw_sig                   : std_logic_vector(15 downto 0);
    signal sw_event_sig             : std_logic_vector(15 downto 0);
    
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
            SW_OUT                 	=> sw_sig,
            SW_EVENT_OUT            => sw_event_sig
        );

    led(1) <= rst_sig;
    
    valid_in_sig <= valid_out_sig or sw_event_sig(15);
    
    led(15) <= sw_sig(15);


    PacketSerialFullDuplex_module: entity work.PacketSerialFullDuplex
        -- Serial baud rate is clk_freq/100
        generic map (
            RX_HEADER_BYTES         => 2,
            RX_DATA_BYTES           => 8,
            TX_HEADER_BYTES         => 2,
            TX_DATA_BYTES           => 8,
            BIT_PERIOD              => 868
        )
        port map (
            CLK                     => CLK,
            RST                     => rst_sig,
            
            SERIAL_RX               => RX,
            SERIAL_TX               => TX,
            RX_ALARM                => serial_alarm_sig,
    
            -- RX data
            VALID_OUT               => valid_out_sig,
            RX_HEADER		        => x"7478", -- 't','x'
            RX_DATA  		        => rx_data_sig,
            
            -- TX data
            VALID_IN                => valid_in_sig,
            TX_HEADER		        => x"7278", -- 'r','x'
            TX_DATA  		        => rx_data_reg_sig
        );
    
    reg: entity work.Reg1D
        generic map (
            LENGTH              => 8*8
        )
        port map (
            CLK                 => CLK,
            RST                 => rst_sig,
    
            PAR_EN              => valid_out_sig,
            PAR_IN              => rx_data_sig,
            PAR_OUT             => rx_data_reg_sig
        );
    
    ILA : entity work.ila_TestPacketSerialFullDuplex
    port map (
        clk             => CLK,
        probe0(0)       => valid_out_sig,
        probe1          => rx_data_sig,
        probe2          => rx_data_reg_sig,
        probe3          => serial_alarm_sig
    );

end Behavioral;

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
    generic (
    	-- Sample rate
        SAMPLE_PERIOD           : positive := 99;   -- units of clock cycles (minus 1)
        SAMPLE_PERIOD_WIDTH     : positive := 8;
        -- Serial rate
        SERIAL_RATE             : positive := 99   -- units of clock cycles (minus 1)
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;        
        
        RX                      : in std_logic;
        TX                      : out std_logic
    );
end TestPacketSerialFullDuplex;


architecture Behavioral of TestPacketSerialFullDuplex is

    signal serial_alarm_sig         : std_logic_vector(1 downto 0);
    signal rx_data_reg_sig          : std_logic_vector(8*8-1 downto 0);
    signal rx_data_sig              : std_logic_vector(8*8-1 downto 0);
    signal valid_sig                : std_logic;
    
begin

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
            RST                     => RST,
            
            SERIAL_RX               => RX,
            SERIAL_TX               => TX,
            RX_ALARM                => serial_alarm_sig,
    
            -- RX data
            VALID_OUT               => valid_sig,
            RX_HEADER		        => x"7478", -- 't','x'
            RX_DATA  		        => rx_data_sig,
            
            -- TX data
            VALID_IN                => valid_sig,
            TX_HEADER		        => x"7278", -- 'r','x'
            TX_DATA  		        => rx_data_reg_sig
        );
    
    reg: entity work.Reg1D
        generic map (
            LENGTH              => 8*8
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
    
            PAR_EN              => valid_sig,
            PAR_IN              => rx_data_sig,
            PAR_OUT             => rx_data_reg_sig
        );
    
    ILA : entity work.ila_TestPacketSerialFullDuplex
    port map (
        clk             => CLK,
        probe0(0)       => valid_sig,
        probe1          => rx_data_sig,
        probe2          => rx_data_reg_sig,
        probe3          => serial_alarm_sig
    );

end Behavioral;

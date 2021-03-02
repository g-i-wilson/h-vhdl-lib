library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity TestMemoryMapServer is
    port (
        CLK                     : in std_logic;
        
        sw                      : in std_logic_vector(15 downto 0);
        led                     : out std_logic_vector(15 downto 0);     
        btnL                    : in std_logic;
        btnR                    : in std_logic;

        RX                      : in std_logic;
        TX                      : out std_logic
    );
end TestMemoryMapServer;


architecture Behavioral of TestMemoryMapServer is

    signal clk_sig                  : std_logic;
    signal rst_sig                  : std_logic;
    signal sw_sig                   : std_logic_vector(15 downto 0);
    signal sw_event_sig             : std_logic_vector(15 downto 0);

    signal rx_valid_sig             : std_logic;
    signal sym_valid_sig            : std_logic;
    signal tx_ready_sig             : std_logic;
    signal packet_valid_sig         : std_logic;
    signal mem_ready_sig            : std_logic;
    signal mem_valid_sig            : std_logic;
    signal packet_ready_sig         : std_logic;

    signal rx_sym_sig               : std_logic_vector(7 downto 0);
    signal tx_sym_sig               : std_logic_vector(7 downto 0);

    signal addr_out_sig             : std_logic_vector(15 downto 0);
    signal data_in_sig              : std_logic_vector(7 downto 0);
    signal data_out_sig             : std_logic_vector(7 downto 0);

    signal rx_alarm_sig             : std_logic_vector(1 downto 0);
    
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

    SerialRx_module: entity work.SerialRx
        generic map (
            SAMPLE_PERIOD_WIDTH 	=> 1,
            SAMPLE_PERIOD 			=> 1,
            DETECTOR_PERIOD_WIDTH 	=> 4,
            DETECTOR_PERIOD 		=> 16, -- sample detector MA filter
            DETECTOR_LOGIC_HIGH 	=> 12, -- 12..15 is high
            DETECTOR_LOGIC_LOW 		=> 3,  -- 0..3 is low
            BIT_TIMER_WIDTH 		=> 16, -- 868 == 0x0364
            BIT_TIMER_PERIOD 		=> 100, -- clk_freq/SAMPLE_PERIOD/BIT_PERIOD == 100MHz/1/100 == 1Mbps
            VALID_LAG 				=> 100/2  -- when to start looking for a VALID signal
        )
        port map (
            -- inputs
            CLK 					=> clk_sig,
            EN 						=> '1',
            RST 					=> rst_sig,
            RX 						=> RX,
            -- outputs
            VALID 					=> rx_valid_sig,
            DATA 					=> rx_sym_sig,
            ALARM 					=> rx_alarm_sig
        );

    SerialTX_module: entity work.SerialTx
        port map (
            -- inputs
            CLK                 => clk_sig,
            EN                  => '1',
            RST                 => rst_sig,
            BIT_TIMER_PERIOD    => x"0063", -- 99 == 100MHz/(99+1) == 1Mbps
            VALID               => sym_valid_sig,
            DATA                => tx_sym_sig,
            -- outputs
            READY               => tx_ready_sig,
            TX                  => TX
        );

    MemoryMapServer_module: entity work.MemoryMapServer
        generic map (
            -- symbol width in bits
            SYMBOL_WIDTH                => 8, -- typically a BYTE
            -- packet header length in symbols
            SERVER_ID_LEN               => 2,
            -- packet field lengths in symbols
            MEM_ADDR_LEN                => 2,
            MEM_DATA_LEN		        => 1
        )
        port map (
            CLK                         => clk_sig,
            RST                         => rst_sig,
    
            -- packet
            SERVER_ID                   => x"6D30", -- 'm','0'
    
            -- handshake FROM serial
            SYMBOL_IN                   => rx_sym_sig,
            SYM_READY_OUT               => open,
            SYM_VALID_IN                => rx_valid_sig,
            -- handshake TO serial
            SYMBOL_OUT                  => tx_sym_sig,
            SYM_READY_IN                => tx_ready_sig,
            SYM_VALID_OUT               => sym_valid_sig,
    
            -- write ADDR or ADDR+DATA_OUT to memory and read DATA_IN from memory
            ADDR_OUT                    => addr_out_sig,
            DATA_OUT                    => data_out_sig,
            DATA_IN                     => data_in_sig,
    
            -- handshake TO memory
            MEM_READY_IN                => mem_ready_sig,
            MEM_VALID_OUT               => packet_valid_sig,
            -- handshake FROM memory
            MEM_READY_OUT               => packet_ready_sig,
            MEM_VALID_IN                => mem_valid_sig
            
        );

    RAM: entity work.SimpleRAM12a8d
        port map (
            CLK                         => clk_sig,
            RST                         => rst_sig,
            
            ADDR                        => addr_out_sig(11 downto 0),
            WRITE                       => addr_out_sig(15),
    
            DATA_IN                     => data_out_sig,
            DATA_OUT                    => data_in_sig,
            
            VALID_IN                    => packet_valid_sig,
            READY_OUT                   => mem_ready_sig,
            VALID_OUT                   => mem_valid_sig,
            READY_IN                    => packet_ready_sig
        );
        
    ILA : entity work.ila_TestMemoryMapServer
    port map (
        clk             => clk_sig,
        probe0(0)       => packet_ready_sig,
        probe1(0)       => packet_valid_sig,
        probe2(0)       => mem_ready_sig,
        probe3(0)       => mem_valid_sig,
        probe4(0)       => rx_valid_sig,
        probe5(0)       => tx_ready_sig,
        probe6          => rx_sym_sig,
        probe7          => tx_sym_sig,
        probe8          => addr_out_sig,
        probe9          => data_out_sig,
        probe10         => rx_alarm_sig
    );

end Behavioral;

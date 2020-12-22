library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity FreqBurst is
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;

        SAMPLE                  : out std_logic;
        I_SIGNAL                : in std_logic_vector(15 downto 0);
        Q_SIGNAL                : in std_logic_vector(15 downto 0);

        RF_EN                   : out std_logic;
        RF_FREQ                 : out std_logic_vector(3 downto 0);
        RF_FREQ_DIV             : in std_logic;

        SERIAL_TX               : out std_logic;
        SERIAL_RX               : in std_logic
    );
end FreqBurst;


architecture Behavioral of FreqBurst is

    -- FSM & control signals
    signal timer_en_sig             : std_logic;
    signal timer_done_sig           : std_logic;
    signal timer_rst_sig            : std_logic;
    signal timer_end_sig            : std_logic_vector(15 downto 0);
    signal timer_mode_pre_sig       : std_logic;
    signal timer_mode_step_sig      : std_logic;
    signal timer_mode_post_sig      : std_logic;
    signal freq_counter_en_sig      : std_logic;
    signal freq_counter_done_sig    : std_logic;
    signal freq_counter_rst_sig     : std_logic;
    signal cycle_en_sig             : std_logic;
    signal cycle_done_sig           : std_logic;
    signal cycle_rst_sig            : std_logic;
    signal sample_en_sig            : std_logic;
    signal sample_rst_sig           : std_logic;
    signal zero_pre_sig             : std_logic;
    signal zero_step_sig            : std_logic;
    signal zero_post_sig            : std_logic;
    signal fsm_state_sig            : std_logic_vector(3 downto 0);

    -- RX control signals
    signal packet_rx_data_sig       : std_logic_vector(8*8-1 downto 0);
    signal packet_rx_data_reg_sig   : std_logic_vector(8*8-1 downto 0);
    signal packet_rx_header_sig     : std_logic_vector(2*8-1 downto 0);
    signal packet_rx_valid_sig      : std_logic;
    signal serial_alarm_sig         : std_logic_vector(1 downto 0);

    -- TX control signals
    signal adc_sample_sig           : std_logic;
    signal packet_tx_data_sig       : std_logic_vector(8*8-1 downto 0);
    signal packet_tx_header_sig     : std_logic_vector(2*8-1 downto 0);
    signal packet_tx_valid_sig      : std_logic;

    -- RX data signals
    signal cycle_end_sig            : std_logic_vector(7 downto 0);
    signal freq_start_sig           : std_logic_vector(3 downto 0);
    signal freq_end_sig             : std_logic_vector(3 downto 0);
    signal time_pre_sig             : std_logic_vector(15 downto 0);
    signal time_step_sig            : std_logic_vector(15 downto 0);
    signal time_post_sig            : std_logic_vector(15 downto 0);

    -- TX data signals
    signal i_out_sig                : std_logic_vector(15 downto 0);
    signal q_out_sig                : std_logic_vector(15 downto 0);
    signal freq_div_sig             : std_logic_vector(7 downto 0);
    signal cycle_count_sig          : std_logic_vector(7 downto 0);
    signal sample_count_sig         : std_logic_vector(15 downto 0);
    
begin

    --------------------------------------------------------------
    -- FSM & sample rate
    --------------------------------------------------------------
    
    process (timer_mode_pre_sig, timer_mode_step_sig, timer_mode_post_sig, time_pre_sig, time_step_sig, time_post_sig) begin
        if (timer_mode_pre_sig = '1') then
            timer_end_sig <= time_pre_sig;
        elsif (timer_mode_step_sig = '1') then
            timer_end_sig <= time_step_sig;
        elsif (timer_mode_post_sig = '1') then
            timer_end_sig <= time_post_sig;
        end if;
    end process;
    
    zero_pre_sig    <= '1' when time_pre_sig = x"0000" else '0';
    zero_step_sig   <= '1' when time_step_sig = x"0000" else '0';
    zero_post_sig   <= '1' when time_post_sig = x"0000" else '0';
    
    FSM: entity work.FreqBurstFSM
        port map ( 
            CLK             => CLK,
            RST             => RST,
            
            VALID_IN        => packet_rx_valid_sig,
    
            SAMPLE          => adc_sample_sig,
    
            TIMER_EN        => timer_en_sig,
            TIMER_RST       => timer_rst_sig,
            TIMER_DONE      => timer_done_sig,

            TIMER_MODE_PRE  => timer_mode_pre_sig,
            TIMER_MODE_STEP => timer_mode_step_sig,
            TIMER_MODE_POST => timer_mode_post_sig,
            ZERO_PRE        => zero_pre_sig,
            ZERO_STEP       => zero_step_sig,
            ZERO_POST       => zero_post_sig,
            
            FREQ_RST        => freq_counter_rst_sig,
            FREQ_EN         => freq_counter_en_sig,
            FREQ_DONE       => freq_counter_done_sig,
            
            CYCLE_RST       => cycle_rst_sig,
            CYCLE_EN        => cycle_en_sig,
            CYCLE_DONE      => cycle_done_sig,
    
            SAMPLE_RST      => sample_rst_sig,
            SAMPLE_EN       => sample_en_sig,
            
            -- debug
            STATE           => fsm_state_sig
        );

    sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH                       => 8
    )
    port map (
        CLK                         => CLK,
        EN                          => '1',
        RST                         => RST,
        PERIOD                      => x"63", -- 100MHz/1MHz-1 to hex
        INIT_PERIOD                 => x"63",
        PULSE                       => adc_sample_sig
    );
    
    SAMPLE <= adc_sample_sig;


    --------------------------------------------------------------
    -- packet telemetry
    --------------------------------------------------------------

    packet_telemetry: entity work.PacketSerialFullDuplex
        generic map (
            RX_HEADER_BYTES         => 2,
            RX_DATA_BYTES           => 8,
            TX_HEADER_BYTES         => 2,
            TX_DATA_BYTES           => 8
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            
            SERIAL_RX               => SERIAL_RX,
            SERIAL_TX               => SERIAL_TX,
            SERIAL_ALARM            => serial_alarm_sig,
    
            -- RX valid
            VALID_OUT               => packet_rx_valid_sig,
            RX_HEADER    			=> packet_rx_header_sig,
            RX_DATA                 => packet_rx_data_sig,
            
            -- TX valid
            VALID_IN                => packet_tx_valid_sig,
            TX_HEADER               => packet_tx_header_sig,
            TX_DATA					=> packet_tx_data_sig
        );
        
    RX_reg : entity work.Reg1D
        generic map (
            LENGTH      => 8*8
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => packet_rx_valid_sig,
            PAR_IN      => packet_rx_data_sig,
            PAR_OUT     => packet_rx_data_reg_sig
        );
        
    packet_tx_header_sig <= x"0102" when 
    
    packet_tx_data_sig <=
        I_SIGNAL &          -- 2 bytes
        Q_SIGNAL &          -- 2 bytes
        freq_div_sig &      -- 1 byte
        cycle_count_sig &   -- 1 byte
        sample_count_sig ;  -- 2 bytes
        
    packet_rx_header_sig <= x"0102";

    cycle_end_sig   <= packet_rx_data_reg_sig(8*8-1 downto 8*7); -- cycles-1
    freq_start_sig  <= packet_rx_data_reg_sig(8*7-1 downto 8*6+4);
    freq_end_sig 	<= packet_rx_data_reg_sig(8*6+3 downto 8*6);
    time_pre_sig 	<= packet_rx_data_reg_sig(8*6-1 downto 8*4);
    time_step_sig 	<= packet_rx_data_reg_sig(8*4-1 downto 8*2);
    time_post_sig 	<= packet_rx_data_reg_sig(8*2-1 downto 0);
    

    --------------------------------------------------------------
    -- counters and timers
    --------------------------------------------------------------

    PeriodDetector_module: entity work.PeriodDetector
        generic map (
            SAMPLE_LENGTH           => 16,
            SUM_WIDTH               => 4,
            LOGIC_HIGH              => 13,
            LOGIC_LOW               => 2,
            SUM_START               => 7,
            PERIOD_WIDTH            => 8
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN                      => '1',
            
            SIG_IN                  => RF_FREQ_DIV,
            
            PERIOD                  => freq_div_sig
        );    
    
    sample_timer : entity work.Timer
        generic map (
            WIDTH                   => 16
        )
        port map (
            CLK                     => CLK,
            EN                      => timer_en_sig,
            RST                     => timer_rst_sig,
            COUNT_END               => timer_end_sig,
    
            DONE                    => timer_done_sig
        );

    frequency_counter : entity work.TimerBidirectional
        generic map (
            WIDTH                   => 4
        )
        port map (
            CLK                     => CLK,
            EN                      => freq_counter_en_sig,
            RST                     => freq_counter_rst_sig,
            COUNT_START             => freq_start_sig,
            COUNT_END               => freq_end_sig,
    
            COUNT                   => RF_FREQ,
            DONE                    => freq_counter_done_sig
        );

    cycle_counter : entity work.Timer
        generic map (
            WIDTH                   => 8
        )
        port map (
            CLK                     => CLK,
            EN                      => cycle_en_sig,
            RST                     => cycle_rst_sig,
            COUNT_END               => cycle_end_sig,
    
            COUNT                   => cycle_count_sig,
            DONE                    => cycle_done_sig
        );
    
    sample_counter : entity work.Timer
        generic map (
            WIDTH                   => 16
        )
        port map (
            CLK                     => CLK,
            EN                      => sample_en_sig,
            RST                     => sample_rst_sig,
    
            COUNT                   => sample_count_sig
        );

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/21/2020 02:40:32 PM
-- Design Name: 
-- Module Name: SerialRx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SerialRx is
    generic (
        SAMPLE_PERIOD_WIDTH     : positive := 4;        -- vector width
        SAMPLE_PERIOD           : positive := 10;       -- units of clock cycles
        DETECTOR_PERIOD_WIDTH   : positive := 12;       -- vector width
        DETECTOR_PERIOD         : positive := 512;      -- units of samples
        DETECTOR_LOGIC_HIGH     : positive := 384;      -- units of samples
        DETECTOR_LOGIC_LOW      : positive := 128;      -- units of samples
        BIT_TIMER_WIDTH         : positive := 12;        -- vector width
        BIT_TIMER_PERIOD        : positive := 1042;     -- units of samples (default: 9600bps)
        VALID_LAG               : positive := 300       -- units of samples (when to start looking for a VALID signal)
    );
    port (
        -- inputs
        CLK                     : in STD_LOGIC;
        EN                      : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        RX                      : in STD_LOGIC;
        -- outputs
        VALID                   : out STD_LOGIC;
        DATA                    : out STD_LOGIC_VECTOR (7 downto 0);
        ALARM                   : out STD_LOGIC_VECTOR (1 downto 0);
        -- debug outputs
        COUNT                   : out STD_LOGIC_VECTOR (4 downto 0);
        DETECTOR_COUNT          : out STD_LOGIC_VECTOR (DETECTOR_PERIOD_WIDTH-1 downto 0);
        DETECTOR_EDGE_EVENT     : out STD_LOGIC;
        DETECTOR_DATA           : out STD_LOGIC;
        DETECTOR_VALID          : out STD_LOGIC;
        SAMPLE                  : out STD_LOGIC
    );
end SerialRx;

architecture Behavioral of SerialRx is

    signal sample_en_sig : std_logic;

    signal edge_event_sig : std_logic;
    signal valid_sig : std_logic;
    signal data_sig : std_logic;
    signal timer_sig : std_logic;
    signal count_sig : std_logic_vector(4 downto 0);
    signal count_break_sig : std_logic;
    signal count_bit_sig : std_logic;
    signal rst_timer_sig : std_logic;
    signal rst_count_sig : std_logic;
    signal shift_in_bit_sig : std_logic;
    signal data_bit_invalid_sig : std_logic;
    signal stop_bit_invalid_sig : std_logic;
    signal alarm_sig : std_logic_vector(1 downto 0);
    signal detector_count_sig : std_logic_vector(DETECTOR_PERIOD_WIDTH-1 downto 0);

begin

   sample_en : entity work.clk_div_generic
        generic map (
            period_width        => SAMPLE_PERIOD_WIDTH
        )
        port map (
            period              => std_logic_vector(to_unsigned(SAMPLE_PERIOD,SAMPLE_PERIOD_WIDTH)),
            clk                 => CLK,
            en                  => EN,
            rst                 => RST,
            en_out              => sample_en_sig
        );
        
     SAMPLE <= sample_en_sig;

    edge_detect: entity work.EdgeDetector
    generic map (
        SAMPLE_LENGTH             => DETECTOR_PERIOD,
        SUM_WIDTH                 => DETECTOR_PERIOD_WIDTH,
        LOGIC_HIGH                => DETECTOR_LOGIC_HIGH,
        LOGIC_LOW                 => DETECTOR_LOGIC_LOW,
        SUM_START                 => DETECTOR_PERIOD/2
    )
    port map (
    -- inputs
        CLK                       => CLK,
        RST                       => RST,
        SAMPLE                    => sample_en_sig,
        SIG_IN                    => RX,
    -- outputs
        EDGE_EVENT                => edge_event_sig,
        DATA                      => data_sig,
        VALID                     => valid_sig,
        SUM                       => detector_count_sig
    );

    DETECTOR_COUNT <= detector_count_sig;
    DETECTOR_EDGE_EVENT <= edge_event_sig;
    DETECTOR_DATA <= data_sig;
    DETECTOR_VALID <= valid_sig;

   bit_timer : entity work.clk_div_generic
        generic map (
            period_width        => BIT_TIMER_WIDTH,
            phase_lag           => VALID_LAG
        )
        port map (
            period              => std_logic_vector(to_unsigned(BIT_TIMER_PERIOD,BIT_TIMER_WIDTH)),
            clk                 => CLK,
            en                  => sample_en_sig,
            rst                 => rst_timer_sig,
            en_out              => timer_sig
        );
        
   counter : process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1' or rst_count_sig = '1') then
                count_sig <= "00000";
            elsif (
                count_bit_sig = '1' or                          -- pulse to count each bit in the data-byte
                (count_break_sig = '1' and timer_sig = '1')     -- continuously counting in the break state
            ) then
                count_sig <= std_logic_vector(unsigned(count_sig)+1);
            else
                count_sig <= count_sig;
            end if;
        end if;
    end process;
    
  COUNT <= count_sig;

  data_reg : entity work.Reg1D
  generic map (
        LENGTH          => 8,
        BIG_ENDIAN      => false
      )
      port map (
        RST             => RST,
        CLK             => CLK,
        SHIFT_EN        => shift_in_bit_sig,
        SHIFT_IN        => data_sig,
        PAR_OUT         => DATA
      );

   alarm_reg : process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                alarm_sig <= "00";
            elsif (data_bit_invalid_sig = '1') then
                alarm_sig <= '1' & alarm_sig(0);
            elsif (stop_bit_invalid_sig = '1') then
                alarm_sig <= alarm_sig(1) & '1';
            else
                alarm_sig <= alarm_sig;
            end if;
        end if;
    end process;
    
    ALARM <= alarm_sig;


    FSM: entity work.SerialRxFSM
    port map (
    -- inputs
        CLK                     => CLK,
        RST                     => RST,
        EN                      => EN,
        EDGE_EVENT              => edge_event_sig,
        VALID_IN                => valid_sig,
        DATA                    => data_sig,
        TIMER                   => timer_sig,
        COUNT                   => count_sig,
    -- outputs
        COUNT_BREAK             => count_break_sig,
        COUNT_BIT               => count_bit_sig,
        RST_COUNT               => rst_count_sig,
        RST_TIMER               => rst_timer_sig,
        SHIFT_IN_BIT            => shift_in_bit_sig,
        VALID_OUT               => VALID,
        DATA_BIT_INVALID_ALARM  => data_bit_invalid_sig,
        STOP_BIT_INVALID_ALARM  => stop_bit_invalid_sig
    );


end Behavioral;

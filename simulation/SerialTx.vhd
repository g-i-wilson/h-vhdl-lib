library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SerialTx is
    generic (
        BIT_TIMER_WIDTH        : positive := 16;
        BIT_TIMER_PERIOD       : positive := 10417  -- units of clock cycles (default: 9600bps)
    );
    port ( 
        -- inputs
        CLK                     : in STD_LOGIC;
        EN                      : in STD_LOGIC;
        RST                     : in STD_LOGIC;
        VALID                   : in STD_LOGIC;
        DATA                    : in STD_LOGIC_VECTOR (7 downto 0);
        -- outputs
        READY                   : out STD_LOGIC;
        TX                      : out STD_LOGIC
    );
end SerialTx;

architecture Behavioral of SerialTx is
       
  signal bit_en_sig             : std_logic;
  signal word_en_sig            : std_logic;
  signal ready_sig              : std_logic;
  signal ready_or_rst           : std_logic;
  
  signal tx_signal              : std_logic;

  signal reg_par_en             : std_logic;
  signal reg_shift_en           : std_logic;
  signal reg_bits_in            : std_logic_vector (9 downto 0);
  signal valid_data_sig         : std_logic_vector (7 downto 0);
  
  signal word_period            : std_logic_vector (BIT_TIMER_WIDTH+4-1 downto 0);
       
begin


    ready_or_rst <= ready_sig or RST;

    -- bit counter
   bit_timer : entity work.clk_div_generic
        generic map (
            period_width        => BIT_TIMER_WIDTH,
            phase_lead          => 1 -- load and timing start together, but after that, the shift happens 1 after timing
        )
        port map (
            period              => std_logic_vector(to_unsigned(BIT_TIMER_PERIOD,BIT_TIMER_WIDTH)),
            clk                 => clk,
            en                  => en,
            rst                 => ready_or_rst,
            en_out              => bit_en_sig
        );

    -- word (byte + start/stop bits) counter
    word_div : entity work.clk_div_generic
        generic map (
            period_width        => BIT_TIMER_WIDTH+4,
            phase_lead          => 1
        )
        port map (
            period              => std_logic_vector(to_unsigned(BIT_TIMER_PERIOD*10,BIT_TIMER_WIDTH+4)),
            clk                 => clk,
            en                  => en,
            rst                 => ready_or_rst,
            en_out              => word_en_sig
        );
        
    -- sample the data on valid signal
    valid_reg: entity work.reg1D
        generic map (
            LENGTH              => 8,
            BIG_ENDIAN          => false
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            PAR_EN              => VALID,
            PAR_IN              => DATA,
            PAR_OUT             => valid_data_sig
        );
        
    reg_bits_in <= '1' & valid_data_sig & '0'; -- stop-bit, data, start-bit
    
    -- output load/shift register
    tx_reg: entity work.reg1D
        generic map (
            LENGTH              => 10,
            BIG_ENDIAN          => false
        )
        port map (
            CLK                 => CLK,
            RST                 => ready_or_rst,
            
            PAR_EN              => reg_par_en,
            PAR_IN              => reg_bits_in,
            
            SHIFT_EN            => reg_shift_en,
            SHIFT_OUT           => tx_signal,
            
            DEFAULT_STATE       => "1111111111" -- all stop bits
        );
        
    TX <= tx_signal;
        
    -- FSM to control the load/shift register
    FSM: entity work.SerialTxFSM
        port map (
            CLK                 => CLK,
            EN                  => EN,
            RST                 => RST,
            VALID               => VALID,
            BIT_EN              => bit_en_sig,
            BYTE_EN             => word_en_sig,
            
            READY               => ready_sig,
            LOAD                => reg_par_en,
            SHIFT               => reg_shift_en
        );
    
    READY <= ready_sig;
    
    ila0: entity work.ila_SerialTx
    port map (
        CLK => CLK,
        probe0 => tx_signal & "0000000",
        probe1 => valid_data_sig
    );


end Behavioral;

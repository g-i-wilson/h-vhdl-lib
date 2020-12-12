library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity FreqTxRx is
    generic (
        ADC_PERIOD_WIDTH        : positive := 8
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;

        ADC_PERIOD              : in std_logic_vector(ADC_PERIOD_WIDTH-1 downto 0);
        UART_PERIOD             : in std_logic_vector(15 downto 0);

        I_CMP_IN                : in std_logic;
        I_INV_OUT               : out std_logic;
        Q_CMP_IN                : in std_logic;
        Q_INV_OUT               : out std_logic;

        TX                      : out std_logic
    );
end FreqTxRx;


architecture Behavioral of FreqTxRx is

  signal adc_out_sig            : std_logic;
  signal adc_sample_sig         : std_logic;
  signal qd_in_sample_sig       : std_logic;
  signal qd_out_sample_sig      : std_logic;
  signal qd_out_x2_sample_sig   : std_logic;
  signal tx_ready_out           : std_logic;
  signal packet_valid_out       : std_logic;
  signal filter_in_sig          : std_logic_vector(1 downto 0);
  signal filter_out_sig         : std_logic_vector(11 downto 0);
  signal freq_re_sig            : std_logic_vector(15 downto 0);
  signal freq_im_sig            : std_logic_vector(15 downto 0);
--  signal phase_sig          : std_logic_vector(7 downto 0);
--  signal phase_der_sig      : std_logic_vector(7 downto 0);
--  signal phase_2der_sig     : std_logic_vector(7 downto 0);
  signal packet_symbol_out      : std_logic_vector(7 downto 0);
  signal i_out_sig              : std_logic_vector(15 downto 0);
  signal q_out_sig              : std_logic_vector(15 downto 0);
  signal packet_in_sig          : std_logic_vector(95 downto 0);

begin

    I_ADC: entity work.ADCSimpleDeltaSigma
        generic map (
            ADC_PERIOD_WIDTH        => 8,
            SIG_OUT_WIDTH    		    => 16
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            CMP_IN                  => I_CMP_IN,
            ADC_PERIOD              => ADC_PERIOD,
            INV_OUT                 => I_INV_OUT,
            VALID                   => i_valid_sig,
            SIG_OUT                 => i_out_sig
        );

    I_ADC: entity work.ADCSimpleDeltaSigma
        generic map (
            ADC_PERIOD_WIDTH        => 8,
            SIG_OUT_WIDTH    		    => 16
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            CMP_IN                  => Q_CMP_IN,
            ADC_PERIOD              => ADC_PERIOD,
            INV_OUT                 => Q_INV_OUT,
            VALID                   => q_valid_sig,
            SIG_OUT                 => q_out_sig
        );


    packet_in_sig <= x"0102" & i_out_sig & q_out_sig;

    PacketTx_module: entity work.PacketTx
        generic map (
            SYMBOL_WIDTH        => 8,
            PACKET_SYMBOLS      => 6
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            
            READY_OUT           => open,
            VALID_IN            => qd_out_sample_sig,
            
            READY_IN            => tx_ready_out,
            VALID_OUT           => packet_valid_out,
            
            PACKET_IN           => packet_in_sig,
            SYMBOL_OUT          => packet_symbol_out
        );

    
    TX_module: entity work.SerialTx
        port map (
            -- inputs
            CLK                 => CLK,
            EN                  => '1',
            RST                 => RST,
            BIT_TIMER_PERIOD    => UART_PERIOD,
            VALID               => packet_valid_out,
            DATA                => packet_symbol_out,
            -- outputs
            READY               => tx_ready_out,
            TX                  => TX
        );

--    ila0: entity work.ila_qd
--        port map (
--            CLK => CLK,
--            probe0 => i_out_sig,
--            probe1 => q_out_sig,
--            probe2 => filter_out_sig
--        );

end Behavioral;

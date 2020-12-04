library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ADCQuadDemodSerial is
    generic (
        ADC_PERIOD_WIDTH        : positive := 8;
        CARRIER_PERIOD_WIDTH    : positive := 24
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;

        ADC_PERIOD              : in std_logic_vector(ADC_PERIOD_WIDTH-1 downto 0);
        CARRIER_PERIOD          : in std_logic_vector(CARRIER_PERIOD_WIDTH-1 downto 0);
        UART_PERIOD             : in std_logic_vector(15 downto 0);

        CMP_IN                  : in std_logic;
        INV_OUT                 : out std_logic;

        TX                      : out std_logic
    );
end ADCQuadDemodSerial;


architecture Behavioral of ADCQuadDemodSerial is

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

    ADC_sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => ADC_PERIOD_WIDTH
    )
    port map (
        CLK             => CLK,
        EN              => '1',
        RST             => RST,
        PERIOD          => ADC_PERIOD, -- x"63" is 100MHz/1MHz-1 to hex
        INIT_PERIOD     => ADC_PERIOD,
        PULSE           => adc_sample_sig
    );

    carrier_x8_sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => CARRIER_PERIOD_WIDTH
    )
    port map (
        CLK             => CLK,
        EN              => '1',
        RST             => RST,
        PERIOD          => CARRIER_PERIOD, -- x"1312CF" is 100MHz/80Hz-1 to hex
        INIT_PERIOD     => CARRIER_PERIOD,
        PULSE           => qd_in_sample_sig
    );

    qd_output_x2_sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => 4
    )
    port map (
        CLK             => CLK,
        EN              => qd_in_sample_sig,
        RST             => RST,
        PERIOD          => x"3",
        INIT_PERIOD     => x"3",
        PULSE           => qd_out_x2_sample_sig
    );

    qd_output_sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => 4
    )
    port map (
        CLK             => CLK,
        EN              => qd_in_sample_sig,
        RST             => RST,
        PERIOD          => x"7",
        INIT_PERIOD     => x"7",
        PULSE           => qd_out_sample_sig
    );

    ADC: entity work.ADC1Bit
        port map (
            CLK                     => CLK,
            EN                      => adc_sample_sig,
            RST                     => RST,
            CMP_IN                  => CMP_IN,
            INV_OUT                 => INV_OUT,
            PDM_OUT                 => adc_out_sig
        );

    filter_in_sig <= (not adc_out_sig) & adc_out_sig; -- +1 for high, -1 for low

    LP_filter: entity work.FIRFilterLP15tap
        generic map (
            SIG_IN_WIDTH        => 2, -- signal input path width
            SIG_OUT_WIDTH       => 12 -- signal output path width
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN_IN               => adc_sample_sig,
            EN_OUT              => qd_in_sample_sig,
            SIG_IN              => filter_in_sig,

            SIG_OUT             => filter_out_sig
        );

    QuadDemod: entity work.QuadratureDemodulator
        generic map (
            SIG_IN_WIDTH            => 12,
            SIG_OUT_WIDTH           => 16
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN_IN                   => qd_in_sample_sig, -- sample rate must be 8x frequency of interest
            EN_OUT                  => qd_out_x2_sample_sig, -- IDM runs at 1/2 sample rate
            SIG_IN                  => filter_out_sig,

            I_OUT                   => i_out_sig,
            Q_OUT                   => q_out_sig
        );
        
--    inst_phase: entity work.InstantaneousPhase
--        generic map (
--            SIG_IN_WIDTH            => 24,
--            SIG_OUT_WIDTH           => 16
--        )
--        port map (
--            CLK                     => CLK,
--            RST                     => RST,
--            EN_ANGLE                => '1',
--            EN_OUT                  => qd_out_sample_sig,
--            RE_IN                   => i_out_sig(23 downto 0),
--            IM_IN                   => q_out_sig(23 downto 0),
    
--            PHASE                   => phase_sig,
--            PHASE_DER               => phase_der_sig
--        );
    
    inst_frequency: entity work.InstantaneousFrequency
        generic map (
            SIG_IN_WIDTH            => 16,
            RE_WIDTH                => 16,
            IM_WIDTH                => 16
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN_IN                   => qd_out_sample_sig,
            EN_OUT                  => qd_out_x2_sample_sig, -- IDM runs at 1/2 sample rate
            RE_IN                   => i_out_sig,
            IM_IN                   => q_out_sig,
    
            FREQ_RE                 => freq_re_sig,
            FREQ_IM                 => freq_im_sig
        );


    packet_in_sig <= x"0102" & i_out_sig & q_out_sig & freq_re_sig & freq_im_sig & std_logic_vector( resize( signed(filter_out_sig), 16 ) );

    PacketTx_module: entity work.PacketTx
        generic map (
            SYMBOL_WIDTH        => 8,
            PACKET_SYMBOLS      => 12
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

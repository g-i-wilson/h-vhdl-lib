library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity TestADCQuadDemodSerial is
    port (
        CLK     : in STD_LOGIC;

        XA1_P   : in STD_LOGIC;
        XA1_N   : out STD_LOGIC;

        TX      : out STD_LOGIC
    );
end TestADCQuadDemodSerial;

architecture Behavioral of TestADCQuadDemodSerial is

    signal mmcm_clk : std_logic;
    signal mmcm_rst : std_logic;

begin

    mmcm0: entity work.SimpleMMCM2
      generic map (
        CLKIN_PERIOD              => 10.000,
        PLL_MUL                   => 10.0,
        PLL_DIV                   => 10,
        FB_BUFG                   => FALSE
      )
      port map (
        RST_IN                    => '0',
        CLK_IN                    => CLK,

        RST_OUT                   => mmcm_rst,
        CLK_OUT                   => mmcm_clk
      );

    ADCQuadDemodSerial_module: entity work.ADCQuadDemodSerial
    generic map (
        ADC_PERIOD_WIDTH        => 8,
        CARRIER_PERIOD_WIDTH    => 24
    )
    port map (
        CLK                     => mmcm_clk,
        RST                     => mmcm_rst,

        ADC_PERIOD              => x"63", -- 100MHz/1MHz to hex
        CARRIER_PERIOD          => x"1312CF", -- 100MHz/80Hz-1 to hex
        UART_PERIOD             => x"0063",

        CMP_IN                  => XA1_P,
        INV_OUT                 => XA1_N,

        TX                      => TX
    );

end Behavioral;

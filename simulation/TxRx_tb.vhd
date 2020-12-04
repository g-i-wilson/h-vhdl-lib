library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TxRx_tb is
--  Port ( );
end TxRx_tb;

architecture Behavioral of TxRx_tb is

signal test_clk, test_rst, test_valid_tx_in, test_valid_rx_out, test_ready, test_tx : std_logic;
signal test_data_tx_in, test_data_rx_out : std_logic_vector(7 downto 0);
signal test_alarm : std_logic_vector(1 downto 0);

begin

    Tx: entity work.SerialTx
    port map ( 
        -- inputs
        CLK => test_clk,
        EN => '1',
        RST => test_rst,
        BIT_TIMER_PERIOD => x"0010",
        VALID => test_valid_tx_in,
        DATA => test_data_tx_in,
        -- outputs
        READY => test_ready,
        TX => test_tx
    );
    
    Rx: entity work.SerialRx
    generic map (
        SAMPLE_PERIOD_WIDTH => 1,
        SAMPLE_PERIOD => 1,
        DETECTOR_PERIOD_WIDTH => 4,
        DETECTOR_PERIOD => 8,
        DETECTOR_LOGIC_HIGH => 5, -- 5,6,7 are high
        DETECTOR_LOGIC_LOW => 2,  -- 0,1,2 are low
        BIT_TIMER_WIDTH => 8,
        BIT_TIMER_PERIOD => 16,
        VALID_LAG => 6
    )
    port map (
        CLK => test_clk,
        EN => '1',
        RST => test_rst,
        RX => test_tx,
        VALID => test_valid_rx_out,
        DATA => test_data_rx_out,
        ALARM => test_alarm
    );

    process
    begin

        -- initial
        test_rst <= '1';

        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;

        test_rst <= '0';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;


    -- test break state


        test_valid_tx_in <= '0';
        test_data_tx_in <= x"88";

        for a in 0 to 500 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;


    -- test valid pulse


        test_valid_tx_in <= '1';
        test_data_tx_in <= x"88";

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;

        test_valid_tx_in <= '0';

        for a in 0 to 255 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;
        
        
        -- test valid continuous
        
        
        test_valid_tx_in <= '1';
        test_data_tx_in <= x"7F";

        for a in 0 to 399 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;

    end process;




end Behavioral;

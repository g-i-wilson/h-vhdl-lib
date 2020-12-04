----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 07/27/2020 11:05:12 AM
-- Design Name:
-- Module Name: sq_wave_gen_tb - Behavioral
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

entity SerialTx_tb is
--  Port ( );
end SerialTx_tb;

architecture Behavioral of SerialTx_tb is


signal test_clk, test_rst, test_in, test_valid, test_ready, test_tx : std_logic;
signal test_data : std_logic_vector(7 downto 0);


begin

    test0: entity work.SerialTx
    generic map (
        BIT_PERIOD_WIDTH => 4
    )
    port map ( 
        CLK => test_clk,
        EN => '1',
        RST => test_rst,
        VALID => test_valid,
        DATA => test_data,
        BIT_PERIOD => x"4",
        
        READY => test_ready,
        TX => test_tx
    );

    process
    begin

        -- initial
        test_rst <= '1';
        test_in <= '0';

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


    -- test valid pulse


        test_valid <= '1';
        test_data <= x"88";

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;

        test_valid <= '0';

        for a in 0 to 63 loop

          test_in <= '1';

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;
        
        
        -- test valid continuous
        
        
        test_valid <= '1';
        test_data <= x"7F";

        for a in 0 to 63 loop

          test_in <= '1';

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;

    end process;



end Behavioral;

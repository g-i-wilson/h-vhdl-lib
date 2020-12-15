library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PacketRx_tb is
--  Port ( );
end PacketRx_tb;

architecture Behavioral of PacketRx_tb is

	signal test_clk : std_logic;
	signal test_rst : std_logic;
	signal test_valid : std_logic;
	signal tx_ready_out : std_logic;
	signal tx_valid_out : std_logic;
	signal rx_ready_out : std_logic;
	signal rx_valid_out : std_logic;
	
	signal test_packet : std_logic_vector(31 downto 0);

    signal test_data_out : std_logic_vector(15 downto 0);
    signal test_symbol_out : std_logic_vector(7 downto 0);


begin


    PacketTx_module: entity work.PacketTx
        generic map (
            SYMBOL_WIDTH        => 8,
            PACKET_SYMBOLS      => 4
        )
        port map (
            CLK                 => test_clk,
            RST                 => test_rst,
            
            -- upstream
            READY_OUT           => tx_ready_out,
            VALID_IN            => test_valid,
            
            -- downstream
            READY_IN            => rx_ready_out,
            VALID_OUT           => tx_valid_out,
            
            PACKET_IN           => test_packet,
            SYMBOL_OUT          => test_symbol_out
        );


    PacketRx_module: entity work.PacketRx
        generic map (
            SYMBOL_WIDTH        => 8,
            DATA_SYMBOLS        => 4,
            HEADER_SYMBOLS		=> 2
        )
        port map (
            CLK                 => test_clk,
            RST                 => test_rst,
            
            -- upstream
            READY_OUT           => rx_ready_out,
            VALID_IN            => tx_valid_out,
            
            -- downstream
            READY_IN            => '1',
            VALID_OUT           => rx_valid_out,
            
        	HEADER_IN           => x"0102",
            SYMBOL_IN           => test_symbol_out,
        
            DATA_OUT            => test_data_out
        );
    

    


    process
    begin

        -- initial
        test_packet <= x"01020304";
        test_rst <= '1';
        test_valid <= '0';

        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';

        test_rst <= '0';
        test_valid <= '1';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_valid <= '0';

        for a in 0 to 63 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;
        
        test_packet <= x"0102eeff";
        test_valid <= '1';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_valid <= '0';

        for a in 0 to 63 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;

    end process;


end Behavioral;

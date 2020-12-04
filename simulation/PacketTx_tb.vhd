library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PacketTx_tb is
--  Port ( );
end PacketTx_tb;

architecture Behavioral of PacketTx_tb is

	signal test_clk : std_logic;
	signal test_rst : std_logic;
	signal test_ready_out : std_logic;
	signal test_valid_in : std_logic;
	signal test_ready_in : std_logic;
	signal test_valid_out : std_logic;
	signal test_tx : std_logic;

    signal test_packet_in : std_logic_vector(31 downto 0);
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
            
            READY_OUT           => test_ready_out,
            VALID_IN            => test_valid_in,
            
            READY_IN            => test_ready_in,
            VALID_OUT           => test_valid_out,
            
            PACKET_IN           => test_packet_in,
            SYMBOL_OUT          => test_symbol_out
        );
    
        Tx: entity work.SerialTx
        port map ( 
            -- inputs
            CLK => test_clk,
            EN => '1',
            RST => test_rst,
            BIT_TIMER_PERIOD => x"0004",
            VALID => test_valid_out,
            DATA => test_symbol_out,
            -- outputs
            READY => test_ready_in,
            TX => test_tx
        );
    


    process
    begin

        -- initial
        test_rst <= '1';
        test_packet_in <= x"01020304";
        test_valid_in <= '0';

        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';

        test_rst <= '0';
        test_valid_in <= '1';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_valid_in <= '0';

        for a in 0 to 255 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;

    end process;


end Behavioral;

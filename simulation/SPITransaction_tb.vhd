library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPITransaction_tb is
--  Port ( );
end SPITransaction_tb;

architecture Behavioral of SPITransaction_tb is

	signal test_clk : std_logic;
	signal test_rst : std_logic;
	signal test_ready_out : std_logic;
	signal test_valid_in : std_logic;
	signal test_ready_in : std_logic;
	signal test_valid_out : std_logic;
	signal test_mosi : std_logic;
	signal test_miso : std_logic;
	signal test_sck : std_logic;
	signal test_cs : std_logic;
	signal test_tristate_en : std_logic;
	signal test_write : std_logic;

    signal test_data_out : std_logic_vector(7 downto 0);


begin



    SPIMaster_module: entity work.SPIMaster
    generic map (
        SCK_HALF_PERIOD_WIDTH   =>  8,
        MISO_DETECTOR_SAMPLES   =>  16,
        ADDR_WIDTH              =>  16,
        DATA_WIDTH              =>  8,
        COUNTER_WIDTH           =>  8
    )
    port map (
        CLK                     => test_clk,
        RST                     => test_rst,
        
        -- R/W
        WRITE                   => test_write,
        
        -- upstream
        READY_OUT               => test_ready_out,
        VALID_IN                => test_valid_in,
        
        -- downstream
        READY_IN                => test_ready_in,
        VALID_OUT               => test_valid_out,

        -- ADDR & DATA
        ADDR                    => x"AAAA",
        DATA_IN                 => x"CC",
        DATA_OUT                => test_data_out,
        
        -- SPI
        SCK_HALF_PERIOD         => x"03",
        MISO                    => test_miso,
        MOSI                    => test_mosi,
        SCK                     => test_sck,
        CS                      => test_cs,
        TRISTATE_EN             => test_tristate_en
    );
    

    process
    begin
    

        test_rst <= '1';
        test_valid_in <= '0';
        test_ready_in <= '1';
        test_miso <= '1';
        
        
        test_write <= '1';

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
        
        

        test_write <= '0';

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
        
        
        test_write <= '1';

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
        
        

        test_write <= '0';

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

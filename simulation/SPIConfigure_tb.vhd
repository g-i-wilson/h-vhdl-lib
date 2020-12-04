library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPIConfigure_tb is
--  Port ( );
end SPIConfigure_tb;

architecture Behavioral of SPIConfigure_tb is

	signal test_clk : std_logic;
	signal test_rst : std_logic;
	signal test_pass : std_logic;
	signal test_fail : std_logic;
	signal test_mosi : std_logic;
	signal test_miso : std_logic;
	signal test_sck : std_logic;
	signal test_cs : std_logic;
	signal test_tristate_en : std_logic;
	signal test_retry : std_logic;

	signal test_slave_cs : std_logic;
	signal test_slave_sck : std_logic;
	signal test_slave_sda : std_logic;

	
	signal test_config : std_logic_vector(95 downto 0);
	signal test_verify : std_logic_vector(47 downto 0);

	signal test_verify_addr : std_logic_vector(15 downto 0);
	signal test_verify_data : std_logic_vector(7 downto 0);
	signal test_actual_data : std_logic_vector(7 downto 0);


begin



    SPIConfigure_module: entity work.SPIConfigure
    generic map (
        ADDR_WIDTH                  => 16,
        DATA_WIDTH		            => 8,
        CONFIG_LENGTH               => 4,
        VERIFY_LENGTH               => 2,
        SCK_HALF_PERIOD_WIDTH       => 8,
        VERIFY_RETRY_PERIOD_WIDTH   => 28,
        COUNTER_WIDTH               => 8,
        MISO_DETECTOR_SAMPLES       => 4
    )
    port map (
        CLK                     => test_clk,
        RST                     => test_rst,
        CONFIG                  => test_config,
        VERIFY                  => test_verify,
        SCK_HALF_PERIOD         => x"05",
        MISO                    => test_miso,
        MOSI                    => test_mosi,
        SCK                     => test_sck,
        CS                      => test_cs,
        TRISTATE_EN             => test_tristate_en,
        
        VERIFY_PASS             => test_pass,
        VERIFY_FAIL             => test_fail,
        VERIFY_RETRY            => test_retry,
        VERIFY_RETRY_PERIOD     => x"0000040",
        
        VERIFY_ADDR             => test_verify_addr,
        VERIFY_DATA             => test_verify_data,
        ACTUAL_DATA             => test_actual_data
    );

    convert_3wire_to_4wire: entity work.SPI3WireConverter
        port map (
            MASTER_CS           => test_cs,
            MASTER_SCK          => test_sck,
            MASTER_MOSI         => test_mosi,
            MASTER_MISO         => test_miso,
            MASTER_TRISTATE_EN  => test_tristate_en,
            
            SLAVE_CS            => test_slave_cs,
            SLAVE_SCK           => test_slave_sck,
            SLAVE_SDA           => test_slave_sda
        );



        test_slave_sda <= '1' when (test_tristate_en = '1') else 'Z';


    process
    begin
    

        
--        test_miso <= '1';
        test_retry <= '1';
        test_config <=  x"AAAA55" &
        				x"BBBB55" &
        				x"CCCC55" &
        				x"DDDD55" ;   
        				   				
        test_verify <=  x"111155" &
        				x"222255" ;      
        								
        test_rst <= '1';
        
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';

        test_rst <= '0';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;

        for a in 0 to 4095 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;
        test_retry <= '0';
        
        for a in 0 to 4095 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;


--        test_miso <= '1';
        test_config <=  x"AAAA55" &
        				x"BBBB55" &
        				x"CCCC55" &
        				x"DDDD55" ;      
        								
        test_verify <=  x"1111FF" &
        				x"2222FF" ;      				

        test_rst <= '1';
        
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';

        test_rst <= '0';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;

        for a in 0 to 4095 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;
        
        


    end process;


end Behavioral;

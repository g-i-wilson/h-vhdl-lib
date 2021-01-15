library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RampSampling_tb is
--  Port ( );
end RampSampling_tb;

architecture Behavioral of RampSampling_tb is

	signal test_clk : std_logic;
	signal test_rst : std_logic;
	
	-- inputs
	signal test_valid_in : std_logic;

	signal test_sample_period : std_logic_vector(7 downto 0);
	signal test_cycles : std_logic_vector(7 downto 0);
	signal test_ramp_start : std_logic_vector(7 downto 0);
	signal test_ramp_end : std_logic_vector(7 downto 0);
	signal test_pre_duration : std_logic_vector(7 downto 0);
	signal test_step_duration : std_logic_vector(7 downto 0);
	signal test_post_duration : std_logic_vector(7 downto 0);

	-- outputs
	signal test_valid_out : std_logic;
	signal test_ready_out : std_logic;
	signal test_sample_pulse : std_logic;

	signal test_ramp : std_logic_vector(7 downto 0);
	signal test_cycle_count : std_logic_vector(7 downto 0);
	signal test_sample_count : std_logic_vector(7 downto 0);
	
	-- state
	signal test_state : std_logic_vector(3 downto 0);
	

begin


RampSampling_module: entity work.RampSampling
    generic map (
        SAMPLE_PERIOD_WIDTH     => 8,
        SAMPLE_COUNT_WIDTH      => 8,
        CYCLE_COUNT_WIDTH       => 8,
        RAMP_WIDTH              => 8
    )
    port map (
        CLK                     => test_clk,
        RST                     => test_rst,        
        
        -- settings
        SAMPLE_PERIOD           => test_sample_period,
        
        -- upstream handshake
        VALID_IN                => test_valid_in,
        READY_OUT               => test_ready_out,

        -- input data
        -- cycles-1 (total number of repeated cycles with same start/step/end)
        CYCLES                  => test_cycles,
        -- start frequency
        RAMP_START              => test_ramp_start,
        -- end frequency
        RAMP_END                => test_ramp_end,
        -- PRE segment duration (units of samples)
        PRE_DURATION            => test_pre_duration,
        -- STEP segment duration (each step; units of samples; total duration of segment is ramp_delta*step_duration)
        STEP_DURATION           => test_step_duration,
        -- POST segment duration (units of samples)
        POST_DURATION           => test_post_duration,
        
        -- output data & control
        -- ADC sample pulse
        SAMPLE_PULSE            => test_sample_pulse,
        -- control output frequency setting
        RAMP                    => test_ramp,
        -- output cycle count (contiguous cycles with same start/step/end)
        CYCLE_COUNT             => test_cycle_count,
        -- output sample count (sample count in the current cycle)
        SAMPLE_COUNT            => test_sample_count,

        -- downstream valid
        VALID_OUT               => test_valid_out,
        
        
        -- debug
        STATE                   => test_state
    );
    

    


    process
    begin

        -- initial
        test_valid_in <= '0';

        test_sample_period <= x"03";
        test_cycles <= x"00";
        test_ramp_start <= x"01";
        test_ramp_end <= x"04";
        test_pre_duration <= x"08";
        test_step_duration <= x"02";
        test_post_duration <= x"08";

        test_rst <= '1';
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

        for a in 0 to 800 loop
        
		        -- clock edge
		        wait for 2ns;
		        test_clk <= '1';
		        wait for 2ns;
		        test_clk <= '0';

	      end loop;
        
        test_sample_period <= x"03";
        test_cycles <= x"04";
        test_ramp_start <= x"01";
        test_ramp_end <= x"01";
        test_pre_duration <= x"02";
        test_step_duration <= x"04";
        test_post_duration <= x"02";

        test_valid_in <= '1';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        
        wait for 2ns;
        test_valid_in <= '0';

        for a in 0 to 800 loop
        
		        -- clock edge
		        wait for 2ns;
		        test_clk <= '1';
		        wait for 2ns;
		        test_clk <= '0';

	      end loop;
        
        test_sample_period <= x"03";
        test_cycles <= x"04";
        test_ramp_start <= x"04";
        test_ramp_end <= x"01";
        test_pre_duration <= x"04";
        test_step_duration <= x"04";
        test_post_duration <= x"00";

        test_valid_in <= '1';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        
        wait for 2ns;
        test_valid_in <= '0';

        for a in 0 to 800 loop
        
		        -- clock edge
		        wait for 2ns;
		        test_clk <= '1';
		        wait for 2ns;
		        test_clk <= '0';

	      end loop;

        test_sample_period <= x"03";
        test_cycles <= x"04";
        test_ramp_start <= x"04";
        test_ramp_end <= x"01";
        test_pre_duration <= x"00";
        test_step_duration <= x"04";
        test_post_duration <= x"04";

        test_valid_in <= '1';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        
        wait for 2ns;
        test_valid_in <= '0';

        for a in 0 to 800 loop
        
		        -- clock edge
		        wait for 2ns;
		        test_clk <= '1';
		        wait for 2ns;
		        test_clk <= '0';

	      end loop;

        test_sample_period <= x"03";
        test_cycles <= x"04";
        test_ramp_start <= x"04";
        test_ramp_end <= x"01";
        test_pre_duration <= x"01";
        test_step_duration <= x"04";
        test_post_duration <= x"01";

        test_valid_in <= '1';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        
        wait for 2ns;
        test_valid_in <= '0';

        for a in 0 to 254 loop
        
		        -- clock edge
		        wait for 2ns;
		        test_clk <= '1';
		        wait for 2ns;
		        test_clk <= '0';

	      end loop;

    end process;

end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/24/2020 10:09:10 AM
-- Design Name: 
-- Module Name: LongFIFO_tb - Behavioral
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

entity LongFIFO_tb is
--  Port ( );
end LongFIFO_tb;

architecture Behavioral of LongFIFO_tb is

    signal clk_sig, rst_sig, valid_in_sig, simple_valid_out_sig, long_valid_out_sig, ready_in_sig, simple_ready_out_sig, long_ready_out_sig
        : std_logic; 
    signal data_in_sig, simple_data_out_sig, long_data_out_sig
        : std_logic_vector( 15 downto 0 ); 

begin

    SimpleFIFO_inst: entity work.SimpleFIFO
        generic map (
            DATA_WIDTH              => 16
        )
        port map (
            CLK                     => clk_sig,
            RST                     => rst_sig,
            
            -- upstream
            DATA_IN					=> data_in_sig,
            VALID_IN                => valid_in_sig,
            READY_OUT               => simple_ready_out_sig,
            
            -- downstream
            DATA_OUT				=> simple_data_out_sig,
            VALID_OUT               => simple_valid_out_sig,
            READY_IN                => ready_in_sig
            
        );

    LongFIFO_inst: entity work.LongFIFO
        generic map (
            DATA_WIDTH              => 16,
            FIFO_SEGMENTS           => 4
        )
        port map (
            CLK                     => clk_sig,
            RST                     => rst_sig,
            
            -- upstream
            DATA_IN					=> data_in_sig,
            VALID_IN                => valid_in_sig,
            READY_OUT               => long_ready_out_sig,
            
            -- downstream
            DATA_OUT				=> long_data_out_sig,
            VALID_OUT               => long_valid_out_sig,
            READY_IN                => ready_in_sig
            
        );


    process
    
    begin
        -- initial
        rst_sig <= '1';
        
        data_in_sig <= x"0000";
        valid_in_sig <= '0';
        ready_in_sig <= '0';
        
        wait for 100ns;
        
--        for a in 0 to 9 loop
            
            wait for 5ns;
            clk_sig <= '0';
            wait for 5ns;
            clk_sig <= '1';
        
--        end loop;
        
        wait for 5ns;
        rst_sig <= '0';
        
        wait for 5ns;
        clk_sig <= '0';
        wait for 5ns;
        clk_sig <= '1';
        wait for 5ns;
        clk_sig <= '0';
        wait for 5ns;
                
        valid_in_sig <= '1';

        -- data "chirp"
        for a in 0 to 255 loop
        
            data_in_sig <= std_logic_vector(to_unsigned(a, 16));
            wait for 5ns;
            clk_sig <= '1';
            wait for 5ns;
            clk_sig <= '0';
                
        end loop;

        data_in_sig <= x"0000";

        -- clock for a while
        for a in 0 to 1023 loop
        
            wait for 5ns;
            clk_sig <= '1';
            wait for 5ns;
            clk_sig <= '0';
                
        end loop;
        
        ready_in_sig <= '1';

        -- clock for a while
        for a in 0 to 1023 loop
        
            wait for 5ns;
            clk_sig <= '1';
            wait for 5ns;
            clk_sig <= '0';
                
        end loop;

    end process;

end Behavioral;

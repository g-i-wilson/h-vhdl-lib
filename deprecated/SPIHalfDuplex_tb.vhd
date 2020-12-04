----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/23/2020 12:55:34 PM
-- Design Name: 
-- Module Name: SPIHalfDuplex_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPIHalfDuplex_tb is
--  Port ( );
end SPIHalfDuplex_tb;

architecture Behavioral of SPIHalfDuplex_tb is

    signal clk_sig : std_logic;
    signal rst_sig : std_logic;
    
    -- data path IN
    signal ready_out_sig : std_logic;
    signal valid_in_sig : std_logic;
    signal data_in_sig : std_logic_vector(7 downto 0);
    -- data path OUT
    signal ready_in_sig : std_logic;
    signal valid_out_sig : std_logic;
    signal data_out_sig : std_logic_vector(7 downto 0);
    
    -- SPI
    signal three_wire_sig : std_logic;
    signal sck_half_period_sig : std_logic_vector(7 downto 0);
    signal miso_sig : std_logic;
    signal mosi_sig : std_logic;
    signal sck_sig : std_logic;
    signal cs_sig : std_logic;
    signal tristate_en_sig : std_logic;


begin

    three_wire_sig <= '0';
    sck_half_period_sig <= x"04";
    valid_in_sig <= '1';
    ready_in_sig <= '1';
    miso_sig <= mosi_sig;

    test_data: entity work.Reg2D
    generic map (
        WIDTH => 8,
        LENGTH => 5
    )
    port map (
        clk => clk_sig,
        rst => rst_sig,
        default_state =>   
            x"03" &  -- 2 bytes to write
            x"02" &  -- 2 bytes to read
            x"81" &  -- write
            x"F0" &  -- write
            x"18" ,  -- write
        
        par_en => ready_out_sig,
        par_out => data_in_sig
    );



    test_SPIHalfDuplex: entity work.SPITransaction
    generic map (
        SCK_HALF_PERIOD_WIDTH => 8
    )
    port map (
        CLK => clk_sig,
        RST => rst_sig,
        
        -- data path IN
        READY_OUT => ready_out_sig,
        VALID_IN => valid_in_sig,
        DATA_IN => data_in_sig,
        -- data path OUT
        READY_IN => ready_in_sig,
        VALID_OUT => valid_out_sig,
        DATA_OUT => data_out_sig,
        
        -- SPI
        SCK_HALF_PERIOD => sck_half_period_sig,
        MOSI => mosi_sig,
        MISO => miso_sig,
        SCK => sck_sig,
        CS => cs_sig,
        TRISTATE_EN => tristate_en_sig
    );


    process
    
    begin
        -- initial
        rst_sig <= '1';
        
        wait for 5ns;
        clk_sig <= '0';
        wait for 5ns;
        clk_sig <= '1';
        wait for 5ns;
        clk_sig <= '0';
        wait for 5ns;
        
        rst_sig <= '0';

        for a in 0 to 1023 loop
        
            -- just clock for a while
                wait for 5ns;
                clk_sig <= '1';
                wait for 5ns;
                clk_sig <= '0';
                
        end loop;

    end process;


end Behavioral;

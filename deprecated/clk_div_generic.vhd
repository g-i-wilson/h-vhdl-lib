----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/10/2020 12:58:40 PM
-- Design Name: 
-- Module Name: clk_div_generic - Behavioral
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

entity clk_div_generic is
    generic (
        period_width : integer;
        phase_lag : integer := 0; -- units of clock cycles
        phase_lead : integer := 0 -- units of clock cycles
    );
    port (
        period : std_logic_vector (period_width-1 downto 0);
        clk : in std_logic;
        en : in std_logic;
        rst : in std_logic;
        
        en_out : out std_logic;
        count_out : out std_logic_vector (period_width-1 downto 0)
    );
end clk_div_generic;



architecture Behavioral of clk_div_generic is

signal en_sig : std_logic;
signal count_in_sig, count_out_sig : std_logic_vector (period_width-1 downto 0) := (others=>'0');

begin

    count_out <= count_out_sig;
    count_in_sig <= std_logic_vector( unsigned(count_out_sig) - 1 );
    en_out <= en_sig;

    -- counter register and output logic
    process (clk) begin
        if rising_edge(clk) then
            if (rst = '1') then
                en_sig <= '0';
                count_out_sig <=    std_logic_vector(
                                        unsigned(period)
                                        + to_unsigned(phase_lag,period_width) 
                                        - to_unsigned(phase_lead,period_width)
                                    ); -- reset to phase start
            elsif (en = '1') then
                if (unsigned(count_in_sig) = 0) then
                    count_out_sig <= period; -- reset to period
                    en_sig <= '1';
                else
                    count_out_sig <= count_in_sig;
                    en_sig <= '0';
                end if;
            else
                count_out_sig <= count_out_sig;
                en_sig <= '0';
            end if;
        end if;
    end process;
    
end Behavioral;

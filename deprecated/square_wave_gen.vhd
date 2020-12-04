----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/27/2020 10:54:27 AM
-- Design Name: 
-- Module Name: square_wave_gen - Behavioral
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

entity square_wave_gen is
    generic (
        half_period_width : integer;
        phase_lag : integer := 0;
        phase_bit : integer := 0
    );
    port (
        half_period : in STD_LOGIC_VECTOR (half_period_width-1 downto 0);
        sq_out : out STD_LOGIC;
        en : in STD_LOGIC := '1';
        clk : in STD_LOGIC;
        rst : in STD_LOGIC
    );
end square_wave_gen;

architecture Behavioral of square_wave_gen is

    signal en_sig, sq_sig : std_logic := '0';

begin

   clk_div : entity work.clk_div_generic
        generic map (
            period_width => half_period_width,
            phase_lag => phase_lag
        )
        port map (
            period => half_period,
            clk => clk,
            en => en,
            rst => rst,
            en_out => en_sig
        );
        
    -- FF after output logic
    process (clk) begin
        if rising_edge(clk) then
            if (rst = '1') then
                sq_sig <= std_logic(to_unsigned(phase_bit, 1)(0));
            elsif (en_sig = '1') then
                sq_sig <= not sq_sig;
            end if;
        end if;
    end process;
    
    sq_out <= sq_sig;
        

end Behavioral;

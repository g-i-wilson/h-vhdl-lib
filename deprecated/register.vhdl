----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2020 08:32:04 AM
-- Design Name: 
-- Module Name: register - Behavioral
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


-- copied from https://vhdlwhiz.com/shift-register/

entity reg_generic is
  generic (
    reg_len : integer
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    en : in std_logic;
 
    reg_in : in std_logic_vector(reg_len-1 downto 0);
    reg_out : out std_logic_vector(reg_len-1 downto 0)
  );
end;


architecture Behavioral of reg_generic is
begin

process (clk) begin
    if rising_edge(clk) then
        if (rst = '1') then
            reg_out <= (others=>'0');
        elsif (en = '1') then
            reg_out <= reg_in;
        end if;
    end if;
end process;

end Behavioral;

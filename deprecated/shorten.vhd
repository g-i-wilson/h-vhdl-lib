----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/21/2020 05:07:34 PM
-- Design Name: 
-- Module Name: shorten - Behavioral
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

entity shorten is
    generic (
        width : integer;
        places : integer
    );
    port ( 
        input : in STD_LOGIC_VECTOR (width-1 downto 0);
        output : out STD_LOGIC_VECTOR (width-1 downto 0);
        round_up : in STD_LOGIC;
        clk : in STD_LOGIC;
        en : in STD_LOGIC;
        rst : in STD_LOGIC
    );
end shorten;

architecture Behavioral of shorten is

    component reg_generic
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
    end component;

    signal
        shifted_sig,
        rounded_sig
        : std_logic_vector(width-1 downto 0);
        
begin

    shifted_reg : reg_generic
        generic map (
            reg_len => width
        )
        port map (
            clk => clk,
            en => en,
            rst => rst,
            reg_in => rounded_sig,
            reg_out => output
        );


    shifted_sig <= std_logic_vector(
        shift_right(
            signed(input),
            places
        )
    );

    process (shifted_sig, round_up) begin
        if (round_up = '1') then
            rounded_sig <= std_logic_vector( signed(shifted_sig) + 1 );
        else
            rounded_sig <= shifted_sig;
        end if;
    end process;
    
end Behavioral;

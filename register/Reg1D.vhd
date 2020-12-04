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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity Reg1D is
  generic (
    LENGTH        : positive := 8;
    BIG_ENDIAN    : boolean := true
  );
  port (
    CLK           : in std_logic;
    RST           : in std_logic;

    SHIFT_EN      : in std_logic := '0';
    PAR_EN        : in std_logic := '0';

    SHIFT_IN      : in std_logic := '0';
    PAR_IN        : in std_logic_vector(LENGTH-1 downto 0) := (others=>'0');

    DEFAULT_STATE : in std_logic_vector(LENGTH-1 downto 0) := (others=>'0');
    SHIFT_OUT     : out std_logic;
    PAR_OUT       : out std_logic_vector(LENGTH-1 downto 0)
  );
end;


architecture Behavioral of Reg1D is

    signal reg_state : std_logic_vector(LENGTH-1 downto 0);

begin

    PAR_OUT <= reg_state;

    process (reg_state) begin
        if (BIG_ENDIAN) then
            SHIFT_OUT <= reg_state(LENGTH-1);
        else
            SHIFT_OUT <= reg_state(0);
        end if;
    end process;

    process (CLK) begin
        if rising_edge(CLK) then
            if (RST = '1') then
                reg_state <= DEFAULT_STATE;
            elsif (SHIFT_EN = '1') then
                if (BIG_ENDIAN) then
                    reg_state <= reg_state(LENGTH-2 downto 0) & SHIFT_IN;
                else
                    reg_state <= SHIFT_IN & reg_state(LENGTH-1 downto 1);
                end if;
            elsif (PAR_EN = '1') then
                reg_state <= PAR_IN;
            end if;
        end if;
    end process;

end Behavioral;

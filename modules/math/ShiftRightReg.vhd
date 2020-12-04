library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ShiftRightReg is
    generic (
        WIDTH       : integer;
        PLACES      : integer
    );
    port (
        CLK         : in STD_LOGIC;
        EN          : in STD_LOGIC := '1';
        RST         : in STD_LOGIC;
        INPUT       : in STD_LOGIC_VECTOR (width-1 downto 0);
        ROUND_UP    : in STD_LOGIC;

        OUTPUT      : out STD_LOGIC_VECTOR (width-1 downto 0)
    );
end ShiftRightReg;

architecture Behavioral of ShiftRightReg is

    signal shifted_sig : std_logic_vector(WIDTH-1 downto 0);
    signal rounded_sig : std_logic_vector(WIDTH-1 downto 0);

begin

    shifted_reg : entity work.Reg1D
        generic map (
            LENGTH      => WIDTH
        )
        port map (
            CLK         => CLK,
            RST         => RST,
            PAR_EN      => EN,
            PAR_IN      => rounded_sig,
            PAR_OUT     => OUTPUT
        );


    shifted_sig <= std_logic_vector(
        shift_right(
            signed(INPUT),
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Derivative is
	generic (
		WIDTH		: positive := 8
	);
    port (
        CLK         : in STD_LOGIC;
        EN          : in STD_LOGIC := '1';
        RST         : in STD_LOGIC;

        SIG_IN      : in STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        SIG_OUT     : out STD_LOGIC_VECTOR(WIDTH-1 downto 0);
        DIFF_OUT    : out STD_LOGIC_VECTOR(WIDTH-1 downto 0)
    );
end Derivative;

architecture Behavioral of Derivative is

    signal diff_sig         : std_logic_vector(WIDTH-1 downto 0);
    signal previous_sig     : std_logic_vector(WIDTH-1 downto 0);

begin

    pass_through_reg : entity work.Reg1D
    generic map (
        LENGTH      => WIDTH
    )
    port map (
        CLK         => CLK,
        RST         => RST,
        PAR_EN      => EN,
        PAR_IN      => SIG_IN,
        PAR_OUT     => previous_sig
    );
    
    SIG_OUT <= previous_sig;

    diff_sig <= std_logic_vector(signed(SIG_IN) - signed(previous_sig));
    
    diff_out_reg : entity work.Reg1D
    generic map (
        LENGTH      => WIDTH
    )
    port map (
        CLK         => CLK,
        RST         => RST,
        PAR_EN      => EN,
        PAR_IN      => diff_sig,
        PAR_OUT     => DIFF_OUT
    );

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DifferenceAccumulator is
    generic (
        IN_WIDTH    : integer;
        SUM_WIDTH   : integer
    );
    port (
        CLK         : in STD_LOGIC;
        EN          : in STD_LOGIC;
        RST         : in STD_LOGIC;
        IN_A        : in STD_LOGIC_VECTOR (IN_WIDTH-1 downto 0);
        IN_B        : in STD_LOGIC_VECTOR (IN_WIDTH-1 downto 0);

        DIFF_SUM    : out STD_LOGIC_VECTOR (SUM_WIDTH-1 downto 0);
        POS_SIGN    : out STD_LOGIC
    );
end DifferenceAccumulator;

architecture Behavioral of DifferenceAccumulator is

    signal diff_sig         : std_logic_vector(IN_WIDTH-1 downto 0);
    signal diff_resized_sig : std_logic_vector(SUM_WIDTH-1 downto 0);
    signal sum_sig          : std_logic_vector(SUM_WIDTH-1 downto 0);
    signal sum_reg_sig      : std_logic_vector(SUM_WIDTH-1 downto 0);

begin

    adder : entity work.Reg1D
        generic map (
            LENGTH      => SUM_WIDTH
        )
        port map (
            CLK         => CLK,
            RST         => RST,

            PAR_EN      => EN,
            PAR_IN      => sum_sig,
            PAR_OUT     => sum_reg_sig
        );


    diff_sig <= std_logic_vector( signed(IN_A) - signed(IN_B) );
    
    diff_resized_sig <= std_logic_vector( resize(signed(diff_sig), SUM_WIDTH) );

    sum_sig <= std_logic_vector( signed(diff_resized_sig) + signed(sum_reg_sig) );

    DIFF_SUM <= sum_reg_sig;

    process (sum_reg_sig) begin
        if (signed(sum_reg_sig) > 0) then
            POS_SIGN <= '1';
        else
            POS_SIGN <= '0';
        end if;
    end process;


end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SinusoidGenerator64 is
    generic (
        WIDTH           : positive := 16
    );
    port (
        CLK             : in STD_LOGIC;
        RST             : in STD_LOGIC;
        EN              : in STD_LOGIC := '1';

        COS_OUT         : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
        SIN_OUT         : out STD_LOGIC_VECTOR (WIDTH-1 downto 0)
    );
end SinusoidGenerator64;

architecture Behavioral of SinusoidGenerator64 is

    signal sin_sig : std_logic_vector (15 downto 0);
    signal cos_sig : std_logic_vector (15 downto 0);

    signal all_lower_out_sig : std_logic_vector (63*16-1 downto 0);

begin

    -- Note: values apear backwards because Reg2D shifts to right, so read out in reverse.
    sin_reg : entity work.reg2D
        generic map (
            LENGTH          => 64,
            WIDTH           => WIDTH
        )
        port map (
            CLK             => CLK,
            RST             => RST,
            PAR_EN          => EN,
            DEFAULT_STATE   =>
        		x"F374" &
        		x"E707" &
        		x"DAD8" &
        		x"CF04" &
        		x"C3A9" &
        		x"B8E3" &
        		x"AECC" &
        		x"A57E" &
        		x"9D0E" &
        		x"9593" &
        		x"8F1E" &
        		x"89BF" &
        		x"8583" &
        		x"8276" &
        		x"809E" &
        		x"8001" &
        		x"809E" &
        		x"8276" &
        		x"8583" &
        		x"89BF" &
        		x"8F1E" &
        		x"9593" &
        		x"9D0E" &
        		x"A57E" &
        		x"AECC" &
        		x"B8E3" &
        		x"C3A9" &
        		x"CF04" &
        		x"DAD8" &
        		x"E707" &
        		x"F374" &
        		x"0000" &
        		x"0C8B" &
        		x"18F8" &
        		x"2527" &
        		x"30FB" &
        		x"3C56" &
        		x"471C" &
        		x"5133" &
        		x"5A81" &
        		x"62F1" &
        		x"6A6C" &
        		x"70E1" &
        		x"7640" &
        		x"7A7C" &
        		x"7D89" &
        		x"7F61" &
        		x"7FFF" & -- COS tap
        		x"7F61" &
        		x"7D89" &
        		x"7A7C" &
        		x"7640" &
        		x"70E1" &
        		x"6A6C" &
        		x"62F1" &
        		x"5A81" &
        		x"5133" &
        		x"471C" &
        		x"3C56" &
        		x"30FB" &
        		x"2527" &
        		x"18F8" &
        		x"0C8B" &
        		x"0000" , -- SIN tap
            PAR_IN          => sin_sig,
            PAR_OUT         => sin_sig,
            ALL_LOWER_OUT   => all_lower_out_sig
        );
        
        cos_sig <= all_lower_out_sig(48*16-1 downto 47*16);

        sin_coupler: entity work.BitWidthCoupler
            generic map (
                SIG_IN_WIDTH            => 16,
                SIG_OUT_WIDTH           => WIDTH
            )
            port map (
                CLK                     => CLK,
                RST                     => RST,
                EN                      => EN,
                SIG_IN                  => sin_sig,

                SIG_OUT                 => SIN_OUT
            );

        cos_coupler: entity work.BitWidthCoupler
            generic map (
                SIG_IN_WIDTH            => 16,
                SIG_OUT_WIDTH           => WIDTH
            )
            port map (
                CLK                     => CLK,
                RST                     => RST,
                EN                      => EN,
                SIG_IN                  => cos_sig,

                SIG_OUT                 => COS_OUT
            );

end Behavioral;

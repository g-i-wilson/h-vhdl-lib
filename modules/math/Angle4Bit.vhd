library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Angle4Bit is
    port (
        CLK         : in STD_LOGIC;
        EN          : in STD_LOGIC := '1';
        RST         : in STD_LOGIC;

        X_IN        : in STD_LOGIC_VECTOR(3 downto 0);
		Y_IN        : in STD_LOGIC_VECTOR(3 downto 0);

        A_OUT       : out STD_LOGIC_VECTOR(7 downto 0);
        DIFF_OUT    : out STD_LOGIC_VECTOR(7 downto 0)
    );
end Angle4Bit;

architecture Behavioral of Angle4Bit is

    signal angle_sig        : std_logic_vector(7 downto 0);
    signal angle_reg_sig    : std_logic_vector(7 downto 0);
    signal diff_sig         : std_logic_vector(7 downto 0);
    signal diff_out_sig     : std_logic_vector(7 downto 0);

begin

    diff_reg : entity work.Derivative
    generic map (
        WIDTH       => 8
    )
    port map (
        CLK         => CLK,
        RST         => RST,
        EN          => EN,
        SIG_IN      => angle_sig,
        SIG_OUT     => angle_reg_sig,
        DIFF_OUT    => DIFF_OUT
    );

    A_OUT <= angle_reg_sig;

	process (X_IN, Y_IN)
	begin
        case (X_IN & Y_IN) is
            when x"88" => angle_sig <= x"A0";
            when x"89" => angle_sig <= x"9D";
            when x"8A" => angle_sig <= x"9A";
            when x"8B" => angle_sig <= x"97";
            when x"8C" => angle_sig <= x"93";
            when x"8D" => angle_sig <= x"8F";
            when x"8E" => angle_sig <= x"8A";
            when x"8F" => angle_sig <= x"85";
            when x"80" => angle_sig <= x"7F";
            when x"81" => angle_sig <= x"7A";
            when x"82" => angle_sig <= x"75";
            when x"83" => angle_sig <= x"70";
            when x"84" => angle_sig <= x"6C";
            when x"85" => angle_sig <= x"68";
            when x"86" => angle_sig <= x"65";
            when x"87" => angle_sig <= x"62";
            when x"98" => angle_sig <= x"A3";
            when x"99" => angle_sig <= x"A0";
            when x"9A" => angle_sig <= x"9D";
            when x"9B" => angle_sig <= x"99";
            when x"9C" => angle_sig <= x"95";
            when x"9D" => angle_sig <= x"90";
            when x"9E" => angle_sig <= x"8B";
            when x"9F" => angle_sig <= x"86";
            when x"90" => angle_sig <= x"7F";
            when x"91" => angle_sig <= x"79";
            when x"92" => angle_sig <= x"74";
            when x"93" => angle_sig <= x"6F";
            when x"94" => angle_sig <= x"6A";
            when x"95" => angle_sig <= x"66";
            when x"96" => angle_sig <= x"62";
            when x"97" => angle_sig <= x"5F";
            when x"A8" => angle_sig <= x"A6";
            when x"A9" => angle_sig <= x"A3";
            when x"AA" => angle_sig <= x"A0";
            when x"AB" => angle_sig <= x"9C";
            when x"AC" => angle_sig <= x"98";
            when x"AD" => angle_sig <= x"93";
            when x"AE" => angle_sig <= x"8D";
            when x"AF" => angle_sig <= x"87";
            when x"A0" => angle_sig <= x"7F";
            when x"A1" => angle_sig <= x"78";
            when x"A2" => angle_sig <= x"72";
            when x"A3" => angle_sig <= x"6C";
            when x"A4" => angle_sig <= x"67";
            when x"A5" => angle_sig <= x"63";
            when x"A6" => angle_sig <= x"5F";
            when x"A7" => angle_sig <= x"5C";
            when x"B8" => angle_sig <= x"A9";
            when x"B9" => angle_sig <= x"A7";
            when x"BA" => angle_sig <= x"A4";
            when x"BB" => angle_sig <= x"A0";
            when x"BC" => angle_sig <= x"9B";
            when x"BD" => angle_sig <= x"96";
            when x"BE" => angle_sig <= x"8F";
            when x"BF" => angle_sig <= x"88";
            when x"B0" => angle_sig <= x"7F";
            when x"B1" => angle_sig <= x"77";
            when x"B2" => angle_sig <= x"70";
            when x"B3" => angle_sig <= x"69";
            when x"B4" => angle_sig <= x"64";
            when x"B5" => angle_sig <= x"5F";
            when x"B6" => angle_sig <= x"5B";
            when x"B7" => angle_sig <= x"58";
            when x"C8" => angle_sig <= x"AD";
            when x"C9" => angle_sig <= x"AB";
            when x"CA" => angle_sig <= x"A8";
            when x"CB" => angle_sig <= x"A4";
            when x"CC" => angle_sig <= x"A0";
            when x"CD" => angle_sig <= x"9A";
            when x"CE" => angle_sig <= x"93";
            when x"CF" => angle_sig <= x"8A";
            when x"C0" => angle_sig <= x"7F";
            when x"C1" => angle_sig <= x"75";
            when x"C2" => angle_sig <= x"6C";
            when x"C3" => angle_sig <= x"65";
            when x"C4" => angle_sig <= x"5F";
            when x"C5" => angle_sig <= x"5B";
            when x"C6" => angle_sig <= x"57";
            when x"C7" => angle_sig <= x"54";
            when x"D8" => angle_sig <= x"B1";
            when x"D9" => angle_sig <= x"AF";
            when x"DA" => angle_sig <= x"AD";
            when x"DB" => angle_sig <= x"AA";
            when x"DC" => angle_sig <= x"A6";
            when x"DD" => angle_sig <= x"A0";
            when x"DE" => angle_sig <= x"98";
            when x"DF" => angle_sig <= x"8D";
            when x"D0" => angle_sig <= x"7F";
            when x"D1" => angle_sig <= x"72";
            when x"D2" => angle_sig <= x"67";
            when x"D3" => angle_sig <= x"5F";
            when x"D4" => angle_sig <= x"59";
            when x"D5" => angle_sig <= x"55";
            when x"D6" => angle_sig <= x"52";
            when x"D7" => angle_sig <= x"50";
            when x"E8" => angle_sig <= x"B6";
            when x"E9" => angle_sig <= x"B4";
            when x"EA" => angle_sig <= x"B3";
            when x"EB" => angle_sig <= x"B0";
            when x"EC" => angle_sig <= x"AD";
            when x"ED" => angle_sig <= x"A8";
            when x"EE" => angle_sig <= x"A0";
            when x"EF" => angle_sig <= x"93";
            when x"E0" => angle_sig <= x"7F";
            when x"E1" => angle_sig <= x"6C";
            when x"E2" => angle_sig <= x"5F";
            when x"E3" => angle_sig <= x"57";
            when x"E4" => angle_sig <= x"52";
            when x"E5" => angle_sig <= x"4F";
            when x"E6" => angle_sig <= x"4C";
            when x"E7" => angle_sig <= x"4B";
            when x"F8" => angle_sig <= x"BB";
            when x"F9" => angle_sig <= x"BA";
            when x"FA" => angle_sig <= x"B9";
            when x"FB" => angle_sig <= x"B8";
            when x"FC" => angle_sig <= x"B6";
            when x"FD" => angle_sig <= x"B3";
            when x"FE" => angle_sig <= x"AD";
            when x"FF" => angle_sig <= x"A0";
            when x"F0" => angle_sig <= x"7F";
            when x"F1" => angle_sig <= x"5F";
            when x"F2" => angle_sig <= x"52";
            when x"F3" => angle_sig <= x"4C";
            when x"F4" => angle_sig <= x"49";
            when x"F5" => angle_sig <= x"47";
            when x"F6" => angle_sig <= x"46";
            when x"F7" => angle_sig <= x"45";
            when x"08" => angle_sig <= x"C0";
            when x"09" => angle_sig <= x"C0";
            when x"0A" => angle_sig <= x"C0";
            when x"0B" => angle_sig <= x"C0";
            when x"0C" => angle_sig <= x"C0";
            when x"0D" => angle_sig <= x"C0";
            when x"0E" => angle_sig <= x"C0";
            when x"0F" => angle_sig <= x"C0";
            when x"00" => angle_sig <= x"00";
            when x"01" => angle_sig <= x"3F";
            when x"02" => angle_sig <= x"3F";
            when x"03" => angle_sig <= x"3F";
            when x"04" => angle_sig <= x"3F";
            when x"05" => angle_sig <= x"3F";
            when x"06" => angle_sig <= x"3F";
            when x"07" => angle_sig <= x"3F";
            when x"18" => angle_sig <= x"C5";
            when x"19" => angle_sig <= x"C6";
            when x"1A" => angle_sig <= x"C6";
            when x"1B" => angle_sig <= x"C8";
            when x"1C" => angle_sig <= x"CA";
            when x"1D" => angle_sig <= x"CD";
            when x"1E" => angle_sig <= x"D3";
            when x"1F" => angle_sig <= x"E0";
            when x"10" => angle_sig <= x"00";
            when x"11" => angle_sig <= x"1F";
            when x"12" => angle_sig <= x"2C";
            when x"13" => angle_sig <= x"32";
            when x"14" => angle_sig <= x"35";
            when x"15" => angle_sig <= x"37";
            when x"16" => angle_sig <= x"39";
            when x"17" => angle_sig <= x"39";
            when x"28" => angle_sig <= x"CA";
            when x"29" => angle_sig <= x"CB";
            when x"2A" => angle_sig <= x"CD";
            when x"2B" => angle_sig <= x"CF";
            when x"2C" => angle_sig <= x"D3";
            when x"2D" => angle_sig <= x"D8";
            when x"2E" => angle_sig <= x"E0";
            when x"2F" => angle_sig <= x"ED";
            when x"20" => angle_sig <= x"00";
            when x"21" => angle_sig <= x"12";
            when x"22" => angle_sig <= x"1F";
            when x"23" => angle_sig <= x"27";
            when x"24" => angle_sig <= x"2C";
            when x"25" => angle_sig <= x"30";
            when x"26" => angle_sig <= x"32";
            when x"27" => angle_sig <= x"34";
            when x"38" => angle_sig <= x"CE";
            when x"39" => angle_sig <= x"D0";
            when x"3A" => angle_sig <= x"D3";
            when x"3B" => angle_sig <= x"D6";
            when x"3C" => angle_sig <= x"DA";
            when x"3D" => angle_sig <= x"E0";
            when x"3E" => angle_sig <= x"E8";
            when x"3F" => angle_sig <= x"F2";
            when x"30" => angle_sig <= x"00";
            when x"31" => angle_sig <= x"0D";
            when x"32" => angle_sig <= x"17";
            when x"33" => angle_sig <= x"1F";
            when x"34" => angle_sig <= x"25";
            when x"35" => angle_sig <= x"29";
            when x"36" => angle_sig <= x"2C";
            when x"37" => angle_sig <= x"2F";
            when x"48" => angle_sig <= x"D3";
            when x"49" => angle_sig <= x"D5";
            when x"4A" => angle_sig <= x"D8";
            when x"4B" => angle_sig <= x"DB";
            when x"4C" => angle_sig <= x"E0";
            when x"4D" => angle_sig <= x"E5";
            when x"4E" => angle_sig <= x"ED";
            when x"4F" => angle_sig <= x"F6";
            when x"40" => angle_sig <= x"00";
            when x"41" => angle_sig <= x"09";
            when x"42" => angle_sig <= x"12";
            when x"43" => angle_sig <= x"1A";
            when x"44" => angle_sig <= x"1F";
            when x"45" => angle_sig <= x"24";
            when x"46" => angle_sig <= x"27";
            when x"47" => angle_sig <= x"2A";
            when x"58" => angle_sig <= x"D6";
            when x"59" => angle_sig <= x"D9";
            when x"5A" => angle_sig <= x"DC";
            when x"5B" => angle_sig <= x"E0";
            when x"5C" => angle_sig <= x"E4";
            when x"5D" => angle_sig <= x"EA";
            when x"5E" => angle_sig <= x"F0";
            when x"5F" => angle_sig <= x"F7";
            when x"50" => angle_sig <= x"00";
            when x"51" => angle_sig <= x"08";
            when x"52" => angle_sig <= x"0F";
            when x"53" => angle_sig <= x"15";
            when x"54" => angle_sig <= x"1B";
            when x"55" => angle_sig <= x"1F";
            when x"56" => angle_sig <= x"23";
            when x"57" => angle_sig <= x"26";
            when x"68" => angle_sig <= x"DA";
            when x"69" => angle_sig <= x"DD";
            when x"6A" => angle_sig <= x"E0";
            when x"6B" => angle_sig <= x"E3";
            when x"6C" => angle_sig <= x"E8";
            when x"6D" => angle_sig <= x"ED";
            when x"6E" => angle_sig <= x"F2";
            when x"6F" => angle_sig <= x"F9";
            when x"60" => angle_sig <= x"00";
            when x"61" => angle_sig <= x"06";
            when x"62" => angle_sig <= x"0D";
            when x"63" => angle_sig <= x"12";
            when x"64" => angle_sig <= x"17";
            when x"65" => angle_sig <= x"1C";
            when x"66" => angle_sig <= x"1F";
            when x"67" => angle_sig <= x"22";
            when x"78" => angle_sig <= x"DD";
            when x"79" => angle_sig <= x"E0";
            when x"7A" => angle_sig <= x"E3";
            when x"7B" => angle_sig <= x"E6";
            when x"7C" => angle_sig <= x"EA";
            when x"7D" => angle_sig <= x"EF";
            when x"7E" => angle_sig <= x"F4";
            when x"7F" => angle_sig <= x"FA";
            when x"70" => angle_sig <= x"00";
            when x"71" => angle_sig <= x"05";
            when x"72" => angle_sig <= x"0B";
            when x"73" => angle_sig <= x"10";
            when x"74" => angle_sig <= x"15";
            when x"75" => angle_sig <= x"19";
            when x"76" => angle_sig <= x"1C";
            when x"77" => angle_sig <= x"1F";
            when others => angle_sig <= x"00";
        end case;
	end process;

end Behavioral;

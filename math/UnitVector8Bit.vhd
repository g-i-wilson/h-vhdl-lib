library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity UnitVector8Bit is
    port (
        CLK         : in STD_LOGIC;
        EN          : in STD_LOGIC := '1';
        RST         : in STD_LOGIC;
        A_IN        : in STD_LOGIC_VECTOR(7 downto 0);

        X_OUT       : out STD_LOGIC_VECTOR(11 downto 0);
		Y_OUT       : out STD_LOGIC_VECTOR(11 downto 0)
    );
end UnitVector8Bit;

architecture Behavioral of UnitVector8Bit is

    signal x_out_sig        : std_logic_vector(11 downto 0);
    signal y_out_sig        : std_logic_vector(11 downto 0);

begin

    x_out_reg : entity work.Reg1D
    generic map (
        LENGTH      => 12
    )
    port map (
        CLK         => CLK,
        RST         => RST,
        PAR_EN      => EN,
        PAR_IN      => x_out_sig,
        PAR_OUT     => X_OUT
    );

    y_out_reg : entity work.Reg1D
    generic map (
        LENGTH      => 12
    )
    port map (
        CLK         => CLK,
        RST         => RST,
        PAR_EN      => EN,
        PAR_IN      => y_out_sig,
        PAR_OUT     => Y_OUT
    );

	process (A_IN)
	begin
        case (A_IN) is
            when x"80" => x_out_sig <= x"801"; y_out_sig <= x"FFF";
        	when x"81" => x_out_sig <= x"801"; y_out_sig <= x"FCD";
        	when x"82" => x_out_sig <= x"803"; y_out_sig <= x"F9B";
        	when x"83" => x_out_sig <= x"806"; y_out_sig <= x"F69";
        	when x"84" => x_out_sig <= x"80A"; y_out_sig <= x"F37";
        	when x"85" => x_out_sig <= x"810"; y_out_sig <= x"F05";
        	when x"86" => x_out_sig <= x"817"; y_out_sig <= x"ED3";
        	when x"87" => x_out_sig <= x"81F"; y_out_sig <= x"EA2";
        	when x"88" => x_out_sig <= x"828"; y_out_sig <= x"E70";
        	when x"89" => x_out_sig <= x"832"; y_out_sig <= x"E3F";
        	when x"8A" => x_out_sig <= x"83E"; y_out_sig <= x"E0E";
        	when x"8B" => x_out_sig <= x"84B"; y_out_sig <= x"DDE";
        	when x"8C" => x_out_sig <= x"859"; y_out_sig <= x"DAD";
        	when x"8D" => x_out_sig <= x"868"; y_out_sig <= x"D7D";
        	when x"8E" => x_out_sig <= x"878"; y_out_sig <= x"D4E";
        	when x"8F" => x_out_sig <= x"88A"; y_out_sig <= x"D1F";
        	when x"90" => x_out_sig <= x"89C"; y_out_sig <= x"CF0";
        	when x"91" => x_out_sig <= x"8B0"; y_out_sig <= x"CC2";
        	when x"92" => x_out_sig <= x"8C5"; y_out_sig <= x"C94";
        	when x"93" => x_out_sig <= x"8DB"; y_out_sig <= x"C67";
        	when x"94" => x_out_sig <= x"8F2"; y_out_sig <= x"C3B";
        	when x"95" => x_out_sig <= x"90A"; y_out_sig <= x"C0F";
        	when x"96" => x_out_sig <= x"924"; y_out_sig <= x"BE3";
        	when x"97" => x_out_sig <= x"93E"; y_out_sig <= x"BB8";
        	when x"98" => x_out_sig <= x"959"; y_out_sig <= x"B8E";
        	when x"99" => x_out_sig <= x"976"; y_out_sig <= x"B65";
        	when x"9A" => x_out_sig <= x"993"; y_out_sig <= x"B3C";
        	when x"9B" => x_out_sig <= x"9B2"; y_out_sig <= x"B14";
        	when x"9C" => x_out_sig <= x"9D1"; y_out_sig <= x"AED";
        	when x"9D" => x_out_sig <= x"9F1"; y_out_sig <= x"AC6";
        	when x"9E" => x_out_sig <= x"A13"; y_out_sig <= x"AA1";
        	when x"9F" => x_out_sig <= x"A35"; y_out_sig <= x"A7C";
        	when x"A0" => x_out_sig <= x"A58"; y_out_sig <= x"A58";
        	when x"A1" => x_out_sig <= x"A7C"; y_out_sig <= x"A35";
        	when x"A2" => x_out_sig <= x"AA1"; y_out_sig <= x"A13";
        	when x"A3" => x_out_sig <= x"AC6"; y_out_sig <= x"9F1";
        	when x"A4" => x_out_sig <= x"AED"; y_out_sig <= x"9D1";
        	when x"A5" => x_out_sig <= x"B14"; y_out_sig <= x"9B2";
        	when x"A6" => x_out_sig <= x"B3C"; y_out_sig <= x"993";
        	when x"A7" => x_out_sig <= x"B65"; y_out_sig <= x"976";
        	when x"A8" => x_out_sig <= x"B8E"; y_out_sig <= x"959";
        	when x"A9" => x_out_sig <= x"BB8"; y_out_sig <= x"93E";
        	when x"AA" => x_out_sig <= x"BE3"; y_out_sig <= x"924";
        	when x"AB" => x_out_sig <= x"C0F"; y_out_sig <= x"90A";
        	when x"AC" => x_out_sig <= x"C3B"; y_out_sig <= x"8F2";
        	when x"AD" => x_out_sig <= x"C67"; y_out_sig <= x"8DB";
        	when x"AE" => x_out_sig <= x"C94"; y_out_sig <= x"8C5";
        	when x"AF" => x_out_sig <= x"CC2"; y_out_sig <= x"8B0";
        	when x"B0" => x_out_sig <= x"CF0"; y_out_sig <= x"89C";
        	when x"B1" => x_out_sig <= x"D1F"; y_out_sig <= x"88A";
        	when x"B2" => x_out_sig <= x"D4E"; y_out_sig <= x"878";
        	when x"B3" => x_out_sig <= x"D7D"; y_out_sig <= x"868";
        	when x"B4" => x_out_sig <= x"DAD"; y_out_sig <= x"859";
        	when x"B5" => x_out_sig <= x"DDE"; y_out_sig <= x"84B";
        	when x"B6" => x_out_sig <= x"E0E"; y_out_sig <= x"83E";
        	when x"B7" => x_out_sig <= x"E3F"; y_out_sig <= x"832";
        	when x"B8" => x_out_sig <= x"E70"; y_out_sig <= x"828";
        	when x"B9" => x_out_sig <= x"EA2"; y_out_sig <= x"81F";
        	when x"BA" => x_out_sig <= x"ED3"; y_out_sig <= x"817";
        	when x"BB" => x_out_sig <= x"F05"; y_out_sig <= x"810";
        	when x"BC" => x_out_sig <= x"F37"; y_out_sig <= x"80A";
        	when x"BD" => x_out_sig <= x"F69"; y_out_sig <= x"806";
        	when x"BE" => x_out_sig <= x"F9B"; y_out_sig <= x"803";
        	when x"BF" => x_out_sig <= x"FCD"; y_out_sig <= x"801";
        	when x"C0" => x_out_sig <= x"000"; y_out_sig <= x"801";
        	when x"C1" => x_out_sig <= x"032"; y_out_sig <= x"801";
        	when x"C2" => x_out_sig <= x"064"; y_out_sig <= x"803";
        	when x"C3" => x_out_sig <= x"096"; y_out_sig <= x"806";
        	when x"C4" => x_out_sig <= x"0C8"; y_out_sig <= x"80A";
        	when x"C5" => x_out_sig <= x"0FA"; y_out_sig <= x"810";
        	when x"C6" => x_out_sig <= x"12C"; y_out_sig <= x"817";
        	when x"C7" => x_out_sig <= x"15D"; y_out_sig <= x"81F";
        	when x"C8" => x_out_sig <= x"18F"; y_out_sig <= x"828";
        	when x"C9" => x_out_sig <= x"1C0"; y_out_sig <= x"832";
        	when x"CA" => x_out_sig <= x"1F1"; y_out_sig <= x"83E";
        	when x"CB" => x_out_sig <= x"221"; y_out_sig <= x"84B";
        	when x"CC" => x_out_sig <= x"252"; y_out_sig <= x"859";
        	when x"CD" => x_out_sig <= x"282"; y_out_sig <= x"868";
        	when x"CE" => x_out_sig <= x"2B1"; y_out_sig <= x"878";
        	when x"CF" => x_out_sig <= x"2E0"; y_out_sig <= x"88A";
        	when x"D0" => x_out_sig <= x"30F"; y_out_sig <= x"89C";
        	when x"D1" => x_out_sig <= x"33D"; y_out_sig <= x"8B0";
        	when x"D2" => x_out_sig <= x"36B"; y_out_sig <= x"8C5";
        	when x"D3" => x_out_sig <= x"398"; y_out_sig <= x"8DB";
        	when x"D4" => x_out_sig <= x"3C4"; y_out_sig <= x"8F2";
        	when x"D5" => x_out_sig <= x"3F0"; y_out_sig <= x"90A";
        	when x"D6" => x_out_sig <= x"41C"; y_out_sig <= x"924";
        	when x"D7" => x_out_sig <= x"447"; y_out_sig <= x"93E";
        	when x"D8" => x_out_sig <= x"471"; y_out_sig <= x"959";
        	when x"D9" => x_out_sig <= x"49A"; y_out_sig <= x"976";
        	when x"DA" => x_out_sig <= x"4C3"; y_out_sig <= x"993";
        	when x"DB" => x_out_sig <= x"4EB"; y_out_sig <= x"9B2";
        	when x"DC" => x_out_sig <= x"512"; y_out_sig <= x"9D1";
        	when x"DD" => x_out_sig <= x"539"; y_out_sig <= x"9F1";
        	when x"DE" => x_out_sig <= x"55E"; y_out_sig <= x"A13";
        	when x"DF" => x_out_sig <= x"583"; y_out_sig <= x"A35";
        	when x"E0" => x_out_sig <= x"5A7"; y_out_sig <= x"A58";
        	when x"E1" => x_out_sig <= x"5CA"; y_out_sig <= x"A7C";
        	when x"E2" => x_out_sig <= x"5EC"; y_out_sig <= x"AA1";
        	when x"E3" => x_out_sig <= x"60E"; y_out_sig <= x"AC6";
        	when x"E4" => x_out_sig <= x"62E"; y_out_sig <= x"AED";
        	when x"E5" => x_out_sig <= x"64D"; y_out_sig <= x"B14";
        	when x"E6" => x_out_sig <= x"66C"; y_out_sig <= x"B3C";
        	when x"E7" => x_out_sig <= x"689"; y_out_sig <= x"B65";
        	when x"E8" => x_out_sig <= x"6A6"; y_out_sig <= x"B8E";
        	when x"E9" => x_out_sig <= x"6C1"; y_out_sig <= x"BB8";
        	when x"EA" => x_out_sig <= x"6DB"; y_out_sig <= x"BE3";
        	when x"EB" => x_out_sig <= x"6F5"; y_out_sig <= x"C0F";
        	when x"EC" => x_out_sig <= x"70D"; y_out_sig <= x"C3B";
        	when x"ED" => x_out_sig <= x"724"; y_out_sig <= x"C67";
        	when x"EE" => x_out_sig <= x"73A"; y_out_sig <= x"C94";
        	when x"EF" => x_out_sig <= x"74F"; y_out_sig <= x"CC2";
        	when x"F0" => x_out_sig <= x"763"; y_out_sig <= x"CF0";
        	when x"F1" => x_out_sig <= x"775"; y_out_sig <= x"D1F";
        	when x"F2" => x_out_sig <= x"787"; y_out_sig <= x"D4E";
        	when x"F3" => x_out_sig <= x"797"; y_out_sig <= x"D7D";
        	when x"F4" => x_out_sig <= x"7A6"; y_out_sig <= x"DAD";
        	when x"F5" => x_out_sig <= x"7B4"; y_out_sig <= x"DDE";
        	when x"F6" => x_out_sig <= x"7C1"; y_out_sig <= x"E0E";
        	when x"F7" => x_out_sig <= x"7CD"; y_out_sig <= x"E3F";
        	when x"F8" => x_out_sig <= x"7D7"; y_out_sig <= x"E70";
        	when x"F9" => x_out_sig <= x"7E0"; y_out_sig <= x"EA2";
        	when x"FA" => x_out_sig <= x"7E8"; y_out_sig <= x"ED3";
        	when x"FB" => x_out_sig <= x"7EF"; y_out_sig <= x"F05";
        	when x"FC" => x_out_sig <= x"7F5"; y_out_sig <= x"F37";
        	when x"FD" => x_out_sig <= x"7F9"; y_out_sig <= x"F69";
        	when x"FE" => x_out_sig <= x"7FC"; y_out_sig <= x"F9B";
        	when x"FF" => x_out_sig <= x"7FE"; y_out_sig <= x"FCD";
        	when x"00" => x_out_sig <= x"7FF"; y_out_sig <= x"000";
        	when x"01" => x_out_sig <= x"7FE"; y_out_sig <= x"032";
        	when x"02" => x_out_sig <= x"7FC"; y_out_sig <= x"064";
        	when x"03" => x_out_sig <= x"7F9"; y_out_sig <= x"096";
        	when x"04" => x_out_sig <= x"7F5"; y_out_sig <= x"0C8";
        	when x"05" => x_out_sig <= x"7EF"; y_out_sig <= x"0FA";
        	when x"06" => x_out_sig <= x"7E8"; y_out_sig <= x"12C";
        	when x"07" => x_out_sig <= x"7E0"; y_out_sig <= x"15D";
        	when x"08" => x_out_sig <= x"7D7"; y_out_sig <= x"18F";
        	when x"09" => x_out_sig <= x"7CD"; y_out_sig <= x"1C0";
        	when x"0A" => x_out_sig <= x"7C1"; y_out_sig <= x"1F1";
        	when x"0B" => x_out_sig <= x"7B4"; y_out_sig <= x"221";
        	when x"0C" => x_out_sig <= x"7A6"; y_out_sig <= x"252";
        	when x"0D" => x_out_sig <= x"797"; y_out_sig <= x"282";
        	when x"0E" => x_out_sig <= x"787"; y_out_sig <= x"2B1";
        	when x"0F" => x_out_sig <= x"775"; y_out_sig <= x"2E0";
        	when x"10" => x_out_sig <= x"763"; y_out_sig <= x"30F";
        	when x"11" => x_out_sig <= x"74F"; y_out_sig <= x"33D";
        	when x"12" => x_out_sig <= x"73A"; y_out_sig <= x"36B";
        	when x"13" => x_out_sig <= x"724"; y_out_sig <= x"398";
        	when x"14" => x_out_sig <= x"70D"; y_out_sig <= x"3C4";
        	when x"15" => x_out_sig <= x"6F5"; y_out_sig <= x"3F0";
        	when x"16" => x_out_sig <= x"6DB"; y_out_sig <= x"41C";
        	when x"17" => x_out_sig <= x"6C1"; y_out_sig <= x"447";
        	when x"18" => x_out_sig <= x"6A6"; y_out_sig <= x"471";
        	when x"19" => x_out_sig <= x"689"; y_out_sig <= x"49A";
        	when x"1A" => x_out_sig <= x"66C"; y_out_sig <= x"4C3";
        	when x"1B" => x_out_sig <= x"64D"; y_out_sig <= x"4EB";
        	when x"1C" => x_out_sig <= x"62E"; y_out_sig <= x"512";
        	when x"1D" => x_out_sig <= x"60E"; y_out_sig <= x"539";
        	when x"1E" => x_out_sig <= x"5EC"; y_out_sig <= x"55E";
        	when x"1F" => x_out_sig <= x"5CA"; y_out_sig <= x"583";
        	when x"20" => x_out_sig <= x"5A7"; y_out_sig <= x"5A7";
        	when x"21" => x_out_sig <= x"583"; y_out_sig <= x"5CA";
        	when x"22" => x_out_sig <= x"55E"; y_out_sig <= x"5EC";
        	when x"23" => x_out_sig <= x"539"; y_out_sig <= x"60E";
        	when x"24" => x_out_sig <= x"512"; y_out_sig <= x"62E";
        	when x"25" => x_out_sig <= x"4EB"; y_out_sig <= x"64D";
        	when x"26" => x_out_sig <= x"4C3"; y_out_sig <= x"66C";
        	when x"27" => x_out_sig <= x"49A"; y_out_sig <= x"689";
        	when x"28" => x_out_sig <= x"471"; y_out_sig <= x"6A6";
        	when x"29" => x_out_sig <= x"447"; y_out_sig <= x"6C1";
        	when x"2A" => x_out_sig <= x"41C"; y_out_sig <= x"6DB";
        	when x"2B" => x_out_sig <= x"3F0"; y_out_sig <= x"6F5";
        	when x"2C" => x_out_sig <= x"3C4"; y_out_sig <= x"70D";
        	when x"2D" => x_out_sig <= x"398"; y_out_sig <= x"724";
        	when x"2E" => x_out_sig <= x"36B"; y_out_sig <= x"73A";
        	when x"2F" => x_out_sig <= x"33D"; y_out_sig <= x"74F";
        	when x"30" => x_out_sig <= x"30F"; y_out_sig <= x"763";
        	when x"31" => x_out_sig <= x"2E0"; y_out_sig <= x"775";
        	when x"32" => x_out_sig <= x"2B1"; y_out_sig <= x"787";
        	when x"33" => x_out_sig <= x"282"; y_out_sig <= x"797";
        	when x"34" => x_out_sig <= x"252"; y_out_sig <= x"7A6";
        	when x"35" => x_out_sig <= x"221"; y_out_sig <= x"7B4";
        	when x"36" => x_out_sig <= x"1F1"; y_out_sig <= x"7C1";
        	when x"37" => x_out_sig <= x"1C0"; y_out_sig <= x"7CD";
        	when x"38" => x_out_sig <= x"18F"; y_out_sig <= x"7D7";
        	when x"39" => x_out_sig <= x"15D"; y_out_sig <= x"7E0";
        	when x"3A" => x_out_sig <= x"12C"; y_out_sig <= x"7E8";
        	when x"3B" => x_out_sig <= x"0FA"; y_out_sig <= x"7EF";
        	when x"3C" => x_out_sig <= x"0C8"; y_out_sig <= x"7F5";
        	when x"3D" => x_out_sig <= x"096"; y_out_sig <= x"7F9";
        	when x"3E" => x_out_sig <= x"064"; y_out_sig <= x"7FC";
        	when x"3F" => x_out_sig <= x"032"; y_out_sig <= x"7FE";
        	when x"40" => x_out_sig <= x"000"; y_out_sig <= x"7FF";
        	when x"41" => x_out_sig <= x"FCD"; y_out_sig <= x"7FE";
        	when x"42" => x_out_sig <= x"F9B"; y_out_sig <= x"7FC";
        	when x"43" => x_out_sig <= x"F69"; y_out_sig <= x"7F9";
        	when x"44" => x_out_sig <= x"F37"; y_out_sig <= x"7F5";
        	when x"45" => x_out_sig <= x"F05"; y_out_sig <= x"7EF";
        	when x"46" => x_out_sig <= x"ED3"; y_out_sig <= x"7E8";
        	when x"47" => x_out_sig <= x"EA2"; y_out_sig <= x"7E0";
        	when x"48" => x_out_sig <= x"E70"; y_out_sig <= x"7D7";
        	when x"49" => x_out_sig <= x"E3F"; y_out_sig <= x"7CD";
        	when x"4A" => x_out_sig <= x"E0E"; y_out_sig <= x"7C1";
        	when x"4B" => x_out_sig <= x"DDE"; y_out_sig <= x"7B4";
        	when x"4C" => x_out_sig <= x"DAD"; y_out_sig <= x"7A6";
        	when x"4D" => x_out_sig <= x"D7D"; y_out_sig <= x"797";
        	when x"4E" => x_out_sig <= x"D4E"; y_out_sig <= x"787";
        	when x"4F" => x_out_sig <= x"D1F"; y_out_sig <= x"775";
        	when x"50" => x_out_sig <= x"CF0"; y_out_sig <= x"763";
        	when x"51" => x_out_sig <= x"CC2"; y_out_sig <= x"74F";
        	when x"52" => x_out_sig <= x"C94"; y_out_sig <= x"73A";
        	when x"53" => x_out_sig <= x"C67"; y_out_sig <= x"724";
        	when x"54" => x_out_sig <= x"C3B"; y_out_sig <= x"70D";
        	when x"55" => x_out_sig <= x"C0F"; y_out_sig <= x"6F5";
        	when x"56" => x_out_sig <= x"BE3"; y_out_sig <= x"6DB";
        	when x"57" => x_out_sig <= x"BB8"; y_out_sig <= x"6C1";
        	when x"58" => x_out_sig <= x"B8E"; y_out_sig <= x"6A6";
        	when x"59" => x_out_sig <= x"B65"; y_out_sig <= x"689";
        	when x"5A" => x_out_sig <= x"B3C"; y_out_sig <= x"66C";
        	when x"5B" => x_out_sig <= x"B14"; y_out_sig <= x"64D";
        	when x"5C" => x_out_sig <= x"AED"; y_out_sig <= x"62E";
        	when x"5D" => x_out_sig <= x"AC6"; y_out_sig <= x"60E";
        	when x"5E" => x_out_sig <= x"AA1"; y_out_sig <= x"5EC";
        	when x"5F" => x_out_sig <= x"A7C"; y_out_sig <= x"5CA";
        	when x"60" => x_out_sig <= x"A58"; y_out_sig <= x"5A7";
        	when x"61" => x_out_sig <= x"A35"; y_out_sig <= x"583";
        	when x"62" => x_out_sig <= x"A13"; y_out_sig <= x"55E";
        	when x"63" => x_out_sig <= x"9F1"; y_out_sig <= x"539";
        	when x"64" => x_out_sig <= x"9D1"; y_out_sig <= x"512";
        	when x"65" => x_out_sig <= x"9B2"; y_out_sig <= x"4EB";
        	when x"66" => x_out_sig <= x"993"; y_out_sig <= x"4C3";
        	when x"67" => x_out_sig <= x"976"; y_out_sig <= x"49A";
        	when x"68" => x_out_sig <= x"959"; y_out_sig <= x"471";
        	when x"69" => x_out_sig <= x"93E"; y_out_sig <= x"447";
        	when x"6A" => x_out_sig <= x"924"; y_out_sig <= x"41C";
        	when x"6B" => x_out_sig <= x"90A"; y_out_sig <= x"3F0";
        	when x"6C" => x_out_sig <= x"8F2"; y_out_sig <= x"3C4";
        	when x"6D" => x_out_sig <= x"8DB"; y_out_sig <= x"398";
        	when x"6E" => x_out_sig <= x"8C5"; y_out_sig <= x"36B";
        	when x"6F" => x_out_sig <= x"8B0"; y_out_sig <= x"33D";
        	when x"70" => x_out_sig <= x"89C"; y_out_sig <= x"30F";
        	when x"71" => x_out_sig <= x"88A"; y_out_sig <= x"2E0";
        	when x"72" => x_out_sig <= x"878"; y_out_sig <= x"2B1";
        	when x"73" => x_out_sig <= x"868"; y_out_sig <= x"282";
        	when x"74" => x_out_sig <= x"859"; y_out_sig <= x"252";
        	when x"75" => x_out_sig <= x"84B"; y_out_sig <= x"221";
        	when x"76" => x_out_sig <= x"83E"; y_out_sig <= x"1F1";
        	when x"77" => x_out_sig <= x"832"; y_out_sig <= x"1C0";
        	when x"78" => x_out_sig <= x"828"; y_out_sig <= x"18F";
        	when x"79" => x_out_sig <= x"81F"; y_out_sig <= x"15D";
        	when x"7A" => x_out_sig <= x"817"; y_out_sig <= x"12C";
        	when x"7B" => x_out_sig <= x"810"; y_out_sig <= x"0FA";
        	when x"7C" => x_out_sig <= x"80A"; y_out_sig <= x"0C8";
        	when x"7D" => x_out_sig <= x"806"; y_out_sig <= x"096";
        	when x"7E" => x_out_sig <= x"803"; y_out_sig <= x"064";
        	when x"7F" => x_out_sig <= x"801"; y_out_sig <= x"032";
            when others => x_out_sig <= x"801"; y_out_sig <= x"032";
        end case;
	end process;

end Behavioral;

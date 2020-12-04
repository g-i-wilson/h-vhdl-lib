library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPITap is
    generic (
        FILTER_LENGTH       : positive := 16;
        FILTER_SUM_WIDTH    : positive := 8
    );
    port ( 
        CLK                 : in STD_LOGIC;
        RST                 : in STD_LOGIC;
        CS                  : in STD_LOGIC;
        SCK                 : in STD_LOGIC;
        SDA                 : in STD_LOGIC;
        START               : out STD_LOGIC;
        UNEXPECTED_END      : out STD_LOGIC;
        VALID               : out STD_LOGIC;
        DATA                : out STD_LOGIC_VECTOR (7 downto 0)
    );
end SPITap;

architecture Behavioral of SPITap is

    signal byte_done_sig            : std_logic;
    signal bit_count_en_sig         : std_logic;
    signal bit_count_rst_sig        : std_logic;
    signal shift_data_sig           : std_logic;

    signal cs_sig                   : std_logic;
    signal sck_sig                  : std_logic;
    signal sda_sig                  : std_logic;

begin

    FSM: entity work.SPITapFSM
    port map ( 
        CLK                 => CLK,
        RST                 => RST,
        BYTE_DONE           => byte_done_sig,
        CS                  => cs_sig,
        SCK                 => sck_sig,
        
        VALID               => VALID,
        BIT_COUNT_EN        => bit_count_en_sig,
        BIT_COUNT_RST       => bit_count_rst_sig,
        SHIFT_DATA          => shift_data_sig,
        START               => START,
        UNEXPECTED_END      => UNEXPECTED_END
    );

    DATA_reg: entity work.reg1D
        generic map (
            LENGTH              => 8
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            SHIFT_EN            => shift_data_sig,
            SHIFT_IN            => sda_sig,
            PAR_OUT             => DATA
        );

    bit_counter : entity work.Timer
        generic map (
            WIDTH               => 3 -- defaults to "000" through "111", which is 8 combinations
        )
        port map (
            CLK                 => CLK,
            EN                  => bit_count_en_sig,
            RST                 => bit_count_rst_sig,
            DONE                => byte_done_sig
        );

    CS_detect: entity work.EdgeDetector
    generic map (
        SAMPLE_LENGTH             => FILTER_LENGTH,
        SUM_WIDTH                 => FILTER_SUM_WIDTH,
        LOGIC_HIGH                => FILTER_LENGTH*3/4-1,
        LOGIC_LOW                 => FILTER_LENGTH/4,
        SUM_START                 => FILTER_LENGTH/2
    )
    port map (
    -- inputs
        CLK                       => CLK,
        RST                       => RST,
        SAMPLE                    => '1',
        SIG_IN                    => CS,
    -- outputs
        DATA                      => cs_sig
    );

    SCK_detect: entity work.EdgeDetector
    generic map (
        SAMPLE_LENGTH             => FILTER_LENGTH,
        SUM_WIDTH                 => FILTER_SUM_WIDTH,
        LOGIC_HIGH                => FILTER_LENGTH*3/4-1,
        LOGIC_LOW                 => FILTER_LENGTH/4,
        SUM_START                 => FILTER_LENGTH/2
    )
    port map (
    -- inputs
        CLK                       => CLK,
        RST                       => RST,
        SAMPLE                    => '1',
        SIG_IN                    => SCK,
    -- outputs
        DATA                      => sck_sig
    );

    SDA_detect: entity work.EdgeDetector
    generic map (
        SAMPLE_LENGTH             => FILTER_LENGTH,
        SUM_WIDTH                 => FILTER_SUM_WIDTH,
        LOGIC_HIGH                => FILTER_LENGTH*3/4-1,
        LOGIC_LOW                 => FILTER_LENGTH/4,
        SUM_START                 => FILTER_LENGTH/2
    )
    port map (
    -- inputs
        CLK                       => CLK,
        RST                       => RST,
        SAMPLE                    => '1',
        SIG_IN                    => SDA,
    -- outputs
        DATA                      => sda_sig
    );


end Behavioral;

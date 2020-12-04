library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


entity UARTSPITap is
    
    port ( 
        CLK             : in STD_LOGIC;
        RST             : in STD_LOGIC;
        CS              : in STD_LOGIC;
        SCK             : in STD_LOGIC;
        SDA             : in STD_LOGIC;
        UART_PERIOD     : in STD_LOGIC_VECTOR(15 downto 0);
        TEST_BYTE       : in STD_LOGIC_VECTOR(7 downto 0);
        TEST_EN         : in STD_LOGIC;
        
        TX              : out STD_LOGIC;
        TX_NOT_READY    : out STD_LOGIC
    );
end UARTSPITap;

architecture Behavioral of UARTSPITap is

    signal start_sig : std_logic;
    signal unexpected_end_sig : std_logic;
    
    signal spitap_valid_sig : std_logic;
    signal spitap_data_sig : std_logic_vector(7 downto 0);
    
    signal fifo_valid_sig : std_logic;
    signal fifo_not_valid_sig : std_logic;
    signal fifo_data_sig : std_logic_vector(7 downto 0);

    signal mux_valid_sig : std_logic;
    signal mux_data_sig : std_logic_vector(7 downto 0);

    signal tx_ready_sig : std_logic;
    signal tx_not_ready_in_sig : std_logic;
    signal tx_not_ready_out_sig : std_logic;

begin

    SPITap_module: entity work.SPITap
    generic map (
        FILTER_LENGTH       => 16,
        FILTER_SUM_WIDTH    => 4
    )
    port map ( 
        CLK                 => CLK,
        RST                 => RST,
        CS                  => CS,
        SCK                 => SCK,
        SDA                 => SDA,
        START               => start_sig,
        UNEXPECTED_END      => unexpected_end_sig,
        VALID               => spitap_valid_sig,
        DATA                => spitap_data_sig
    );
    
    MUX: process (start_sig, unexpected_end_sig, spitap_valid_sig, spitap_data_sig, TEST_BYTE, TEST_EN)
    begin
    
        if (start_sig = '1') then
            mux_valid_sig <= '1';
            mux_data_sig <= x"0A"; -- '\n'
        elsif (unexpected_end_sig = '1') then
            mux_valid_sig <= '1';
            mux_data_sig <= x"3F"; -- '?'
        elsif (TEST_EN = '1') then
            mux_valid_sig <= '1';
            mux_data_sig <= TEST_BYTE;
        else
            mux_valid_sig <= spitap_valid_sig;
            mux_data_sig <= spitap_data_sig;
        end if;
    
    end process;
    
    FIFO_module : FIFO_SYNC_MACRO
    generic map (
--        DEVICE              => "7SERIES",             -- Target Device: "VIRTEX5, "VIRTEX6", "7SERIES" 
--        ALMOST_FULL_OFFSET  => X"0080",               -- Sets almost full threshold
--        ALMOST_EMPTY_OFFSET => X"0080",               -- Sets the almost empty threshold
        DATA_WIDTH          => 8                    -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
--        FIFO_SIZE           => "18Kb"               -- Target BRAM, "18Kb" or "36Kb" 
    )
    port map (
        CLK                 => CLK,                 -- 1-bit input clock
        RST                 => RST,                 -- 1-bit input reset
        -- input path
        DI                  => mux_data_sig,        -- Input data, width defined by DATA_WIDTH parameter
        WREN                => mux_valid_sig,       -- 1-bit input write enable
        -- output path
        DO                  => fifo_data_sig,       -- Output data, width defined by DATA_WIDTH parameter
        RDEN                => tx_ready_sig,        -- 1-bit input read enable
        EMPTY               => fifo_not_valid_sig   -- 1-bit output empty
    );
    
    fifo_valid_sig <= not fifo_not_valid_sig;
    
    TX_module: entity work.SerialTx
    port map ( 
        -- inputs
        CLK                 => CLK,
        EN                  => '1',
        RST                 => RST,
        BIT_TIMER_PERIOD    => UART_PERIOD,
        VALID               => fifo_valid_sig,
        DATA                => fifo_data_sig,
        -- outputs
        READY               => tx_ready_sig,
        TX                  => TX
    );

    ila0: entity work.ila_uartspitap
    port map (
        CLK => CLK,
        probe0 => spitap_valid_sig & mux_valid_sig & fifo_valid_sig & tx_ready_sig & "0000",
        probe1 => mux_data_sig,
        probe2 => fifo_data_sig
    );

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


entity SimpleFIFO is
    generic (
        DATA_WIDTH              : positive := 8
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;
        
        -- upstream
        DATA_IN					: in std_logic_vector(DATA_WIDTH-1 downto 0);
        VALID_IN                : in STD_LOGIC;
        READY_OUT               : out STD_LOGIC;
        
        -- downstream
        DATA_OUT				: out std_logic_vector(DATA_WIDTH-1 downto 0);
        VALID_OUT               : out STD_LOGIC;
        READY_IN                : in STD_LOGIC
        
    );
end SimpleFIFO;


architecture Behavioral of SimpleFIFO is

    signal fifo_full_sig        : std_logic;
    signal fifo_empty_sig       : std_logic;
    
    signal valid_in_sig         : std_logic;
    signal valid_out_sig        : std_logic;
    signal ready_in_sig         : std_logic;
    signal ready_out_sig        : std_logic;

    signal timer_done_sig       : std_logic;
    signal timer_rst_sig        : std_logic;

    signal mem_en_sig           : std_logic;
    signal mem_rst_sig          : std_logic;


begin


    FIFO_FSM: entity work.SimpleFIFOFSM
        port map (
            CLK         => CLK,
            RST         => RST,
                    
            TIMER_DONE  => timer_done_sig,
            TIMER_RST   => timer_rst_sig,
            
            MEM_EN      => mem_en_sig,
            MEM_RST     => mem_rst_sig
        );
    
    -- From Vivado Simulator TCL output:
    -- WREN must be low for at least two WRCLK clock cycles after RST deasserted.
    -- RDEN must be low for at least two RDCLK clock cycles after RST deasserted.
    -- RST must be held high for at least five RDCLK clock cycles,
    --  and RDEN must be low before RST becomes active high,
    --  and RDEN remains low during this reset cycle.

    Timer_module : entity work.Timer
        generic map (
            WIDTH               => 4
        )
        port map (
            CLK                 => CLK,
            RST                 => timer_rst_sig,
            DONE                => timer_done_sig
        );
        
    FIFO_Tx_module : FIFO_SYNC_MACRO
        generic map (
--            DEVICE              => "7SERIES",         -- Target Device: "VIRTEX5, "VIRTEX6", "7SERIES" 
--            ALMOST_FULL_OFFSET  => X"0080",           -- Sets almost full threshold
--            ALMOST_EMPTY_OFFSET => X"0080",           -- Sets the almost empty threshold
            DATA_WIDTH          => DATA_WIDTH,          -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
            FIFO_SIZE           => "36Kb"               -- Target BRAM, "18Kb" or "36Kb" 
        )
        port map (
            CLK                 => CLK,                 -- 1-bit input clock
            RST                 => RST,                 -- 1-bit input reset
            -- input path
            DI                  => DATA_IN,             -- Input data, width defined by DATA_WIDTH parameter
            WREN                => valid_in_sig,        -- 1-bit input write enable
            FULL                => fifo_full_sig,       -- 1-bit output full
            -- output path
            DO                  => DATA_OUT,            -- Output data, width defined by DATA_WIDTH parameter
            RDEN                => ready_in_sig,        -- 1-bit input read enable
            EMPTY               => fifo_empty_sig       -- 1-bit output empty
        );
        
        
    ready_in_sig    <= READY_IN                             and mem_en_sig;
    ready_out_sig   <= (not fifo_full_sig)                  and mem_en_sig;
    
    valid_in_sig    <= VALID_IN                             and mem_en_sig;
    valid_out_sig   <= (not fifo_empty_sig) and READY_IN    and mem_en_sig;
        
        
    process (CLK) begin
        if rising_edge(CLK) then
            if RST='1' then
                VALID_OUT <= '0';
            else
                if READY_IN='1' then
                    VALID_OUT <= valid_out_sig;
                end if;
            end if;
            if RST='1' then
                READY_OUT <= '0';
            else
                READY_OUT <= ready_out_sig;
            end if;
        end if;
    end process;
    
    
--    ILA : entity work.ila_SimpleFIFO
--    port map (
--        clk             => CLK,

--        probe0          => DATA_IN,
--        probe1(0)       => VALID_IN,
--        probe2(0)       => READY_OUT,

--        probe3          => DATA_OUT,
--        probe4(0)       => VALID_OUT
--        probe5(0)       => READY_IN,
--    );


end Behavioral;

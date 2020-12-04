----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/20/2020 01:27:28 PM
-- Design Name: 
-- Module Name: pdm_generic - Behavioral
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

entity pdm_generic is
    generic (
        input_width : integer;
        output_width : integer;
        pulse_count_width : integer
    );
    port (
        input : in STD_LOGIC_VECTOR (input_width-1 downto 0);
        output : out STD_LOGIC_VECTOR (output_width-1 downto 0);
        error : out STD_LOGIC_VECTOR (1+pulse_count_width+(input_width-output_width)-1 downto 0);
        error_sign : out std_logic;
        pulse_length : in STD_LOGIC_VECTOR (pulse_count_width-1 downto 0);
        pulse_count : out STD_LOGIC_VECTOR (pulse_count_width-1 downto 0);
        pulse_en : out std_logic;
        clk : in STD_LOGIC;
        en : in STD_LOGIC;
        rst : in STD_LOGIC
    );
end pdm_generic;


architecture Behavioral of pdm_generic is

    component clk_div_generic
        generic (
            period_width : integer
        );
        port (
            period : std_logic_vector (period_width-1 downto 0);
            clk : in std_logic;
            en : in std_logic;
            rst : in std_logic;
            
            en_out : out std_logic;
            count_out : out std_logic_vector (period_width-1 downto 0)
        );
    end component;

    component diff_accum
        generic (
            in_width : integer;
            sum_width : integer
        );
        port ( in_a : in STD_LOGIC_VECTOR (in_width-1 downto 0);
               in_b : in STD_LOGIC_VECTOR (in_width-1 downto 0);
               diff_sum : out STD_LOGIC_VECTOR (sum_width-1 downto 0);
               pos_sign : out STD_LOGIC;
               clk : in STD_LOGIC;
               en : in STD_LOGIC;
               rst : in STD_LOGIC
        );
    end component;

    component shorten
        generic (
            width : integer;
            places : integer
        );
        port ( 
            input : in STD_LOGIC_VECTOR (width-1 downto 0);
            output : out STD_LOGIC_VECTOR (width-1 downto 0);
            round_up : in STD_LOGIC;
            clk : in STD_LOGIC;
            en : in STD_LOGIC;
            rst : in STD_LOGIC
        );
    end component;


    signal
        en_pulse_sig,
        pos_err
        : std_logic;
    signal
        out_sig,
        out_sig_left_shifted
        : std_logic_vector (input_width-1 downto 0);


begin

    pulse_width: clk_div_generic
        generic map (
            period_width => pulse_count_width
        )
        port map (
            period => pulse_length,
            clk => clk,
            en => en,
            rst => rst,
            en_out => en_pulse_sig,
            count_out => pulse_count
        );

    error_function: diff_accum
        generic map (
            in_width => input_width,
            sum_width => 1+pulse_count_width+(input_width-output_width)
        )
        port map (
            in_a => input,
            in_b => out_sig_left_shifted,
            diff_sum => error,
            pos_sign => pos_err,
            clk => clk,
            en => en,
            rst => rst
        );

    virtual_DAC: shorten
        generic map (
            width => input_width,
            places => (input_width-output_width)
        )
        port map ( 
            input => input,
            output => out_sig,
            round_up => pos_err,
            clk => clk,
            en => en_pulse_sig,
            rst => rst
        );

    out_sig_left_shifted <= std_logic_vector(
        shift_left(
            signed(out_sig),
            (input_width-output_width)
        )
    );
    
    output <= out_sig(output_width-1 downto 0);
    
    error_sign <= pos_err;

    pulse_en <= en_pulse_sig;

end Behavioral;

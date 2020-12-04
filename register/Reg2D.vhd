
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity Reg2D is
  generic (
    LENGTH          : positive := 2;
    WIDTH           : positive := 8;
    BIG_ENDIAN      : boolean := true
  );
  port (
    CLK             : in std_logic;
    RST             : in std_logic;

    SHIFT_EN        : in std_logic := '0';
    PAR_EN          : in std_logic := '0';

    SHIFT_IN        : in std_logic := '0';
    PAR_IN          : in std_logic_vector(WIDTH-1 downto 0) := (others=>'0');

    DEFAULT_STATE   : in std_logic_vector((WIDTH*LENGTH)-1 downto 0) := (others=>'0');
    SHIFT_OUT       : out std_logic;
    PAR_OUT         : out std_logic_vector(WIDTH-1 downto 0);
    
    ALL_LOWER_OUT   : out std_logic_vector((WIDTH*(LENGTH-1))-1 downto 0);
    FIRST_OUT       : out std_logic_vector(WIDTH-1 downto 0)
  );
end;


architecture Behavioral of Reg2D is

  signal par_connect_sig : std_logic_vector((WIDTH*(LENGTH-1))-1 downto 0);
  -- provides parallel signals "between" each register, so WIDTH*(LENGTH-1)

  signal shift_connect_sig : std_logic_vector((LENGTH-1)-1 downto 0);
  -- provides bit signals "between" each register, so WIDTH*(LENGTH-1)

  begin
        
    gen_fiRST: if (LENGTH > 1) generate
        fiRST_reg : entity work.reg1D
            generic map (
            LENGTH => WIDTH,
            BIG_ENDIAN => BIG_ENDIAN
            )
            port map (
            CLK      => CLK,
            RST      => RST,
            
            SHIFT_EN              => SHIFT_EN,
            PAR_EN                => PAR_EN,
            
            DEFAULT_STATE         => DEFAULT_STATE   (WIDTH-1 downto 0),
            
            SHIFT_IN              => SHIFT_IN,
            SHIFT_OUT             => shift_connect_sig  (0),
            
            PAR_IN                => PAR_IN,
            PAR_OUT               => par_connect_sig    (WIDTH-1 downto 0)
            );
    end generate gen_fiRST;

    gen_middle : for i in 0 to (LENGTH-3) generate -- LENGTH 5 regs is: in,0,1,2,out
        middle_reg : entity work.reg1D
            generic map (
                LENGTH          => WIDTH,
                BIG_ENDIAN      => BIG_ENDIAN
            )
            port map (
                CLK             => CLK,
                RST             => RST,
                
                SHIFT_EN        => SHIFT_EN,
                PAR_EN          => PAR_EN,
                
                DEFAULT_STATE   => DEFAULT_STATE ( (i+1)*WIDTH  +(WIDTH-1)            downto  (i+1)   *WIDTH ),
                
                SHIFT_IN        => shift_connect_sig (  i   ),
                SHIFT_OUT       => shift_connect_sig (  i+1 ),
                
                PAR_IN          => par_connect_sig (    i   *WIDTH   +(WIDTH-1)           downto  i       *WIDTH ),
                PAR_OUT         => par_connect_sig (   (i+1)*WIDTH   +(WIDTH-1)           downto  (i+1)   *WIDTH )
                
            );
    end generate gen_middle;

    gen_last: if (LENGTH >= 2) generate
        last_reg : entity work.reg1D
            generic map (
                LENGTH          => WIDTH,
                BIG_ENDIAN      => BIG_ENDIAN
            )
            port map (
                CLK             => CLK,
                RST             => RST,
                
                SHIFT_EN        => SHIFT_EN,
                PAR_EN          => PAR_EN,
                
                DEFAULT_STATE   => DEFAULT_STATE   ( DEFAULT_STATE'high   downto   DEFAULT_STATE'high-(WIDTH-1) ),
                
                SHIFT_IN        => shift_connect_sig  ( shift_connect_sig'high ),
                SHIFT_OUT       => SHIFT_OUT,
                
                PAR_IN          => par_connect_sig    ( par_connect_sig'high   downto   par_connect_sig'high-(WIDTH-1) ),
                PAR_OUT         => PAR_OUT
            );
    end generate gen_last;

    ALL_LOWER_OUT <= par_connect_sig;
    FIRST_OUT <= par_connect_sig(WIDTH-1 downto 0);

end Behavioral;

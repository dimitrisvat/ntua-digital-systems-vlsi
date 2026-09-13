library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Sync_FA_MULT is
    Port (
        --FA
        a, b, cin, sin: in std_logic;
        cout, sum: out std_logic;
        a_delayed, b_delayed: out std_logic;

        --FF
        clk: in std_logic
    );
end Sync_FA_MULT;

architecture Behavioral of Sync_FA_MULT is

    component shift_reg is
        generic (DELAY : integer := 1);
        Port (
            clk : in  std_logic;
            d   : in  std_logic;
            q   : out std_logic
        );
    end component;


signal ab : std_logic;

begin

    ab <= a and b;

    process(clk)
    begin
        if(rising_edge(clk)) then
            sum <= ab xor sin xor cin;
            cout <= (ab and sin) or (ab and cin) or (sin and cin);
        end if;
    end process;

    SR_a: shift_reg
        generic map (DELAY => 2)
        port map (
            clk => clk,
            d   => a,
            q   => a_delayed
        );

    SR_b: shift_reg
    generic map (DELAY => 1)
    port map (
        clk => clk,
        d   => b,
        q   => b_delayed
    );

end Behavioral;

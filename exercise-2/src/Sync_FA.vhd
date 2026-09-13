library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Sync_FA is
    Port (
        --FA
        a, b, cin: in std_logic;
        cout, sum: out std_logic;

        --FF
        clk: in std_logic
    );
end Sync_FA;

architecture Behavioral of Sync_FA is

begin

    process(clk)
    begin
        if(rising_edge(clk)) then
            sum <= a xor b xor cin;
            cout <= (a and b) or (a and cin) or (b and cin);
        end if;
    end process;

end Behavioral;

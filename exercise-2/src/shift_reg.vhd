 library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_reg is
    generic (
        DELAY : integer := 1  -- number of clock cycles to delay
    );
    Port (
        clk : in  std_logic;
        d   : in  std_logic;
        q   : out std_logic
    );
end shift_reg;

architecture Behavioral of shift_reg is
    signal tmp : std_logic_vector(DELAY-1 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            tmp(0) <= d;
            for i in 1 to DELAY-1 loop
                tmp(i) <= tmp(i-1);
            end loop;
        end if;
    end process;

    q <= tmp(DELAY-1);
end Behavioral;

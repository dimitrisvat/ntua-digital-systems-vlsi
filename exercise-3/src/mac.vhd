library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all; 

entity mac is
    Port (
        a: in std_logic_vector (7 downto 0);
        b: in std_logic_vector (7 downto 0);
        clk: in std_logic;
        mac_init: in std_logic;
        
        y: out std_logic_vector (16 downto 0)
    );
end mac;

architecture Behavioral of mac is

    signal accumulator: std_logic_vector(16 downto 0) := (others => '0');

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if mac_init = '1' then
                accumulator <= '0' & (a * b);
            else
                accumulator <= accumulator + (a * b);
            end if;
        end if;

    end process;

    y <= accumulator;

end Behavioral;

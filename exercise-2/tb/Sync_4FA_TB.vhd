library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all; 

entity Sync_4FA_TB is
--  Port ( );
end Sync_4FA_TB;

architecture tb of Sync_4FA_TB is

component Sync_4FA is
   Port (
        --FA
        a, b: in std_logic_vector(3 downto 0);
        cin: in std_logic;
        sum: out std_logic_vector(3 downto 0);
        cout: out std_logic;

        --FF
        clk: in std_logic
    );
end component;

signal a, b, sum: std_logic_vector(3 downto 0) := "0000";
signal cin, clk, cout: std_logic := '0';

constant CLOCK_PERIOD : time := 10 ns;

begin

    DUT : Sync_4FA
        port map
        (
            a => a,
            b => b,
            cin => cin,
            cout => cout,
            sum => sum,
            clk => clk
        );

    -- Clock generator
    CLOCK_GEN : process
    begin
        clk <= '0';
        wait for CLOCK_PERIOD / 2;
        clk <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    -- Input A
    IN_A : process
    begin
        a <= a + 1;
        wait for CLOCK_PERIOD;
    end process;

    -- Input B
    IN_B : process
    begin
        b <= b + 1;
        wait for CLOCK_PERIOD * 16;
    end process;

    -- Carry input
    IN_CARRY : process
    begin
        cin <= '0';
        wait for CLOCK_PERIOD * 16 * 16;
        cin <= '1';
        wait for CLOCK_PERIOD * 16 * 16;
    end process;

end tb;

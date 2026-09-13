library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Sync_FA_tb is
    --  Port ( );
end Sync_FA_tb;

architecture tb of Sync_FA_tb is

    component Sync_FA is
        Port (
            a, b, cin, clk : in std_logic;
            cout, sum : out std_logic
        );
    end component;

    signal a_tb, b_tb, cin_tb, clk_tb, cout_tb, sum_tb : std_logic := '0';

    constant CLOCK_PERIOD : time := 10 ns;

begin

    DUT : Sync_FA
        port map
        (
            a => a_tb,
            b => b_tb,
            cin => cin_tb,
            cout => cout_tb,
            sum => sum_tb,
            clk => clk_tb
        );

    -- Clock generator
    CLOCK_GEN : process
    begin
        clk_tb <= '0';
        wait for CLOCK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    -- Input A
    IN_A : process
    begin
        a_tb <= '0';
        wait for CLOCK_PERIOD;
        a_tb <= '1';
        wait for CLOCK_PERIOD;
    end process;

    -- Input B
    IN_B : process
    begin
        b_tb <= '0';
        wait for CLOCK_PERIOD * 2;
        b_tb <= '1';
        wait for CLOCK_PERIOD * 2;
    end process;

    -- Carry input
    IN_CARRY : process
    begin
        cin_tb <= '0';
        wait for CLOCK_PERIOD * 4;
        cin_tb <= '1';
        wait for CLOCK_PERIOD * 4;
    end process;

    check_proc: process
    begin
        wait until rising_edge(clk_tb);

        assert (sum_tb = (a_tb xor b_tb xor cin_tb) and 
                cout_tb = ((a_tb and b_tb) or (cin_tb and (a_tb xor b_tb))))
        report "Test Case Failure" severity error;

        assert not (sum_tb = '1' and cout_tb = '1')     
        report "Assert works just fine" severity warning;

    end process;

end tb;



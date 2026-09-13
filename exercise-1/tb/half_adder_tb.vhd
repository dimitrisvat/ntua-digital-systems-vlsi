library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity half_adder_tb is
--  Port ( );
end half_adder_tb;

architecture tb of half_adder_tb is

------------------component-------------------
component half_adder is
    Port (
        i_a, i_b: in std_logic;
    
        o_sum  ,o_carry : out std_logic
    );

end component;

-----------------signals-----------------------
signal i_a,i_b,o_sum ,o_carry : std_logic := '0' ;

-----------------constant----------------------
constant CLOCK_PERIOD : time := 10 ns;

begin

    DUT: half_adder 
    port map (
        i_a=>i_a,
        i_b=>i_b,

        o_sum=>o_sum,
        o_carry=>o_carry
    );

    GEN_IA : process
    begin
        i_a <= '0';
        wait for (CLOCK_PERIOD );
        i_a <= '1';
        wait for (CLOCK_PERIOD );
    end process;

    GEN_IB : process
    begin
        i_b <= '0';
        wait for (2*CLOCK_PERIOD );
        i_b <= '1';
        wait for (2*CLOCK_PERIOD );
    end process;
    
end tb;

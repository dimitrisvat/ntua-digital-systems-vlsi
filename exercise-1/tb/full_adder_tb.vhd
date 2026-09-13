library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_adder_tb is
--  Port ( );
end full_adder_tb;

architecture tb of full_adder_tb is

    component full_adder is
        Port (
            i_a, i_b,i_cin       : in std_logic;
            o_sum, o_carry : out std_logic
        );
    end component;

    signal i_a ,i_b ,i_cin ,o_sum ,o_carry :std_logic :='0' ;

    constant CLOCK_PERIOD : time := 10 ns;

begin

    DUT :full_adder 
        port map 
        (
            i_a=>i_a,
            i_b=>i_b,
            i_cin=>i_cin,
            o_sum=>o_sum,
            o_carry=>o_carry
        );

    IN_A : process
    begin
        i_a <= '0';
        wait for (CLOCK_PERIOD );
        i_a <= '1';
        wait for (CLOCK_PERIOD );
    end process;

    IN_B : process
    begin
        i_b <= '0';
        wait for (2*CLOCK_PERIOD );
        i_b <= '1';
        wait for (2*CLOCK_PERIOD );
    end process;

    IN_carry : process
    begin
        i_cin <= '0';
        wait for (3*CLOCK_PERIOD );
        i_cin <= '1';
        wait for (3*CLOCK_PERIOD );
    end process;

end tb;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_adder is
    Port (
        i_a, i_b, i_cin : in std_logic;
        o_sum, o_carry  : out std_logic
    );
end full_adder;

architecture structural of full_adder is

    component half_adder is
        Port (
            i_a, i_b       : in std_logic;
            o_sum, o_carry : out std_logic
        );
    end component;

    signal o_sum_mid   : std_logic;
    signal o_carry_mid : std_logic;
    signal o_c         : std_logic;

begin

    HA1 : half_adder
        port map(
            i_a     => i_a,
            i_b     => i_b,
            o_sum   => o_sum_mid,
            o_carry => o_carry_mid
        );

    HA2 : half_adder
        port map(
            i_a     => o_sum_mid,
            i_b     => i_cin,
            o_sum   => o_sum,
            o_carry => o_c
        );

    o_carry <= o_c or o_carry_mid;

end structural;

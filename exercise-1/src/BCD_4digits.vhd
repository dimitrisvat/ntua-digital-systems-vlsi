library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD_4digits is
    Port(
        i_a0, i_a1, i_a2, i_a3 : in std_logic_vector(3 downto 0);
        i_b0, i_b1, i_b2, i_b3 : in std_logic_vector(3 downto 0);
        o_bcd0, o_bcd1, o_bcd2, o_bcd3 : out std_logic_vector(3 downto 0);
        o_bcd_final : out std_logic
    );
end BCD_4digits;

architecture structural of BCD_4digits is

    component BDC_adder is
        Port (
            i_a, i_b : in std_logic_vector(3 downto 0);
            i_cin    : in std_logic;
            o_bcd0   : out std_logic_vector(3 downto 0);
            o_bcd1   : out std_logic
        );
    end component;

    signal bcd01, bcd12, bcd23 : std_logic := '0';

begin

    BCD0 : BDC_adder
        port map(
            i_a    => i_a0,
            i_b    => i_b0,
            i_cin  => '0',
            o_bcd0 => o_bcd0,
            o_bcd1 => bcd01
        );

    BCD1 : BDC_adder
        port map(
            i_a    => i_a1,
            i_b    => i_b1,
            i_cin  => bcd01,
            o_bcd0 => o_bcd1,
            o_bcd1 => bcd12
        );

    BCD2 : BDC_adder
        port map(
            i_a    => i_a2,
            i_b    => i_b2,
            i_cin  => bcd12,
            o_bcd0 => o_bcd2,
            o_bcd1 => bcd23
        );

    BCD3 : BDC_adder
        port map(
            i_a    => i_a3,
            i_b    => i_b3,
            i_cin  => bcd23,
            o_bcd0 => o_bcd3,
            o_bcd1 => o_bcd_final
        );
        
end structural;

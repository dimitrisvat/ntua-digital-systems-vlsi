library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FA_4bit is
  Port ( 
    i_a ,i_b :in std_logic_vector (3 downto 0);
    i_cin : in std_logic;
    o_sum :out std_logic_vector (3 downto 0);
    o_cout : out std_logic
  );
end FA_4bit;

architecture structural of FA_4bit is

    component full_adder is
        Port (
            i_a, i_b,i_cin       : in std_logic;
            o_sum, o_carry : out std_logic
        );
    end component;

    signal carry01,carry12,carry23 : std_logic := '0';

begin

    FA1 : full_adder
        port map (
            i_a     => i_a(0),
            i_b     => i_b(0),
            i_cin   => i_cin,
            o_sum   => o_sum(0),
            o_carry => carry01
        );

    FA2 : full_adder
        port map (
            i_a     => i_a(1),
            i_b     => i_b(1),
            i_cin   => carry01,
            o_sum   => o_sum(1),
            o_carry => carry12
        );

    FA3 : full_adder
        port map (
            i_a     => i_a(2),
            i_b     => i_b(2),
            i_cin   => carry12,
            o_sum   => o_sum(2),
            o_carry => carry23
        );

    FA4 : full_adder
        port map (
            i_a     => i_a(3),
            i_b     => i_b(3),
            i_cin   => carry23,
            o_sum   => o_sum(3),
            o_carry => o_cout
        );

end structural;

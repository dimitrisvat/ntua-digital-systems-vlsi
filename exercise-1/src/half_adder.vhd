library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity half_adder is
  Port (
    i_a,i_b: in std_logic;
    
    o_sum  ,o_carry : out std_logic
);
end half_adder;

architecture Dataflow of half_adder is

begin
    o_sum   <= i_a xor i_b;
    o_carry <= i_a and i_b;

end Dataflow;

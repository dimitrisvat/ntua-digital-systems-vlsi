library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BDC_adder is
 Port (
    i_a ,i_b :in std_logic_vector (3 downto 0);
    i_cin : in std_logic;
    o_bcd0 :out std_logic_vector (3 downto 0);
    o_bcd1: out std_logic 
  );
end BDC_adder;

architecture Structural of BDC_adder is

component FA_4bit is
  Port ( 
    i_a ,i_b :in std_logic_vector (3 downto 0);
    i_cin : in std_logic;
    o_sum :out std_logic_vector (3 downto 0);
    o_cout : out std_logic
  );
end component;

signal o_cout :std_logic := '0';
signal o_sum :std_logic_vector(3 downto 0) := "0000";
signal checker: std_logic :='0'; 
begin
    FA1 : FA_4bit
    port map(
        i_a=>i_a,
        i_b=>i_b,
        i_cin=>i_cin,
        o_sum=>o_sum,
        o_cout=>o_cout
    );
    
    checker<=o_cout or ((o_sum(3)) and (o_sum(2) or o_sum(1)));
    o_bcd1<=checker;

    FA_2: FA_4bit
    port map(
        i_a=>o_sum,
        i_b=>'0'&checker&checker&'0',
        i_cin=>'0',
        o_sum=>o_bcd0
        
    );

end Structural;

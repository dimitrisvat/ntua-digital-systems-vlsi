library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all; 

entity FA_4bit_tb is
--  Port ( );
end FA_4bit_tb;

architecture tb of FA_4bit_tb is

component FA_4bit is
  Port ( 
    i_a ,i_b :in std_logic_vector (3 downto 0);
    i_cin : in std_logic;
    o_sum :out std_logic_vector (3 downto 0);
    o_cout : out std_logic
  );
end component;

signal i_cin ,o_cout :std_logic := '0';
signal i_a, i_b , o_sum :std_logic_vector(3 downto 0) := "0000";
    
constant CLOCK_PERIOD : time := 10 ns;

begin
    DUT : FA_4bit
    port map(
        i_a=>i_a,
        i_b=>i_b,
        o_sum=>o_sum,
        i_cin=>i_cin,
        o_cout=>o_cout
    );

    IN_A : process
    begin
        i_a <= i_a+1;
        wait for (CLOCK_PERIOD );
    end process;

    IN_B : process
    begin
        i_b <= i_b+1;
        wait for (16*CLOCK_PERIOD);
    end process;


end tb;

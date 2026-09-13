library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all; 

entity bcd_adder_tb is
--  Port ( );
end bcd_adder_tb;

architecture tb of bcd_adder_tb is

component BDC_adder is
 Port (
    i_a ,i_b :in std_logic_vector (3 downto 0);
    i_cin : in std_logic;
    o_bcd0 :out std_logic_vector (3 downto 0);
    o_bcd1: out std_logic 
  );
end component;

signal i_a,i_b,o_bcd0 :  std_logic_vector (3 downto 0) := "0000";
signal i_cin ,o_bcd1 : std_logic := '0';

constant CLOCK_PERIOD : time := 10 ns;

begin
    DUT: BDC_adder
    port map (

     i_a=>i_a,
     i_b=>i_b,
     i_cin=>i_cin,
     o_bcd0=>o_bcd0,
     o_bcd1=>o_bcd1

    );

        IN_A : process
        begin
            if i_a = "1010" then
                i_a <= "0000";
            else
                i_a <= i_a + 1;
            end if;
            wait for CLOCK_PERIOD;
        end process;

        IN_B : process
        begin
            if i_b = "1010" then
                i_b <= "0000";
            else
                i_b <= i_b + 1;
            end if;
            wait for 10 * CLOCK_PERIOD;
        end process;

end tb;

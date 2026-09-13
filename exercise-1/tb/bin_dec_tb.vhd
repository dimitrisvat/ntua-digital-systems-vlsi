library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity bin_dec_tb is
--  Port ( );
end bin_dec_tb;

architecture tb of bin_dec_tb is
    -- COMPONENT
    component bin_dec is
        port 
        (
        i_dec : in std_logic_vector(2 downto 0);
        o_dec : out std_logic_vector(7 downto 0)
        );
    end component;

    -- SIGNALS 
    signal i_dec      : std_logic_vector(3-1 downto 0) := (others => '0');
    signal o_dec      : std_logic_vector(8-1 downto 0) := (others => '0');
        
    -- CONSTANTS
    constant TIME_DELAY : time := 10 ns;

begin

    DUT : bin_dec
        port map (
            i_dec     => i_dec,
            o_dec     => o_dec
        );

    STIMULUS : process
    begin
        i_dec <= "000";
        wait for (1 * TIME_DELAY);

        i_dec <= "001";
        wait for (1 * TIME_DELAY);

        i_dec <= "010";
        wait for (1 * TIME_DELAY);

        i_dec <= "011";
        wait for (1 * TIME_DELAY);

        i_dec <= "100";
        wait for (1 * TIME_DELAY);

        i_dec <= "101";
        wait for (1 * TIME_DELAY);

        i_dec <= "110";
        wait for (1 * TIME_DELAY);

        i_dec <= "111";
        wait for (1 * TIME_DELAY);
       
     wait;

    end process;
end tb;

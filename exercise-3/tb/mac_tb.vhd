library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all; 

entity mac_tb is
--  Port ( );
end mac_tb;

architecture Behavioral of mac_tb is

component mac is
    Port(
        a: in std_logic_vector (7 downto 0);
        b: in std_logic_vector (7 downto 0);
        clk: in std_logic;
        mac_init: in std_logic;
        y: out std_logic_vector (16 downto 0)
    );
end component;

signal a_tb, b_tb: std_logic_vector (7 downto 0) := (others => '0');
signal y_tb: std_logic_vector (16 downto 0);
signal clk_tb, mac_init_tb: std_logic;

constant CLOCK_PERIOD: time := 10 ns;

begin

    DUT :mac
    port map (
       a => a_tb,
       b => b_tb,
       clk => clk_tb,
       mac_init => mac_init_tb,
       y => y_tb 
    );

    CLOCK_GEN : process
    begin
        clk_tb <= '0';
        wait for CLOCK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    IN_A: process
    begin
        a_tb <= a_tb + 1;
        wait for (CLOCK_PERIOD);
    end process;

    IN_B: process
    begin
        b_tb <= b_tb + 1;
        wait for (CLOCK_PERIOD * 16);
    end process;

    IN_MAC_INIT: process
    begin
        mac_init_tb <= '1';
        wait for (CLOCK_PERIOD * 4);
        mac_init_tb <= '0';
        wait;
    end process;

end Behavioral;

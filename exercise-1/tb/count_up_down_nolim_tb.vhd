library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity count_up_down_nolim_tb is
--  Port ( );
end count_up_down_nolim_tb;

architecture tb of count_up_down_nolim_tb is

-- COMPONENT
component counter_up_down is
    port(
        clk, resetn, count_en, up_down : in std_logic;
        sum  : out std_logic_vector(2 downto 0);
        cout : out std_logic
    );
end component;

-- SIGNALS
signal clk, resetn, count_en, up_down : std_logic;
signal sum  : std_logic_vector(2 downto 0);
signal cout : std_logic;

-- CONSTANTS
constant CLOCK_PERIOD : time := 10 ns;

begin
    DUT : counter_up_down
        port map(
            clk      => clk,
            resetn   => resetn,
            count_en => count_en,
            up_down  => up_down,
            sum      => sum,
            cout     => cout
        );

        STIMULUS : process
        begin

        up_down  <= '1';
        count_en<='0';
        resetn <='0'; --initialize the counter to zero
        wait for (1*CLOCK_PERIOD);
        
        resetn <='1';
        count_en<='1'; --enable counting
        wait for (14*CLOCK_PERIOD); --count two times from zero to 7 

        resetn <='0'; --test reset
        wait for (1*CLOCK_PERIOD);

        resetn <='1';
        up_down<='0' ; --count down
        wait for (14*CLOCK_PERIOD);  
        
        wait ;
        
        end process;

        GEN_CLK : process
        begin
            clk <= '0';
            wait for (CLOCK_PERIOD / 2);
            clk <= '1';
            wait for (CLOCK_PERIOD / 2);
        end process;
end tb;

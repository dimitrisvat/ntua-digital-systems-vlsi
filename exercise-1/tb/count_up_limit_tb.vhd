library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all; 

entity count_up_limit_tb is
--  Port ( );
end count_up_limit_tb;

architecture tb of count_up_limit_tb is

    -- COMPONENT
    component counter_up_down_lim is
        port( 
            clk, resetn, count_en, up_down : in std_logic;
            limit : in std_logic_vector(2 downto 0); 
            sum   : out std_logic_vector(2 downto 0); 
            cout  : out std_logic
        ); 
    end component;

    -- SIGNALS
    signal clk      : std_logic := '0';
    signal resetn   : std_logic := '0';
    signal count_en : std_logic := '0';
    signal up_down  : std_logic := '0';
    signal limit : std_logic_vector(2 downto 0) := "000";
    signal sum      : std_logic_vector(2 downto 0);
    signal cout     : std_logic;

    -- CONSTANTS
    constant CLOCK_PERIOD : time := 10 ns;

begin
    DUT : counter_up_down_lim
    port map(
        clk      => clk,
        resetn   => resetn,
        count_en => count_en,
        up_down  => up_down,
        limit    => limit,
        sum      => sum,
        cout     => cout
    );

    STIMULUS : process
    begin
        resetn <= '1';
        wait for (24*CLOCK_PERIOD);
        resetn <= '0';
        wait for (CLOCK_PERIOD);
    end process;

    COUNT : process
    begin
        count_en <= '1';  
        wait for (15*CLOCK_PERIOD);
        count_en <= '0';
        wait for (4*CLOCK_PERIOD);
    end process;    

    GEN_LIMIT : process
    begin
        limit <= (limit) + 1;
        wait for (8*CLOCK_PERIOD);
    end process;

    GEN_CLK : process
    begin
        clk <= '0';
        wait for (CLOCK_PERIOD / 2);
        clk <= '1';
        wait for (CLOCK_PERIOD / 2);
    end process;

end tb;

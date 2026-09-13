library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_reg_tb is
--  Port ( );
end shift_reg_tb;

architecture tb of shift_reg_tb is

component shift_reg is
    generic (
        DELAY : integer := 1  -- number of clock cycles to delay
    );
    Port (
        clk : in  std_logic;
        d   : in  std_logic;
        q   : out std_logic
    );
end component;

signal d, q, clk: std_logic := '0';
constant CLOCK_PERIOD : time := 10 ns;

begin

    DUT : shift_reg
        generic map(DELAY => 3)
        port map(
            d => d,
            q => q,
            clk => clk
        );

    GEN_CLK : process
    begin
        clk <= '0';
        wait for (CLOCK_PERIOD/2);
        clk <= '1';
        wait for (CLOCK_PERIOD/2);
    end process;

    IN_D : process
    begin
        d <= '0';
        wait for (CLOCK_PERIOD);
        d <= '1';
        wait for (CLOCK_PERIOD);
    end process;

end tb;

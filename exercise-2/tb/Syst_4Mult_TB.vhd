library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all; 

entity Syst_4Mult_TB is
--  Port ( );
end Syst_4Mult_TB;

architecture Behavioral of Syst_4Mult_TB is

    component Syst_4Mult is
        Port (
            a, b : in  std_logic_vector(3 downto 0);
            p    : out std_logic_vector(7 downto 0);
            clk  : in  std_logic
        );
    end component;

    component Sync_FA_MULT is
        Port (
            -- FA
            a, b, cin, sin : in  std_logic;
            cout, sum      : out std_logic;
            a_delayed, b_delayed : out std_logic;

            -- FF
            clk : in std_logic
        );
    end component;

    component shift_reg is
        generic (DELAY : integer := 1);
        Port (
            clk : in  std_logic;
            d   : in  std_logic;
            q   : out std_logic
        );
    end component;

    signal a, b: std_logic_vector(3 downto 0) := "0000";
    signal p: std_logic_vector(7 downto 0) := "00000000";
    signal cin, clk, cout: std_logic := '0';

    constant CLOCK_PERIOD : time := 10 ns;

begin

    DUT : Syst_4Mult
        port map
        (
            a => a,
            b => b,
            p => p,
            clk => clk
        );

    -- Clock generator
    CLOCK_GEN : process
    begin
        clk <= '0';
        wait for CLOCK_PERIOD / 2;
        clk <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    -- Test stimulus
    TEST_STIMULUS : process
    begin
        -- Test case 1: 3 * 2 = 6
        a <= "0011"; -- 3 in binary
        b <= "0010"; -- 2 in binary
        wait for CLOCK_PERIOD*16;

        -- Test case 2: 7 * 5 = 35
        a <= "0111"; -- 7 in binary
        b <= "0101"; -- 5 in binary
        wait for CLOCK_PERIOD*16*2;

        -- Test case 3: 15 * 15 = 225 (only lower 8 bits will be captured)
        a <= "1111"; -- 15 in binary
        b <= "1111"; -- 15 in binary
        wait for CLOCK_PERIOD*16*4;

        -- Test case 4: 6 * 3 = 18 
        a<= "1010"; -- Reset to 0
        b<= "0011"; -- Reset to 0
        wait for CLOCK_PERIOD*16*8;

        -- Add more test cases as needed

        wait; -- Wait indefinitely after tests are done
    end process;

end Behavioral;

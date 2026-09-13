library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity mlab_ram_tb is
end mlab_ram_tb;

architecture Behavioral of mlab_ram_tb is

component mlab_ram is
    generic (
        data_width : integer := 8
    );
    port (
        clk  : in std_logic;
        we   : in std_logic;
        en   : in std_logic;
        addr : in std_logic_vector(2 downto 0);
        di   : in std_logic_vector(data_width-1 downto 0);
        do   : out std_logic_vector(data_width-1 downto 0)
    );
end component;

signal clk_tb  : std_logic;
signal we_tb   : std_logic;
signal en_tb   : std_logic;
signal addr_tb : std_logic_vector(2 downto 0) := (others => '0');
signal di_tb   : std_logic_vector(7 downto 0) := (others => '0');
signal do_tb   : std_logic_vector(7 downto 0);

constant CLOCK_PERIOD : time := 10 ns;

begin

    DUT: mlab_ram
    port map (
        clk  => clk_tb,
        we   => we_tb,
        en   => en_tb,
        addr => addr_tb,
        di   => di_tb,
        do   => do_tb
    );

    -- Clock (same style as yours)
    CLOCK_GEN : process
    begin
        clk_tb <= '0';
        wait for CLOCK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    -- Enable always ON
    EN_PROC: process
    begin
        en_tb <= '1';
        wait;
    end process;

    -- Write enable toggling
    WE_PROC: process
    begin
        we_tb <= '1';                 -- write mode (shift)
        wait for CLOCK_PERIOD * 20;

        we_tb <= '0';                 -- read mode
        wait;
    end process;

    -- Input data (like your a_tb)
    IN_DI: process
    begin
        di_tb <= di_tb + 1;
        wait for CLOCK_PERIOD;
    end process;

    -- Address changes slowly (like your b_tb idea)
    ADDR_PROC: process
    begin
        addr_tb <= addr_tb + 1;
        wait for CLOCK_PERIOD * 4;
    end process;

end Behavioral;
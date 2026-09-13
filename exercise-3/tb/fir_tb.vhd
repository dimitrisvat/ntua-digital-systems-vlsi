library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fir_tb is
end fir_tb;

architecture behavior of fir_tb is

    component fir
        port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            valid_in   : in  std_logic;
            x          : in  std_logic_vector(7 downto 0);
            valid_out  : out std_logic;
            y          : out std_logic_vector(16 downto 0)
        );
    end component;

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal valid_in  : std_logic := '0';
    signal x         : std_logic_vector(7 downto 0) := (others => '0');
    signal valid_out : std_logic;
    signal y         : std_logic_vector(16 downto 0);


type input_type is array (0 to 31) of std_logic_vector(7 downto 0);

signal input : input_type := (
    "11010000", "11100111", "01000000", "11101001",
    "10100001", "00011000", "01000111", "10001100",
    "11110101", "11110111", "00101000", "11111000",
    "11110101", "01111100", "11001100", "00100100",
    "01101011", "11101010", "11001010", "11110101",
    "00000000", "00000000", "00000000", "00000000",
    "00000000", "00000000", "00000000", "00000000",
    "00000000", "00000000", "00000000", "00000000"
);

    constant CLK_PERIOD : time := 10 ns;

begin

    uut: fir
        port map (
            clk       => clk,
            rst       => rst,
            valid_in  => valid_in,
            x         => x,
            valid_out => valid_out,
            y         => y
        );

    -- Clock generation
    clk_process : process
    begin
        while now < CLK_PERIOD * 1000 loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;
     
    -- Stimulus process
    stim_process : process
    begin
        -- Reset sequence
        rst <= '1';
        valid_in <= '0';
        wait for 10 * CLK_PERIOD ;

        rst <= '0';
        wait for 2 * CLK_PERIOD;

        -- Calculate again
        for i in 0 to 31 loop
            valid_in <= '1';
            x <= input(i);
            wait for CLK_PERIOD;

            valid_in <= '0';
            wait for 9 * CLK_PERIOD;
        end loop;

        wait;
    end process;

end behavior;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity calculator is
    Generic (
        N : integer := 4
    );
    Port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        valid_in : in  std_logic;

        din00 : in std_logic_vector(7 downto 0);
        din01 : in std_logic_vector(7 downto 0);
        din02 : in std_logic_vector(7 downto 0);

        din10 : in std_logic_vector(7 downto 0);
        din11 : in std_logic_vector(7 downto 0);
        din12 : in std_logic_vector(7 downto 0);

        din20 : in std_logic_vector(7 downto 0);
        din21 : in std_logic_vector(7 downto 0);
        din22 : in std_logic_vector(7 downto 0);

        valid_out : out std_logic;
        R         : out std_logic_vector(7 downto 0);
        G         : out std_logic_vector(7 downto 0);
        B         : out std_logic_vector(7 downto 0)
    );
end calculator;

architecture Behavioral of calculator is

    type pixel_color_type is (
        GREEN1,
        GREEN2,
        RED,
        BLUE
    );

    signal pixel_color : pixel_color_type;
    signal blue_line   : std_logic := '1';
    signal counter     : unsigned(31 downto 0) := (others => '0');

begin

    pixel_color <=
        GREEN2 when (blue_line = '1' and counter(0) = '0') else
        BLUE   when (blue_line = '1' and counter(0) = '1') else
        RED    when (blue_line = '0' and counter(0) = '0') else
        GREEN1;

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            blue_line  <= '1';
            counter    <= (others => '0');
            R          <= (others => '0');
            G          <= (others => '0');
            B          <= (others => '0');
            valid_out  <= '0';

        elsif rising_edge(clk) then

            if valid_in = '1' then

                valid_out <= '1';

                if (counter = N - 1) then
                    counter   <= (others => '0');
                    blue_line <= not blue_line;
                else
                    counter <= counter + 1;
                end if;

                case pixel_color is

                    when GREEN1 =>
                        R <= std_logic_vector(resize(shift_right(
                                resize(unsigned(din10), 9) +
                                resize(unsigned(din12), 9),
                             1), 8));
                        G <= din11;
                        B <= std_logic_vector(resize(shift_right(
                                resize(unsigned(din01), 9) +
                                resize(unsigned(din21), 9),
                             1), 8));

                    when GREEN2 =>
                        R <= std_logic_vector(resize(shift_right(
                                resize(unsigned(din01), 9) +
                                resize(unsigned(din21), 9),
                             1), 8));
                        G <= din11;
                        B <= std_logic_vector(resize(shift_right(
                                resize(unsigned(din10), 9) +
                                resize(unsigned(din12), 9),
                             1), 8));

                    when RED =>
                        R <= din11;
                        G <= std_logic_vector(resize(shift_right(
                                resize(unsigned(din10), 10) +
                                resize(unsigned(din01), 10) +
                                resize(unsigned(din12), 10) +
                                resize(unsigned(din21), 10),
                             2), 8));
                        B <= std_logic_vector(resize(shift_right(
                                resize(unsigned(din00), 10) +
                                resize(unsigned(din02), 10) +
                                resize(unsigned(din20), 10) +
                                resize(unsigned(din22), 10),
                             2), 8));

                    when BLUE =>
                        R <= std_logic_vector(resize(shift_right(
                                resize(unsigned(din00), 10) +
                                resize(unsigned(din02), 10) +
                                resize(unsigned(din20), 10) +
                                resize(unsigned(din22), 10),
                             2), 8));
                        G <= std_logic_vector(resize(shift_right(
                                resize(unsigned(din10), 10) +
                                resize(unsigned(din01), 10) +
                                resize(unsigned(din12), 10) +
                                resize(unsigned(din21), 10),
                             2), 8));
                        B <= din11;

                end case;

            else
                valid_out <= '0';
            end if;
        end if;
    end process;

end Behavioral;
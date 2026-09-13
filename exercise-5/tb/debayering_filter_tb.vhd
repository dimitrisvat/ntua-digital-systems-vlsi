library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity debayering_filter_tb is
end debayering_filter_tb;

architecture Behavioral of debayering_filter_tb is

    constant N       : integer := 32;
    constant CLK_PER : time    := 10 ns;

    signal clk            : std_logic := '0';
    signal rst_n          : std_logic := '0';
    signal new_image      : std_logic := '0';
    signal valid_in       : std_logic := '0';
    signal pixel          : std_logic_vector(7 downto 0) := (others => '0');
    signal image_finished : std_logic;
    signal valid_out      : std_logic;
    signal R, G, B        : std_logic_vector(7 downto 0);

    signal sim_done : std_logic := '0';

    component debayering_filter is
        Generic ( N : integer );
        Port (
            clk            : in  std_logic;
            rst_n          : in  std_logic;
            new_image      : in  std_logic;
            valid_in       : in  std_logic;
            pixel          : in  std_logic_vector(7 downto 0);
            image_finished : out std_logic;
            valid_out      : out std_logic;
            R              : out std_logic_vector(7 downto 0);
            G              : out std_logic_vector(7 downto 0);
            B              : out std_logic_vector(7 downto 0)
        );
    end component;

begin

    clk <= not clk after CLK_PER / 2;

    dut : debayering_filter
        generic map ( N => N )
        port map (
            clk            => clk,
            rst_n          => rst_n,
            new_image      => new_image,
            valid_in       => valid_in,
            pixel          => pixel,
            image_finished => image_finished,
            valid_out      => valid_out,
            R              => R,
            G              => G,
            B              => B
        );

    -- =========================================================
    -- Process 1: Sends pixels to the DUT
    -- =========================================================
       stimulus : process
        file     input_file : text;
        variable input_line : line;
        variable pixel_val  : integer;
        constant PAUSE_START : integer := (N*N) / 2; 
        constant PAUSE_LEN   : integer := 10;   
    begin
        rst_n <= '0';
        wait for 3 * CLK_PER;
        rst_n <= '1';
        wait for 2 * CLK_PER;

        wait until rising_edge(clk);
        new_image <= '1';
        wait until rising_edge(clk);
        new_image <= '0';

        file_open(input_file, "input_image.txt", read_mode);

        for i in 0 to N*N - 1 loop

            -- ---- random pause in the middle ----
            if i = PAUSE_START then
                valid_in <= '0';
                pixel    <= (others => '0');
                for p in 1 to PAUSE_LEN loop
                    wait until rising_edge(clk);
                end loop;
            end if;
            -- ------------------------

            readline(input_file, input_line);
            read(input_line, pixel_val);
            wait until rising_edge(clk);
            pixel    <= std_logic_vector(to_unsigned(pixel_val, 8));
            valid_in <= '1';
        end loop;

        wait until rising_edge(clk);
        valid_in <= '0';
        pixel    <= (others => '0');

        file_close(input_file);

        wait until image_finished = '1';
        wait for 20 * CLK_PER;

        sim_done <= '1';
        report "Simulation finished!" severity note;
        wait;
    end process;

    -- =========================================================
    -- Process 2: Write R,G,B when valid_out='1'
    -- =========================================================
    output_capture : process
        file     output_file : text;
        variable output_line : line;
        variable r_val, g_val, b_val : integer;
    begin
        file_open(output_file, "output_sim.txt", write_mode);

        while sim_done = '0' loop
            wait until rising_edge(clk);
            if valid_out = '1' then
                r_val := to_integer(unsigned(R));
                g_val := to_integer(unsigned(G));
                b_val := to_integer(unsigned(B));

                write(output_line, r_val);
                write(output_line, string'(" "));
                write(output_line, g_val);
                write(output_line, string'(" "));
                write(output_line, b_val);
                writeline(output_file, output_line);
            end if;
        end loop;

        file_close(output_file);
        wait;
    end process;

end Behavioral;
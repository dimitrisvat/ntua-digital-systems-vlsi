library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
    
entity serial_to_parallel is
    Generic (
        N : integer := 16-- N can be up to 65535
    );
    Port (
        clk  : in  std_logic;
        rst_n : in  std_logic;
        din  : in  std_logic_vector(7 downto 0);
        valid_in: in std_logic;
        counter: in std_logic_vector(31 downto 0);
        en: in std_logic;

        valid_out : out std_logic;
        dout00 : out std_logic_vector(7 downto 0);
        dout01 : out std_logic_vector(7 downto 0);
        dout02 : out std_logic_vector(7 downto 0);

        dout10 : out std_logic_vector(7 downto 0);
        dout11 : out std_logic_vector(7 downto 0);
        dout12 : out std_logic_vector(7 downto 0);

        dout20 : out std_logic_vector(7 downto 0);
        dout21 : out std_logic_vector(7 downto 0);
        dout22 : out std_logic_vector(7 downto 0)
    );
end serial_to_parallel;

architecture Behavioral of serial_to_parallel is

    COMPONENT fifo_d65536
        PORT (
            clk   : IN STD_LOGIC;
            srst  : IN STD_LOGIC;
            din   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            full  : OUT STD_LOGIC;
            empty : OUT STD_LOGIC 
        );
    END COMPONENT;

    type matrix_3x3 is array (0 to 2, 0 to 2) of std_logic_vector(7 downto 0);
    signal w : matrix_3x3 := (others => (others => (others => '0')));

    signal counter_us : unsigned(31 downto 0) := (others => '0'); -- N can be up to 65535.

    signal line1_out, line2_out, line3_out : std_logic_vector(7 downto 0) := (others => '0');
    signal full1, full2, full3 : std_logic;
    signal empty1, empty2, empty3 : std_logic;
    signal wr_en1, wr_en2, wr_en3: std_logic := '0';
    signal rd_en1, rd_en2, rd_en3: std_logic := '0';
    signal srst: std_logic := '0';

begin

    fifo1 : fifo_d65536
        PORT MAP (
            clk   => clk,
            srst  => srst,
            din   => din,
            wr_en => wr_en1,
            rd_en => rd_en1,
            dout  => line1_out,
            full  => full1,
            empty => empty1
        );

    fifo2 : fifo_d65536
        PORT MAP (
            clk   => clk,
            srst  => srst,
            din   => line1_out,
            wr_en => wr_en2,
            rd_en => rd_en2,
            dout  => line2_out,
            full  => full2,
            empty => empty2
        );

    fifo3 : fifo_d65536
        PORT MAP (
            clk   => clk,
            srst  => srst,
            din   => line2_out,
            wr_en => wr_en3,
            rd_en => rd_en3,
            dout  => line3_out,
            full  => full3,
            empty => empty3
        );

    process(clk, rst_n)
    begin

        if rst_n = '0' then

            --wr_en1 <= '0';
            wr_en2 <= '0';
            wr_en3 <= '0';
            rd_en1 <= '0';
            rd_en2 <= '0';
            rd_en3 <= '0';

            for i in 0 to 2 loop
                for j in 0 to 2 loop
                    w(i,j) <= (others => '0');
                end loop;
            end loop;

        elsif rising_edge(clk) then

            if en = '1' then

                w(0,2) <= w(0,1);
                w(0,1) <= w(0,0);
                w(0,0) <= line1_out;

                w(1,2) <= w(1,1);
                w(1,1) <= w(1,0);
                w(1,0) <= line2_out;

                w(2,2) <= w(2,1);
                w(2,1) <= w(2,0);
                w(2,0) <= line3_out;
                
            end if;

            -- fifo read and write conditions
            if (valid_in = '1' or counter_us > N*N - 2) and counter_us > N-1 then
                rd_en1 <= '1';
                wr_en2 <= '1';
            else
                rd_en1 <= '0';
                wr_en2 <= '0';
            end if;

            if (valid_in = '1' or counter_us > N*N - 2) and counter_us > 2*(N-1) then
                rd_en2 <= '1';
                wr_en3 <= '1';
            else
                rd_en2 <= '0';
                wr_en3 <= '0';
            end if;
            
            if (valid_in = '1' or counter_us > N*N - 2) and counter_us > 3*(N-1) then
                rd_en3 <= '1';
            else
                rd_en3 <= '0';
            end if;
            
        end if;
    end process;

    -- left border ignores X2
    -- right border ignores X0
    -- top border ignores 2X
    -- bottom border ignored 0X

    -- left border
    dout02 <= (others => '0') when ((counter_us mod N = 4) or (counter_us > N*N+N+3)) else w(0,2);
    dout12 <= (others => '0') when (counter_us mod N = 4) else w(1,2);
    dout22 <= (others => '0') when ((counter_us mod N = 4) or (counter_us < N-1)) else w(2,2);

    -- right border
    dout00 <= (others => '0') when ((counter_us mod N = 3) or (counter_us > N*N+N+3)) else w(0,0);
    dout10 <= (others => '0') when (counter_us mod N = 3) else w(1,0);
    dout20 <= (others => '0') when ((counter_us mod N = 3) or (counter_us < N-1)) else w(2,0);

    -- top border
    dout21 <= (others => '0') when (counter_us < N-1) else w(2,1);

    -- bottom border
    dout01 <= (others => '0') when (counter_us > N*N+N+3) else w(0,1);

    -- main pixel
    dout11 <= w(1,1);

    valid_out <= '1' when (counter_us > 2*N+3 and en = '1') else '0';
    counter_us <= unsigned(counter);

    srst <= not rst_n;

    wr_en1 <= valid_in;

end Behavioral;
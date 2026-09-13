library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debayering_filter is
    Generic (
    N : integer := 16
    );

    Port(
        clk: in std_logic;
        rst_n: in std_logic;
        
        new_image: in std_logic;
        valid_in: in std_logic;
        pixel: in std_logic_vector (7 downto 0);

        image_finished: out std_logic;
        valid_out: out std_logic;
        R: out std_logic_vector (7 downto 0);
        G: out std_logic_vector (7 downto 0);
        B: out std_logic_vector (7 downto 0)
    );
end debayering_filter;

architecture Structural of debayering_filter is

    component fsm is
        Generic (
                N : integer
            );
            Port ( 
                clk  : in std_logic;
                rst_n : in std_logic;
                valid_in : in std_logic;
                new_image : in std_logic;

                en: out std_logic;
                counter: out std_logic_vector(31 downto 0);
                image_finished : out std_logic
            );
    end component;

    component serial_to_parallel is
        Generic (
            N : integer
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
    end component;

    component calculator is
        Generic (
            N : integer
        );
        Port (
            clk  : in  std_logic;
            rst_n : in  std_logic;
            valid_in: in std_logic;

            din00 : in std_logic_vector(7 downto 0);
            din01 : in std_logic_vector(7 downto 0);
            din02 : in std_logic_vector(7 downto 0);

            din10 : in std_logic_vector(7 downto 0);
            din11 : in std_logic_vector(7 downto 0);
            din12 : in std_logic_vector(7 downto 0);

            din20 : in std_logic_vector(7 downto 0);
            din21 : in std_logic_vector(7 downto 0);
            din22 : in std_logic_vector(7 downto 0);

            valid_out: out std_logic;
            R: out std_logic_vector(7 downto 0);
            G: out std_logic_vector(7 downto 0);
            B: out std_logic_vector(7 downto 0)
        );
    end component;

    signal counter: std_logic_vector(31 downto 0);
    signal en: std_logic;
    signal valid_out_s2p: std_logic;

    signal s2p_00        : std_logic_vector(7 downto 0);
    signal s2p_01        : std_logic_vector(7 downto 0);
    signal s2p_02        : std_logic_vector(7 downto 0);
    signal s2p_10        : std_logic_vector(7 downto 0);
    signal s2p_11        : std_logic_vector(7 downto 0);
    signal s2p_12        : std_logic_vector(7 downto 0);
    signal s2p_20        : std_logic_vector(7 downto 0);
    signal s2p_21        : std_logic_vector(7 downto 0);
    signal s2p_22        : std_logic_vector(7 downto 0);

begin

    fsm1 : fsm
        generic map (
            N => N
        )
        port map (
            clk            => clk,
            rst_n           => rst_n,
            valid_in       => valid_in,
            new_image      => new_image,

            counter        => counter,
            en         => en,
            image_finished => image_finished
        );

    s2p : serial_to_parallel
        generic map (
            N => N
        )
        port map (
            clk       => clk,
            rst_n      => rst_n,
            din       => pixel,
            valid_in  => valid_in,
            en        => en,
            counter   => counter,

            valid_out => valid_out_s2p,
            dout00    => s2p_00,
            dout01    => s2p_01,
            dout02    => s2p_02,
            dout10    => s2p_10,
            dout11    => s2p_11,
            dout12    => s2p_12,
            dout20    => s2p_20,
            dout21    => s2p_21,
            dout22    => s2p_22
        );

    calc : calculator
        generic map (
            N => N
        )
        port map (
            clk     => clk,
            rst_n    => rst_n,
            valid_in => valid_out_s2p,

            din00 => s2p_00,
            din01 => s2p_01,
            din02 => s2p_02,
            din10 => s2p_10,
            din11 => s2p_11,
            din12 => s2p_12,
            din20 => s2p_20,
            din21 => s2p_21,
            din22 => s2p_22,

            valid_out => valid_out,
            R     => R,
            G     => G,
            B     => B
        );

end Structural;

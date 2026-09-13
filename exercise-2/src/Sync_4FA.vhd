library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Sync_4FA is
    Port (
        a, b: in  std_logic_vector(3 downto 0);
        cin: in  std_logic;
        sum: out std_logic_vector(3 downto 0);
        cout: out std_logic;
        clk: in  std_logic
    );
end Sync_4FA;

architecture Behavioral of Sync_4FA is

    component Sync_FA is
        Port (
            a, b, cin: in  std_logic;
            sum, cout: out std_logic;
            clk: in  std_logic
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

    signal c : std_logic_vector(4 downto 0);

    signal a_pipe, b_pipe : std_logic_vector(3 downto 0);
    signal sum_pipe : std_logic_vector(3 downto 0);

begin

    c(0) <= cin;

    -- bit 0 (LSB), no delay needed
    a_pipe(0) <= a(0);
    b_pipe(0) <= b(0);

    -- bits 1..3 use shift registers
    gen_shift_in: for i in 1 to 3 generate

        SR_a: shift_reg
            generic map (DELAY => i)
            port map (
                clk => clk,
                d   => a(i),
                q   => a_pipe(i)
            );

        SR_b: shift_reg
            generic map (DELAY => i)
            port map (
                clk => clk,
                d   => b(i),
                q   => b_pipe(i)
            );

    end generate;

    gen_FA: for i in 0 to 3 generate
    begin
        FA_i: Sync_FA
            port map(
                a => a_pipe(i),
                b => b_pipe(i),
                cin => c(i),
                sum => sum_pipe(i),
                cout => c(i+1),
                clk => clk
            );
    end generate;

    -- bit 4 (MSB), no delay needed
    sum(3) <= sum_pipe(3);

    -- bits 1..3 use shift registers
    gen_shift_out: for i in 0 to 2 generate

        SR_sum: shift_reg
            generic map (DELAY => 3 - i)
            port map (
                clk => clk,
                d   => sum_pipe(i),
                q   => sum(i)
            );

    end generate;

    cout <= c(4);

end Behavioral;



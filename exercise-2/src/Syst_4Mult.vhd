library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Syst_4Mult is
    Port (
        a, b : in  std_logic_vector(3 downto 0);
        p    : out std_logic_vector(7 downto 0);
        clk  : in  std_logic
    );
end Syst_4Mult;

architecture Behavioral of Syst_4Mult is

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

    type matrix_5x5 is array (0 to 4) of std_logic_vector(4 downto 0);
    signal sout_wire, cout_wire : matrix_5x5;
    signal a_wire, b_wire       : matrix_5x5;
    signal cout_del             : std_logic_vector(2 downto 0);
    signal p_zero_to_two      : std_logic_vector(3 downto 0);
    
begin

    a_wire(0)(0) <= a(0);
    b_wire(0)(0) <= b(0);

    gen_rows: for i in 0 to 3 generate
        gen_cols: for j in 0 to 3 generate

        begin

            first_cell: if (i = 0 and j = 0) generate
                Sync_FA_MULT_inst: Sync_FA_MULT
                    port map (
                        a   => a_wire(i)(j),
                        b   => b_wire(i)(j),
                        clk => clk,

                        cin => '0',
                        sin => '0',
                        sum => p_zero_to_two(i),

                        cout      => cout_wire(i)(j+1),
                        a_delayed => a_wire(i+1)(j),
                        b_delayed => b_wire(i)(j+1)
                    );
            end generate;

            top_row: if (i = 0 and j > 0) generate
                Sync_FA_MULT_inst: Sync_FA_MULT
                    port map (
                        a   => a_wire(i)(j),
                        b   => b_wire(i)(j),
                        cin => cout_wire(i)(j),
                        sin => '0',
                        clk => clk,

                        cout      => cout_wire(i)(j+1),
                        sum       => sout_wire(i+1)(j-1),
                        a_delayed => a_wire(i+1)(j),
                        b_delayed => b_wire(i)(j+1)
                    );
            end generate;

            left_column: if (i > 0 and j = 3) generate
                Sync_FA_MULT_inst: Sync_FA_MULT
                    port map (
                        a   => a_wire(i)(j),
                        b   => b_wire(i)(j),
                        clk => clk,

                        cin => cout_wire(i)(j),
                        sin => cout_del(i-1),
                        sum => sout_wire(i+1)(j-1),

                        cout      => cout_wire(i)(j+1),
                        a_delayed => a_wire(i+1)(j),
                        b_delayed => b_wire(i)(j+1)
                    );
            end generate;

            inner_cells: if (i > 0 and (j > 0 and j < 3)) generate
                Sync_FA_MULT_inst: Sync_FA_MULT
                    port map (
                        a   => a_wire(i)(j),
                        b   => b_wire(i)(j),
                        clk => clk,

                        cin => cout_wire(i)(j),
                        sin => sout_wire(i)(j),
                        sum => sout_wire(i+1)(j-1),

                        cout      => cout_wire(i)(j+1),
                        a_delayed => a_wire(i+1)(j),
                        b_delayed => b_wire(i)(j+1)
                    );
            end generate;

            right_column: if (i > 0 and j = 0) generate
                Sync_FA_MULT_inst: Sync_FA_MULT
                    port map (
                        a   => a_wire(i)(j),
                        b   => b_wire(i)(j),
                        clk => clk,

                        cin => '0',
                        sin => sout_wire(i)(j),
                        sum => p_zero_to_two(i),

                        cout      => cout_wire(i)(j+1),
                        a_delayed => a_wire(i+1)(j),
                        b_delayed => b_wire(i)(j+1)
                    );
            end generate;

        end generate;
    end generate;

    gen_shift_in_a: for i in 0 to 2 generate
        SR_a: shift_reg
            generic map (DELAY => i+1)
            port map (
                clk => clk,
                d   => a(i+1),
                q   => a_wire(0)(i+1)
            );
    end generate;

    gen_shift_out_3_to_7: for i in 0 to 1 generate
        SR_p_1: shift_reg
            generic map (DELAY => 2-i)
            port map (
                clk => clk,
                d   => sout_wire(4)(i),
                q   => p(4+i)
            );
    end generate;

    gen_shift_out_0_to_3: for i in 0 to 3 generate
        SR_p_2: shift_reg
            generic map (DELAY => 3 + 2*i)
            port map (
                clk => clk,
                d   => p_zero_to_two(3-i),
                q   => p(3-i)
            );
    end generate;

    gen_shift_cout: for i in 0 to 2 generate
        SR_cout: shift_reg
            generic map (DELAY => 1)
            port map (
                clk => clk,
                d   => cout_wire(i)(4),
                q   => cout_del(i)
            );
    end generate;

    gen_shift_in_b: for i in 0 to 2 generate
        SR_bt: shift_reg
            generic map (DELAY => 2*(i+1))
            port map (
                clk => clk,
                d   => b(i+1),
                q   => b_wire(i+1)(0)
            );
    end generate;
     
    P(6) <= sout_wire(4)(2);
    p(7) <= cout_wire(3)(4);

end Behavioral;
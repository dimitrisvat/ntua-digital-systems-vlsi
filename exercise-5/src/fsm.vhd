library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm is
    Generic (
        N : integer := 6
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
end fsm;

architecture Behavioral of fsm is

    type state_type is (
        IDLE, 
        RECEIVE, 
        OUTPUTING, 
        SHUTTING_DOWN, 
        DONE
    );

    signal current_state, next_state : state_type;
    signal counter_i : unsigned(31 downto 0) := (others => '0');

begin

    counter <= std_logic_vector(counter_i);

    -- State register
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- Next state logic
    process(current_state, valid_in, new_image, counter_i)
    begin
        case current_state is

            when IDLE =>
                if new_image = '1' then
                    next_state <= RECEIVE;
                else
                    next_state <= IDLE;
                end if;

            when RECEIVE =>
                if counter_i = to_unsigned(N*N-1, 32) then
                    next_state <= OUTPUTING;
                else
                    next_state <= RECEIVE;
                end if;

            when OUTPUTING =>
                if counter_i = to_unsigned(N*N+2*N+2, 32) then
                    next_state <= SHUTTING_DOWN;
                else 
                    next_state <= OUTPUTING;
                end if;

            when SHUTTING_DOWN =>
                next_state <= DONE;

            when DONE =>
                next_state <= IDLE;

        end case;
    end process;

    -- Sequential logic
    process(clk)
    begin
        if rising_edge(clk) then

            if current_state = IDLE then
                counter_i <= (others => '0');
                en <= '0';

            elsif current_state = RECEIVE then
                if valid_in = '1' or counter_i = to_unsigned(N*N-1, 32) then
                    counter_i <= counter_i + 1;
                    en <= '1';
                else 
                    en <= '0';
                end if;
            
            elsif current_state = OUTPUTING then
                counter_i <= counter_i + 1;
                en <= '1';

            elsif current_state = SHUTTING_DOWN then
                en <= '0';

            elsif current_state = DONE then
                counter_i <= (others => '0');
                en <= '0';

            end if;
        end if;
    end process;

    -- Output logic
    process(current_state)
    begin
        case current_state is

            when IDLE | RECEIVE | OUTPUTING | SHUTTING_DOWN =>
                image_finished <= '0';

            when DONE =>
                image_finished <= '1';

        end case;
    end process;

end Behavioral;
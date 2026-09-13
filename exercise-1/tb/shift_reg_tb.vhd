library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_reg_tb is
--  Port ( );
end shift_reg_tb;

architecture tb of shift_reg_tb is
    -- COMPONENT
    component shift_reg is
        Port ( 
                clk,rst,si,en,pl,ch_way: in std_logic; 
                din: in std_logic_vector(3 downto 0); 
                so: out std_logic;
                ins_test :out std_logic_vector(3 downto 0) 
        );
    end component;
    -- SIGNALS 
    signal clk,rst,si,en,pl,ch_way :  std_logic ;
    signal din : std_logic_vector(3 downto 0);
    signal so: std_logic ;
    signal ins_test : std_logic_vector(3 downto 0) ;
    -- CONSTANTS
    constant CLOCK_PERIOD : time := 10 ns;

begin
  
    DUT : shift_reg 
        port map (
            clk    => clk,
            rst    => rst,
            si     => si,
            en     => en,
            pl     => pl,
            ch_way => ch_way,
            din    => din,
            so     => so,
            ins_test =>ins_test
        );
   STIMULUS : process
        begin
            ------initialize signals---------
            rst    <= '0';   -- active low reset
            en     <= '0';
            pl     <= '0';
            ch_way <= '1';
            din    <= "1010";
            wait for CLOCK_PERIOD;

            ------load initial number---------
            rst <= '1';      -- release reset
            pl <= '1';
            wait for 4*CLOCK_PERIOD;

            -----------test shift right--------
            pl <= '0';
            en <= '1';
            wait for 8*CLOCK_PERIOD;

            -----------test reset--------------
            rst <= '0';
            wait for 4*CLOCK_PERIOD;
        
            ----------load new number-----------
            en  <= '0';
            rst <= '1';
            din <= "1001";
            pl  <= '1';
            wait for 4*CLOCK_PERIOD;

            ------------test shift left----------
            pl     <= '0';
            en     <= '1';
            ch_way <= '0';
            wait for 8*CLOCK_PERIOD;

            ------------test enable--------------
            en <= '0';
            wait for 4*CLOCK_PERIOD;

            wait;
        end process;

        GEN_SI : process
        begin
            loop
                si <= '0';
                wait for CLOCK_PERIOD;
                si <= '1';
                wait for CLOCK_PERIOD;
            end loop;
        end process;

        GEN_CLK : process
        begin
            clk <= '0';
            wait for (CLOCK_PERIOD / 2);
            clk <= '1';
            wait for (CLOCK_PERIOD / 2);
        end process;

end tb;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all; 

entity control_unit is
    Port(
        valid_in: in std_logic;
        clk: in std_logic;
        rst: in std_logic;
        
        en: out std_logic;
        we: out std_logic;
        mac_init: out std_logic;
        rom_addr: out std_logic_vector(2 downto 0);
        ram_addr: out std_logic_vector(2 downto 0);
        valid_out: out std_logic
    );
end control_unit;

architecture Behavioral of control_unit is

    signal count: std_logic_vector(2 downto 0) := "000";
    signal enabled_flag: std_logic := '0';
    signal first_out: std_logic:= '0';

begin

    process(clk, rst, valid_in)
    begin
        if rst = '1' then
            count <= "000";
            mac_init <= '1';
            valid_out <= '0';
            enabled_flag <= '0';
            en <= '0';

        elsif (enabled_flag = '0' and valid_in = '1') then
            enabled_flag <= '1';
            en <= '1';

        elsif (rising_edge(clk) and enabled_flag = '1') then

            if valid_in = '1' and count = "000" then
                count <= count + 1;
                mac_init <= '1';
                
                if(first_out = '0') then
                    first_out <= '1';
                else 
                    valid_out <= '1';
                end if;
            
            elsif valid_in = '0' and count = "111" then
                enabled_flag <= '0';
                en <= '0';
                count <= "000";

            else
                mac_init <= '0';
                valid_out <= '0';
                count <= count + 1;

            end if;

        end if;
    end process;

    we <= valid_in;
    rom_addr <= count;
    ram_addr <= count;

end Behavioral;
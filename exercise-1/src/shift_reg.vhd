library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_reg is
 Port ( 
        clk,rst,si,en,pl,ch_way: in std_logic; 
        din: in std_logic_vector(3 downto 0); 
        so: out std_logic;
        ins_test :out std_logic_vector(3 downto 0)
 );
end shift_reg;

architecture rtl of shift_reg is

signal dff: std_logic_vector(3 downto 0); 
signal sf: std_logic; 
begin 
 edge: process (clk,rst) 
 begin 
    if rst='0' then --reset is negative logic 
            dff<=(others=>'0'); 
            sf  <= '0';
    elsif clk'event and clk='1' then 
            if pl='1' then 
                    dff<=din; 
            elsif en='1' then
                    case ch_way is 
                    when '1'=>
                    sf <= dff(0);  
                    dff<=si&dff(3 downto 1);
                    when '0'=>
                    sf <= dff(3);  
                    dff<=dff(2 downto 0)&si;
                    when others =>
                    null;
                    end case; 
            end if; 
    end if; 
 end process; 
 so<=sf;
 ins_test<= dff;


end rtl;

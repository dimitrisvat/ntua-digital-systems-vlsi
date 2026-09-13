library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all; 

entity counter_up_down is
    port( 
        clk,resetn,count_en,up_down : in std_logic; 
        sum  : out std_logic_vector(2 downto 0); 
        cout  : out std_logic
        
    ); 
end counter_up_down;

architecture rtl_nolimit of counter_up_down is

signal count: std_logic_vector(2 downto 0); 
begin 
 process(clk, resetn) 
    begin 
        if resetn='0' then --reset is negative logic
        count <= (others=>'0'); 
        elsif clk'event and clk='1' then 
            if count_en='1' then --enable counting positive logic
                  case up_down is
                    when '1'=>
                        count<=count+1;
                    when '0' =>
                        count<=count-1;
                    when others =>
                        null;
                    end case;    
            end if; 
        end if; 
 end process; 
 sum <= count; 
 cout <= '1' when count=7 and count_en='1' else '0'; 

end rtl_nolimit;

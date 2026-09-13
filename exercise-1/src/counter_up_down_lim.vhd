library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all; 

entity counter_up_down_lim is
    port( 
        clk,resetn,count_en,up_down : in std_logic;
        limit : in std_logic_vector(2 downto 0); 
        sum  : out std_logic_vector(2 downto 0); 
        cout  : out std_logic
        
    ); 
end counter_up_down_lim;

architecture rtl_lim of counter_up_down_lim is
    signal count : std_logic_vector(2 downto 0); 
    begin 
    process(clk, resetn, limit) 
        begin 
            if resetn='0' then 
            -- Asynchronous reset 
            count <= (others=>'0'); 
            elsif clk'event and clk='1' then 
            if count_en = '1' then 
                -- Count only if count_en=’1’ 
                    if count/=limit then 
                    -- Increase the counter only if it is not 7 
                    count <= count+1; 
                    else 
                    -- Otherwise we reset it 
                    count<=(others=>'0'); 
                end if; 
            end if;  
        end if; 
    end process; 
    sum<= count; 
    cout <= '1' when count=7 and count_en='1' else  '0'; 

end rtl_lim;

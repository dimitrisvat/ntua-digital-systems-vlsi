library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity bin_dec is
    port 
    (
    i_dec : in std_logic_vector(2 downto 0);
    o_dec : out std_logic_vector(7 downto 0)
    );
end bin_dec;

architecture Dataflow of bin_dec is

begin
    o_dec(0) <= (not i_dec(2)) and (not i_dec(1)) and (not i_dec(0));
    o_dec(1) <= (not i_dec(2)) and (not i_dec(1)) and     i_dec(0);
    o_dec(2) <= (not i_dec(2)) and     i_dec(1)  and (not i_dec(0));
    o_dec(3) <= (not i_dec(2)) and     i_dec(1)  and     i_dec(0);
    o_dec(4) <=     i_dec(2)  and (not i_dec(1)) and (not i_dec(0));
    o_dec(5) <=     i_dec(2)  and (not i_dec(1)) and     i_dec(0);
    o_dec(6) <=     i_dec(2)  and     i_dec(1)  and (not i_dec(0));
    o_dec(7) <=     i_dec(2)  and     i_dec(1)  and     i_dec(0);

end Dataflow;

architecture Behavioral of bin_dec is

begin

   ENC_MODULE: process(i_dec)
    begin
        case i_dec is
            when "000" => o_dec <= "00000001";
            when "001" => o_dec <= "00000010";
            when "010" => o_dec <= "00000100";
            when "011" => o_dec <= "00001000";
            when "100" => o_dec <= "00010000";
            when "101" => o_dec <= "00100000";
            when "110" => o_dec <= "01000000";
            when "111" => o_dec <= "10000000";
            when others => o_dec <= "00000000";
        end case;
    end process;

end Behavioral;

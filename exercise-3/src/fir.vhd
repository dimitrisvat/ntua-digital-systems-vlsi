library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all; 

entity fir is
    Port (
        clk: in std_logic;
        rst: in std_logic;
        valid_in: in std_logic;
        x: in std_logic_vector (7 downto 0);

        valid_out: out std_logic;
        y: out std_logic_vector (16 downto 0)

    );
end fir;

architecture Behavioral of fir is

component control_unit is 
    Port ( 
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
end component; 

component mac is
    Port (
        a: in std_logic_vector (7 downto 0);
        b: in std_logic_vector (7 downto 0);
        clk: in std_logic;
        mac_init: in std_logic;

        y: out std_logic_vector (16 downto 0)
    );
end component;

component mlab_ram is
	generic (
		data_width : integer :=8                -- width of data (bits)
	);
    Port (
        clk  : in std_logic;
        we   : in std_logic;                    -- memory write enable
        en   : in std_logic;                    -- operation enable
        addr : in std_logic_vector(2 downto 0); -- memory address
        di   : in std_logic_vector(7 downto 0); -- input data
        rst  : in std_logic;

        do   : out std_logic_vector(7 downto 0) -- output data
    );    
end component;

component mlab_rom is
	generic (
		coeff_width : integer :=8                                   -- width of coefficients (bits)
	);
    Port ( 
        clk : in  STD_LOGIC;
		en : in  STD_LOGIC;                                         -- operation enable
        addr : in  STD_LOGIC_VECTOR (2 downto 0);                   -- memory address
        			       
        rom_out : out  STD_LOGIC_VECTOR (coeff_width-1 downto 0) ;  -- output data
        rst : in std_logic
    );
end component;

signal rom_addr, ram_addr: std_logic_vector(2 downto 0):= (others => '0');
signal rom_data, ram_data: std_logic_vector(7 downto 0):= (others => '0');
signal rom_out, ram_out: std_logic_vector (7 downto 0) := (others => '0');
signal mac_init, en, we: std_logic; 

begin
    rom_out <= rom_data when en = '1' else (others => '0');
    ram_out <= ram_data when en = '1' else (others => '0');

    cu: control_unit port map( 
        clk => clk,  
        rst => rst, 
        en => en,
        we => we,
        valid_in => valid_in, 
        rom_addr => rom_addr, 
        ram_addr => ram_addr, 
        mac_init => mac_init,
        valid_out => valid_out 
    ); 
     
    rom: mlab_rom port map( 
        clk => clk, 
        en => en,  
        addr => rom_addr, 
        rom_out => rom_data, 
        rst=>rst
    ); 
     
    ram: mlab_ram port map( 
        clk => clk, 
        we => we, 
        en => en,  
        addr => ram_addr, 
        di => x,
        rst => rst, 
        do => ram_data
    ); 
     
    mac1: mac port map( 
        clk => clk, 
        a => rom_out, 
        b => ram_out, 
        mac_init => mac_init, 
        y => y 
    );    

end Behavioral;
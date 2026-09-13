library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debayaring_v1_0_M00_AXIS is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M_START_COUNT	: integer	:= 32
	);
	port (
		-- Users to add ports here
		R              : in std_logic_vector(7 downto 0);
		G              : in std_logic_vector(7 downto 0);
		B              : in std_logic_vector(7 downto 0);
		valid_out      : in std_logic;
		image_finished : in std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line

		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic
	);
end debayaring_v1_0_M00_AXIS;

architecture implementation of debayaring_v1_0_M00_AXIS is

	-- Total number of output data                                              
	constant NUMBER_OF_OUTPUT_WORDS : integer := 8;                                   

	function clogb2 (bit_depth : integer) return integer is                  
	 	variable depth  : integer := bit_depth;                               
	 	variable count  : integer := 1;                                       
	 begin                                                                   
	 	 for clogb2 in 1 to bit_depth loop
	      if (bit_depth <= 2) then                                           
	        count := 1;                                                      
	      else                                                               
	        if(depth <= 1) then                                              
	 	       count := count;                                                
	 	     else                                                             
	 	       depth := depth / 2;                                            
	          count := count + 1;                                            
	 	     end if;                                                          
	 	   end if;                                                            
	   end loop;                                                             
	   return(count);        	                                              
	 end;                                                                    

	constant  WAIT_COUNT_BITS  : integer := clogb2(C_M_START_COUNT-1);               
	constant depth : integer := NUMBER_OF_OUTPUT_WORDS;                               
	constant bit_num : integer := clogb2(depth);                                      

	type state is ( IDLE, INIT_COUNTER, SEND_STREAM);
	signal  mst_exec_state : state;                                                   
	signal read_pointer : integer range 0 to depth-1;                               

	signal count	: std_logic_vector(WAIT_COUNT_BITS-1 downto 0);
	signal axis_tvalid	: std_logic;
	signal axis_tvalid_delay	: std_logic;
	signal axis_tlast	: std_logic;
	signal axis_tlast_delay	: std_logic;
	signal stream_data_out	: std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
	signal tx_en	: std_logic;
	signal tx_done	: std_logic;

begin

	-- Add user logic here
	M_AXIS_TVALID	<= valid_out;
	M_AXIS_TDATA	<= "00000000" & R & G & B;
	M_AXIS_TLAST	<= image_finished;
	M_AXIS_TSTRB	<= (others => '1');

	-- User logic ends

end implementation;
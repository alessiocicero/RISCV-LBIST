library ieee;
use ieee.std_logic_1164.all;
--Port map must be modified, this is just a mockup
entity bist is
	port(	clk: in std_logic;
		resetn: in std_logic;
		test_normal: out std_logic;	
		go_nogo: in std_logic);
		
end entity bist;

architecture rtl of bist is
begin
end architecture; 

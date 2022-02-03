library IEEE;
use IEEE.std_logic_1164.all;

entity   mux_generic  is

generic (nbit: integer:= 32);

	port (	a:		in	std_logic_vector(nbit-1 downto 0) ;
			b:		in	std_logic_vector(nbit-1 downto 0);
			sel:	in	std_logic;
			y:		out	std_logic_vector(nbit-1 downto 0));

end entity mux_generic;

architecture structural of mux_generic is


	component mux21
	
		port (	a:	in	std_logic;
				b:	in	std_logic;
                s:  in  std_logic;
				y:	out	std_logic);
	
	end component;

begin

	g1: for i in nbit-1 downto 0 generate --implementing a generix mux by instanciating n single muxes
  		mux2to1: mux21 port map (a(i), b(i), sel, y(i));
	end generate;

end structural;




library ieee;
use ieee.std_logic_1164.all;

entity misr is
	port(	clk:	in std_logic;
		 	rstn:	in std_logic;
		 	misr_so_enable: in std_logic;
		 	din:	in std_logic_vector(19 downto 0);
		 	signature:	out std_logic_vector(19 downto 0));
end entity misr;

architecture rtl of misr is
	signal c3,c20:	std_logic;
	signal ff_in,ff_out:	std_logic_vector(19 downto 0);
	component flipflop is
	
		Port (	D:	In	std_logic;
				CLK:	In	std_logic;
				RESETN:	In	std_logic;
				ENABLE: In std_logic;	
				Q:	Out	std_logic);
	end component flipflop;
begin 
	ff_in(0)<=c20 xor din(0);
ff0:	flipflop port map(d=>ff_in(0), clk => clk, resetn => rstn, enable =>misr_so_enable, q=> ff_out(0));
	signature(0)<=ff_out(0);

chain_gen: for i in 1 to 16 generate
	ff_in(i) <= ff_out(i-1) xor din(i);
ffx:	flipflop port map(d=>ff_in(i), clk => clk, resetn => rstn, enable =>misr_so_enable, q=> ff_out(i));
	signature(i)<=ff_out(i);
	end generate;

	ff_in(17)<=c3 xor din(17) xor ff_out(16);
ff17:	flipflop port map(d=>ff_in(17), clk => clk, resetn => rstn, enable =>misr_so_enable, q=> ff_out(17));
	signature(17)<=ff_out(17);

	ff_in(18)<=ff_out(17) xor din(18);
ff18:	flipflop port map(d=>ff_in(18), clk => clk, resetn => rstn, enable =>misr_so_enable, q=> ff_out(18));
	signature(18)<=ff_out(18);

	ff_in(19)<=ff_out(18) xor din(19);
ff19:	flipflop port map(d=>ff_in(19), clk => clk, resetn => rstn, enable =>misr_so_enable, q=> ff_out(19));	
	signature(19)<=ff_out(19);
	c3<=ff_out(19);
	c20<=ff_out(19);

end architecture;

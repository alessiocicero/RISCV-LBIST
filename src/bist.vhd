library ieee;
use ieee.std_logic_1164.all;

entity bist is

	port(	
		clk: 				in std_logic;
		resetn: 			in std_logic;
		test_normal: 		in std_logic;
		pi: 				in std_logic;
		scan_chain_output: 	in std_logic_vector(19 downto 0);	
		scan_chain_input: 	out std_logic_vector(19 downto 0);
		test_en_i: 			out std_logic;
		muxed_pi: 			out std_logic;
		go_nogo: 			out std_logic
	);
		
end entity bist;

architecture rtl of bist is

	component bist_controller is

		port(		
			clk: 			in std_logic;
			resetn: 		in std_logic;
			test_normal: 	in std_logic;
			misr_eval: 		in std_logic_vector(19 downto 0);
			test_en_i:		out std_logic;
			misr_so_enable: out std_logic;
			go_nogo: 		out std_logic;
			lfsr_start: 	out std_logic;
			lfsr_load: 		out std_logic;
			mux_select: 	out std_logic
		);
	
	end component;

	component lfsr is

		port(
			seed: 			in std_logic_vector(19 downto 0);
			clk: 			in std_logic;
			resetn: 		in std_logic;
			lfsr_start:		in std_logic; 
			lfsr_load: 		in std_logic;
			output: 		out std_logic_vector(19 downto 0)
		);
	
	end component;

	component misr is

		port(	
			clk:			in std_logic;
			rstn:			in std_logic;
			misr_so_enable:	in std_logic;
			din:			in std_logic_vector(19 downto 0);
			signature:		out std_logic_vector(19 downto 0)
		);

	end component;

	component mux2to1 is

		port(
			x: 				in std_logic;
			y:				in std_logic;
			s:				in std_logic;
			m:				out std_logic
		);

	end component;

	signal lfsr_start, lfsr_load, misr_so_enable, mux_select: std_logic;
	signal misr_eval: std_logic_vector(19 downto 0);
	signal seed, scan_chain_input_sig: std_logic_vector(19 downto 0) := "00000000000000000001";

begin
	
	scan_chain_input <= scan_chain_input_sig;

	mux : mux2to1 port map (
							x => pi,
							y => scan_chain_input_sig(0),
							s => mux_select,
							m => muxed_pi
					);

	lfsr_port : lfsr port map (
							seed => seed, --da gestire
							clk => clk,
							resetn => resetn,
							lfsr_start => lfsr_start, --signal
							lfsr_load => lfsr_load, --signal
							output => scan_chain_input_sig
					);
			
	misr_port : misr port map (
							clk => clk,
							rstn => resetn,
							misr_so_enable => misr_so_enable, --signal
							din => scan_chain_output,
							signature => misr_eval --signal
					);

	bist_port : bist_controller port map (
							clk => clk,
							resetn => resetn,
							test_normal => test_normal,
							misr_eval => misr_eval, --signal
							test_en_i => test_en_i,
							misr_so_enable => misr_so_enable, 
							go_nogo => go_nogo,
							lfsr_start => lfsr_start, 
							lfsr_load => lfsr_load, 
							mux_select => mux_select
					);

end architecture; 	

library ieee;
use ieee.std_logic_1164.all;

entity lfsr is

	port(seed: in std_logic_vector(19 downto 0);
		 clk: in std_logic;
		 resetn: in std_logic;
		 lfsr_start, lfsr_load: in std_logic;
		 output: out std_logic_vector(19 downto 0)
	);

end lfsr;

architecture rtl of lfsr is

	component flipflop

		port (
			  D: in std_logic;
			  clk: in std_logic;
			  resetn: in std_logic;
			  enable: in std_logic;
			  Q: out std_logic
			 );

	end component;

	component mux2to1

		port(x: in std_logic;
			 y: in std_logic;
			 s: in std_logic;
			 m: out std_logic);

	end component;

	signal ff_input, ff_output: std_logic_vector(19 downto 0);
	signal xor_result: std_logic;
        signal enable: std_logic;

begin 
  enable<= lfsr_start or lfsr_load;
	ff_mux_generate: for I in 1 to 19 generate

		ff: flipflop port map (clk => clk,
								resetn => resetn,
								enable => enable,
								D => ff_input(I),
								Q => ff_output(I));

		mux: mux2to1 port map (x => ff_output(I-1),
							   y => seed(I),
							   s => lfsr_load,
							   m => ff_input(I));
	end generate;

	ff_0: flipflop port map (clk => clk,
							  resetn => resetn,
							  enable => enable,
							  D => ff_input(0),
							  Q => ff_output(0));

	mux_0: mux2to1 port map (x => xor_result,
							   y => seed(0),
							   s => lfsr_load,
							   m => ff_input(0));

	xor_result <= ff_output(19) xor ff_output(2);
	--output <= ff_output(0 to 19);
	output <= ff_output;

end architecture rtl;

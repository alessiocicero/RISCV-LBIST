library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bist_controller is

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

end bist_controller;


architecture arch of bist_controller is

	type state_type is (reset_state, idle_state, teststart_state, firstshift_state, testshift_state, testexec_state, endtest_state, evaluate_state);
	signal present_state, future_state: state_type;
	signal count_shift, count_vector: std_logic_vector(19 downto 0);
	signal count_shift_unsigned, count_vector_unsigned: unsigned(19 downto 0);
	signal golden_signature: std_logic_vector(19 downto 0);
	signal count_vector_enable, resetn_count_vector, count_shift_enable, resetn_count_shift: std_logic;

begin
	--100 vectors: 01111100110101101101
	--100 vectors: 01101010110001101011
	
	golden_signature <= "00101110101011100110";

	change_state: process(clk, present_state, future_state, resetn)
	begin
		if (clk'event and clk = '1') then
			if resetn = '0' then
				present_state <= reset_state;
			else
				present_state <= future_state;
			end if;
		end if;
	end process;

	chose_state: process(present_state, future_state, resetn, test_normal, count_shift, count_vector)
	begin
		case present_state is
			when reset_state 		=> 	if resetn = '1' then future_state <= idle_state;
										else future_state <= reset_state;
										end if;
			when idle_state 		=> 	if test_normal = '1' then future_state <= teststart_state;
										else future_state <= idle_state;
										end if;
			when teststart_state 	=>	future_state <= firstshift_state;
			when firstshift_state 	=>	if count_shift = "00000000000010011000" then future_state <= testexec_state;
										else future_state <= firstshift_state;
										end if;
										--10k vectors: 00000010011100010000
										--100 vettori:00000000000001100100
										--10 vettori: 00000000000000001010
			when testshift_state 	=>  if count_shift = "00000000000010011000" and count_vector = "00000010011100010000" then future_state <= endtest_state;
										elsif count_shift = "00000000000010011000" then future_state <= testexec_state; 
										else future_state <= testshift_state;
										end if;
			when testexec_state 	=>	future_state <= testshift_state;
			when endtest_state 		=>	future_state <= evaluate_state;
			when evaluate_state 	=>  future_state <= idle_state;
		end case;
	end process;

	control_signal: process(present_state, misr_eval)
	begin
		case present_state is
			when reset_state		=> 	go_nogo <= '0';
										lfsr_start <= '0';
										lfsr_load <= '0';
										mux_select <= '0';
										test_en_i <= '0';
										misr_so_enable <= '0';
										count_vector_enable <= '0';
										count_shift_enable <= '0';
										resetn_count_shift <= '0';
										resetn_count_vector <= '0';
			when idle_state 		=>  go_nogo <= '0';
										lfsr_start <= '0';
										lfsr_load <= '0';
										mux_select <= '0';
										test_en_i <= '0';
										misr_so_enable <= '0';
										count_vector_enable <= '0';
										count_shift_enable <= '0';
										resetn_count_shift <= '1';
										resetn_count_vector <= '1';
			when teststart_state 	=>	go_nogo <= '1';
										lfsr_start <= '0';
										lfsr_load <= '1';
										mux_select <= '1';
										test_en_i <= '1';
										misr_so_enable <= '0';
										count_vector_enable <= '1';
										count_shift_enable <= '0';
										resetn_count_shift <= '1';
										resetn_count_vector <= '1';
			when firstshift_state 	=>	go_nogo <= '0';
										lfsr_start <= '1';
										lfsr_load <= '0';
										mux_select <= '1';
										test_en_i <= '1';
										misr_so_enable <= '0';
										count_vector_enable <= '0';
										count_shift_enable <= '1';
										resetn_count_shift <= '1';
										resetn_count_vector <= '1';
			when testshift_state 	=>	go_nogo <= '0';
										lfsr_start <= '1';
										lfsr_load <= '0';
										mux_select <= '1';
										test_en_i <= '1';
										misr_so_enable <= '1';
										count_vector_enable <= '0';
										count_shift_enable <= '1';
										resetn_count_shift <= '1';
										resetn_count_vector <= '1';
			when testexec_state 	=>	go_nogo <= '0';
										lfsr_start <= '0';
										lfsr_load <= '0';
										mux_select <= '1';
										test_en_i <= '0';
										misr_so_enable <= '0';
										count_vector_enable <= '1';
										count_shift_enable <= '0';
										resetn_count_shift <= '0';
										resetn_count_vector <= '1';
			when endtest_state 		=> 	go_nogo <= '1';
										lfsr_start <= '0';
										lfsr_load <= '0';
										mux_select <= '0';
										test_en_i <= '0';
										misr_so_enable <= '0';
										count_vector_enable <= '0';
										count_shift_enable <= '0';
										resetn_count_shift <= '0';
										resetn_count_vector <= '0';
			when evaluate_state 	=>	if misr_eval = golden_signature then go_nogo <= '1'; 
										else go_nogo <= '0';
										end if;
										lfsr_start <= '0';
										lfsr_load <= '0';
										mux_select <= '0';
										test_en_i <= '0';
										misr_so_enable <= '0';
										count_vector_enable <= '0';
										count_shift_enable <= '0';
										resetn_count_shift <= '0';
										resetn_count_vector <= '0';
		end case;
	end process;

	counter_1: process(clk, count_vector_enable, resetn_count_vector, count_vector)
	begin
		if (clk'event and clk = '1') then
			if resetn_count_vector = '0' then
				count_vector_unsigned <= (others => '0');
			elsif count_vector_enable = '1' then
				count_vector_unsigned <= unsigned(count_vector) + "1";
			end if;
		end if;
	end process;

	counter_2: process(clk, count_shift_enable, resetn_count_shift, count_shift)
	begin
		if (clk'event and clk = '1') then
			if resetn_count_shift = '0' then
				count_shift_unsigned <= (others => '0');
			elsif count_shift_enable = '1' then
				count_shift_unsigned <= unsigned(count_shift) + "1";
			end if;
		end if;
	end process;

	count_shift <= std_logic_vector(count_shift_unsigned);
	count_vector <= std_logic_vector(count_vector_unsigned);

end arch;

library IEEE;
use IEEE.std_logic_1164.all; 

entity flipflop is

	Port (	D:	In	std_logic;
			CLK:	In	std_logic;
			RESETN:	In	std_logic;
			ENABLE: In std_logic;	
			Q:	Out	std_logic);

end flipflop;


architecture SYNCH of flipflop is -- flip flop D with syncronous reset

begin

	PSYNCH: process(CLK,RESETN,ENABLE)
	begin
	  if CLK'event and CLK='1' then -- positive edge triggered:

	    if RESETN='0' then -- active low reset 
	      Q <= '0'; 

	    elsif ENABLE='1' then
	      Q <= D; -- input is written on output if the flipflop is enabled
	    end if;

	  end if;
	end process;

end SYNCH;




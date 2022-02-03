library ieee;
use ieee.std_logic_1164.all;

entity clk_gen is
	port(	clk: out std_logic;
		rstn: out std_logic);	
end entity;

architecture beh of clk_gen is
  constant Ts : time := 10 ns;
  
  signal CLK_i : std_logic;
  
begin  -- beh

  process
  begin  -- process
    if (CLK_i = 'U') then
      CLK_i <= '0';
    else
      CLK_i <= not(CLK_i);
    end if;
    wait for Ts/2;
  end process;

  clk <= CLK_i; -- and not(END_SIM);

  process
  begin  -- process
    rstn <= '0';
    wait for 3*Ts/2;
    rstn <= '1';
    wait;
  end process;




end architecture beh;

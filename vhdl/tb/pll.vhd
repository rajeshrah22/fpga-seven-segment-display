library ieee;
use ieee.std_logic_1164.all;

entity pll is
	port (
		inclk0:	in	std_logic;
		c0:		out	std_logic
	);
end entity pll;

architecture dummy of pll is
begin
	c0 <= inclk0;
end architecture dummy;

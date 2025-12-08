-- This is the toplevel
library ieee;
use ieee.std_logic_1164.all;

entity seven_segment_display is
	port (
		src_clk: in std_logic;
		display_clk: in std_logic;
	);
end entity seven_segment_display;

architecture toplevel of seven_segment_display is
	signal pll_clk: std_logic;
begin

pll_inst: entity work.pll
	port map (
		inclk0 => src_clk,
		c0 => src_clk
	);
	
adc: entity work.max10_adc
	port map (
		pll_clk => pll_clk,
		chsel => ,
		soc => ,
		tsen => ,
		dout => ,
		eoc => ,
		clk_dft => ,
	);
memory:
adc_fsm:
display_fsm:
prod2cons_sync:
cons2prod_sync:

end architecture toplevel;
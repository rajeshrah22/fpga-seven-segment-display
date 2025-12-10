library ieee;
use ieee.std_logic_1164.all;

use work.seven_segment_pkg.all;

entity tb_toplevel is
	generic (
		ADDR_WIDTH:	positive := 6;
		lamp_mode:	lamp_configuration := common_anode
	);
end entity tb_toplevel;

architecture test of tb_toplevel is
	signal clk_1mhz: std_logic := '0';
	signal clk_50mhz: std_logic := '0';
	signal reset: std_logic := '0';

	signal done: boolean := false;
begin

	clk_1mhz <= not clk_1mhz after 500 ns when not done else '0';
	clk_50mhz <= not clk_50mhz after 10 ns when not done else '0';


	dut: entity work.seven_segment_display
		generic map (
			ADDR_WIDTH =>	ADDR_WIDTH,
			lamp_mode =>	lamp_mode
		)
		port map (
			src_clk	=>		clk_1mhz,
			display_clk =>	clk_50mhz,
			reset =>		reset,
			digits_out =>	open
		);

	stimulus: process is
	begin
		reset <= '0';
		wait until rising_edge(clk_1mhz);
		wait until rising_edge(clk_1mhz);

		reset <= '1';
		for i in 0 to 100 loop
			wait until rising_edge(clk_1mhz);
		end loop;
		done <= true;
		wait;
	end process stimulus;

end architecture test;

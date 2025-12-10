library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

----
-- port map:
--
-- pll_clk:	clock input (1 MHz)
-- chsel:	channel select
-- soc:		start of conversion
-- tsen:	0 - normal mode
--		1 - temperature sensing mode.
-- dout:	data output
-- eoc:		end of conversion
-- clk_dft:	clock output from clock divider

entity max10_adc is
	port (
		pll_clk:	in	std_logic;
		chsel:		in	natural range 0 to 2**5 - 1;
		soc:		in	std_logic;
		tsen:		in	std_logic;
		dout:		out	natural range 0 to 2**12 - 1;
		eoc:		out	std_logic;
		clk_dft:	out	std_logic
	);
end entity max10_adc;

architecture wrapper of max10_adc is
	signal adc_dout: std_logic_vector(11 downto 0);
	signal adc_chsel: std_logic_vector(4 downto 0);
begin

	dout <= 1234;	-- nice number
	clk_dft <= pll_clk;

	simulated: process(pll_clk) is
	begin
		if rising_edge(pll_clk) then
			if soc = '1' then
				eoc <= '1' after 100 ns;
			else
				eoc <= '0' after 100 ns;
			end if;
		end if;
	end process simulated;

end architecture wrapper;

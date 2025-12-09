library ieee;
use ieee.std_logic_1164.all;

use work.gray_to_bin;
use work.bin_to_gray;

entity sync is
	generic (
		addr_width: positive := 5
	);
	port (
		input: in std_logic_vector(addr_width - 1 downto 0);
		output: out std_logic_vector(addr_width - 1 downto 0);
		src_clk: in std_logic;
		target_clk: in std_logic
	);
end entity sync;


architecture rtl of sync is
	type stage_type is array(0 to 3) of std_logic_vector(addr_width - 1 downto 0);
	signal gray_in: std_logic_vector(addr_width - 1 downto 0);
	signal stage_reg: stage_type;
	signal bin_out_s: std_logic_vector(addr_width - 1 downto 0);
begin

convert_bin2gray:	entity work.bin_to_gray
	port map (
		bin_in => input,
		gray_out => stage_reg(0)
	);
	
process (src_clk)
begin
	if rising_edge(src_clk) then
		stage_reg(1) <= stage_reg(0);
	end if;
end process;

process (target_clk)
begin
	if rising_edge(target_clk) then
		stage_reg(2) <= stage_reg(1);
		stage_reg(3) <= stage_reg(2);
	end if;
end process;


convert_gray2bin:	entity gray_to_bin
	port map (
		gray_in => stage_reg(3),
		bin_out => output
	);

end architecture rtl;


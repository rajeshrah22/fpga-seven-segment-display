library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.seven_segment_pkg.all;
use work.pll;

entity seven_segment_display is
	generic(
		ADDR_WIDTH : positive := 5;
		lamp_mode  : lamp_configuration := common_anode
	);
	port (
		src_clk: 		in std_logic;
		display_clk: 	in std_logic;
		reset:			in std_logic;
		digits_out:		out seven_segment_array(0 to 2)
	);
end entity seven_segment_display;

architecture toplevel of seven_segment_display is
	constant DATA_WIDTH  : positive := 12;
	signal pll_clk			: std_logic;
	signal read_addr		: unsigned(ADDR_WIDTH - 1 downto 0);
	signal write_addr		: unsigned(ADDR_WIDTH - 1 downto 0);
	signal prod_sync_out : unsigned(ADDR_WIDTH - 1 downto 0);
	signal cons_sync_out : unsigned(ADDR_WIDTH - 1 downto 0);

	signal adc_data: natural range 0 to 2**12 - 1;
	signal adc_data_vector: std_logic_vector(DATA_WIDTH - 1 downto 0);
	signal adc_start: std_logic;
	signal adc_done: std_logic;
	signal adc_clk: std_logic;

	signal read_address_natural: natural range 0 to 2**ADDR_WIDTH - 1;
	signal write_address_natural: natural range 0 to 2**ADDR_WIDTH - 1;
	signal w_en: std_logic;

	signal data_out: std_logic_vector(DATA_WIDTH - 1 downto 0);
begin

	gen_outs: for i in digits_out'range generate
	begin
		digits_out(i) <= get_hex_digit(to_integer(unsigned(data_out(4*i + 3 downto 4*i))), lamp_mode);
	end generate gen_outs;

	read_address_natural <= to_integer(read_addr);
	write_address_natural <= to_integer(write_addr);
	adc_data_vector <= std_logic_vector(to_unsigned(adc_data, DATA_WIDTH));

pll_inst: entity work.pll
	port map (
		inclk0 	=> src_clk,
		c0 		=> pll_clk
	);
	
adc: entity work.max10_adc
	port map (
		pll_clk 	=> pll_clk,
		chsel 	=> 0,
		soc 		=> adc_start,
		tsen 		=> '1',
		dout 		=> adc_data,
		eoc 		=> adc_done,
		clk_dft 	=> adc_clk
	);

memory:
	entity work.true_dual_port_ram_dual_clock
	generic map (
		ADDR_WIDTH => 16
	)
	port map (
		clk_a		=> adc_clk,
		clk_b		=> display_clk,
		addr_a	=> write_address_natural,
		addr_b	=> read_address_natural,
		data_a	=> adc_data_vector,
		data_b	=> ( others => '0' ),
		we_a		=> w_en,
		we_b		=> '0',
		q_a		=> open,
		q_b		=> data_out
	);

  adc_fsm: entity work.adc_fsm
		port map (
			adc_clk => adc_clk,
			reset => reset,
			raddr_in => cons_sync_out,
			waddr_out => write_addr,
			start_out => adc_start,
			done => adc_done,
			w_en_out => w_en
		);

display_fsm: entity work.Display_FSM
	generic map(
		Data_Width => 16
	)
	
	port map(
		data_in 	=>	prod_sync_out,
		clk_50  	=>	display_clk,
		reset   	=>	reset,
		data_out	=>	read_addr
	);

prod2cons_sync: entity work.sync
	generic map(
		ADDR_WIDTH => 16
	)
	
	port map(
		prod_out 			=>	prod_sync_out,
		prod_in 				=>	write_addr,
		prod_src_clk		=>	adc_clk,
		prod_target_clk 	=>	display_clk
	);

cons2prod_sync: entity work.sync 
	generic map(
		ADDR_WIDTH => 16
	)
	port map(
		cons_out 			=>	cons_sync_out,
		cons_in 				=> read_addr,
		cons_src_clk		=>	display_clk,
		cons_target_clk 	=>	adc_clk
	);

	-- TODO: std_logic_vector --> BCD raw value to temp conversion
	-- TODO fix Display_FSM errors
	
end architecture toplevel;

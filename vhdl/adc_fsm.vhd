library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_fsm is
	generic (
		addr_width: positive := 5
	);

	port (
		adc_clk: in std_logic;
		reset: in std_logic;

		-- addresses
		raddr_in: in unsigned(addr_width - 1 downto 0);
		waddr_out: out unsigned(addr_width - 1 downto 0);

		-- adc controls
		start_out: out std_logic;
		done: in std_logic;

		-- memory
		w_en_out: out std_logic
	);
end entity adc_fsm;

architecture fsm of adc_fsm is
	type state_type is
		(START_OF_CONV, WAIT_FOR_CONV, CHECK_ADV, ADV_AND_STR);

	signal state, next_state: state_type;
	signal waddr: unsigned(addr_width - 1 downto 0);
	signal w_en: std_logic;
	signal start: std_logic;
begin
	waddr_out <= waddr;
	w_en_out <= w_en;
	start_out <= start;

	save_state: process(adc_clk, reset) is
	begin
		if reset = '0' then
			state <= START_OF_CONV;
		elsif rising_edge(adc_clk) then
			state <= next_state;
    end if;
	end process save_state;

	transition_fn: process(state, done, waddr, raddr_in) is
	begin
		next_state <= state;
		case state is
			when START_OF_CONV =>
				next_state <= WAIT_FOR_CONV;
			when WAIT_FOR_CONV =>
				if done = '1' then
					next_state <= CHECK_ADV;
				end if;
			when CHECK_ADV =>
				if waddr + 1 /= raddr_in then
					next_state <= ADV_AND_STR;
				end if;
			when ADV_AND_STR =>
				next_state <= START_OF_CONV;
			when others =>
				next_state <= START_OF_CONV;
		end case;
	end process transition_fn;

	output_fn: process(adc_clk, reset) is
	begin
		if reset = '0' then
			w_en <= '0';
			waddr <= (others => '0');
		elsif rising_edge(adc_clk) then
			case state is
				when START_OF_CONV =>
					start <= '1';
					w_en <= '0';
				when WAIT_FOR_CONV =>
					start <= '0';
					w_en <= '0';
				when ADV_AND_STR =>
					waddr <= waddr + 1;
					w_en <= '1';
				when others => null;
			end case;
		end if;
	end process output_fn;
end architecture fsm;

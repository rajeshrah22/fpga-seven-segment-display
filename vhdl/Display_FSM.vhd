library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Display_FSM is
	generic (
		data_width: positive := 16;
	);
	port (
		data_in : in unsigned;
		clk_50  : in std_logic;
		reset   : in std_logic;
		data_out: out unsigned;
	);
end Display_FSM;

architecture Dis_FSM  of Display_FSM is
	signal read_addr : unsigned
	--signal output  : unsigned
	type state_type is 
		(wait_advance, advance);
		
	signal state		: state_type;
	signal next_state : state_type;
	
begin
	--state 1: checks if it can advance read pointer
	--state 2: advance the read pointer
	save_state: process(clk_50, reset) is
		begin
			if reset ='0' then
				state <= state_0;
			elsif rising_edge(clk_50) then
				state <= next_state;
			end if;
		end process save_state;
		
	transistion: process (state, data_in) is 
		begin
			next_state <= state;
			case state is
				when wait_advance =>
					if data_in = read_addr+1 then
						next_state <=wait_advance;
					elsif
						next_state <= advance
					end if;
				when advance =>
						next_state <=wait_advance;
					end if;
				end case;
		end process transition;
		
	output_fn: process (clk_50, reset) is
		begin
			if reset = '0' then
				read_addr <= (others => '1');
			elsif rising_edge(clk_50)
				if state = advance then
					read_addr <= read_addr + 1;
				end if;
			end if
		end process output_fn;
		
	data_out <= read_addr;
	
end Dis_FSM
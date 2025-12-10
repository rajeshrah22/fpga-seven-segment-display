library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Display_FSM is
	generic (
		data_width: positive := 16;
		addr_width: positive := 5
	);
	port (
		data_in : in unsigned;
		clk_50  : in std_logic;
		reset   : in std_logic;
		data_out: out unsigned
	);
end Display_FSM;

architecture Dis_FSM  of Display_FSM is
	signal read_addr : unsigned(addr_width - 1 downto 0);
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
				state <= wait_advance;
			elsif rising_edge(clk_50) then
				state <= next_state;
			end if;
		end process save_state;
		
	transition: process (state, data_in) is 
		begin
			next_state <= state;
			case state is
				when wait_advance =>
					if data_in = read_addr+1 then
						next_state <=wait_advance;
          else
						next_state <= advance;
					end if;
				when advance =>
						next_state <=wait_advance;
      end case;
		end process transition;
		
	output_fn: process (clk_50, reset) is
		begin
			if reset = '0' then
				read_addr <= (others => '1');
      elsif rising_edge(clk_50) then
				if state = advance then
					read_addr <= read_addr + 1;
				end if;
			end if;
		end process output_fn;
		
	data_out <= read_addr;
	
end architecture Dis_FSM;

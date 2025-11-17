library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_controller is
  generic (
    DATA_WIDTH : positive := 12
  );
  port (
    clk        : in  std_logic;  -- ADC domain clock (clk_dft from max10_adc)
    rst_n      : in  std_logic;  -- active low reset

    -- ADC interface
    adc_dout   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    adc_eoc    : in  std_logic;
    soc        : out std_logic;
    tsen       : out std_logic;

    -- FIFO interface (write side)
    fifo_full  : in  std_logic;
    fifo_wdata : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    fifo_wen   : out std_logic
  );
end entity adc_controller;

architecture rtl of adc_controller is

  type state_t is (IDLE, START_CONV, WAIT_EOC, WRITE_FIFO);
  signal state, next_state : state_t;

  signal soc_reg    : std_logic := '0';
  signal fifo_wen_r : std_logic := '0';
  signal data_reg   : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

begin

  tsen <= '1';  -- temperature sensing mode always on

  -- next-state logic
  process(state, adc_eoc, fifo_full)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if fifo_full = '0' then
          next_state <= START_CONV;
        end if;

      when START_CONV =>
        -- single-cycle SOC pulse
        next_state <= WAIT_EOC;

      when WAIT_EOC =>
        if adc_eoc = '1' then
          next_state <= WRITE_FIFO;
        end if;

      when WRITE_FIFO =>
        next_state <= IDLE;

      when others =>
        next_state <= IDLE;
    end case;
  end process;

  -- state registers & outputs
  process(clk, rst_n)
  begin
    if rst_n = '0' then
      state      <= IDLE;
      soc_reg    <= '0';
      fifo_wen_r <= '0';
      data_reg   <= (others => '0');
    elsif rising_edge(clk) then
      state <= next_state;

      soc_reg    <= '0';
      fifo_wen_r <= '0';

      case state is
        when IDLE =>
          -- nothing

        when START_CONV =>
          soc_reg <= '1';

        when WAIT_EOC =>
          if adc_eoc = '1' then
            data_reg <= adc_dout;  -- latch ADC sample
          end if;

        when WRITE_FIFO =>
          fifo_wen_r <= '1';

        when others =>
          null;
      end case;
    end if;
  end process;

  soc        <= soc_reg;
  fifo_wdata <= data_reg;
  fifo_wen   <= fifo_wen_r;

end architecture rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity project3_top is
  port (
    clk_50     : in  std_logic;  -- 50 MHz main clock
    clk_10m    : in  std_logic;  -- 10 MHz clock for ADC (PLL output)
    rst_n      : in  std_logic;  -- global active-low reset

    HEX0       : out std_logic_vector(6 downto 0);
    HEX1       : out std_logic_vector(6 downto 0);
    HEX2       : out std_logic_vector(6 downto 0);
    HEX3       : out std_logic_vector(6 downto 0)
  );
end entity project3_top;

architecture rtl of project3_top is

  -- ADC signals
  signal adc_soc     : std_logic;
  signal adc_tsen    : std_logic;
  signal adc_dout    : std_logic_vector(11 downto 0);
  signal adc_eoc     : std_logic;
  signal adc_clk_slow: std_logic;  -- clk_dft from ADC (producer domain)

  -- FIFO signals
  signal fifo_full   : std_logic;
  signal fifo_empty  : std_logic;
  signal fifo_wdata  : std_logic_vector(11 downto 0);
  signal fifo_wen    : std_logic;
  signal fifo_rdata  : std_logic_vector(11 downto 0);
  signal fifo_ren    : std_logic;

  -- ADC channel selection constant (board-dependent)
  constant ADC_CH_TEMP : std_logic_vector(4 downto 0) := "00000";  -- adjust per docs

begin

  ---------------------------------------------------------------------------
  -- ADC instance (provided max10_adc wrapper / IP)
  ---------------------------------------------------------------------------
  adc_inst : entity work.max10_adc
    port map (
      pll_clk => clk_10m,      -- 10 MHz clock
      chsel   => ADC_CH_TEMP,  -- temperature channel (from board docs)
      soc     => adc_soc,
      tsen    => adc_tsen,
      dout    => adc_dout,
      eoc     => adc_eoc,
      clk_dft => adc_clk_slow
    );

  ---------------------------------------------------------------------------
  -- ADC controller FSM in producer (ADC) clock domain
  ---------------------------------------------------------------------------
  adc_ctrl_inst : entity work.adc_controller
    generic map (
      DATA_WIDTH => 12
    )
    port map (
      clk        => adc_clk_slow,
      rst_n      => rst_n,
      adc_dout   => adc_dout,
      adc_eoc    => adc_eoc,
      soc        => adc_soc,
      tsen       => adc_tsen,
      fifo_full  => fifo_full,
      fifo_wdata => fifo_wdata,
      fifo_wen   => fifo_wen
    );

  ---------------------------------------------------------------------------
  -- Asynchronous FIFO for clock-domain crossing
  ---------------------------------------------------------------------------
  fifo_inst : entity work.async_fifo
    generic map (
      DATA_WIDTH => 12,
      ADDR_WIDTH => 4      -- 16 entries
    )
    port map (
      wr_clk   => adc_clk_slow,
      wr_rst_n => rst_n,
      wr_en    => fifo_wen,
      wr_data  => fifo_wdata,
      full     => fifo_full,

      rd_clk   => clk_50,
      rd_rst_n => rst_n,
      rd_en    => fifo_ren,
      rd_data  => fifo_rdata,
      empty    => fifo_empty
    );

  ---------------------------------------------------------------------------
  -- Consumer logic in 50 MHz domain – shows latest sample on HEX displays
  ---------------------------------------------------------------------------
  consumer_inst : entity work.consumer_display
    generic map (
      DATA_WIDTH => 12
    )
    port map (
      clk_50     => clk_50,
      rst_n      => rst_n,
      fifo_empty => fifo_empty,
      fifo_rdata => fifo_rdata,
      fifo_ren   => fifo_ren,
      HEX0       => HEX0,
      HEX1       => HEX1,
      HEX2       => HEX2,
      HEX3       => HEX3
    );

end architecture rtl;

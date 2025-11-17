library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity consumer_display is
  generic (
    DATA_WIDTH : positive := 12
  );
  port (
    clk_50      : in  std_logic;
    rst_n       : in  std_logic;

    -- FIFO read side
    fifo_empty  : in  std_logic;
    fifo_rdata  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    fifo_ren    : out std_logic;

    -- 7-seg outputs
    HEX0        : out std_logic_vector(6 downto 0);
    HEX1        : out std_logic_vector(6 downto 0);
    HEX2        : out std_logic_vector(6 downto 0);
    HEX3        : out std_logic_vector(6 downto 0)
  );
end entity consumer_display;

architecture rtl of consumer_display is

  signal sample_reg : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');

  signal bcd_th    : std_logic_vector(3 downto 0);
  signal bcd_h     : std_logic_vector(3 downto 0);
  signal bcd_t     : std_logic_vector(3 downto 0);
  signal bcd_o     : std_logic_vector(3 downto 0);

begin

  -- Always read when not empty; show latest value
  fifo_ren <= not fifo_empty;

  process(clk_50, rst_n)
  begin
    if rst_n = '0' then
      sample_reg <= (others => '0');
    elsif rising_edge(clk_50) then
      if fifo_empty = '0' then
        sample_reg <= fifo_rdata;
      end if;
    end if;
  end process;

  -- Convert binary sample to BCD digits
  b2bcd_inst : entity work.bin_to_bcd_12bit
    port map (
      bin_in        => sample_reg(11 downto 0),
      bcd_thousands => bcd_th,
      bcd_hundreds  => bcd_h,
      bcd_tens      => bcd_t,
      bcd_ones      => bcd_o
    );

  -- 4 digits → 7-seg
  seg0 : entity work.seven_seg_decoder port map (nibble => bcd_o, seg => HEX0);
  seg1 : entity work.seven_seg_decoder port map (nibble => bcd_t, seg => HEX1);
  seg2 : entity work.seven_seg_decoder port map (nibble => bcd_h, seg => HEX2);
  seg3 : entity work.seven_seg_decoder port map (nibble => bcd_th, seg => HEX3);

end architecture rtl;

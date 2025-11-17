library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity async_fifo is
  generic (
    DATA_WIDTH : positive := 12;  -- ADC data width
    ADDR_WIDTH : positive := 4    -- depth = 2**ADDR_WIDTH (16)
  );
  port (
    -- write domain (producer / ADC)
    wr_clk   : in  std_logic;
    wr_rst_n : in  std_logic;
    wr_en    : in  std_logic;
    wr_data  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    full     : out std_logic;

    -- read domain (consumer / 50 MHz)
    rd_clk   : in  std_logic;
    rd_rst_n : in  std_logic;
    rd_en    : in  std_logic;
    rd_data  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    empty    : out std_logic
  );
end entity async_fifo;

architecture rtl of async_fifo is

  constant DEPTH : integer := 2**ADDR_WIDTH;

  type mem_t is array (0 to DEPTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal mem : mem_t;

  signal wr_ptr_bin, wr_ptr_bin_next : unsigned(ADDR_WIDTH downto 0) := (others => '0');
  signal rd_ptr_bin, rd_ptr_bin_next : unsigned(ADDR_WIDTH downto 0) := (others => '0');

  signal wr_ptr_gray, wr_ptr_gray_next : std_logic_vector(ADDR_WIDTH downto 0) := (others => '0');
  signal rd_ptr_gray, rd_ptr_gray_next : std_logic_vector(ADDR_WIDTH downto 0) := (others => '0');

  signal rd_ptr_gray_sync : std_logic_vector(ADDR_WIDTH downto 0);
  signal wr_ptr_gray_sync : std_logic_vector(ADDR_WIDTH downto 0);

  signal full_reg, full_next   : std_logic := '0';
  signal empty_reg, empty_next : std_logic := '1';

  -------------------------------------------------------------------------
  -- Local bin <-> gray functions
  -------------------------------------------------------------------------
  function bin2gray(b : unsigned) return std_logic_vector is
    variable g : std_logic_vector(b'range);
  begin
    g(b'left) := std_logic(b(b'left));
    for i in b'left - 1 downto b'right loop
      g(i) := std_logic(b(i+1) xor b(i));
    end loop;
    return g;
  end function bin2gray;

  function gray2bin(g : std_logic_vector) return unsigned is
    variable b : unsigned(g'range);
  begin
    b(g'left) := (g(g'left));
    for i in g'left - 1 downto g'right loop
      b(i) := b(i+1) xor unsigned(g(i downto i))(0);
    end loop;
    return b;
  end function gray2bin;

begin

  -------------------------------------------------------------------------
  -- Synchronize Gray pointers across domains
  -------------------------------------------------------------------------

  -- read pointer Gray into write clock domain
  sync_rdptr : entity work.sync_twoff
    generic map (WIDTH => ADDR_WIDTH + 1)
    port map (
      clk   => wr_clk,
      rst_n => wr_rst_n,
      din   => rd_ptr_gray,
      dout  => rd_ptr_gray_sync
    );

  -- write pointer Gray into read clock domain
  sync_wrptr : entity work.sync_twoff
    generic map (WIDTH => ADDR_WIDTH + 1)
    port map (
      clk   => rd_clk,
      rst_n => rd_rst_n,
      din   => wr_ptr_gray,
      dout  => wr_ptr_gray_sync
    );

  -------------------------------------------------------------------------
  -- Write side logic
  -------------------------------------------------------------------------

  process(wr_ptr_bin, wr_ptr_gray, wr_en, full_reg, rd_ptr_gray_sync, wr_data)
    variable ptr_bin_tmp  : unsigned(ADDR_WIDTH downto 0);
    variable ptr_gray_tmp : std_logic_vector(ADDR_WIDTH downto 0);
    variable full_v       : std_logic;
  begin
    ptr_bin_tmp  := wr_ptr_bin;
    if (wr_en = '1' and full_reg = '0') then
      ptr_bin_tmp := wr_ptr_bin + 1;
    end if;

    ptr_gray_tmp := bin2gray(ptr_bin_tmp);

    wr_ptr_bin_next  <= ptr_bin_tmp;
    wr_ptr_gray_next <= ptr_gray_tmp;

    -- Full condition:
    -- when write pointer is one cycle behind read pointer in Gray space with MSB inverted
    if (ptr_gray_tmp(ADDR_WIDTH downto ADDR_WIDTH-1) =
          not rd_ptr_gray_sync(ADDR_WIDTH downto ADDR_WIDTH-1) and
        ptr_gray_tmp(ADDR_WIDTH-2 downto 0) =
          rd_ptr_gray_sync(ADDR_WIDTH-2 downto 0)) then
      full_v := '1';
    else
      full_v := '0';
    end if;

    full_next <= full_v;
  end process;

  process(wr_clk, wr_rst_n)
    variable addr : integer;
  begin
    if wr_rst_n = '0' then
      wr_ptr_bin  <= (others => '0');
      wr_ptr_gray <= (others => '0');
      full_reg    <= '0';
    elsif rising_edge(wr_clk) then
      wr_ptr_bin  <= wr_ptr_bin_next;
      wr_ptr_gray <= wr_ptr_gray_next;
      full_reg    <= full_next;

      if (wr_en = '1' and full_reg = '0') then
        addr := to_integer(wr_ptr_bin(ADDR_WIDTH - 1 downto 0));
        mem(addr) <= wr_data;
      end if;
    end if;
  end process;

  full <= full_reg;

  -------------------------------------------------------------------------
  -- Read side logic
  -------------------------------------------------------------------------

  process(rd_ptr_bin, rd_ptr_gray, rd_en, empty_reg, wr_ptr_gray_sync)
    variable ptr_bin_tmp  : unsigned(ADDR_WIDTH downto 0);
    variable ptr_gray_tmp : std_logic_vector(ADDR_WIDTH downto 0);
    variable empty_v      : std_logic;
  begin
    ptr_bin_tmp := rd_ptr_bin;
    if (rd_en = '1' and empty_reg = '0') then
      ptr_bin_tmp := rd_ptr_bin + 1;
    end if;

    ptr_gray_tmp     := bin2gray(ptr_bin_tmp);
    rd_ptr_bin_next  <= ptr_bin_tmp;
    rd_ptr_gray_next <= ptr_gray_tmp;

    -- Empty when next read pointer equals synchronized write pointer
    if (ptr_gray_tmp = wr_ptr_gray_sync) then
      empty_v := '1';
    else
      empty_v := '0';
    end if;

    empty_next <= empty_v;
  end process;

  process(rd_clk, rd_rst_n)
    variable addr : integer;
  begin
    if rd_rst_n = '0' then
      rd_ptr_bin   <= (others => '0');
      rd_ptr_gray  <= (others => '0');
      empty_reg    <= '1';
      rd_data      <= (others => '0');
    elsif rising_edge(rd_clk) then
      rd_ptr_bin  <= rd_ptr_bin_next;
      rd_ptr_gray <= rd_ptr_gray_next;
      empty_reg   <= empty_next;

      if (rd_en = '1' and empty_reg = '0') then
        addr    := to_integer(rd_ptr_bin_next(ADDR_WIDTH - 1 downto 0));
        rd_data <= mem(addr);
      end if;
    end if;
  end process;

  empty <= empty_reg;

end architecture rtl;

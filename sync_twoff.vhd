library ieee;
use ieee.std_logic_1164.all;

entity sync_twoff is
  generic (
    WIDTH : positive := 1
  );
  port (
    clk    : in  std_logic;
    rst_n  : in  std_logic;  -- active low
    din    : in  std_logic_vector(WIDTH - 1 downto 0);
    dout   : out std_logic_vector(WIDTH - 1 downto 0)
  );
end entity sync_twoff;

architecture rtl of sync_twoff is
  signal q1, q2 : std_logic_vector(WIDTH - 1 downto 0);
begin
  process(clk, rst_n)
  begin
    if rst_n = '0' then
      q1 <= (others => '0');
      q2 <= (others => '0');
    elsif rising_edge(clk) then
      q1 <= din;
      q2 <= q1;
    end if;
  end process;

  dout <= q2;
end architecture rtl;

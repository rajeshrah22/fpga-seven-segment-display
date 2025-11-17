library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_to_bcd_12bit is
  port (
    bin_in       : in  std_logic_vector(11 downto 0);  -- 0..4095
    bcd_thousands: out std_logic_vector(3 downto 0);
    bcd_hundreds : out std_logic_vector(3 downto 0);
    bcd_tens     : out std_logic_vector(3 downto 0);
    bcd_ones     : out std_logic_vector(3 downto 0)
  );
end entity bin_to_bcd_12bit;

architecture rtl of bin_to_bcd_12bit is
  signal val       : integer range 0 to 4095;
  signal th, h, t, o : integer range 0 to 9;
begin
  val <= to_integer(unsigned(bin_in));

  th <= val / 1000;
  h  <= (val / 100) mod 10;
  t  <= (val / 10) mod 10;
  o  <= val mod 10;

  bcd_thousands <= std_logic_vector(to_unsigned(th, 4));
  bcd_hundreds  <= std_logic_vector(to_unsigned(h, 4));
  bcd_tens      <= std_logic_vector(to_unsigned(t, 4));
  bcd_ones      <= std_logic_vector(to_unsigned(o, 4));
end architecture rtl;

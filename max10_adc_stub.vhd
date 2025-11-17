library ieee;
use ieee.std_logic_1164.all;

entity max10_adc is
  port (
    pll_clk : in  std_logic;                         -- 10 MHz input
    chsel   : in  std_logic_vector(4 downto 0);      -- channel select
    soc     : in  std_logic;                         -- start of conversion
    tsen    : in  std_logic;                         -- temperature sense enable
    dout    : out std_logic_vector(11 downto 0);     -- 12-bit result
    eoc     : out std_logic;                         -- end of conversion
    clk_dft : out std_logic                          -- derived clock (slow domain)
  );
end entity max10_adc;

architecture blackbox of max10_adc is
begin
  -- Empty; actual implementation comes from device library / megafunction
end architecture blackbox;

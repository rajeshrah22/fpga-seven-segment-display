library ieee;
use ieee.std_logic_1164.all;

package seven_segment_pkg is
  type seven_segement_config is record
    a: std_logic;
    b: std_logic;
    c: std_logic;
    d: std_logic;
    e: std_logic;
    f: std_logic;
    g: std_logic;
  end record seven_segement_config;

  type seven_segment_array is array(natural range<>) of seven_segement_config;

  type lamp_configuration is (
    common_anode,
    common_cathode
  );

  subtype hex_digit is natural range 0 to 15;

  constant default_lamp_config: lamp_configuration := common_cathode;

  constant seven_segement_table: seven_segment_array := (
    0 => (
      a => '1',
      b => '1',
      c => '1',
      d => '1',
      e => '1',
      f => '1',
      g => '0'
    ),
    1 => (
      a => '0',
      b => '1',
      c => '1',
      d => '0',
      e => '0',
      f => '0',
      g => '0'
    ),
    2 => (
      a => '1',
      b => '1',
      c => '0',
      d => '1',
      e => '1',
      f => '0',
      g => '1'
    ),
    3 => (
      a => '1',
      b => '1',
      c => '1',
      d => '1',
      e => '0',
      f => '0',
      g => '1'
    ),
    4 => (
      a => '0',
      b => '1',
      c => '1',
      d => '0',
      e => '0',
      f => '1',
      g => '1'
    ),
    5 => (
      a => '1',
      b => '0',
      c => '1',
      d => '1',
      e => '0',
      f => '1',
      g => '1'
    ),
    6 => (
      a => '1',
      b => '0',
      c => '1',
      d => '1',
      e => '1',
      f => '1',
      g => '1'
    ),
    7 => (
      a => '1',
      b => '1',
      c => '1',
      d => '0',
      e => '0',
      f => '0',
      g => '1'
    ),
    8 => (
      a => '1',
      b => '1',
      c => '1',
      d => '1',
      e => '1',
      f => '1',
      g => '1'
    ),
    9 => (
      a => '1',
      b => '1',
      c => '1',
      d => '1',
      e => '0',
      f => '1',
      g => '1'
    ),
    10 => (
      a => '1',
      b => '1',
      c => '1',
      d => '1',
      e => '0',
      f => '1',
      g => '1'
    ),
    11 => (
      a => '0',
      b => '0',
      c => '1',
      d => '1',
      e => '1',
      f => '1',
      g => '1'
    ),
    12 => (
      a => '1',
      b => '0',
      c => '0',
      d => '1',
      e => '1',
      f => '1',
      g => '1'
    ),
    13 => (
      a => '0',
      b => '1',
      c => '1',
      d => '1',
      e => '1',
      f => '0',
      g => '1'
    ),
    14 => (
      a => '1',
      b => '0',
      c => '0',
      d => '1',
      e => '1',
      f => '1',
      g => '1'
    ),
    15 => (
      a => '1',
      b => '0',
      c => '0',
      d => '0',
      e => '1',
      f => '1',
      g => '1'
    )
  );

  function get_hex_digit (
    digit: in hex_digit;
    lamp_mode: in lamp_configuration := default_lamp_config
  ) return seven_segement_config;

  function lamps_off (
    lamp_mode: in lamp_configuration := default_lamp_config
  ) return seven_segement_config;
end package seven_segment_pkg;

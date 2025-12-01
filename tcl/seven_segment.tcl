set sseg_lamps {
  { C14, E15, C15, C16, E16, D17, C17, D15 }
  { C18, D18, E18, B16, A17, A18, B17, A16 }
  { B20, A20, B19, A21, B21, C22, B22, A19 }
  { F21, E22, E21, C19, C20, D19, E17, D22 }
  { F18, E20, E19, J18, H19, F19, F20, F17 }
  { J20, K20, L18, N18, M20, N19, N20, L19 }
}

proc set_pins { digits { name "hex_digit" } } {
  global sseg_lamps
  for { set i 0 } { ${i} < 6 } { incr i } {
    foreach lamp { a b c d e f g } {
      set location [ lindex [ lindex ${sseg_lamps} ${i} ] ${j} ]
      set_location_assignment PIN_${location} -to name\[${i}\].${lamp}
      set_instance_assignemt -name IO_STANDARD "3.3-V LVTTL" -to name\[${i}\].${lamp}
      incr j
    }
  }
}

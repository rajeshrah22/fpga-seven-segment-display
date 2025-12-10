# set instance assignemnt for clock
set_location_assignment PIN_N5 -to src_clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to src_clk

set_location_assignment PIN_P11 -to display_clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to display_clk

set_location_assignment PIN_B8 -to reset
set_instance_assignment -name IO_STANDARD "3.3 V SCHMITT TRIGGER" -to reset

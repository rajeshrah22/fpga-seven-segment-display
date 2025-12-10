# main 50 MHz clock
create_clock -period 20 [ get_ports { PIN_P11 } ]
create_clock -period 20 -name display_clk

# ADC 10 MHz clock
create_clock -period 100 [ get_ports { PIN_N5 } ]
create_clock -period 100 -name src_clk

# ADC derived clock
create_generated_clock -name adc_clk -source [ get_pins ??? ] \
-divide_by 10 -multiply_by 1 [ get_pins ??? ]

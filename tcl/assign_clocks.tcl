# main 50 MHz clock
create_clock -name main_clk -period "50 MHz" [ get_ports display_clk ]

# ADC 10 MHz clock
create_clock -period 100 [ get_ports src_clk ]

derive_pll_clocks

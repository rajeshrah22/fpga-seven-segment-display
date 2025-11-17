# ===============================
# Clocks
# ===============================

# 50 MHz main clock on port clk_50
create_clock -name clk50 -period 20.000 [get_ports {clk_50}]

# 10 MHz clock feeding ADC (PLL output) on port clk_10m
create_clock -name clk10m -period 100.000 [get_ports {clk_10m}]

# Derived ADC domain clock (from ADC block)
# If clk_dft is a divide-by-10 from 10 MHz → 1 MHz, adjust as needed.
# Replace u_adc with your ADC instance name if different.
create_generated_clock -name adc_clk_slow \
  -source [get_ports {clk_10m}] \
  -divide_by 10 \
  [get_pins {adc_inst|clk_dft}]

# ===============================
# I/O (example – you’ll need to add drive/load if required)
# ===============================

set_input_delay -clock clk50 5.0 [get_ports {rst_n}]
set_output_delay -clock clk50 5.0 [get_ports {HEX0[*] HEX1[*] HEX2[*] HEX3[*]}]

# ===============================
# (Optional) False paths / multi-cycle paths, if any
# For most async FIFO designs, we rely on 2-FF synchronizers and don't need
# extra false-path constraints if clocks are independent.
# ===============================

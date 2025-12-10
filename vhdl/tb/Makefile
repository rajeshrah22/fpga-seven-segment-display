FILES := \
../seven_segment_pkg.vhd \
../adc_fsm.vhd \
../bin_to_gray.vhd \
../Display_FSM.vhd \
../gray_to_bin.vhd \
../memory.vhd \
pll.vhd \
../sync.vhd \
max10_adc.vhd \
../seven_segment_display.vhd \
tb_toplevel.vhd

all: $(FILES)
	for f in $(FILES); do \
		ghdl analyze $$f; \
	done
	ghdl elaborate tb_toplevel

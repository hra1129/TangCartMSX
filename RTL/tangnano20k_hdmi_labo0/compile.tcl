#	Tangnano20k_hdmi_labo compile script
# =============================================================================
#	2024/12/15 t.hara
#

puts "Run compile Tangnano20k_hdmi_labo"

# =============================================================================
#	Add files
# =============================================================================
add_file src/cz80/cz80.v
add_file src/cz80/cz80_alu.v
add_file src/cz80/cz80_inst.v
add_file src/cz80/cz80_mcode.v
add_file src/cz80/cz80_reg.v
add_file src/sdram/ip_sdram_tangnano20k_c.v
add_file src/gowin_rpll/gowin_rpll.v
add_file src/gowin_clkdiv/gowin_clkdiv.v
add_file src/rom/ip_rom.v
add_file src/ram/ip_ram.v
add_file src/tangnano20k_hdmi_labo.v
add_file src/gpio/ip_gpio.v

# =============================================================================
#	Physical Constraints file
# =============================================================================
add_file src/tangnano20k_hdmi_labo.cst

# =============================================================================
#	Device name
# =============================================================================
set_device -device_version C GW2AR-LV18QN88C8/I7

# =============================================================================
#	Synsesis and Place/Route
# =============================================================================
set_option -top_module tangnano20k_hdmi_labo
set_option -gen_io_cst 1
set_option -output_base_name tangnano20k_hdmi_labo
set_option -looplimit 8000

puts "Start Synsesis"
run syn

puts "Start Place and Route"
run pnr

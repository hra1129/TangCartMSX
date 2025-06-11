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
add_file src/cz80/cz80_wrap.v
add_file src/ddr3_memory_interface/ddr3_memory_interface.v
add_file src/gowin_clkdiv2/gowin_clkdiv2.v
add_file src/gowin_rpll/gowin_rpll.v
add_file src/ram/ip_ram.v
add_file src/rom/ddr3_test_rom.v
add_file src/sdram/ip_sdram_tangprimer20k.v
add_file src/tangprimer20k_step3.v
add_file src/test_controller/test_controller.v
add_file src/uart/ip_uart.v
add_file src/uart/ip_uart_inst.v

# =============================================================================
#	Physical Constraints file
# =============================================================================
add_file src/tangprimer20k_step3.cst

# =============================================================================
#	Device name
# =============================================================================
set_device -device_version C GW2A-LV18PG256C8/I7

# =============================================================================
#	Synsesis and Place/Route
# =============================================================================
set_option -top_module tangprimer20k_step3
set_option -gen_io_cst 1
set_option -output_base_name tangprimer20k_step3
set_option -looplimit 20000

puts "Start Synsesis"
run syn

puts "Start Place and Route"
run pnr

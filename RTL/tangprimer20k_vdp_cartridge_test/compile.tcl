#	Tangprimer20k_vdp_cartridge_test compile script
# =============================================================================
#	2024/12/15 t.hara
#

puts "Run compile Tangprimer20k_vdp_cartridge_test"

# =============================================================================
#	Add files
# =============================================================================
add_file src/tangprimer20k_vdp_cartridge_test.v
add_file src/msx_slot/msx_slot.v
add_file src/test_controller/test_controller.v

# =============================================================================
#	Physical Constraints file
# =============================================================================
add_file src/tangprimer20k_vdp_cartridge_test.cst

# =============================================================================
#	Device name
# =============================================================================
set_device -device_version C GW2A-LV18PG256C8/I7

# =============================================================================
#	Synsesis and Place/Route
# =============================================================================
set_option -top_module tangprimer20k_vdp_cartridge_test
set_option -gen_io_cst 1
set_option -output_base_name tangprimer20k_vdp_cartridge_test
set_option -looplimit 20000

puts "Start Synsesis"
run syn

puts "Start Place and Route"
run pnr

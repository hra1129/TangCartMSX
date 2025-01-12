#	Tangnano20k_step7 compile script
# =============================================================================
#	2024/12/15 t.hara
#

puts "Run compile Tangnano20k_step7"

# =============================================================================
#	Add files
# =============================================================================
add_file ../modules/cz80/cz80.v
add_file ../modules/cz80/cz80_alu.v
add_file ../modules/cz80/cz80_inst.v
add_file ../modules/cz80/cz80_mcode.v
add_file ../modules/cz80/cz80_reg.v
add_file ../modules/micom_connect/micom_connect.v
add_file ../modules/sdram/ip_sdram_tangnano20k_c.v
add_file ../modules/megarom/scc/scc_channel_mixer.v
add_file ../modules/megarom/scc/scc_channel_volume.v
add_file ../modules/megarom/scc/scc_core.v
add_file ../modules/megarom/scc/scc_inst.v
add_file ../modules/megarom/scc/scc_ram.v
add_file ../modules/megarom/scc/scc_register.v
add_file ../modules/megarom/scc/scc_selector.v
add_file ../modules/megarom/scc/scc_tone_generator_5ch.v
add_file ../modules/megarom/megarom.v
add_file ../modules/megarom/megarom_wo_scc.v
add_file ../modules/secondary_slot/secondary_slot_inst.v
add_file ../modules/ssg/ssg.v
add_file ../modules/i2s_audio/i2s_audio.v
add_file ../modules/v9918/vdp.v
add_file ../modules/v9918/vdp_color_bus.v
add_file ../modules/v9918/vdp_color_decoder.v
add_file ../modules/v9918/vdp_double_buffer.v
add_file ../modules/v9918/vdp_graphic123m.v
add_file ../modules/v9918/vdp_inst.v
add_file ../modules/v9918/vdp_interrupt.v
add_file ../modules/v9918/vdp_lcd.v
add_file ../modules/v9918/vdp_ram_256byte.v
add_file ../modules/v9918/vdp_ram_line_buffer.v
add_file ../modules/v9918/vdp_register.v
add_file ../modules/v9918/vdp_spinforam.v
add_file ../modules/v9918/vdp_sprite.v
add_file ../modules/v9918/vdp_ssg.v
add_file ../modules/v9918/vdp_text12.v
add_file ../modules/v9918/vdp_wait_control.v
add_file ../modules/ppi/ppi.v
add_file ../modules/ppi/ppi_inst.v
add_file src/gowin_pll/gowin_pll.v
add_file src/ram/ip_ram.v
add_file src/rom/ip_hello_world_rom.v
add_file src/tangnano20k_step7.v
add_file src/uart/ip_uart.v
add_file src/uart/ip_uart_inst.v

# =============================================================================
#	Physical Constraints file
# =============================================================================
add_file src/tangnano20k_step7.cst

# =============================================================================
#	Device name
# =============================================================================
set_device -device_version C GW2AR-LV18QN88C8/I7

# =============================================================================
#	Synsesis and Place/Route
# =============================================================================
set_option -top_module tangnano20k_step7
set_option -gen_io_cst 1
set_option -output_base_name tangnano20k_step7
set_option -looplimit 5000

puts "Start Synsesis"
run syn

puts "Start Place and Route"
run pnr

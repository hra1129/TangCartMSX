onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/timing
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_register/vdp_mode_graphic1
add wave -noupdate -radix binary /tb/u_vdp/u_v9918_core/u_vdp_graphic123m/dot_state
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9918_core/u_vdp_graphic123m/eight_dot_state
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9918_core/u_vdp_graphic123m/dot_counter_x
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_name_address
add wave -noupdate -radix hexadecimal -childformat {{{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[13]} -radix hexadecimal} {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[12]} -radix hexadecimal} {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[11]} -radix hexadecimal} {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[10]} -radix hexadecimal} {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[9]} -radix hexadecimal} {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[8]} -radix hexadecimal} {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[7]} -radix hexadecimal} {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[6]} -radix hexadecimal} {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[5]} -radix hexadecimal} {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[4]} -radix hexadecimal} {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[3]} -radix hexadecimal} {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[2]} -radix hexadecimal} {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[1]} -radix hexadecimal} {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[0]} -radix hexadecimal}} -subitemconfig {{/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[13]} {-height 15 -radix hexadecimal} {/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[12]} {-height 15 -radix hexadecimal} {/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[11]} {-height 15 -radix hexadecimal} {/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[10]} {-height 15 -radix hexadecimal} {/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[9]} {-height 15 -radix hexadecimal} {/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[8]} {-height 15 -radix hexadecimal} {/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[7]} {-height 15 -radix hexadecimal} {/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[6]} {-height 15 -radix hexadecimal} {/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[5]} {-height 15 -radix hexadecimal} {/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[4]} {-height 15 -radix hexadecimal} {/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[3]} {-height 15 -radix hexadecimal} {/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[2]} {-height 15 -radix hexadecimal} {/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[1]} {-height 15 -radix hexadecimal} {/tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address[0]} {-height 15 -radix hexadecimal}} /tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_pattern_generator_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9918_core/u_vdp_graphic123m/w_color_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9918_core/u_vdp_graphic123m/ff_vram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9918_core/p_dram_oe_n
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9918_core/p_dram_address
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9918_core/p_dram_rdata
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9918_core/u_vdp_graphic123m/ff_ram_dat
add wave -noupdate -radix hexadecimal /tb/u_vdp/u_v9918_core/u_vdp_graphic123m/ff_pre_pattern_num
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_register/reg_r0_disp_mode
add wave -noupdate /tb/u_vdp/u_v9918_core/u_vdp_register/reg_r1_disp_mode
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {552809 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 312
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {550969 ns} {552877 ns}

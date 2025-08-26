; =============================================================================
;	V9958 software test program
; -----------------------------------------------------------------------------
;	Programmed by t.hara (HRA!)
; =============================================================================

			org		0x100

start:
			; 準備
			call	vdp_io_select
			call	copy_rom_font
			; テスト
			call	screen5
			call	test001
			call	test002
			call	test003
			call	test004

			call	test005
			call	test006
			call	test007
			call	test008

			call	test009
			call	test010
			call	test011
			call	test012

			call	test013
			call	test014
			call	test015
			call	test016

			call	test017
			call	test018
			call	test019
			call	test020

			call	test021
			call	test022
			call	test023
			call	test024

			call	test025
			call	test026
			call	test027
			call	test028

			call	test029
			call	test030
			call	test031
			call	test032
			; 後始末
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include		"lib.asm"

; =============================================================================
;	SCREEN5
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen5
screen5::
			; R#0 = 0x0E
			ld		a, 0x06
			ld		e, 0
			call	write_control_register
			; R#1 = 0x40
			ld		a, 0x40
			ld		e, 1
			call	write_control_register
			; R#7 = 0x07
			ld		a, 0x07					; 周辺色 7
			ld		e, 7
			call	write_control_register
			; R#8 = 0x02
			ld		a, 0x0A					; スプライト非表示
			ld		e, 8
			call	write_control_register
			; R#9 = 0x80
			ld		a, 0x80					; 212line
			ld		e, 9
			call	write_control_register
			; Pattern Name Table R#2 = 0b0pp11111 : p = page
			ld		a, 0b00011111
			ld		e, 2
			call	write_control_register
			; Sprite Attribute Table
			ld		hl, 0x7A00
			call	set_sprite_attribute_table
			; Sprite Pattern Generator Table
			ld		hl, 0x7000
			call	set_sprite_pattern_generator_table
			; Pattern Name Table をクリア
			xor		a, a
			ld		[vram_bit16], a
			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x44
			call	fill_vram

			ld		hl, 0x8000
			ld		d, 0
			ld		bc, 128 * 212
			ld		e, 0x55
			call	fill_vram

			ld		a, 1
			ld		[vram_bit16], a
			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x88
			call	fill_vram

			ld		hl, 0x8000
			ld		d, 1
			ld		bc, 128 * 212
			ld		e, 0x99
			call	fill_vram

			call	wait_push_space_key
			ret
			endscope

; =============================================================================
;	LINE
;	input:
;		cmd_xxxx .... パラメータ
;	output:
;		none
;	break:
;		AF BC DE HL
;	comment:
;		none
; =============================================================================
			scope	line
line::
			ld		a, [cmd_exec]
			and		a, 0x0F
			or		a, 0x70
			ld		[cmd_exec], a

			ld		a, 32
			ld		e, 17
			call	write_control_register

			ld		a, [io_vdp_port3]
			ld		c, a
			ld		hl, cmd_sx
			ld		b, 15
			otir
			ret
			endscope

; =============================================================================
			scope	test001
test001::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, 10
			ld		[cmd_dx], hl
			ld		hl, 11
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 15
			ld		[cmd_color], a
			ld		a, 0x00
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test002
test002::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, 11
			ld		[cmd_dx], hl
			ld		hl, 10
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 12
			ld		[cmd_color], a
			ld		a, 0x00
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test003
test003::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, 10
			ld		[cmd_dx], hl
			ld		hl, 10
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 13
			ld		[cmd_color], a
			ld		a, 0x00
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test004
test004::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, 11
			ld		[cmd_dx], hl
			ld		hl, 11
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 6
			ld		[cmd_color], a
			ld		a, 0x00
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test005
test005::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, 20
			ld		[cmd_dx], hl
			ld		hl, 11
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 15
			ld		[cmd_color], a
			ld		a, 0x04
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test006
test006::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, 21
			ld		[cmd_dx], hl
			ld		hl, 10
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 12
			ld		[cmd_color], a
			ld		a, 0x04
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test007
test007::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, 20
			ld		[cmd_dx], hl
			ld		hl, 10
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 13
			ld		[cmd_color], a
			ld		a, 0x04
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test008
test008::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, 21
			ld		[cmd_dx], hl
			ld		hl, 11
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 6
			ld		[cmd_color], a
			ld		a, 0x04
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test009
test009::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, 30
			ld		[cmd_dx], hl
			ld		hl, 11
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 15
			ld		[cmd_color], a
			ld		a, 0x08
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test010
test010::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, 31
			ld		[cmd_dx], hl
			ld		hl, 10
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 12
			ld		[cmd_color], a
			ld		a, 0x08
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test011
test011::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, 30
			ld		[cmd_dx], hl
			ld		hl, 10
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 13
			ld		[cmd_color], a
			ld		a, 0x08
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test012
test012::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, 31
			ld		[cmd_dx], hl
			ld		hl, 11
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 6
			ld		[cmd_color], a
			ld		a, 0x08
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test013
test013::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 11
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 15
			ld		[cmd_color], a
			ld		a, 0x0C
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test014
test014::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, 41
			ld		[cmd_dx], hl
			ld		hl, 10
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 12
			ld		[cmd_color], a
			ld		a, 0x0C
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test015
test015::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 10
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 13
			ld		[cmd_color], a
			ld		a, 0x0C
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test016
test016::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, 41
			ld		[cmd_dx], hl
			ld		hl, 11
			ld		[cmd_dy], hl
			ld		hl, 0
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 6
			ld		[cmd_color], a
			ld		a, 0x0C
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
; =============================================================================
			scope	test017
test017::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 15
			ld		[cmd_color], a
			ld		a, 0x00
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test018
test018::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 5
			ld		[cmd_ny], hl
			ld		a, 12
			ld		[cmd_color], a
			ld		a, 0x00
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test019
test019::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 10
			ld		[cmd_ny], hl
			ld		a, 13
			ld		[cmd_color], a
			ld		a, 0x00
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test020
test020::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 5
			ld		[cmd_ny], hl
			ld		a, 6
			ld		[cmd_color], a
			ld		a, 0x01
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test021
test021::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 15
			ld		[cmd_color], a
			ld		a, 0x05
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test022
test022::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 5
			ld		[cmd_ny], hl
			ld		a, 12
			ld		[cmd_color], a
			ld		a, 0x05
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test023
test023::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 10
			ld		[cmd_ny], hl
			ld		a, 13
			ld		[cmd_color], a
			ld		a, 0x04
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test024
test024::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 5
			ld		[cmd_ny], hl
			ld		a, 6
			ld		[cmd_color], a
			ld		a, 0x04
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test025
test025::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 15
			ld		[cmd_color], a
			ld		a, 0x0C
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test026
test026::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 5
			ld		[cmd_ny], hl
			ld		a, 12
			ld		[cmd_color], a
			ld		a, 0x0C
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test027
test027::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 10
			ld		[cmd_ny], hl
			ld		a, 13
			ld		[cmd_color], a
			ld		a, 0x0C
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test028
test028::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 5
			ld		[cmd_ny], hl
			ld		a, 6
			ld		[cmd_color], a
			ld		a, 0x0D
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test029
test029::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 0
			ld		[cmd_ny], hl
			ld		a, 15
			ld		[cmd_color], a
			ld		a, 0x09
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test030
test030::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 5
			ld		[cmd_ny], hl
			ld		a, 12
			ld		[cmd_color], a
			ld		a, 0x09
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test031
test031::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 10
			ld		[cmd_ny], hl
			ld		a, 13
			ld		[cmd_color], a
			ld		a, 0x08
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	test032
test032::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, 40
			ld		[cmd_dx], hl
			ld		hl, 40
			ld		[cmd_dy], hl
			ld		hl, 10
			ld		[cmd_nx], hl
			ld		hl, 5
			ld		[cmd_ny], hl
			ld		a, 6
			ld		[cmd_color], a
			ld		a, 0x08
			ld		[cmd_arg], a
			call	line
			call	wait_command
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	vdp_command
cmd_sx::
			dw		0
cmd_sy::
			dw		0
cmd_dx::
			dw		0
cmd_dy::
			dw		0
cmd_nx::
			dw		0
cmd_ny::
			dw		0
cmd_color::
			db		0
cmd_arg::
			db		0
cmd_exec::
			db		0
			endscope

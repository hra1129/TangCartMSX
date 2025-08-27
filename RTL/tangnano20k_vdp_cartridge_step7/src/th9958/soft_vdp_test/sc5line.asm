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

			call	test033
			call	test034
			call	test035
			call	test036

			call	test037
			call	test038
			call	test039
			call	test040

			call	test041
			call	test042
			call	test043
			call	test044

			call	test045
			call	test046
			call	test047
			call	test048

			call	test049
			call	test050
			call	test051
			call	test052

			call	test053
			call	test054
			call	test055
			call	test056

			call	test057
			call	test058
			call	test059
			call	test060

			call	test061
			call	test062
			call	test063
			call	test064

			call	test065
			call	test066
			call	test067
			call	test068

			call	test069
			call	test070
			call	test071
			call	test072

			call	test073
			call	test074
			call	test075
			call	test076

			call	test077
			call	test078
			call	test079
			call	test080

			call	test081
			call	test082
			call	test083
			call	test084
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
			scope	test001
test001::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		10			; DX
			dw		11			; DY
			dw		0			; NX
			dw		0			; NY
			db		15			; CLR
			db		0			; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test002
test002::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		11			; DX
			dw		10			; DY
			dw		0			; NX
			dw		0			; NY
			db		12			; CLR
			db		0			; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test003
test003::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		10			; DX
			dw		10			; DY
			dw		0			; NX
			dw		0			; NY
			db		13			; CLR
			db		0			; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test004
test004::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		11			; DX
			dw		11			; DY
			dw		0			; NX
			dw		0			; NY
			db		6			; CLR
			db		0			; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test005
test005::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		20			; DX
			dw		11			; DY
			dw		0			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test006
test006::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		21			; DX
			dw		10			; DY
			dw		0			; NX
			dw		0			; NY
			db		12			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test007
test007::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		20			; DX
			dw		10			; DY
			dw		0			; NX
			dw		0			; NY
			db		13			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test008
test008::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		21			; DX
			dw		11			; DY
			dw		0			; NX
			dw		0			; NY
			db		6			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test009
test009::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		30			; DX
			dw		11			; DY
			dw		0			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test010
test010::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		31			; DX
			dw		10			; DY
			dw		0			; NX
			dw		0			; NY
			db		12			; CLR
			db		0x08		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test011
test011::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		30			; DX
			dw		10			; DY
			dw		0			; NX
			dw		0			; NY
			db		13			; CLR
			db		0x08		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test012
test012::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		31			; DX
			dw		11			; DY
			dw		0			; NX
			dw		0			; NY
			db		6			; CLR
			db		0x08		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test013
test013::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		11			; DY
			dw		0			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test014
test014::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		41			; DX
			dw		10			; DY
			dw		0			; NX
			dw		0			; NY
			db		12			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test015
test015::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		10			; DY
			dw		0			; NX
			dw		0			; NY
			db		13			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test016
test016::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		41			; DX
			dw		11			; DY
			dw		0			; NX
			dw		0			; NY
			db		6			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
; =============================================================================
			scope	test017
test017::
			ld		a, 2
			ld		e, 7
			call	write_control_register
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x00		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test018
test018::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x00		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test019
test019::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x00		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test020
test020::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x01		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test021
test021::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x05		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test022
test022::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x05		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test023
test023::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test024
test024::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test025
test025::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test026
test026::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test027
test027::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test028
test028::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x0D		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test029
test029::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x09		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test030
test030::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x09		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test031
test031::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x08		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test032
test032::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		40			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x08		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
; =============================================================================
			scope	test033
test033::
			ld		a, 2
			ld		e, 7
			call	write_control_register
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x00		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test034
test034::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x00		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test035
test035::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x00		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test036
test036::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x01		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test037
test037::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x05		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test038
test038::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x05		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test039
test039::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test040
test040::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test041
test041::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test042
test042::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test043
test043::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test044
test044::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x0D		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test045
test045::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x09		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test046
test046::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x09		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test047
test047::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x08		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test048
test048::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		81			; DX
			dw		40			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x08		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
; =============================================================================
			scope	test049
test049::
			ld		a, 2
			ld		e, 7
			call	write_control_register
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x00		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test050
test050::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x00		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test051
test051::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x00		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test052
test052::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x01		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test053
test053::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x05		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test054
test054::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x05		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test055
test055::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test056
test056::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test057
test057::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test058
test058::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test059
test059::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test060
test060::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x0D		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test061
test061::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x09		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test062
test062::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x09		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test063
test063::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x08		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test064
test064::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x08		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
; =============================================================================
			scope	test065
test065::
			ld		a, 2
			ld		e, 7
			call	write_control_register
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x00		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test066
test066::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x00		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test067
test067::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x00		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test068
test068::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x01		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test069
test069::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x05		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test070
test070::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x05		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test071
test071::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test072
test072::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test073
test073::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test074
test074::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test075
test075::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test076
test076::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x0D		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test077
test077::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		0			; NY
			db		15			; CLR
			db		0x09		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test078
test078::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		12			; CLR
			db		0x09		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test079
test079::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		10			; NY
			db		13			; CLR
			db		0x08		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test080
test080::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		161			; DX
			dw		41			; DY
			dw		10			; NX
			dw		5			; NY
			db		6			; CLR
			db		0x08		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
; =============================================================================
			scope	test081
test081::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		0			; DX
			dw		80			; DY
			dw		255			; NX
			dw		19			; NY
			db		15			; CLR
			db		0x00		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test082
test082::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		0			; DX
			dw		120			; DY
			dw		255			; NX
			dw		19			; NY
			db		12			; CLR
			db		0x08		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test083
test083::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		255			; DX
			dw		80			; DY
			dw		255			; NX
			dw		19			; NY
			db		13			; CLR
			db		0x04		; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	test084
test084::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		255			; DX
			dw		120			; DY
			dw		255			; NX
			dw		19			; NY
			db		6			; CLR
			db		0x0C		; ARG
			db		0x70		; CMD (LINE)
			endscope

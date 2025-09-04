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
			di
			call	screen5
			call	s5_load_image
			call	s5_vscroll
			call	s5_hscroll
			call	s5_display_adjust

			call	screen6
			call	s6_vscroll
			call	s6_hscroll
			call	s6_display_adjust

			call	screen7
			call	s7_vscroll
			call	s7_hscroll
			call	s7_display_adjust

			call	screen8
			call	s8_vscroll
			call	s8_hscroll
			call	s8_display_adjust
			ei
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
			ld		a, 0x02					; スプライト非表示
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
			ld		hl, 0x0000
			ld		bc, 128 * 212
			call	fill_random
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x00
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x11
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x22
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x33
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x44
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x55
			call	fill_vram
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
;	SCREEN6
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen6
screen6::
			; R#0 = 0x08
			ld		a, 0x08
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
			ld		a, 0x02					; スプライト非表示
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
			ld		hl, 0x0000
			ld		bc, 128 * 212
			call	fill_random
			ret
			endscope

; =============================================================================
;	SCREEN7
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen7
screen7::
			; R#0 = 0x0A
			ld		a, 0x0A
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
			ld		a, 0x02					; スプライト非表示
			ld		e, 8
			call	write_control_register
			; R#9 = 0x80
			ld		a, 0x80					; 212line
			ld		e, 9
			call	write_control_register
			; Pattern Name Table R#2 = 0b00p11111 : p = page
			ld		a, 0b00011111
			ld		e, 2
			call	write_control_register
			; Sprite Attribute Table
			ld		hl, 0xFA00
			call	set_sprite_attribute_table
			; Sprite Pattern Generator Table
			ld		hl, 0xF000
			call	set_sprite_pattern_generator_table
			; Pattern Name Table をクリア
			ld		hl, 0x0000
			ld		bc, 256 * 212
			call	fill_random
			ret
			endscope

; =============================================================================
;	SCREEN8
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen8
screen8::
			; R#0 = 0x0E
			ld		a, 0x0E
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
			ld		a, 0x02					; スプライト非表示
			ld		e, 8
			call	write_control_register
			; R#9 = 0x80
			ld		a, 0x80					; 212line
			ld		e, 9
			call	write_control_register
			; Pattern Name Table R#2 = 0b00p11111 : p = page
			ld		a, 0b00011111
			ld		e, 2
			call	write_control_register
			; Sprite Attribute Table
			ld		hl, 0xFA00
			call	set_sprite_attribute_table
			; Sprite Pattern Generator Table
			ld		hl, 0xF000
			call	set_sprite_pattern_generator_table
			; Pattern Name Table をクリア
			ld		hl, 0x0000
			ld		bc, 256 * 212
			call	fill_random
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 256 * 212
			ld		e, 0x00
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 256 * 212
			ld		e, 0x11
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 256 * 212
			ld		e, 0x22
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 256 * 212
			ld		e, 0x33
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 256 * 212
			ld		e, 0x44
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 256 * 212
			ld		e, 0x55
			call	fill_vram
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
;	[SCREEN5] 垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s5_vscroll
s5_vscroll::
			jp		vscroll
			endscope

; =============================================================================
;	[SCREEN6] 垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s6_vscroll
s6_vscroll::
			jp		vscroll
			endscope

; =============================================================================
;	[SCREEN7] 垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s7_vscroll
s7_vscroll::
			jp		vscroll
			endscope

; =============================================================================
;	[SCREEN8] 垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s8_vscroll
s8_vscroll::
			jp		vscroll
			endscope

; =============================================================================
;	[SCREEN5] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s5_hscroll
s5_hscroll::
			jp		hscroll
			endscope

; =============================================================================
;	[SCREEN6] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s6_hscroll
s6_hscroll::
			jp		hscroll
			endscope

; =============================================================================
;	[SCREEN7] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s7_hscroll
s7_hscroll::
			jp		hscroll
			endscope

; =============================================================================
;	[SCREEN8] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s8_hscroll
s8_hscroll::
			jp		hscroll
			endscope

; =============================================================================
;	[SCREEN5] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s5_display_adjust
s5_display_adjust::
			jp		display_adjust
			endscope

; =============================================================================
;	[SCREEN6] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s6_display_adjust
s6_display_adjust::
			jp		display_adjust
			endscope

; =============================================================================
;	[SCREEN7] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s7_display_adjust
s7_display_adjust::
			jp		display_adjust
			endscope

; =============================================================================
;	[SCREEN8] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s8_display_adjust
s8_display_adjust::
			jp		display_adjust
			endscope

; =============================================================================
;	[SCREEN5] load screen5 image
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s5_load_image
s5_load_image::

			ld		hl, small_image			; 転送元
			ld		de, 0					; 転送先
			ld		c, 16
	y_loop:
			ld		b, 16
	x_loop:
			push	bc
			push	hl
			push	de
			ld		bc, 8
			call	block_copy
			ld		bc, 8
			pop		hl						; 転送先
			add		hl, bc					; +8
			ex		de, hl
			pop		hl						; 転送元
			pop		bc
			djnz	x_loop

			push	bc
			ld		bc, 8
			add		hl, bc
			pop		bc
			dec		c
			jr		nz, y_loop
			call	wait_push_space_key
			ret

	small_image:
			db		0x00,0x11,0x11,0x11,0x10,0x00,0x00,0x00		;	0
			db		0x01,0xFF,0xFF,0xFF,0xF1,0x10,0x00,0x00		;	1
			db		0x01,0x11,0x11,0x1F,0xFF,0xF1,0x00,0x00		;	2
			db		0x1F,0xFF,0xFF,0xFF,0xFF,0xFF,0x10,0x00		;	3
			db		0x01,0x11,0x1F,0xFF,0xFF,0x1F,0x10,0x00		;	4
			db		0x00,0x01,0xFF,0xFF,0xFF,0x1F,0xF1,0x00		;	5
			db		0x00,0x1F,0xFF,0xFF,0xDD,0xDF,0xF1,0x00		;	6
			db		0x00,0x1F,0xFF,0xFF,0xFF,0xFF,0xF1,0x00		;	7
			db		0x01,0x1F,0xF1,0xFF,0xFF,0xFF,0xF1,0x00		;	8
			db		0x1F,0xFF,0x1F,0xFF,0xFF,0xFF,0xF1,0x00		;	9
			db		0x1F,0xFF,0x1F,0xF1,0xFF,0xFF,0xF1,0x00		;	A
			db		0x01,0xFF,0xF1,0x1F,0xFF,0xFF,0x11,0x10		;	B
			db		0x1F,0x1F,0xFF,0xFF,0xFF,0xF1,0x1F,0xF1		;	C
			db		0x1F,0xF1,0x1F,0xFF,0xF1,0x1F,0xFF,0x10		;	D
			db		0x01,0xFF,0xF1,0x11,0x1F,0xFF,0x11,0x00		;	E
			db		0x00,0x11,0x10,0x00,0x01,0x11,0x00,0x00		;	F
			endscope

; =============================================================================
;	Workarea
; =============================================================================
fcb::
			ds		37

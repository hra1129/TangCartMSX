; =============================================================================
;	V9958 software test program
; -----------------------------------------------------------------------------
;	Programmed by t.hara (HRA!)
; =============================================================================

			org		0x100

font_ptr		:= 0x0004
bdos			:= 0x0005
calslt			:= 0x001C
enaslt			:= 0x0024
rom_version		:= 0x002D
chgmod			:= 0x005F
gttrig			:= 0x00D8
kilbuf			:= 0x0156
chgcpu			:= 0x0180

command_line	:= 0x005D
ramad0			:= 0xF341
ramad1			:= 0xF342
ramad2			:= 0xF343
ramad3			:= 0xF344
main_rom_slot	:= 0xFCC1

vdp_port0		:= 0x98
vdp_port1		:= 0x99
vdp_port2		:= 0x9A
vdp_port3		:= 0x9B

font_data		:= 0x8000

func_term		:= 0x00

start:
			; 準備
			call	vdp_io_select
			call	copy_rom_font
			; テスト
			call	screen5
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

			; 後始末
			call	clear_key_buffer
			ld		c, func_term
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
			ld		hl, 0x3A00
			call	set_sprite_attribute_table
			; Sprite Pattern Generator Table
			ld		hl, 0x3000
			call	set_sprite_pattern_generator_table
			; Pattern Name Table をクリア
			ld		hl, 0x0000
			ld		bc, 128 * 212
			call	fill_increment
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
			ld		hl, 0x3A00
			call	set_sprite_attribute_table
			; Sprite Pattern Generator Table
			ld		hl, 0x3000
			call	set_sprite_pattern_generator_table
			; Pattern Name Table をクリア
			ld		hl, 0x0000
			ld		bc, 128 * 212
			call	fill_increment
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
			call	fill_increment
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
			call	fill_increment
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

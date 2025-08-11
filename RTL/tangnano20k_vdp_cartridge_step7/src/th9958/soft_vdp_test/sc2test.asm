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
			call	screen2
			call	s2_vscroll
			call	s2_hscroll
			call	s2_display_adjust
			; 後始末
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include "lib.asm"

; =============================================================================
;	SCREEN2
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen2
screen2::
			; R#0 = 0x02
			ld		a, 2
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
			; Pattern Name Table
			ld		hl, 0x1800
			call	set_pattern_name_table
			; Color Table
			ld		hl, 0x2000
			call	set_color_table
			; Sprite Attribute Table
			ld		hl, 0x1B00
			call	set_sprite_attribute_table
			; Sprite Pattern Generator Table
			ld		hl, 0x3800
			call	set_sprite_pattern_generator_table
			; Pattern Generator Table
			ld		hl, 0x0000
			call	set_pattern_generator_table
			; Pattern Name Table をクリア
			ld		hl, 0x1800
			ld		bc, 32 * 26
			call	fill_increment
			; Font をセット
			ld		hl, 0x0000
			call	set_font
			ld		hl, 0x0800
			call	set_font
			ld		hl, 0x1000
			call	set_font
			; Fontの色をセット
			ld		hl, font_color
			ld		de, 0x2000
			ld		bc, 8
			xor		a, a
	loop:
			push	af
			push	de
			push	bc
			ld		hl, font_color
			call	block_copy
			pop		bc
			pop		hl
			add		hl, bc
			ex		de, hl
			pop		af
			dec		a
			jr		nz, loop
			ret
	font_color:
			db		0xFC, 0xFC, 0x72, 0x72, 0x53, 0x53, 0x4A, 0x4A
			endscope

; =============================================================================
;	[SCREEN2] 垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s2_vscroll
s2_vscroll::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		vscroll
	s_message:
			db		"[S2] V-SCROLL TEST ", 0
			endscope

; =============================================================================
;	[SCREEN2] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s2_hscroll
s2_hscroll::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		hscroll
	s_message:
			db		"[S2] H-SCROLL TEST ", 0
			endscope

; =============================================================================
;	[SCREEN2] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s2_display_adjust
s2_display_adjust::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		display_adjust
	s_message:
			db		"[S2] DISPLAY ADJUST TEST ", 0
			endscope

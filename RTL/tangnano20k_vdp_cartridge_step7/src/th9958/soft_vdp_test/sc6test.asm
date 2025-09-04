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
			call	screen6
			call	s6_vscroll
			call	s6_hscroll
			call	s6_display_adjust
			ei
			; 後始末
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include		"lib.asm"

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

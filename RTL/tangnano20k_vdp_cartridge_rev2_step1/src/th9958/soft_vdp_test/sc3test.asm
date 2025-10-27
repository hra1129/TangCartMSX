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
			call	screen3
			call	s3_vscroll
			call	s3_hscroll
			call	s3_display_adjust
			ei
			; 後始末
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include "lib.asm"

; =============================================================================
;	SCREEN3
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen3
screen3::
			; R#0 = 0x00
			xor		a, a
			ld		e, a
			call	write_control_register
			; R#1 = 0x48
			ld		a, 0x48
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
			ld		hl, 0x0800
			call	set_pattern_name_table
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
			ld		hl, 0x0800
			ld		bc, 32 * 26
			call	fill_increment
			; 色をセット
			ld		hl, 0x0000
			ld		bc, 256 * 8
			call	fill_increment
			ret
			endscope

; =============================================================================
;	[SCREEN3] 垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s3_vscroll
s3_vscroll::
			jp		vscroll
			endscope

; =============================================================================
;	[SCREEN3] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s3_hscroll
s3_hscroll::
			jp		hscroll
			endscope

; =============================================================================
;	[SCREEN3] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s3_display_adjust
s3_display_adjust::
			jp		display_adjust
			endscope

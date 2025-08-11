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
			call	screen1
			call	s1_font_test
			call	s1_color
			call	s1_palette
			call	s1_vscroll
			call	s1_hscroll
			call	s1_display_adjust
			call	s1_interlace
			; 後始末
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include "lib.asm"

; =============================================================================
;	SCREEN1
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen1
screen1::
			; R#0 = 0
			xor		a, a
			ld		e, a
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
			ld		e, ' '
			call	fill_vram
			; Font をセット
			ld		hl, 0x0000
			call	set_font
			; Fontの色をセット
			ld		hl, 0x2000
			ld		bc, 256 / 8
			ld		e, 0xF4
			call	fill_vram
			ret
			endscope

; =============================================================================
;	[SCREEN1] 文字フォントが期待通りに表示される・32桁、24行表示される
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s1_font_test
s1_font_test::
			; Pattern Name Table にインクリメントデータを敷き詰める
			ld		hl, 0x1800
			ld		bc, 32 * 24
			call	fill_increment
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			; キー待ち
			call	wait_push_space_key
			ret
	s_message:
			db		"[S1] FONT TEST ", 0
			endscope

; =============================================================================
;	[SCREEN1] 文字の色を変える
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s1_color
s1_color::
			; Pattern Name Table にインクリメントデータを敷き詰める
			ld		hl, 0x1800
			ld		bc, 32 * 24
			call	fill_increment
			; 色データをコピー
			ld		hl, color_table
			ld		de, 0x2000
			ld		bc, 32
			call	block_copy
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			; キー待ち
			call	wait_push_space_key
			ret
	color_table:
			db		0xF4, 0xE5, 0xF6, 0xE7, 0xF2, 0xE3, 0x17, 0x71
			db		0xBC, 0x23, 0xF8, 0x7F, 0xF3, 0xD4, 0x27, 0x72
			db		0xA6, 0x45, 0xE9, 0xF7, 0xE2, 0xB5, 0x37, 0x73
			db		0xB4, 0x68, 0xE6, 0xE4, 0xA3, 0xC6, 0x47, 0x74
	s_message:
			db		"[S1] COLOR TEST ", 0
			endscope


; =============================================================================
;	[SCREEN1] パレットを変える
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s1_palette
s1_palette::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			ld		hl, palette_table
	palette_loop:
			ld		a, [hl]
			inc		a
			ret		z
	color_loop:
			ld		a, [hl]
			inc		hl
			inc		a
			jr		z, key_wait
			dec		a
			ld		e, 16
			call	write_control_register		; R#16 = palette number
			ld		a, [hl]
			inc		hl
			ld		e, [hl]
			inc		hl
			call	write_palette
			jr		color_loop
	key_wait:
			call	wait_push_space_key
			jr		palette_loop
	s_message:
			db		"[S0W40] PALETTE TEST ", 0
	palette_table:
			db		0x04, 0x07, 0x00, 0x0F, 0x77, 0x07, 0xFF
			db		0x04, 0x06, 0x01, 0x0F, 0x66, 0x07, 0xFF
			db		0x04, 0x15, 0x02, 0x0F, 0x55, 0x06, 0xFF
			db		0x04, 0x14, 0x03, 0x0F, 0x44, 0x06, 0xFF
			db		0x04, 0x23, 0x04, 0x0F, 0x33, 0x05, 0xFF
			db		0x04, 0x22, 0x05, 0x0F, 0x22, 0x05, 0xFF
			db		0x04, 0x31, 0x06, 0x0F, 0x11, 0x04, 0xFF
			db		0x04, 0x30, 0x07, 0x0F, 0x00, 0x04, 0xFF
			db		0x04, 0x07, 0x00, 0x0F, 0x77, 0x07, 0xFF
			db		0xFF
			endscope

; =============================================================================
;	[SCREEN1] 垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s1_vscroll
s1_vscroll::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		vscroll
	s_message:
			db		"[S1] V-SCROLL TEST ", 0
			endscope

; =============================================================================
;	[SCREEN1] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s1_hscroll
s1_hscroll::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		hscroll
	s_message:
			db		"[S1] H-SCROLL TEST ", 0
			endscope

; =============================================================================
;	[SCREEN1] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s1_display_adjust
s1_display_adjust::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		display_adjust
	s_message:
			db		"[S1] DISPLAY ADJUST TEST ", 0
			endscope

; =============================================================================
;	[SCREEN1] interlace mode
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s1_interlace
s1_interlace::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message1
			call	puts
			; R#9 = 0b00001000 ... IL=1: Interlace: NT=0: NTSC
			ld		a, 0x08
			ld		e, 9
			call	write_control_register
			call	wait_push_space_key

			; Put test name
			ld		hl, 0x1800
			ld		de, s_message2
			call	puts
			; R#9 = 0b00000010 ... IL=0: Non Interlace, NT=1: PAL
			ld		a, 0x02
			ld		e, 9
			call	write_control_register
			call	wait_push_space_key

			; Put test name
			ld		hl, 0x1800
			ld		de, s_message3
			call	puts
			; R#9 = 0b00001010 ... IL=1: Interlace, NT=1: PAL
			ld		a, 0x0A
			ld		e, 9
			call	write_control_register
			call	wait_push_space_key

			; R#9 = 0b00000000 ... IL=0: Non Interlace, NT=0: NTSC
			ld		a, 0x0A
			ld		e, 9
			jp		write_control_register

	s_message1:
			db		"[S1] INTERLACE TEST      ", 0
	s_message2:
			db		"[S1] PAL TEST      ", 0
	s_message3:
			db		"[S1] INTERLACE/PAL TEST ", 0
			endscope

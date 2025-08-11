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
			call	screen0_w40
			call	s0w40_font_test
			call	s0w40_color
			call	s0w40_palette
			call	s0w40_vscroll
			call	s0w40_hscroll
			call	s0w40_display_adjust
			call	s0w40_interlace
			; 後始末
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include "lib.asm"

; =============================================================================
;	SCREEN0 (WIDTH40)
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen0_w40
screen0_w40::
			; R#0 = 0
			xor		a, a
			ld		e, a
			call	write_control_register
			; R#1 = 0x50
			ld		a, 0x50
			ld		e, 1
			call	write_control_register
			; R#7 = 0xF4
			ld		a, 0xF4					; 前景 15, 背景 4
			ld		e, 7
			call	write_control_register
			; Pattern Name Table
			ld		hl, 0
			call	set_pattern_name_table
			; Pattern Name Table をクリア
			ld		hl, 0
			ld		bc, 40 * 26
			ld		a, ' '
			call	fill_vram
			; Pattern Generator Table
			ld		hl, 0x800
			call	set_pattern_generator_table
			; Font をセット
			ld		hl, 0x800
			call	set_font
			ret
			endscope

; =============================================================================
;	[SCREEN0W40] 文字フォントが期待通りに表示される・40桁、24行表示される
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_font_test
s0w40_font_test::
			; Pattern Name Table にインクリメントデータを敷き詰める
			ld		hl, 0
			ld		bc, 40 * 24
			call	fill_increment
			; Put test name
			ld		hl, 0
			ld		de, s_message
			call	puts
			; キー待ち
			call	wait_push_space_key
			ret
	s_message:
			db		"[S0W40] FONT TEST ", 0
			endscope

; =============================================================================
;	[SCREEN0W40] 文字の色を変える
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_color
s0w40_color::
			; Put test name
			ld		hl, 0
			ld		de, s_message
			call	puts
			ld		hl, color_table
	loop:
			; set color
			ld		a, [hl]
			or		a, a
			ret		z							; finish
			ld		e, 7
			call	write_control_register
			; put message
			inc		hl
			ex		de, hl
			ld		hl, 40
			call	puts
			ex		de, hl
			call	wait_push_space_key
			jr		loop
	s_message:
			db		"[S0W40] COLOR TEST ", 0
	color_table:
			db		0xF0, "FG=WHITE, BG=TRANS ", 0
			db		0xE1, "FG=GRAY,  BG=BLACK ", 0
			db		0xD1, "FG=PINK,  BG=BLACK ", 0
			db		0xC3, "FG=GREEN, BG=LITE GREEN ", 0
			db		0xB6, "FG=CREAM, BG=RED       ", 0
			db		0xA8, "FG=YELLOW,BG=LITE RED", 0
			db		0x91, "FG=RED,   BG=BLACK   ", 0
			db		0x74, "FG=CYAN,  BG=BLUE ", 0
			db		0x57, "FG=BLUE,  BG=CYAN ", 0
			db		0xF4, "FG=WHITE, BG=BLUE ", 0
			db		0xF4, "                  ", 0
			db		0
			endscope

; =============================================================================
;	[SCREEN0W40] パレットを変える
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_palette
s0w40_palette::
			; Put test name
			ld		hl, 0
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
;	[SCREEN0W40] 垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_vscroll
s0w40_vscroll::
			; Put test name
			ld		hl, 0
			ld		de, s_message
			call	puts
			jp		vscroll
	s_message:
			db		"[S0W40] V-SCROLL TEST ", 0
			endscope

; =============================================================================
;	[SCREEN0W40] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_hscroll
s0w40_hscroll::
			; Put test name
			ld		hl, 0
			ld		de, s_message
			call	puts
			jp		hscroll
	s_message:
			db		"[S0W40] H-SCROLL TEST ", 0
			endscope

; =============================================================================
;	[SCREEN0W40] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_display_adjust
s0w40_display_adjust::
			; Put test name
			ld		hl, 0
			ld		de, s_message
			call	puts
			jp		display_adjust
	s_message:
			db		"[S0W40] DISPLAY ADJUST TEST ", 0
			endscope

; =============================================================================
;	[SCREEN0W40] interlace mode
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_interlace
s0w40_interlace::
			; Put test name
			ld		hl, 0
			ld		de, s_message1
			call	puts
			; R#9 = 0b00001000 ... IL=1: Interlace: NT=0: NTSC
			ld		a, 0x08
			ld		e, 9
			call	write_control_register
			call	wait_push_space_key

			; Put test name
			ld		hl, 0
			ld		de, s_message2
			call	puts
			; R#9 = 0b00000010 ... IL=0: Non Interlace, NT=1: PAL
			ld		a, 0x02
			ld		e, 9
			call	write_control_register
			call	wait_push_space_key

			; Put test name
			ld		hl, 0
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
			db		"[S0W40] INTERLACE TEST      ", 0
	s_message2:
			db		"[S0W40] PAL TEST      ", 0
	s_message3:
			db		"[S0W40] INTERLACE/PAL TEST ", 0
			endscope

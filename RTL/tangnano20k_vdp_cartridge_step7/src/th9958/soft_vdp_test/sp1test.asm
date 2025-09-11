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
			call	screen1
			call	sp1_pattern_test
			ei
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
			; R#8 = 0x00
			ld		a, 0x00					; スプライト表示
			ld		e, 8
			call	write_control_register
			; R#9 = 0x00
			ld		a, 0x00
			ld		e, 9
			call	write_control_register
			; R#25 = 0x00
			ld		a, 0x00
			ld		e, 25
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
			call	cls
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
;	[SCREEN1] cls
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	cls
cls::
			ld		hl, 0x1800
			ld		bc, 32 * 26
			ld		e, ' '
			call	fill_vram
			ret
			endscope

; =============================================================================
;	[SCREEN1] スプライトパターン 256種類の定義の確認
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp1_pattern_test
sp1_pattern_test::
			call	cls
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			; R#1 = 0x41
			ld		a, 0x41							; 8x8, 拡大する
			ld		e, 1
			call	write_control_register
			; R#6 = 0x00
			ld		a, 0x00							; スプライトパターンをフォントと同じにする
			ld		e, 6
			call	write_control_register
			xor		a, a
	loop:
			push	af
			ld		[s_message2], a
			; put sprite
			ld		hl, 0x1B00
			call	set_vram_write_address
			xor		a, a
			call	write_vram						; Y
			xor		a, a
			call	write_vram						; X
			pop		af
			push	af
			call	write_vram						; pattern
			ld		a, 11
			call	write_vram						; color
			; 対応する文字
			ld		hl, 0x1880
			ld		de, s_message2
			call	puts
			; キー待ち
			call	wait_push_space_key
			pop		af
			inc		a
			jp		nz, loop
			ret
	s_message:
			db		"[T001] 8x8 PATTERN TEST", 0
	s_message2:
			db		0, 0
			endscope

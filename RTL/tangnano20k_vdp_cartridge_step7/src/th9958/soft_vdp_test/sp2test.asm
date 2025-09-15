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
			call	screen4
			call	sp2_pattern_test1
			call	sp2_pattern_test2
			call	sp2_32plane
			call	sp2_screen_out

			; 後始末
			; R#15 = 0x00
			ld		a, 0x00
			ld		e, 15
			call	write_control_register
			ei
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include "lib.asm"

; =============================================================================
;	SCREEN4
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen4
screen4::
			; R#0 = 0x04
			ld		a, 4
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
			; R#8 = 0x00
			ld		a, 0x00					; スプライト表示
			ld		e, 8
			call	write_control_register
			; R#9 = 0x00
			ld		a, 0x00
			ld		e, 9
			call	write_control_register
			; R#18 = 0
			xor		a, a
			ld		e, 18
			call	write_control_register
			; R#23 = 0
			xor		a, a
			ld		e, 23
			call	write_control_register
			; R#25 = 0x00
			ld		a, 0x00
			ld		e, 25
			call	write_control_register
			; R#26 = 0
			xor		a, a
			ld		e, 26
			call	write_control_register
			; R#27 = 0
			xor		a, a
			ld		e, 27
			call	write_control_register
			; Pattern Name Table
			ld		hl, 0x1800
			call	set_pattern_name_table
			; Color Table
			ld		hl, 0x2000
			call	set_color_table
			; Sprite Attribute Table
			ld		hl, 0x1F80						; 0x1E00 だが、A8, A7 を 1 にする必要がある
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
			ld		hl, 0x0800
			call	set_font
			ld		hl, 0x1000
			call	set_font
			; Fontの色をセット
			ld		hl, 0x2000
			ld		bc, 256 * 8 * 3
			ld		e, 0xF4
			call	fill_vram
			ret
			endscope

; =============================================================================
;	[SCREEN4] set sprite color
;	input:
;		L ... sprite plane number
;		A ... color
;	output:
;		none
;	break:
;		none
;	comment:
;		none
; =============================================================================
			scope	set_sprite_color
set_sprite_color::
			push	hl
			push	de
			push	bc
			push	af
			; HL = L * 16 + 0x1C00
			ld		h, 0
			add		hl, hl
			add		hl, hl
			add		hl, hl
			add		hl, hl
			ld		de, 0x1C00
			add		hl, de
			ld		e, a
			ld		bc, 16
			call	fill_vram
			pop		af
			pop		bc
			pop		de
			pop		hl
			ret
			endscope

; =============================================================================
;	[SCREEN4] cls
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
			; ネームテーブルのクリア
			ld		hl, 0x1800
			ld		bc, 32 * 32
			ld		e, ' '
			call	fill_vram
			; スプライトアトリビュートを初期化
			ld		hl, 0x1E00
			ld		bc, 32 * 4
			ld		e, 208
			call	fill_vram
			ret
			endscope

; =============================================================================
;	[SCREEN4] wait
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	wait
wait::
			; R#15 = 0x02
			ld		a, 0x02
			ld		e, 15
			call	write_control_register
			ld		bc, 5000
	loop:
			dec		bc
			ld		a, c
			or		a, b
			jr		nz, loop
			ret
			endscope

; =============================================================================
;	[SCREEN4] スプライトパターン 256種類の定義の確認
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp2_pattern_test1
sp2_pattern_test1::
			call	cls
			; Put test name
			ld		hl, 0x18A0
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
			; Plane#0 に色を付ける
			ld		l, 0
			ld		a, 9
			call	set_sprite_color

			xor		a, a
	loop:
			push	af
			ld		[s_message2], a
			; put sprite
			ld		hl, 0x1E00
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
			call	wait
			pop		af
			inc		a
			jp		nz, loop
			; キー待ち
			call	wait_push_space_key
			ret
	s_message:
			db		"[T001] 8x8 PATTERN TEST", 0
	s_message2:
			db		0, 0
			endscope

; =============================================================================
;	[SCREEN4] スプライトパターン 64種類の定義の確認
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp2_pattern_test2
sp2_pattern_test2::
			call	cls
			; Put test name
			ld		hl, 0x18A0
			ld		de, s_message
			call	puts
			; R#1 = 0x43
			ld		a, 0x43							; 16x16, 拡大する
			ld		e, 1
			call	write_control_register
			; R#6 = 0x00
			ld		a, 0x00							; スプライトパターンをフォントと同じにする
			ld		e, 6
			call	write_control_register
			; Plane#0 に色を付ける
			ld		l, 0
			ld		a, 3
			call	set_sprite_color

			xor		a, a
	loop:
			push	af
			ld		[s_message2], a
			; put sprite
			ld		hl, 0x1E00
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
			call	wait
			pop		af
			inc		a
			jp		nz, loop
			; キー待ち
			call	wait_push_space_key
			ret
	s_message:
			db		"[T002] 16x16 PATTERN TEST", 0
	s_message2:
			db		0, 0
			endscope

; =============================================================================
;	[SCREEN4] スプライトプレーン 32枚表示の確認
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp2_32plane
sp2_32plane::
			call	cls
			; Put test name
			ld		hl, 0x18A0
			ld		de, s_message
			call	puts
			; 32枚のスプライトプレーンを表示する
			ld		hl, attribute
			ld		de, 0x1E00
			ld		bc, 4 * 32
			call	block_copy
			; 32枚のスプライトプレーンに色を付ける
			ld		b, 32
			ld		l, 0
			ld		de, color_data
	color_loop:
			ld		a, [de]
			call	set_sprite_color
			inc		de
			inc		l
			djnz	color_loop
			; R#6 = 0x00
			ld		a, 0x00							; スプライトパターンをフォントと同じにする
			ld		e, 6
			call	write_control_register

			; R#1 = 0x40
			ld		a, 0x40							; 8x8, 拡大しない
			ld		e, 1
			call	write_control_register
			call	palette0_blink

			; R#1 = 0x41
			ld		a, 0x41							; 8x8, 拡大する
			ld		e, 1
			call	write_control_register
			call	palette0_blink

			; R#1 = 0x42
			ld		a, 0x42							; 16x16, 拡大しない
			ld		e, 1
			call	write_control_register
			call	palette0_blink

			; R#1 = 0x43
			ld		a, 0x43							; 16x16, 拡大する
			ld		e, 1
			call	write_control_register
			call	palette0_blink

			; R#23 = 0
			xor		a, a
			ld		e, 23
			call	write_control_register
			ret

	palette0_blink:
			ld		b, 50
	blink_loop:
			push	bc
			; R#23 = B
			ld		a, 50
			sub		a, b							; 垂直スクロール
			ld		e, 23
			call	write_control_register
			; R#8 = 0x20
			ld		a, 0x20							; パレット0は不透明
			ld		e, 8
			call	write_control_register
			call	wait
			; R#8 = 0x00
			ld		a, 0x00							; パレット0は透明
			ld		e, 8
			call	write_control_register
			call	wait
			pop		bc
			djnz	blink_loop
			; キー待ち
			call	wait_push_space_key
			ret
	s_message:
			db		"[T003] TEST FOR DISPLAYING 32 PLANES", 0
	attribute:		;     Y      X        Pattern Color + EC
			db		 32 * 0,40 * 0 + 50,   0 + 32, 10
			db		 32 * 0,40 * 1 + 50,   4 + 32, 10
			db		 32 * 0,40 * 2 + 50,   8 + 32, 10
			db		 32 * 0,40 * 3 + 50,  12 + 32, 10
			db		 32 * 1,40 * 0 + 50,  16 + 32, 10
			db		 32 * 1,40 * 1 + 50,  20 + 32, 10
			db		 32 * 1,40 * 2 + 50,  24 + 32, 10
			db		 32 * 1,40 * 3 + 50,  28 + 32, 10
			db		 32 * 2,40 * 0 + 50,  32 + 32, 10
			db		 32 * 2,40 * 1 + 50,  36 + 32, 10
			db		 32 * 2,40 * 2 + 50,  40 + 32, 10
			db		 32 * 2,40 * 3 + 50,  44 + 32, 10
			db		 32 * 3,40 * 0 + 50,  48 + 32, 10
			db		 32 * 3,40 * 1 + 50,  52 + 32, 10
			db		 32 * 3,40 * 2 + 50,  56 + 32, 10
			db		 32 * 3,40 * 3 + 50,  60 + 32, 10
			db		 32 * 4,40 * 0 + 50,  64 + 32, 10
			db		 32 * 4,40 * 1 + 50,  68 + 32, 10
			db		 32 * 4,40 * 2 + 50,  72 + 32, 10
			db		 32 * 4,40 * 3 + 50,  76 + 32, 10
			db		 32 * 5,40 * 0 + 50,  80 + 32, 10
			db		 32 * 5,40 * 1 + 50,  84 + 32, 10
			db		 32 * 5,40 * 2 + 50,  88 + 32, 10
			db		 32 * 5,40 * 3 + 50,  92 + 32, 10
			db		 32 * 6,40 * 0 + 50,  96 + 32, 10
			db		 32 * 6,40 * 1 + 50, 100 + 32, 10
			db		 32 * 6,40 * 2 + 50, 104 + 32, 10
			db		 32 * 6,40 * 3 + 50, 108 + 32, 10
			db		 32 * 7,40 * 0 + 50, 112 + 32, 10
			db		 32 * 7,40 * 1 + 50, 116 + 32, 10
			db		 32 * 7,40 * 2 + 50, 120 + 32, 10
			db		 32 * 7,40 * 3 + 50, 124 + 32, 10
	color_data:
			db		  0
			db		  1
			db		  2
			db		  3
			db		  4
			db		  5
			db		  6
			db		  7
			db		  8
			db		  9
			db		 10
			db		 11
			db		 12
			db		 13
			db		 14
			db		 15
			db		  0 + 0x80
			db		  1 + 0x80
			db		  2 + 0x80
			db		  3 + 0x80
			db		  4 + 0x80
			db		  5 + 0x80
			db		  6 + 0x80
			db		  7 + 0x80
			db		  8 + 0x80
			db		  9 + 0x80
			db		 10 + 0x80
			db		 11 + 0x80
			db		 12 + 0x80
			db		 13 + 0x80
			db		 14 + 0x80
			db		 15 + 0x80
			endscope

; =============================================================================
;	[SCREEN4] 左右のはみ出し
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp2_screen_out
sp2_screen_out::
			call	cls
			; Put test name
			ld		hl, 0x18A0
			ld		de, s_message
			call	puts
			; R#1 = 0x43
			ld		a, 0x43							; 16x16, 拡大する
			ld		e, 1
			call	write_control_register

			ld		l, 0
			ld		a, 15 + 0x80
			call	set_sprite_color

			ld		b, 32
	loop1:
			push	bc

			ld		hl, attribute
			ld		de, 0x1E00
			ld		bc, 4
			call	block_copy

			ld		a, [attribute + 1]
			inc		a
			ld		[attribute + 1], a

			call	wait
			pop		bc
			djnz	loop1

			ld		l, 0
			ld		a, 15
			call	set_sprite_color

			ld		a, 15
			ld		[attribute + 3], a
			xor		a, a
			ld		[attribute + 1], a

	loop2:
			push	bc

			ld		hl, attribute
			ld		de, 0x1E00
			ld		bc, 4
			call	block_copy

			ld		a, [attribute + 1]
			inc		a
			ld		[attribute + 1], a

			call	wait
			pop		bc
			djnz	loop2

			call	wait_push_space_key
			ret

	s_message:
			db		"[T004] OVERSPILL BEYOND THE SCREEN", 0
	attribute:	;   Y  X  Pattern Color + EC
			db		0, 0,      64, 0
			endscope

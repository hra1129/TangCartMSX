; =============================================================================
;	V9968 software test program
;	Sprite mode2 test on VRAM Interleave mode
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
			call	screen8
			call	sp2_pattern_test1
			call	sp2_pattern_test2
			call	sp2_32plane
			call	sp2_screen_out
			call	sp2_screen_out2
			call	sp2_line_color
			call	sp2_or_mix
			call	sp2_or_mix2
			call	sp2_8sprite
			call	sp2_nonR23

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
			; R#2 = 0x1F
			ld		a, 0x1F
			ld		e, 2
			call	write_control_register
			; R#7 = 0x07
			ld		a, 0x07					; 周辺色 7
			ld		e, 7
			call	write_control_register
			; R#8 = 0x08
			ld		a, 0x08					; スプライト表示
			ld		e, 8
			call	write_control_register
			; R#9 = 0x00
			ld		a, 0x00					; 192line
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
			ld		hl, font_data
			ld		de, 0xF000
			ld		bc, 0x800
			call	block_copy
			; Pattern Name Table をクリア
			ld		hl, 0x0000
			call	set_vram_write_address

			xor		a, a
			ld		b, 4
	loop_blue_block_width:
			push	bc						; -- 4ループカウンタ保存
			push	af

			ld		b, 8
	loop_green_block_width:
			push	bc						; -- 8ループカウンタ保存

			ld		b, 6
	loop_red_line:
			push	bc						; -- 6ループカウンタ保存
			push	af

			ld		b, 8					; 水平に8ブロック並ぶ
	loop_red_increment:
			push	bc						; -- 8ループカウンタ保存

			ld		b, 32					; 1ブロック（同じ色の塊）は水平 32画素
	loop_red_block_width:
			call	write_vram
			djnz	loop_red_block_width

			pop		bc						; -- 8ループカウンタ復帰
			add		a, 0x04
			djnz	loop_red_increment

			pop		af
			pop		bc						; -- 6ループカウンタ復帰
			djnz	loop_red_line

			pop		bc						; -- 8ループカウンタ復帰
			add		a, 0x20
			djnz	loop_green_block_width

			pop		af
			pop		bc						; -- 4ループカウンタ復帰
			inc		a
			djnz	loop_blue_block_width

			call	wait_push_space_key
			ret
			endscope

; =============================================================================
;	[SCREEN8] set sprite color
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
			; HL = L * 16 + 0xF800
			ld		h, 0
			add		hl, hl
			add		hl, hl
			add		hl, hl
			add		hl, hl
			ld		de, 0xF800
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
;	[SCREEN8] cls
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
			; スプライトアトリビュートを初期化
			xor		a, a
			ld		[vram_bit16], a
			ld		hl, 0xFA00
			ld		bc, 32 * 4
			ld		e, 216
			call	fill_vram
			ret
			endscope

; =============================================================================
;	[SCREEN8] wait
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
;	[SCREEN8] スプライトパターン 256種類の定義の確認
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
			; R#1 = 0x41
			ld		a, 0x41							; 8x8, 拡大する
			ld		e, 1
			call	write_control_register
			; Plane#0 に色を付ける
			ld		l, 0
			ld		a, 9
			call	set_sprite_color

			xor		a, a
	loop:
			push	af
			; put sprite
			ld		hl, 0xFA00
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
			call	wait
			pop		af
			inc		a
			jp		nz, loop
			; キー待ち
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
;	[SCREEN8] スプライトパターン 64種類の定義の確認
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
			; R#1 = 0x43
			ld		a, 0x43							; 16x16, 拡大する
			ld		e, 1
			call	write_control_register
			; Plane#0 に色を付ける
			ld		l, 0
			ld		a, 3
			call	set_sprite_color

			xor		a, a
	loop:
			push	af
			; put sprite
			ld		hl, 0xFA00
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
			call	wait
			pop		af
			inc		a
			jp		nz, loop
			; キー待ち
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
;	[SCREEN8] スプライトプレーン 32枚表示の確認
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
			; 32枚のスプライトプレーンを表示する
			ld		hl, attribute
			ld		de, 0xFA00
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
			; R#8 = 0x28
			ld		a, 0x28							; パレット0は不透明
			ld		e, 8
			call	write_control_register
			call	wait
			; R#8 = 0x08
			ld		a, 0x08							; パレット0は透明
			ld		e, 8
			call	write_control_register
			call	wait
			pop		bc
			djnz	blink_loop
			; キー待ち
			call	wait_push_space_key
			ret
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
;	[SCREEN8] 左右のはみ出し確認
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
			ld		de, 0xFA00
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
			ld		de, 0xFA00
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

	attribute:	;   Y  X  Pattern Color + EC
			db		0, 0,      64, 0
			endscope

; =============================================================================
;	[SCREEN8] 上下のはみ出し確認
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp2_screen_out2
sp2_screen_out2::
			call	cls
			; R#1 = 0x43
			ld		a, 0x43							; 16x16, 拡大する
			ld		e, 1
			call	write_control_register

			ld		l, 0
			ld		a, 15
			call	set_sprite_color

			ld		a, 15
			ld		[attribute + 3], a
			xor		a, -32
			ld		[attribute + 0], a

	loop:
			ld		hl, attribute
			ld		de, 0xFA00
			ld		bc, 4
			call	block_copy

			call	wait
			ld		a, [attribute + 0]
			inc		a
			ld		[attribute + 0], a

			cp		a, 212
			jr		nz, loop

			call	wait_push_space_key
			ret

	attribute:	;     Y   X  Pattern Color + EC
			db		-32, 60,      64, 0
			endscope

; =============================================================================
;	[SCREEN8] ライン単位の色づけ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp2_line_color
sp2_line_color::
			call	cls
			; R#1 = 0x43
			ld		a, 0x43							; 16x16, 拡大する
			ld		e, 1
			call	write_control_register

			ld		a, 15
			ld		[attribute + 3], a
			xor		a, -32
			ld		[attribute + 0], a

			ld		hl, color_data
			ld		de, 0xF800
			ld		bc, 16
			call	block_copy
	loop1:
			ld		hl, attribute
			ld		de, 0xFA00
			ld		bc, 4
			call	block_copy

			call	wait
			ld		a, [attribute + 0]
			inc		a
			ld		[attribute + 0], a

			cp		a, 212
			jr		nz, loop1

			ld		hl, color_data2
			ld		de, 0xF800
			ld		bc, 16
			call	block_copy
	loop2:
			ld		hl, attribute
			ld		de, 0xFA00
			ld		bc, 4
			call	block_copy

			call	wait
			ld		a, [attribute + 0]
			inc		a
			ld		[attribute + 0], a

			cp		a, 212
			jr		nz, loop2

			call	wait_push_space_key
			ret

	attribute:	;     Y   X  Pattern Color + EC
			db		-32, 80,      64, 0
	color_data:
			db		0x01
			db		0x02
			db		0x03
			db		0x05
			db		0x06
			db		0x07
			db		0x08
			db		0x09
			db		0x0A
			db		0x0B
			db		0x0C
			db		0x0D
			db		0x0E
			db		0x0F
			db		0x01
			db		0x02
	color_data2:
			db		0x81
			db		0x82
			db		0x83
			db		0x85
			db		0x86
			db		0x87
			db		0x88
			db		0x89
			db		0x0A
			db		0x0B
			db		0x0C
			db		0x0D
			db		0x0E
			db		0x0F
			db		0x01
			db		0x02
			endscope

; =============================================================================
;	[SCREEN8] OR mix
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp2_or_mix
sp2_or_mix::
			call	cls
			; R#1 = 0x43
			ld		a, 0x43							; 16x16, 拡大する
			ld		e, 1
			call	write_control_register

			ld		hl, attribute
			ld		de, 0xFA00
			ld		bc, 12
			call	block_copy

			ld		hl, color_data
			ld		de, 0xF800
			ld		bc, 48
			call	block_copy
	loop1:
			ld		hl, attribute
			ld		de, 0xFA00
			ld		bc, 4
			call	block_copy

			call	wait
			ld		a, [attribute + 1]
			inc		a
			ld		[attribute + 1], a

			cp		a, 210
			jr		nz, loop1

	loop2:
			ld		hl, attribute + 4
			ld		de, 0xFA04
			ld		bc, 4
			call	block_copy

			call	wait
			ld		a, [attribute + 4]
			inc		a
			ld		[attribute + 4], a

			cp		a, 50
			jr		nz, loop2

	loop3:
			ld		hl, attribute + 4
			ld		de, 0xFA04
			ld		bc, 4
			call	block_copy

			call	wait
			ld		a, [attribute + 4]
			dec		a
			ld		[attribute + 4], a

			jr		nz, loop3

			call	wait_push_space_key
			ret

	attribute:	;     Y   X  Pattern Color + EC
			db		10, 80,      64, 0
			db		10, 128,     64, 0
			db		10, 168,     64, 0
	color_data:
			db		0x01
			db		0x01
			db		0x01
			db		0x01
			db		0x01
			db		0x01
			db		0x01
			db		0x01
			db		0x02
			db		0x02
			db		0x02
			db		0x02
			db		0x02
			db		0x02
			db		0x02
			db		0x02

			db		0x4C
			db		0x4C
			db		0x4C
			db		0x4C
			db		0x4C
			db		0x4C
			db		0x4C
			db		0x4C
			db		0x45
			db		0x45
			db		0x45
			db		0x45
			db		0x45
			db		0x45
			db		0x45
			db		0x45

			db		0x48
			db		0x48
			db		0x48
			db		0x48
			db		0x48
			db		0x48
			db		0x48
			db		0x48
			db		0x41
			db		0x41
			db		0x41
			db		0x41
			db		0x41
			db		0x41
			db		0x41
			db		0x41
			endscope

; =============================================================================
;	[SCREEN8] OR mix
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp2_or_mix2
sp2_or_mix2::
			call	cls
			; R#1 = 0x43
			ld		a, 0x43							; 16x16, 拡大する
			ld		e, 1
			call	write_control_register

			ld		hl, attribute
			ld		de, 0xFA00
			ld		bc, 12
			call	block_copy

			ld		hl, color_data
			ld		de, 0xF800
			ld		bc, 48
			call	block_copy
	loop1:
			ld		hl, attribute
			ld		de, 0xFA00
			ld		bc, 4
			call	block_copy

			call	wait
			ld		a, [attribute + 1]
			inc		a
			ld		[attribute + 1], a

			cp		a, 210
			jr		nz, loop1

	loop2:
			ld		hl, attribute + 4
			ld		de, 0xFA04
			ld		bc, 4
			call	block_copy

			call	wait
			ld		a, [attribute + 4]
			inc		a
			ld		[attribute + 4], a

			cp		a, 50
			jr		nz, loop2

	loop3:
			ld		hl, attribute + 4
			ld		de, 0xFA04
			ld		bc, 4
			call	block_copy

			call	wait
			ld		a, [attribute + 4]
			dec		a
			ld		[attribute + 4], a

			jr		nz, loop3

			call	wait_push_space_key
			ret

	attribute:	;     Y   X  Pattern Color + EC
			db		10, 80,      64, 0
			db		10, 128,     64, 0
			db		10, 168,     64, 0
	color_data:
			db		0x01
			db		0x01
			db		0x01
			db		0x01
			db		0x01
			db		0x01
			db		0x01
			db		0x01
			db		0x02
			db		0x02
			db		0x02
			db		0x02
			db		0x02
			db		0x02
			db		0x02
			db		0x02

			db		0x0C
			db		0x0C
			db		0x0C
			db		0x0C
			db		0x0C
			db		0x0C
			db		0x0C
			db		0x0C
			db		0x05
			db		0x05
			db		0x05
			db		0x05
			db		0x05
			db		0x05
			db		0x05
			db		0x05

			db		0x48
			db		0x48
			db		0x48
			db		0x48
			db		0x48
			db		0x48
			db		0x48
			db		0x48
			db		0x41
			db		0x41
			db		0x41
			db		0x41
			db		0x41
			db		0x41
			db		0x41
			db		0x41
			endscope

; =============================================================================
;	[SCREEN8] 8 sprite test
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp2_8sprite
sp2_8sprite::
			call	cls
			; R#1 = 0x43
			ld		a, 0x42							; 16x16, 拡大しない
			ld		e, 1
			call	write_control_register

			ld		hl, attribute
			ld		de, 0xFA00
			ld		bc, 4 * 9
			call	block_copy

			ld		hl, 0xF800
			ld		bc, 16 * 9
			ld		e, 0x0F
			call	fill_vram
	loop1:
			ld		hl, attribute
			ld		de, 0xFA00
			ld		bc, 4
			call	block_copy

			call	wait
			ld		a, [attribute + 0]
			inc		a
			ld		[attribute + 0], a

			cp		a, 30
			jr		nz, loop1

	loop2:
			ld		hl, attribute
			ld		de, 0xFA00
			ld		bc, 4
			call	block_copy

			call	wait
			ld		a, [attribute + 0]
			inc		a
			ld		[attribute + 0], a

			cp		a, 5
			jr		nz, loop2

			call	wait_push_space_key
			ret

	attribute:	;     Y   X  Pattern Color + EC
			db		10,  10,     64, 0
			db		10,  30,     64, 0
			db		10,  50,     64, 0
			db		10,  70,     64, 0
			db		10,  90,     64, 0
			db		10, 110,     64, 0
			db		10, 130,     64, 0
			db		10, 150,     64, 0
			db		10, 170,     64, 0
			db		10, 190,     64, 0
			endscope

; =============================================================================
;	[SCREEN8] スプライトプレーン 32枚表示の確認
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp2_nonR23
sp2_nonR23::
			call	cls
			; R#20 = 0
			ld		a, 2						; SVNS Sprite Vertical position Non-following Scroll
			ld		e, 20
			call	write_control_register
			; 32枚のスプライトプレーンを表示する
			ld		hl, attribute
			ld		de, 0xFA00
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
			; R#20 = 0
			ld		a, 0
			ld		e, 20
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
			; R#8 = 0x28
			ld		a, 0x28							; パレット0は不透明
			ld		e, 8
			call	write_control_register
			call	wait
			; R#8 = 0x08
			ld		a, 0x08							; パレット0は透明
			ld		e, 8
			call	write_control_register
			call	wait
			pop		bc
			djnz	blink_loop
			; キー待ち
			call	wait_push_space_key
			ret
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

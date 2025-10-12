; =============================================================================
;	V9968 Sprite Priority and Crash Test for MODE1
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
			call	sp1_pattern_test1

			; 後始末
			; R#15 = 0x00
			ld		a, 0x00
			ld		e, 15
			call	write_control_register
			ei
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include "../lib.asm"

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
			; ネームテーブルのクリア
			ld		hl, 0x1800
			ld		bc, 32 * 32
			ld		e, ' '
			call	fill_vram
			; スプライトアトリビュートを初期化
			ld		hl, 0x1B00
			ld		bc, 32 * 4
			ld		e, 208
			call	fill_vram
			ret
			endscope

; =============================================================================
;	[SCREEN1] wait
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
;	[SCREEN1] スプライト 5枚以上並んだことを検出
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp1_pattern_test1
sp1_pattern_test1::
			call	cls
			; Put test name
			ld		hl, 0x1800 + 20 * 32
			ld		de, s_message
			call	puts
			; R#1 = 0x42
			ld		a, 0x42							; 16x16, 拡大しない
			ld		e, 1
			call	write_control_register
			; R#6 = 0x00
			ld		a, 0x00							; スプライトパターンをフォントと同じにする
			ld		e, 6
			call	write_control_register
			xor		a, a
			; アトリビュートを転送する
			ld		hl, attribute
			ld		de, 0x1B00
			ld		bc, 4 * 32
			call	block_copy
			call	put_status

			; ちょっとずつ消去
			ld		a, 208
			ld		[attribute], a
			; #30, #31
			ld		hl, attribute
			ld		de, 0x1B00 + 4 * 30
			ld		bc, 4
			call	block_copy
			call	put_status

			; #25, #26, #27, #28, #29
			ld		hl, attribute
			ld		de, 0x1B00 + 4 * 25
			ld		bc, 4
			call	block_copy
			call	put_status

			; #20, #21, #22, #23, #24
			ld		hl, attribute
			ld		de, 0x1B00 + 4 * 20
			ld		bc, 4
			call	block_copy
			call	put_status

			; #15, #16, #17, #18, #19
			ld		hl, attribute
			ld		de, 0x1B00 + 4 * 15
			ld		bc, 4
			call	block_copy
			call	put_status

			; #10, #11, #12, #13, #14
			ld		hl, attribute
			ld		de, 0x1B00 + 4 * 10
			ld		bc, 4
			call	block_copy
			call	put_status

			; #5, #6, #7, #8, #9
			ld		hl, attribute
			ld		de, 0x1B00 + 4 * 5
			ld		bc, 4
			call	block_copy
			call	put_status

			ret

	put_status:
			; ステータスレジスタリード
			ld		e, 0
			call	read_status_register
			; 待ち
			call	wait
			call	wait
			call	wait
			; ステータスレジスタリード
			ld		e, 0
			call	read_status_register
			ld		a, e
			; リード結果をダンプ
			ld		hl, 0x1800 + 21 * 32
			ld		de, s_message
			call	put_hex
			; ステータスレジスタリード
			ld		e, 0
			call	read_status_register
			ld		a, e
			; リード結果をダンプ
			ld		hl, 0x1800 + 21 * 32 + 3
			ld		de, s_message
			call	put_hex
			call	wait_push_space_key
			ret
	s_message:
			db		"[T001] 16x16 5th Sprite Test", 0
	attribute:
			db		0		; Y
			db		16 * 0	; X
			db		'A'		; Pattern
			db		15		; Color

			db		0		; Y
			db		16 * 1	; X
			db		'A'		; Pattern
			db		15		; Color

			db		0		; Y
			db		16 * 2	; X
			db		'A'		; Pattern
			db		15		; Color

			db		0		; Y
			db		16 * 3	; X
			db		'A'		; Pattern
			db		15		; Color

			db		0		; Y
			db		16 * 4	; X
			db		'A'		; Pattern
			db		15		; Color

			db		16		; Y
			db		16 * 0	; X
			db		'A'		; Pattern
			db		15		; Color

			db		16		; Y
			db		16 * 1	; X
			db		'A'		; Pattern
			db		15		; Color

			db		16		; Y
			db		16 * 2	; X
			db		'A'		; Pattern
			db		15		; Color

			db		16		; Y
			db		16 * 3	; X
			db		'A'		; Pattern
			db		15		; Color

			db		16		; Y
			db		16 * 4	; X
			db		'A'		; Pattern
			db		15		; Color

			db		32		; Y
			db		16 * 0	; X
			db		'A'		; Pattern
			db		15		; Color

			db		32		; Y
			db		16 * 1	; X
			db		'A'		; Pattern
			db		15		; Color

			db		32		; Y
			db		16 * 2	; X
			db		'A'		; Pattern
			db		15		; Color

			db		32		; Y
			db		16 * 3	; X
			db		'A'		; Pattern
			db		15		; Color

			db		32		; Y
			db		16 * 4	; X
			db		'A'		; Pattern
			db		15		; Color

			db		48		; Y
			db		16 * 0	; X
			db		'A'		; Pattern
			db		15		; Color

			db		48		; Y
			db		16 * 1	; X
			db		'A'		; Pattern
			db		15		; Color

			db		48		; Y
			db		16 * 2	; X
			db		'A'		; Pattern
			db		15		; Color

			db		48		; Y
			db		16 * 3	; X
			db		'A'		; Pattern
			db		15		; Color

			db		48		; Y
			db		16 * 4	; X
			db		'A'		; Pattern
			db		15		; Color

			db		64		; Y
			db		16 * 0	; X
			db		'A'		; Pattern
			db		15		; Color

			db		64		; Y
			db		16 * 1	; X
			db		'A'		; Pattern
			db		15		; Color

			db		64		; Y
			db		16 * 2	; X
			db		'A'		; Pattern
			db		15		; Color

			db		64		; Y
			db		16 * 3	; X
			db		'A'		; Pattern
			db		15		; Color

			db		64		; Y
			db		16 * 4	; X
			db		'A'		; Pattern
			db		15		; Color

			db		80		; Y
			db		16 * 0	; X
			db		'A'		; Pattern
			db		15		; Color

			db		80		; Y
			db		16 * 1	; X
			db		'A'		; Pattern
			db		15		; Color

			db		80		; Y
			db		16 * 2	; X
			db		'A'		; Pattern
			db		15		; Color

			db		80		; Y
			db		16 * 3	; X
			db		'A'		; Pattern
			db		15		; Color

			db		80		; Y
			db		16 * 4	; X
			db		'A'		; Pattern
			db		15		; Color

			db		96		; Y
			db		16 * 0	; X
			db		'A'		; Pattern
			db		15		; Color

			db		96		; Y
			db		16 * 1	; X
			db		'A'		; Pattern
			db		15		; Color
			endscope

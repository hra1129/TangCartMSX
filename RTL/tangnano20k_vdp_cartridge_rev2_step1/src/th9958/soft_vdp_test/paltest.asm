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
			call	screen8
			call	s8_change_palette
			call	s8_palette_anime

			; R#20 = 0x00
			ld		a, 0x00
			ld		e, 20
			call	write_control_register
			ei
			; 後始末
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include		"lib.asm"

; =============================================================================
			scope	wait
wait::
			push	bc
			push	af
			ld		bc, 5000
	loop:
			dec		bc
			ld		a, c
			or		a, b
			jr		nz, loop
			pop		af
			pop		bc
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
			; R#8 = 0x0A
			ld		a, 0x0A					; スプライト非表示
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
;	[SCREEN8] Change to 256palette mode
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s8_change_palette
s8_change_palette::
			; R#20 = 0x10
			ld		a, 0x10					; EPAL = 1
			ld		e, 20
			call	write_control_register

			; palette を初期化する
			; R#16 = 0x00
			ld		a, 0x00					; Palette index = #0
			ld		e, 16
			call	write_control_register
			; Palette#0...#31
			ld		b, 32
	loop1:
			ld		a, b
			dec		a
			xor		a, 31
			ld		e, a
			ld		d, a
			call	write_palette555		; Palette (R,G,B) = (A,E,D)
			djnz	loop1
			; Palette#32...#63
			ld		b, 32
	loop2:
			ld		a, b
			dec		a
			xor		a, 31
			ld		e, a
			ld		d, 0
			call	write_palette555		; Palette (R,G,B) = (A,E,D)
			djnz	loop2
			; Palette#64...#95
			ld		b, 32
	loop3:
			ld		a, b
			dec		a
			xor		a, 31
			ld		e, 0
			ld		d, a
			call	write_palette555		; Palette (R,G,B) = (A,E,D)
			djnz	loop3
			; Palette#96...#127
			ld		b, 32
	loop4:
			ld		a, b
			dec		a
			xor		a, 31
			ld		e, 0
			ld		d, 0
			call	write_palette555		; Palette (R,G,B) = (A,E,D)
			djnz	loop4
			; Palette#128...#159
			ld		b, 32
	loop5:
			ld		a, b
			dec		a
			xor		a, 31
			ld		e, a
			ld		d, a
			xor		a, a
			call	write_palette555		; Palette (R,G,B) = (A,E,D)
			djnz	loop5
			; Palette#160...#191
			ld		b, 32
	loop6:
			ld		a, b
			dec		a
			xor		a, 31
			ld		e, 0
			ld		d, a
			xor		a, a
			call	write_palette555		; Palette (R,G,B) = (A,E,D)
			djnz	loop6
			; Palette#192...#223
			ld		b, 32
	loop7:
			ld		a, b
			dec		a
			xor		a, 31
			ld		e, a
			ld		d, 0
			xor		a, a
			call	write_palette555		; Palette (R,G,B) = (A,E,D)
			djnz	loop7
			; Palette#224...#255
			ld		b, 32
	loop8:
			ld		a, b
			dec		a
			xor		a, 31
			ld		e, a
			ld		d, 0
			rr		a
			call	write_palette555		; Palette (R,G,B) = (A,E,D)
			djnz	loop8
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
;	[SCREEN8] Palette animation
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s8_palette_anime
s8_palette_anime::
			ld		h, 0						; First palette# is 0.
	loop:
			ld		l, 0						; animation number
	anime_loop:
			; R#16 = Palette#
			ld		a, h
			ld		e, 16
			call	write_control_register
			; animation
			ld		a, l
			ld		d, a
			ld		e, a
			call	write_palette555		; Palette (R,G,B) = (A,E,D)
			call	wait
			inc		l
			bit		5, l
			jr		z, anime_loop
			inc		h
			jr		nz, loop
			call	wait_push_space_key
			ret
			endscope

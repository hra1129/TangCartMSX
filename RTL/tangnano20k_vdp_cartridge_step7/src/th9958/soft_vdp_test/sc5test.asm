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
			call	screen5
			call	s5_load_image
			call	s5_vscroll
			call	s5_hscroll
			call	s5_hscroll2
			call	s5_blink
			call	s5_blink2
			call	s5_display_adjust
			call	s5_pset_point
			; 後始末
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include		"lib.asm"

; =============================================================================
;	SCREEN5
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen5
screen5::
			; R#0 = 0x0E
			ld		a, 0x06
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
			ld		a, 0x0A					; スプライト非表示
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
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x00
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x11
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x22
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x33
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x44
			call	fill_vram
			call	wait_push_space_key

			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0x55
			call	fill_vram
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
;	[SCREEN5] 垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s5_vscroll
s5_vscroll::
			jp		vscroll
			endscope

; =============================================================================
;	[SCREEN5] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s5_hscroll
s5_hscroll::
			jp		hscroll
			endscope

; =============================================================================
;	[SCREEN5] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s5_hscroll2
s5_hscroll2::
			jp		hscroll2
			endscope

; =============================================================================
;	[SCREEN5] 2画面交互表示
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s5_blink
s5_blink::
			jp		blink
			call	wait_push_space_key
			endscope

; =============================================================================
;	[SCREEN5] 2画面交互表示 + 水平2画面SCROLL
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s5_blink2
s5_blink2::
			call	blink
			jp		hscroll2
			endscope

; =============================================================================
;	[SCREEN5] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s5_display_adjust
s5_display_adjust::
			jp		display_adjust
			endscope

; =============================================================================
;	[SCREEN5] load screen5 image
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s5_load_image
s5_load_image::

			ld		hl, small_image1		; 転送元
			ld		de, 0					; 転送先
			ld		c, 16
	y_loop1:
			ld		b, 16
	x_loop1:
			push	bc
			push	hl
			push	de
			ld		bc, 8
			call	block_copy
			ld		bc, 8
			pop		hl						; 転送先
			add		hl, bc					; +8
			ex		de, hl
			pop		hl						; 転送元
			pop		bc
			djnz	x_loop1

			push	bc
			ld		bc, 8
			add		hl, bc
			pop		bc
			dec		c
			jr		nz, y_loop1
			call	wait_push_space_key

			ld		hl, small_image2		; 転送元
			ld		de, 0x8000				; 転送先
			ld		c, 16
	y_loop2:
			ld		b, 16
	x_loop2:
			push	bc
			push	hl
			push	de
			ld		bc, 8
			call	block_copy
			ld		bc, 8
			pop		hl						; 転送先
			add		hl, bc					; +8
			ex		de, hl
			pop		hl						; 転送元
			pop		bc
			djnz	x_loop2

			push	bc
			ld		bc, 8
			add		hl, bc
			pop		bc
			dec		c
			jr		nz, y_loop2

			call	wait_push_space_key
			ret

	small_image1:
			db		0x00,0x11,0x11,0x11,0x10,0x00,0x00,0x00		;	0
			db		0x01,0xFF,0xFF,0xFF,0xF1,0x10,0x00,0x00		;	1
			db		0x01,0x11,0x11,0x1F,0xFF,0xF1,0x00,0x00		;	2
			db		0x1F,0xFF,0xFF,0xFF,0xFF,0xFF,0x10,0x00		;	3
			db		0x01,0x11,0x1F,0xFF,0xFF,0x1F,0x10,0x00		;	4
			db		0x00,0x01,0xFF,0xFF,0xFF,0x1F,0xF1,0x00		;	5
			db		0x00,0x1F,0xFF,0xFF,0xDD,0xDF,0xF1,0x00		;	6
			db		0x00,0x1F,0xFF,0xFF,0xFF,0xFF,0xF1,0x00		;	7
			db		0x01,0x1F,0xF1,0xFF,0xFF,0xFF,0xF1,0x00		;	8
			db		0x1F,0xFF,0x1F,0xFF,0xFF,0xFF,0xF1,0x00		;	9
			db		0x1F,0xFF,0x1F,0xF1,0xFF,0xFF,0xF1,0x00		;	A
			db		0x01,0xFF,0xF1,0x1F,0xFF,0xFF,0x11,0x10		;	B
			db		0x1F,0x1F,0xFF,0xFF,0xFF,0xF1,0x1F,0xF1		;	C
			db		0x1F,0xF1,0x1F,0xFF,0xF1,0x1F,0xFF,0x10		;	D
			db		0x01,0xFF,0xF1,0x11,0x1F,0xFF,0x11,0x00		;	E
			db		0x00,0x11,0x10,0x00,0x01,0x11,0x00,0x00		;	F

	small_image2:
			db		0x00,0x00,0x00,0x01,0x11,0x11,0x11,0x00		;	0
			db		0x00,0x00,0x01,0x1F,0xFF,0xFF,0xFF,0x10		;	1
			db		0x00,0x00,0x1F,0xFF,0xF1,0x11,0x11,0x10		;	2
			db		0x00,0x01,0xFF,0xFF,0xFF,0xFF,0xFF,0xF1		;	3
			db		0x00,0x01,0xF1,0xFF,0xFF,0xF1,0x11,0x10		;	4
			db		0x00,0x1F,0xF1,0xFF,0xFF,0xFF,0x10,0x00		;	5
			db		0x00,0x1F,0xFD,0xDD,0xFF,0xFF,0xF1,0x00		;	6
			db		0x00,0x1F,0xFF,0xFF,0xFF,0xFF,0xF1,0x00		;	7
			db		0x00,0x1F,0xFF,0xFF,0xFF,0x1F,0xF1,0x10		;	8
			db		0x00,0x1F,0xFF,0xFF,0xFF,0xF1,0xFF,0xF1		;	9
			db		0x00,0x1F,0xFF,0xFF,0x1F,0xF1,0xFF,0xF1		;	A
			db		0x01,0x11,0xFF,0xFF,0xF1,0x1F,0xFF,0x10		;	B
			db		0x1F,0xF1,0x1F,0xFF,0xFF,0xFF,0xF1,0xF1		;	C
			db		0x01,0xFF,0xF1,0x1F,0xFF,0xF1,0x1F,0xF1		;	D
			db		0x00,0x11,0xFF,0xF1,0x11,0x1F,0xFF,0x10		;	E
			db		0x00,0x00,0x11,0x10,0x00,0x01,0x11,0x00		;	F
			endscope

; =============================================================================
;	[SCREEN5] VDP command test : PSET, POINT
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s5_pset_point
s5_pset_point::
			ld		hl, 32
			ld		b, 100
			ld		c, 15
			; for B=0 to 99
	loop:
			push	bc
			push	hl
			; pset (32+B, 32+B), C
			ld		e, l
			ld		d, h
			ld		b, LOP_IMP
			call	pset
			pop		hl
			; A = point(32+B, 32+B)
			push	hl
			ld		e, l
			ld		d, h
			call	point
			pop		hl
			push	hl
			; pset (64+B, 32+B), C
			ld		a, e
			ld		e, l
			ld		d, h
			ld		bc, 32
			add		hl, bc
			ld		c, a
			ld		b, LOP_IMP
			call	pset
			pop		hl
			pop		bc
			inc		hl
			inc		c
			djnz	loop
			call	wait_push_space_key
			endscope

; =============================================================================
;	PSET
;	input:
;		hl ........ X座標
;		de ........ Y座標
;		c ......... 色
;		b ......... LOGICAL OPERATION
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	pset
pset::
			push	de
			ld		a, 36		; DX
			ld		e, 17
			call	write_control_register
			pop		de

			di
			ld		a, l
			call	write_register
			ld		a, h
			call	write_register
			ld		a, e
			call	write_register
			ld		a, d
			call	write_register

			ld		a, 44		; COLOR
			ld		e, 17
			call	write_control_register

			ld		a, c
			call	write_register
			xor		a, a
			call	write_register
			ld		a, b
			and		a, 0x0F
			or		a, 0x50		; PSET
			call	write_register
			ei
			ret
			endscope

; =============================================================================
;	POINT
;	input:
;		hl ........ X座標
;		de ........ Y座標
;	output:
;		e ......... color
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	point
point::
			push	de
			ld		a, 32		; SX
			ld		e, 17
			call	write_control_register
			pop		de

			di
			ld		a, l
			call	write_register
			ld		a, h
			call	write_register
			ld		a, e
			call	write_register
			ld		a, d
			call	write_register

			ld		a, 0x40		; POINT
			ld		e, 46
			call	write_control_register

			nop
			nop
			nop
			nop

			ld		e, 7
			call	read_status_register
			ei
			ret
			endscope

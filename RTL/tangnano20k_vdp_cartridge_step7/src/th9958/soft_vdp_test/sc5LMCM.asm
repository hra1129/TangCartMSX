; =============================================================================
;	V9958 software test program
; -----------------------------------------------------------------------------
;	Programmed by t.hara (HRA!)
; =============================================================================

			org		0x100

start:
			; èÄîı
			call	vdp_io_select
			call	copy_rom_font
			; ÉeÉXÉg
			call	screen5
			call	s5_load_image

			call	test001
			call	test002
			call	test003
			call	test004

			call	test005
			call	test006
			call	test007
			call	test008

			; å„énññ
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
			ld		a, 0x07					; é¸ï”êF 7
			ld		e, 7
			call	write_control_register
			; R#8 = 0x02
			ld		a, 0x0A					; ÉXÉvÉâÉCÉgîÒï\é¶
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
			; Pattern Name Table ÇÉNÉäÉA
			xor		a, a
			ld		[vram_bit16], a
			ld		hl, 0x0000
			ld		bc, 128 * 256
			ld		e, 0x44
			call	fill_vram

			ld		hl, 0x8000
			ld		d, 0
			ld		bc, 128 * 256
			ld		e, 0x85
			call	fill_vram

			ld		a, 1
			ld		[vram_bit16], a
			ld		hl, 0x0000
			ld		bc, 128 * 256
			ld		e, 0x88
			call	fill_vram

			ld		hl, 0x8000
			ld		d, 1
			ld		bc, 128 * 256
			ld		e, 0x99
			call	fill_vram

			xor		a, a
			ld		[vram_bit16], a
			ret
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

			ld		hl, small_image1		; ì]ëóå≥
			ld		de, 0					; ì]ëóêÊ
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
			pop		hl						; ì]ëóêÊ
			add		hl, bc					; +8
			ex		de, hl
			pop		hl						; ì]ëóå≥
			pop		bc
			djnz	x_loop1

			push	bc
			ld		bc, 8
			add		hl, bc
			pop		bc
			dec		c
			jr		nz, y_loop1

			ld		hl, small_image2		; ì]ëóå≥
			ld		de, 0x8000				; ì]ëóêÊ
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
			pop		hl						; ì]ëóêÊ
			add		hl, bc					; +8
			ex		de, hl
			pop		hl						; ì]ëóå≥
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
;	LMCM ÇÃåãâ ÇéÛÇØéÊÇÈ
;	input:
;		HL .... åãâ ÇÃäiî[êÊÉAÉhÉåÉX
; =============================================================================
			scope	get_lmcm_result
get_lmcm_result::
			ld		a, [io_vdp_port1]
			ld		c, a
	loop:
			ld		a, 2
			out		[c], a
			ld		a, 15 + 0x80
			out		[c], a						; R#15 = 2
	wait_tr:
			in		a, [c]						; a = S#2
			or		a, a
			jp		m, get_pixel				; if TR=1 goto get_pixel
			rrca
			jr		c, wait_tr					; if CE=1 goto wait_tr
			ret
	get_pixel:
			ld		a, 7
			out		[c], a
			ld		a, 15 + 0x80
			out		[c], a						; R#15 = 7
			in		a, [c]
			ld		[hl], a
			inc		hl
			jr		loop
			endscope

; =============================================================================
;	ÉÅÉÇÉäî‰är
;	input:
;		HL .... î‰ärå≥1
;		DE .... î‰ärå≥2
;		BC .... ÉTÉCÉY
;	output:
;		Z ..... 1: àÍív, 0: ïsàÍív
; =============================================================================
			scope	memcmp
memcmp::
			ld		a, [de]
			inc		de
			cpi
			ret		pe
			jp		z, memcmp
			ret
			endscope

; =============================================================================
;	ç∂è„XÇ™ãÙêîç¿ïWÇ…Ç»ÇÈ 16x16 ÇÃÉuÉçÉbÉNÇì«Çﬁ
; =============================================================================
			scope	test001
test001::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			ld		hl, work
			call	get_lmcm_result
			ld		hl, work
			ld		de, reference
			ld		bc, 16 * 16
			call	memcmp
			
			call	wait_push_space_key
			ret
	data:
			dw		0			; SX
			dw		0			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		16			; NX
			dw		16			; NY
			db		0			; CLR (dummy)
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xA0		; CMD (LMCM)
	reference:
			db
			endscope

; =============================================================================
work::
			ds		16 * 16		; 256bytes

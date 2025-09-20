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
			di
			call	screen5
			call	s5_load_image
			call	s5_copy
			call	s5_rotate_test

			call	wait_push_space_key
			ei
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
			; R#20 = 0x21
			ld		a, 0x21					; ägí£VDPÉRÉ}ÉìÉh, çÇë¨VDPÉRÉ}ÉìÉh
			ld		e, 20
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

			ld		hl, small_image2		; ì]ëóå≥
			ld		de, 0x0000				; ì]ëóêÊ
			ld		c, 16
	y_loop0:
			ld		b, 16
	x_loop0:
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
			djnz	x_loop0

			push	bc
			ld		bc, 8
			add		hl, bc
			pop		bc
			dec		c
			jr		nz, y_loop0

			ld		hl, small_image1		; ì]ëóå≥
			ld		de, 0x8000				; ì]ëóêÊ
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
			ld		a, 1
			ld		[vram_bit16], a
			ld		de, 0x0000				; ì]ëóêÊ
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

			ld		a, 0
			ld		[vram_bit16], a
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
			scope	s5_copy
s5_copy::
			call	wait_command
			ld		hl, data0
			ld		a, 32
			ld		b, 15
			call	run_command

			call	wait_command
			ld		hl, data1
			ld		a, 32
			ld		b, 15
			call	run_command

			call	wait_command
			ld		hl, data2
			ld		a, 32
			ld		b, 15
			call	run_command

			call	wait_push_space_key
			ret
	data0:
			dw		0			; SX
			dw		0			; SY
			dw		0			; DX
			dw		16			; DY
			dw		256			; NX (dummy)
			dw		240			; NY
			db		0			; CLR (dummy)
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xD0		; CMD (HMMM)

	data1:
			dw		0			; SX
			dw		256			; SY
			dw		0			; DX
			dw		256+16		; DY
			dw		256			; NX (dummy)
			dw		240			; NY
			db		0			; CLR (dummy)
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xD0		; CMD (HMMM)

	data2:
			dw		0			; SX
			dw		512			; SY
			dw		0			; DX
			dw		512+16		; DY
			dw		256			; NX (dummy)
			dw		240			; NY
			db		0			; CLR (dummy)
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xD0		; CMD (HMMM)
			endscope

; =============================================================================
			scope	s5_rotate
s5_rotate::
			call	wait_command
			ld		hl, rotate_vector
			ld		a, 47
			ld		b, 4
			call	run_command

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			ret
	rotate_vector::
			dw		0			; VX
			dw		0			; VY
	data:
			dw		0			; SX
			dw		256			; SY
			dw		0			; DX
			dw		0			; DY
			dw		256			; NX (dummy)
			dw		212			; NY
			db		0			; CLR (dummy)
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0x30		; CMD (LRMM)
			endscope

; =============================================================================
			scope	s5_rotate_test
s5_rotate_test::
			ld		b, 50
	loop0:
			push	bc
			ld		hl, data
	loop:
			ld		e, [hl]
			ld		a, e
			inc		hl
			ld		d, [hl]
			or		a, d
			inc		hl
			ld		[rotate_vector + 0], de
			ld		e, [hl]
			or		a, e
			inc		hl
			ld		d, [hl]
			or		a, d
			jr		z, exit_loop
			inc		hl
			ld		[rotate_vector + 2], de
			push	hl
			call	s5_rotate
			pop		hl
			jr		loop
	exit_loop:
			pop		bc
			djnz	loop0
			call	wait_push_space_key
			ret
	data:
			dw		256,	0
			dw		255,	4
			dw		255,	8
			dw		255,	13
			dw		255,	17
			dw		255,	22
			dw		254,	26
			dw		254,	31
			dw		253,	35
			dw		252,	40
			dw		252,	44
			dw		251,	48
			dw		250,	53
			dw		249,	57
			dw		248,	61
			dw		247,	66
			dw		246,	70
			dw		244,	74
			dw		243,	79
			dw		242,	83
			dw		240,	87
			dw		238,	91
			dw		237,	95
			dw		235,	100
			dw		233,	104
			dw		232,	108
			dw		230,	112
			dw		228,	116
			dw		226,	120
			dw		223,	124
			dw		221,	128
			dw		219,	131
			dw		217,	135
			dw		214,	139
			dw		212,	143
			dw		209,	146
			dw		207,	150
			dw		204,	154
			dw		201,	157
			dw		198,	161
			dw		196,	164
			dw		193,	167
			dw		190,	171
			dw		187,	174
			dw		184,	177
			dw		181,	181
			dw		177,	184
			dw		174,	187
			dw		171,	190
			dw		167,	193
			dw		164,	196
			dw		161,	198
			dw		157,	201
			dw		154,	204
			dw		150,	207
			dw		146,	209
			dw		143,	212
			dw		139,	214
			dw		135,	217
			dw		131,	219
			dw		128,	221
			dw		124,	223
			dw		120,	226
			dw		116,	228
			dw		112,	230
			dw		108,	232
			dw		104,	233
			dw		100,	235
			dw		95,		237
			dw		91,		238
			dw		87,		240
			dw		83,		242
			dw		79,		243
			dw		74,		244
			dw		0,		0
			endscope

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
			ei
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
;	左端から右端までを別のラインへコピーする
; =============================================================================
			scope	test001
test001::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 34
			ld		b, 13
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		0			; SY
			dw		0			; DX
			dw		16			; DY
			dw		123			; NX (dummy)
			dw		16			; NY
			db		0			; CLR (dummy)
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xE0		; CMD (YMMM)
			endscope

; =============================================================================
			scope	test002
test002::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 34
			ld		b, 13
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		0			; SY
			dw		255			; DX
			dw		32			; DY
			dw		234			; NX (dummy)
			dw		16			; NY
			db		0			; CLR (dummy)
			db		0b0000100	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xE0		; CMD (YMMM)
			endscope

; =============================================================================
			scope	test003
test003::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 34
			ld		b, 13
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		15			; SY
			dw		0			; DX
			dw		63			; DY
			dw		345			; NX (dummy)
			dw		16			; NY
			db		0			; CLR (dummy)
			db		0b0001000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xE0		; CMD (YMMM)
			endscope

; =============================================================================
			scope	test004
test004::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 34
			ld		b, 13
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		15			; SY
			dw		255			; DX
			dw		79			; DY
			dw		456			; NX (dummy)
			dw		16			; NY
			db		0			; CLR (dummy)
			db		0b0001100	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xE0		; CMD (YMMM)
			endscope

; =============================================================================
;	幅が256に満たないパターン
; =============================================================================
			scope	test005
test005::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 34
			ld		b, 13
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		256			; SY
			dw		50			; DX
			dw		80			; DY
			dw		123			; NX (dummy)
			dw		16			; NY
			db		0			; CLR (dummy)
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xE0		; CMD (YMMM)
			endscope

; =============================================================================
			scope	test006
test006::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 34
			ld		b, 13
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		256			; SY
			dw		81			; DX
			dw		96			; DY
			dw		234			; NX (dummy)
			dw		16			; NY
			db		0			; CLR (dummy)
			db		0b0000100	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xE0		; CMD (YMMM)
			endscope

; =============================================================================
			scope	test007
test007::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 34
			ld		b, 13
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		271			; SY
			dw		63			; DX
			dw		127			; DY
			dw		345			; NX (dummy)
			dw		16			; NY
			db		0			; CLR (dummy)
			db		0b0001000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xE0		; CMD (YMMM)
			endscope

; =============================================================================
			scope	test008
test008::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 34
			ld		b, 13
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		271			; SY
			dw		90			; DX
			dw		143			; DY
			dw		456			; NX (dummy)
			dw		16			; NY
			db		0			; CLR (dummy)
			db		0b0001100	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xE0		; CMD (YMMM)
			endscope

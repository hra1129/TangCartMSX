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

			call	test001
			call	test002

			call	test003
			call	test004
			call	test005
			call	test006

			call	test007
			call	test008
			call	test009
			call	test010
			ei

			; 後始末
			call	clear_key_buffer

			; 結果を表示
			ld		hl, test001_result
			ld		b, 2
	result_loop:
			push	bc
			push	hl

			ld		l, [hl]
			call	put_l

			pop		hl
			inc		hl
			push	hl

			ld		l, [hl]
			call	put_l

			ld		e, 13
			ld		c, 2
			call	bdos
			ld		e, 10
			ld		c, 2
			call	bdos

			pop		hl
			inc		hl
			pop		bc
			djnz	result_loop

			ld		e, 13
			ld		c, 2
			call	bdos
			ld		e, 10
			ld		c, 2
			call	bdos

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
			ret
			endscope

; =============================================================================
;	ステータスレジスタの読みだしと結果格納
; =============================================================================
			scope	read_status_tr
read_status_tr::
			ld		a, [last_s2]
			and		a, 0x80
			ld		[hl], a
			inc		hl
			ld		e, 2
			call	read_status_register
			ld		a, e
			and		a, 0x80
			ld		[hl], a
			ret
			endscope

; =============================================================================
;	HL の値を表示
; =============================================================================
			scope	put_hl
put_hl::
			ld		de, 10000
			call	put_one
			ld		de, 1000
			call	put_one
			ld		de, 100
			call	put_one
			ld		de, 10
			call	put_one
			ld		de, 1
			call	put_one
			ld		e, ' '
			ld		c, 2
			call	bdos
			ret

	put_one:
			ld		b, 0
	loop:
			or		a, a
			inc		b
			sbc		hl, de
			jr		nc, loop

			add		hl, de
			push	hl
			dec		b
			ld		a, b
			add		a, '0'
			ld		e, a
			ld		c, 2		;	コンソール出力 _CONOUT
			call	bdos
			pop		hl
			ret
			endscope

; =============================================================================
;	L の値を表示
; =============================================================================
			scope	put_l
put_l::
			ld		h, 0
			ld		de, 100
			call	put_one
			ld		de, 10
			call	put_one
			ld		de, 1
			call	put_one
			ld		e, ' '
			ld		c, 2
			call	bdos
			ret

	put_one:
			ld		b, 0
	loop:
			or		a, a
			inc		b
			sbc		hl, de
			jr		nc, loop

			add		hl, de
			push	hl
			dec		b
			ld		a, b
			add		a, '0'
			ld		e, a
			ld		c, 2		;	コンソール出力 _CONOUT
			call	bdos
			pop		hl
			ret
			endscope

; =============================================================================
;	右探索 境界色
; =============================================================================
			scope	test001
test001::
			ld		a, 0xA0
			ld		e, 46
			call	write_control_register

			ld		a, 0x00
			ld		e, 46
			call	write_control_register

			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test001_result
			call	read_status_tr
			ret
			endscope

; =============================================================================
			scope	test002
test002::
			ld		a, 0x01
			ld		e, 44
			call	write_control_register

			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test002_result
			call	read_status_tr
			ret
			endscope

; =============================================================================
;	シンプルな転送
; =============================================================================
			scope	test003
test003::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 8
			call	run_command
			ld		a, [io_vdp_port3]
			ld		c, a
			ld		de, small_image1
			ld		a, [de]
			out		[c], a		; R#44 CLR
			inc		de
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#45
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#46

			ld		b, 8 * 16 - 1
			dec		c
			dec		c
			ld		a, 0x80 + 44
			out		[c], a
			ld		a, 0x80 + 17
			out		[c], a		; R#17=44 (non increment)
			ld		a, 2
			out		[c], a
			ld		a, 0x8F
			out		[c], a		; R#15=2
	loop:
			in		a, [c]		; A=S#2
			rlca
			jr		nc, loop
			inc		c
			inc		c
			ld		a, [de]
			out		[c], a
			inc		de
			dec		c
			dec		c
			djnz	loop
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		0			; DX
			dw		0			; DY
			dw		16			; NX
			dw		16			; NY
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0xF0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test004
test004::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 8
			call	run_command
			ld		a, [io_vdp_port3]
			ld		c, a
			ld		de, small_image2
			ld		a, [de]
			out		[c], a		; R#44 CLR
			inc		de
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#45
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#46

			ld		b, 8 * 16 - 1
			dec		c
			dec		c
			ld		a, 0x80 + 44
			out		[c], a
			ld		a, 0x80 + 17
			out		[c], a		; R#17=44 (non increment)
			ld		a, 2
			out		[c], a
			ld		a, 0x8F
			out		[c], a		; R#15=2
	loop:
			in		a, [c]		; A=S#2
			rlca
			jr		nc, loop
			inc		c
			inc		c
			ld		a, [de]
			out		[c], a
			inc		de
			dec		c
			dec		c
			djnz	loop
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		31			; DX
			dw		0			; DY
			dw		16			; NX
			dw		16			; NY
			db		0b0000100	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0xF0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test005
test005::
			ld		a, 13
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 8
			call	run_command
			ld		a, [io_vdp_port3]
			ld		c, a
			ld		de, small_image1
			ld		a, [de]
			out		[c], a		; R#44 CLR
			inc		de
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#45
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#46

			ld		b, 8 * 16 - 1
			dec		c
			dec		c
			ld		a, 0x80 + 44
			out		[c], a
			ld		a, 0x80 + 17
			out		[c], a		; R#17=44 (non increment)
			ld		a, 2
			out		[c], a
			ld		a, 0x8F
			out		[c], a		; R#15=2
	loop:
			in		a, [c]		; A=S#2
			rlca
			jr		nc, loop
			inc		c
			inc		c
			ld		a, [de]
			out		[c], a
			inc		de
			dec		c
			dec		c
			djnz	loop
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		32			; DX
			dw		15			; DY
			dw		16			; NX
			dw		16			; NY
			db		0b0001000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0xF0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test006
test006::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 8
			call	run_command
			ld		a, [io_vdp_port3]
			ld		c, a
			ld		de, small_image2
			ld		a, [de]
			out		[c], a		; R#44 CLR
			inc		de
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#45
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#46

			ld		b, 8 * 16 - 1
			dec		c
			dec		c
			ld		a, 0x80 + 44
			out		[c], a
			ld		a, 0x80 + 17
			out		[c], a		; R#17=44 (non increment)
			ld		a, 2
			out		[c], a
			ld		a, 0x8F
			out		[c], a		; R#15=2
	loop:
			in		a, [c]		; A=S#2
			rlca
			jr		nc, loop
			inc		c
			inc		c
			ld		a, [de]
			out		[c], a
			inc		de
			dec		c
			dec		c
			djnz	loop
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		63			; DX
			dw		15			; DY
			dw		16			; NX
			dw		16			; NY
			db		0b0001100	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0xF0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test007
test007::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 8
			call	run_command
			ld		a, [io_vdp_port3]
			ld		c, a
			ld		de, small_image1
			ld		a, [de]
			out		[c], a		; R#44 CLR
			inc		de
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#45
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#46

			ld		b, 8 * 16 - 1
			dec		c
			dec		c
			ld		a, 0x80 + 44
			out		[c], a
			ld		a, 0x80 + 17
			out		[c], a		; R#17=44 (non increment)
			ld		a, 2
			out		[c], a
			ld		a, 0x8F
			out		[c], a		; R#15=2
	loop:
			in		a, [c]		; A=S#2
			rlca
			jr		nc, loop
			inc		c
			inc		c
			ld		a, [de]
			out		[c], a
			inc		de
			dec		c
			dec		c
			djnz	loop
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		1			; DX
			dw		16			; DY
			dw		16			; NX
			dw		16			; NY
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0xF0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test008
test008::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 8
			call	run_command
			ld		a, [io_vdp_port3]
			ld		c, a
			ld		de, small_image2
			ld		a, [de]
			out		[c], a		; R#44 CLR
			inc		de
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#45
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#46

			ld		b, 8 * 16 - 1
			dec		c
			dec		c
			ld		a, 0x80 + 44
			out		[c], a
			ld		a, 0x80 + 17
			out		[c], a		; R#17=44 (non increment)
			ld		a, 2
			out		[c], a
			ld		a, 0x8F
			out		[c], a		; R#15=2
	loop:
			in		a, [c]		; A=S#2
			rlca
			jr		nc, loop
			inc		c
			inc		c
			ld		a, [de]
			out		[c], a
			inc		de
			dec		c
			dec		c
			djnz	loop
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		32			; DX
			dw		16			; DY
			dw		16			; NX
			dw		16			; NY
			db		0b0000100	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0xF0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test009
test009::
			ld		a, 13
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 8
			call	run_command
			ld		a, [io_vdp_port3]
			ld		c, a
			ld		de, small_image1
			ld		a, [de]
			out		[c], a		; R#44 CLR
			inc		de
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#45
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#46

			ld		b, 8 * 16 - 1
			dec		c
			dec		c
			ld		a, 0x80 + 44
			out		[c], a
			ld		a, 0x80 + 17
			out		[c], a		; R#17=44 (non increment)
			ld		a, 2
			out		[c], a
			ld		a, 0x8F
			out		[c], a		; R#15=2
	loop:
			in		a, [c]		; A=S#2
			rlca
			jr		nc, loop
			inc		c
			inc		c
			ld		a, [de]
			out		[c], a
			inc		de
			dec		c
			dec		c
			djnz	loop
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		33			; DX
			dw		31			; DY
			dw		16			; NX
			dw		16			; NY
			db		0b0001000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0xF0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test010
test010::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 8
			call	run_command
			ld		a, [io_vdp_port3]
			ld		c, a
			ld		de, small_image2
			ld		a, [de]
			out		[c], a		; R#44 CLR
			inc		de
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#45
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#46

			ld		b, 8 * 16 - 1
			dec		c
			dec		c
			ld		a, 0x80 + 44
			out		[c], a
			ld		a, 0x80 + 17
			out		[c], a		; R#17=44 (non increment)
			ld		a, 2
			out		[c], a
			ld		a, 0x8F
			out		[c], a		; R#15=2
	loop:
			in		a, [c]		; A=S#2
			rlca
			jr		nc, loop
			inc		c
			inc		c
			ld		a, [de]
			out		[c], a
			inc		de
			dec		c
			dec		c
			djnz	loop
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		64			; DX
			dw		31			; DY
			dw		16			; NX
			dw		16			; NY
			db		0b0001100	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0xF0		; CMD (HMMC)
			endscope

; =============================================================================
small_image1::
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

small_image2::	; 上位ニブルと、下位ニブルを入れ替えたもの
			db		0x00,0x11,0x11,0x11,0x01,0x00,0x00,0x00		;	0
			db		0x10,0xFF,0xFF,0xFF,0x1F,0x01,0x00,0x00		;	1
			db		0x10,0x11,0x11,0xF1,0xFF,0x1F,0x00,0x00		;	2
			db		0xF1,0xFF,0xFF,0xFF,0xFF,0xFF,0x01,0x00		;	3
			db		0x10,0x11,0xF1,0xFF,0xFF,0xF1,0x01,0x00		;	4
			db		0x00,0x10,0xFF,0xFF,0xFF,0xF1,0x1F,0x00		;	5
			db		0x00,0xF1,0xFF,0xFF,0xDD,0xFD,0x1F,0x00		;	6
			db		0x00,0xF1,0xFF,0xFF,0xFF,0xFF,0x1F,0x00		;	7
			db		0x10,0xF1,0x1F,0xFF,0xFF,0xFF,0x1F,0x00		;	8
			db		0xF1,0xFF,0xF1,0xFF,0xFF,0xFF,0x1F,0x00		;	9
			db		0xF1,0xFF,0xF1,0x1F,0xFF,0xFF,0x1F,0x00		;	A
			db		0x10,0xFF,0x1F,0xF1,0xFF,0xFF,0x11,0x01		;	B
			db		0xF1,0xF1,0xFF,0xFF,0xFF,0x1F,0xF1,0x1F		;	C
			db		0xF1,0x1F,0xF1,0xFF,0x1F,0xF1,0xFF,0x01		;	D
			db		0x10,0xFF,0x1F,0x11,0xF1,0xFF,0x11,0x00		;	E
			db		0x00,0x11,0x01,0x00,0x10,0x11,0x00,0x00		;	F

; =============================================================================
			scope	results
test001_result::
			db		0
			db		0
test002_result::
			db		0
			db		0
			endscope

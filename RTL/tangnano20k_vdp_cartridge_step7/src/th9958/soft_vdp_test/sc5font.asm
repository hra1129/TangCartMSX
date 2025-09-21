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
			call	s5_copy
			call	s5_draw_font

			call	wait_push_space_key
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
			; R#20 = 0x21
			ld		a, 0x21					; 拡張VDPコマンド, 高速VDPコマンド
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

			ld		hl, small_image2		; 転送元
			ld		de, 0x0000				; 転送先
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
			pop		hl						; 転送先
			add		hl, bc					; +8
			ex		de, hl
			pop		hl						; 転送元
			pop		bc
			djnz	x_loop0

			push	bc
			ld		bc, 8
			add		hl, bc
			pop		bc
			dec		c
			jr		nz, y_loop0

			ld		hl, small_image1		; 転送元
			ld		de, 0x8000				; 転送先
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
			ld		a, 1
			ld		[vram_bit16], a
			ld		de, 0x0000				; 転送先
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
;	文字列を描画
;	input:
;		l ............. X座標
;		h ............. Y座標
;		de ............ 文字列のアドレス
;		char_color .... 前景色
;		R#12 .......... 背景色
; =============================================================================
			scope	s5_draw_string
s5_draw_string::
			ld		[pos_x], hl
	loop:
			ld		a, [de]			; 描画する文字コードを取得する
			or		a, a
			ret		z				; 端末文字なら戻る
			; 表示の準備
			push	de
			cp		a, 10			; 改行か?
			jr		z, string_return
			; -- 文字コードに対応するフォントのアドレスを求める
			ld		l, a
			ld		h, 0
			add		hl, hl
			add		hl, hl
			add		hl, hl
			ld		de, font_data
			add		hl, de
			; -- 座標をセットする
			ld		a, [pos_x]
			ld		[char_dx], a
			ld		a, [pos_y]
			ld		[char_dy], a
			call	s5_draw_char
			; 座標を右隣へ移動
			ld		a, [pos_x]
			add		a, 8
			ld		[pos_x], a
			jr		c, string_return		; 255を超えてきたら改行
			cp		a, 256-8+1				; 右端が欠ける場合も改行
			jr		c, next_char
	string_return:
			xor		a, a
			ld		[pos_x], a
			ld		a, [pos_y]
			add		a, 8
			ld		[pos_y], a
	next_char:
			; 次の文字へ遷移
			pop		de
			inc		de
			jr		loop
	pos_x::
			db		0
	pos_y::
			db		0
			endscope

; =============================================================================
			scope	s5_draw_char
s5_draw_char::
			ld		a, [io_vdp_port3]
			ld		c, a
			push	bc
			push	hl
			call	wait_command
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command

			; R#17 = 0x80+44
			ld		a, 0x80+44
			ld		e, 17
			call	write_control_register

			pop		hl
			pop		bc

			call	wait_status_tr
			outi
			call	wait_status_tr
			outi
			call	wait_status_tr
			outi
			call	wait_status_tr
			outi
			call	wait_status_tr
			outi
			call	wait_status_tr
			outi
			call	wait_status_tr
			outi
			call	wait_status_tr
			outi
			ret
	data:
	char_dx::
			dw		0			; DX
	char_dy::
			dw		0			; DY
			dw		8			; NX
			dw		8			; NY
	char_color::
			db		15			; CLR
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0x20		; CMD (LFMC)
			endscope

; =============================================================================
;	ステータスレジスタの読みだしと結果格納
; =============================================================================
			scope	wait_status_tr
wait_status_tr::
			ld		e, 2
			call	read_status_register
			ld		a, e
			and		a, 0x80
			jr		z, wait_status_tr
			ret
			endscope

; =============================================================================
			scope	s5_draw_font
s5_draw_font::
			; R#12 = 0x04
			ld		a, 0x04
			ld		e, 12
			call	write_control_register
			ld		hl, (0 << 8) | 0			;	(X,Y) = (0,0)
			ld		de, message1
			call	s5_draw_string
			call	wait_push_space_key
			ret
	message1:
			db		"This is MSX Computer.", 10
			db		"V9968 VDP included.", 0
			endscope

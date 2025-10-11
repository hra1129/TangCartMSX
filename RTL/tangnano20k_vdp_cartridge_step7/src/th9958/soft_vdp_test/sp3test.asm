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
			call	sp3_move_test
			call	sp3_move_test2
			call	sp3_move_test3
			call	sp3_move_test4
			call	sp3_move_test5

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
			; R#0 = 0x06
			ld		a, 0x06
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
			ld		a, 0x08					; スプライト表示, VR=1
			ld		e, 8
			call	write_control_register
			; R#9 = 0x80
			ld		a, 0x80					; 212line
			ld		e, 9
			call	write_control_register
			; R#18 = 0
			xor		a, a
			ld		e, 18
			call	write_control_register
			; R#20 = 0x19
			ld		a, 0x19						; Sprite mode3, Extended palette mode, High speed VDP command
			ld		e, 20
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
			; R#6 = Sprite pattern generator table
			ld		a, 0x8000 >> 11
			ld		e, 6
			call	write_control_register
			; R#5 = 0   Sprite attribute table (LOW)
			ld		a, 0x7600 >> 7
			ld		e, 5
			call	write_control_register
			; R#11 = 1  Sprite attribute table (HIGH)
			ld		a, 0
			ld		e, 11
			call	write_control_register
			; Pattern Name Table をクリア
			jp		cls
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

			xor		a, a
			ld		[vram_bit16], a
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

			xor		a, a
			ld		[vram_bit16], a
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
;	[SCREEN5] cls
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
			call	wait_command
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command

			; VDPコマンド完了待ち
			call	wait_command
			; スプライトアトリビュートを初期化
			xor		a, a
			ld		[vram_bit16], a
			ld		hl, 0x7600
			ld		bc, 64 * 8
			ld		e, 216
			call	fill_vram

			call	s5_load_image
			ret
	data:
			dw		0			; DX
			dw		0			; DY
			dw		256			; NX
			dw		1024		; NY
			db		0x44		; CLR
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xC0		; CMD (HMMV)
			endscope

; =============================================================================
;	[SCREEN5] wait
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
			ld		bc, 5000
	loop:
			dec		bc
			ld		a, c
			or		a, b
			jr		nz, loop
			ret
			endscope

; =============================================================================
;	[SCREEN5] 表示テスト
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp3_move_test
sp3_move_test::
			; ループ
	loop:
			; 右へ移動
			ld		hl, [attribute0_x]
			inc		hl
			ld		a, h
			and		a, 0x03
			ld		h, a
			ld		[attribute0_x], hl
			ld		[attribute1_x], hl
			ld		[attribute2_x], hl
			ld		[attribute3_x], hl
			ld		de, 256
			or		a, a
			sbc		hl, de
			jr		z, exit_loop
			; put sprite
			ld		hl, attribute
			ld		de, 0x7600
			ld		bc, 8 * 4
			call	block_copy
			call	wait
			jp		loop
	exit_loop:
			; キー待ち
			call	wait_push_space_key
			ret
	attribute:
	attribute0_y:
			dw		0					; Y
	attribute0_mgy:
			db		16					; MGY
	attribute0_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute0_x:
			dw		-16 & 0x3FF			; X
	attribute0_mgx:
			db		16					; MGX
	attribute0_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute1_y:
			dw		20					; Y
	attribute1_mgy:
			db		16					; MGY
	attribute1_color:
			db		0x40				; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute1_x:
			dw		-16 & 0x3FF			; X
	attribute1_mgx:
			db		16					; MGX
	attribute1_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute2_y:
			dw		40					; Y
	attribute2_mgy:
			db		16					; MGY
	attribute2_color:
			db		0x80				; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute2_x:
			dw		-16 & 0x3FF			; X
	attribute2_mgx:
			db		16					; MGX
	attribute2_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute3_y:
			dw		60					; Y
	attribute3_mgy:
			db		16					; MGY
	attribute3_color:
			db		0xC0				; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute3_x:
			dw		-16 & 0x3FF			; X
	attribute3_mgx:
			db		16					; MGX
	attribute3_pattern:
			db		0					; PatternY(4), PatternX(4)
			endscope

; =============================================================================
;	[SCREEN5] 表示テスト
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp3_move_test2
sp3_move_test2::
			; ループ
	loop:
			; 右へ移動
			ld		hl, [attribute0_x]
			inc		hl
			ld		a, h
			and		a, 0x03
			ld		h, a
			ld		[attribute0_x], hl
			ld		[attribute1_x], hl
			ld		[attribute2_x], hl
			ld		[attribute3_x], hl
			ld		de, 256
			or		a, a
			sbc		hl, de
			jr		z, exit_loop
			; put sprite
			ld		hl, attribute
			ld		de, 0x7600
			ld		bc, 8 * 4
			call	block_copy
			call	wait
			jp		loop
	exit_loop:
			; キー待ち
			call	wait_push_space_key
			ret
	attribute:
	attribute0_y:
			dw		0					; Y
	attribute0_mgy:
			db		16					; MGY
	attribute0_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute0_x:
			dw		-16 & 0x3FF			; X
	attribute0_mgx:
			db		16					; MGX
	attribute0_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute1_y:
			dw		20					; Y
	attribute1_mgy:
			db		16					; MGY
	attribute1_color:
			db		0x10				; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute1_x:
			dw		-16 & 0x3FF			; X
	attribute1_mgx:
			db		16					; MGX
	attribute1_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute2_y:
			dw		40					; Y
	attribute2_mgy:
			db		16					; MGY
	attribute2_color:
			db		0x20				; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute2_x:
			dw		-16 & 0x3FF			; X
	attribute2_mgx:
			db		16					; MGX
	attribute2_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute3_y:
			dw		60					; Y
	attribute3_mgy:
			db		16					; MGY
	attribute3_color:
			db		0x30				; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute3_x:
			dw		-16 & 0x3FF			; X
	attribute3_mgx:
			db		16					; MGX
	attribute3_pattern:
			db		0					; PatternY(4), PatternX(4)
			endscope

; =============================================================================
;	[SCREEN5] 拡大表示テスト
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp3_move_test3
sp3_move_test3::
			; ループ
	loop:
			; 右へ移動
			ld		hl, [attribute0_mgx]
			inc		hl
			ld		a, l
			ld		[attribute0_mgx], a
			ld		[attribute0_mgy], a
			ld		de, 256
			or		a, a
			sbc		hl, de
			jr		z, exit_loop
			; put sprite
			ld		hl, attribute
			ld		de, 0x7600
			ld		bc, 8 * 1
			call	block_copy
			call	wait
			jp		loop
	exit_loop:
			; キー待ち
			call	wait_push_space_key
			ret
	attribute:
	attribute0_y:
			dw		0					; Y
	attribute0_mgy:
			db		1					; MGY
	attribute0_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute0_x:
			dw		0					; X
	attribute0_mgx:
			db		1					; MGX
	attribute0_pattern:
			db		0					; PatternY(4), PatternX(4)
			endscope

; =============================================================================
;	[SCREEN5] 表示テスト
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp3_move_test4
sp3_move_test4::
			; put sprite
			ld		hl, attribute
			ld		de, 0x7600
			ld		bc, 8 * 16
			call	block_copy
			; キー待ち
			call	wait_push_space_key
			call	cls
			ret
	attribute:
	attribute0_y:
			dw		0					; Y
	attribute0_mgy:
			db		16					; MGY
	attribute0_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute0_x:
			dw		16 * 0				; X
	attribute0_mgx:
			db		16					; MGX
	attribute0_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute1_y:
			dw		0					; Y
	attribute1_mgy:
			db		17					; MGY
	attribute1_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute1_x:
			dw		16 * 1				; X
	attribute1_mgx:
			db		16					; MGX
	attribute1_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute2_y:
			dw		0					; Y
	attribute2_mgy:
			db		18					; MGY
	attribute2_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute2_x:
			dw		16 * 2				; X
	attribute2_mgx:
			db		16					; MGX
	attribute2_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute3_y:
			dw		0					; Y
	attribute3_mgy:
			db		19					; MGY
	attribute3_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute3_x:
			dw		16 * 3				; X
	attribute3_mgx:
			db		16					; MGX
	attribute3_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute4_y:
			dw		0					; Y
	attribute4_mgy:
			db		20					; MGY
	attribute4_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute4_x:
			dw		16 * 4				; X
	attribute4_mgx:
			db		16					; MGX
	attribute4_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute5_y:
			dw		0					; Y
	attribute5_mgy:
			db		21					; MGY
	attribute5_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute5_x:
			dw		16 * 5				; X
	attribute5_mgx:
			db		16					; MGX
	attribute5_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute6_y:
			dw		0					; Y
	attribute6_mgy:
			db		22					; MGY
	attribute6_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute6_x:
			dw		16 * 6				; X
	attribute6_mgx:
			db		16					; MGX
	attribute6_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute7_y:
			dw		0					; Y
	attribute7_mgy:
			db		23					; MGY
	attribute7_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute7_x:
			dw		16 * 7				; X
	attribute7_mgx:
			db		16					; MGX
	attribute7_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute8_y:
			dw		0					; Y
	attribute8_mgy:
			db		24					; MGY
	attribute8_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute8_x:
			dw		16 * 8				; X
	attribute8_mgx:
			db		16					; MGX
	attribute8_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute9_y:
			dw		0					; Y
	attribute9_mgy:
			db		25					; MGY
	attribute9_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute9_x:
			dw		16 * 9				; X
	attribute9_mgx:
			db		16					; MGX
	attribute9_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute10_y:
			dw		0					; Y
	attribute10_mgy:
			db		26					; MGY
	attribute10_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute10_x:
			dw		16 * 10				; X
	attribute10_mgx:
			db		16					; MGX
	attribute10_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute11_y:
			dw		0					; Y
	attribute11_mgy:
			db		27					; MGY
	attribute11_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute11_x:
			dw		16 * 11				; X
	attribute11_mgx:
			db		16					; MGX
	attribute11_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute12_y:
			dw		0					; Y
	attribute12_mgy:
			db		28					; MGY
	attribute12_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute12_x:
			dw		16 * 12				; X
	attribute12_mgx:
			db		16					; MGX
	attribute12_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute13_y:
			dw		0					; Y
	attribute13_mgy:
			db		29					; MGY
	attribute13_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute13_x:
			dw		16 * 13				; X
	attribute13_mgx:
			db		16					; MGX
	attribute13_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute14_y:
			dw		0					; Y
	attribute14_mgy:
			db		30					; MGY
	attribute14_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute14_x:
			dw		16 * 14				; X
	attribute14_mgx:
			db		16					; MGX
	attribute14_pattern:
			db		0					; PatternY(4), PatternX(4)

	attribute15_y:
			dw		0					; Y
	attribute15_mgy:
			db		31					; MGY
	attribute15_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute15_x:
			dw		16 * 15				; X
	attribute15_mgx:
			db		16					; MGX
	attribute15_pattern:
			db		0					; PatternY(4), PatternX(4)
			endscope

; =============================================================================
;	[SCREEN5] 表示テスト
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sp3_move_test5
sp3_move_test5::
			; put sprite
			ld		hl, attribute
			ld		de, [address]
			ld		bc, 8 * 1
			call	block_copy
			; キー待ち
			call	wait_push_space_key
			; アドレス移動
			ld		hl, [address]
			ld		de, 8
			add		hl, de
			ld		[address], hl
			; X移動
			ld		a, [attribute0_x]
			add		a, 16
			ld		[attribute0_x], a
			jr		nz, skip_y
			; Y移動
			ld		a, [attribute0_y]
			add		a, 16
			ld		[attribute0_y], a
			cp		a, 64
			jr		nc, exit_loop
	skip_y:
			jp		sp3_move_test5
	exit_loop:
			; 1つずつ消していく
			ld		a, 216
			ld		[attribute0_y], a
	loop2:
			; アドレス移動
			ld		hl, [address]
			ld		de, -8
			add		hl, de
			ld		[address], hl
			; put sprite
			ex		de, hl
			ld		hl, attribute
			ld		bc, 8 * 1
			call	block_copy
			; キー待ち
			call	wait_push_space_key
			ld		a, [address + 1]
			cp		a, 0x76
			jr		nc, loop2
			ret
	address:
			dw		0x7600
	attribute:
	attribute0_y:
			dw		0					; Y
	attribute0_mgy:
			db		16					; MGY
	attribute0_color:
			db		0					; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute0_x:
			dw		0					; X
	attribute0_mgx:
			db		16					; MGX
	attribute0_pattern:
			db		0					; PatternY(4), PatternX(4)
			endscope

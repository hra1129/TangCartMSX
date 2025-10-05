; =============================================================================
;	V9958 demonstration program
; -----------------------------------------------------------------------------
;	Programmed by t.hara (HRA!)
; =============================================================================

			org		0x100

buffer		:= 0x8000

start:
			; 準備
			call	vdp_io_select
			di
			call	screen5
			call	load_logo_image
			call	put_sprites
			call	rotate_logo

			call	wait_push_space_key
			ei
			; 後始末
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
;;;			ld		a, 0x1F
			ld		a, 0x3F
			ld		e, 2
			call	write_control_register
			; R#7 = 0x07
			ld		a, 0x09					; 周辺色 9
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
			; R#20 = 0xFF
			ld		a, 0xFF						; Sprite mode3, Extended palette mode, High speed VDP command
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
			; R#6 Sprite pattern generator table
			ld		a, (128 * (256 + 128)) >> 11
			ld		e, 6
			call	write_control_register
			; R#5 Sprite attribute table (LOW)
			ld		a, 0x7600 >> 7
			ld		e, 5
			call	write_control_register
			; R#11 Sprite attribute table (HIGH)
			ld		a, 0
			ld		e, 11
			call	write_control_register
			; Pattern Name Table をクリア
			jp		cls
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
			ret
	data:
			dw		0			; DX
			dw		0			; DY
			dw		256			; NX
			dw		1024		; NY
			db		0x99		; CLR
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xC0		; CMD (HMMV)
			endscope

; =============================================================================
;	ファイルのオープン
;	input:
;		DE ..... ファイル名
;		A ...... オープンモード
;	output:
;		A ...... エラーコード
;		B ...... ファイルハンドル
;	break:
;		all
;	comment:
;		none
; =============================================================================
			scope	fopen
fopen::
			ld		c, _OPEN
			call	bdos
			ret
			endscope

; =============================================================================
;	ファイルのオープン
;	input:
;		B ...... ファイルハンドル
;	output:
;		none
;	break:
;		all
;	comment:
;		none
; =============================================================================
			scope	fclose
fclose::
			ld		c, _CLOSE
			call	bdos
			ret
			endscope

; =============================================================================
;	ファイルリード
;	input:
;		B ...... ファイルハンドル
;		DE ..... 結果の格納アドレス
;		HL ..... 読み込むサイズ
;	output:
;		none
;	break:
;		all
;	comment:
;		none
; =============================================================================
			scope	fread
fread::
			ld		c, _READ
			call	bdos
			ret
			endscope

; =============================================================================
;	ロゴ画像を読み込みます
;	input:
;		none
;	output:
;		none
;	break:
;		all
;	comment:
;		none
; =============================================================================
			scope	load_logo_image
load_logo_image::
			; パレットを設定
			; -- R#16 = 0
			xor		a, a
			ld		e, 16
			call	write_control_register
			ld		a, [io_vdp_port2]
			ld		c, a
			xor		a, a
			out		[c], a					; R0
			out		[c], a					; G0
			out		[c], a					; B0
			ld		b, 8
	loop:
			out		[c], a					; R
			out		[c], a					; G
			out		[c], a					; B
			add		a, 4
			djnz	loop
			ld		a, 2 << 2;				; R9
			out		[c], a					; R
			ld		a, 3 << 2;				; G9
			out		[c], a					; G
			ld		a, 7 << 2;				; B9
			out		[c], a					; B

			; ファイルから読み込み
			ld		de, s_logo_name
			xor		a, a
			call	fopen
			push	bc
			ld		hl, 208 * 78 / 2		; サイズ
			ld		de, buffer				; バッファアドレス
			call	fread
			pop		bc
			call	fclose
			; 裏画面へ転送
			ld		hl, command_data
			ld		a, 36
			ld		b, 8
			call	run_command
			ld		a, [io_vdp_port3]
			ld		c, a
			ld		de, buffer
			ld		a, [de]
			out		[c], a		; R#44 CLR
			inc		de
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#45
			ld		a, [hl]
			inc		hl
			out		[c], a		; R#46

			ld		hl, (208 >> 1) * 78 - 1
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
	loop2:
			in		a, [c]		; A=S#2
			rlca
			jr		nc, loop2
			inc		c
			inc		c
			ld		a, [de]
			out		[c], a
			inc		de
			dec		c
			dec		c
			dec		hl
			ld		a, l
			or		a, h
			jr		nz, loop2
			call	wait_command
			ret
	command_data:
			dw		0			; DX
			dw		256			; DY
			dw		208			; NX
			dw		78			; NY
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xF0		; CMD (HMMC)
	s_logo_name:
			db		"LOGO.BIN", 0
			endscope

; =============================================================================
;	page0 をスプライトで埋め尽くす
;	input:
;		none
;	output:
;		none
;	break:
;		all
;	comment:
;		none
; =============================================================================
			scope	put_sprites
put_sprites::
			ld		b, 13
	loop:
			push	bc
			; スプライトを１枚表示する
			ld		hl, attribute
			ld		de, [address]
			ld		bc, 8
			call	block_copy
			; 次へ移動
			ld		hl, [address]
			ld		de, 8
			add		hl, de
			ld		[address], hl
			ld		a, [attribute_x]
			add		a, 16
			ld		[attribute_x], a
			ld		a, [attribute_pattern]
			inc		a
			ld		[attribute_pattern], a
			pop		bc
			djnz	loop
			ret

	address:
			dw		0x7600
	attribute:
	attribute_y:
			dw		0 | (3 << 14)		; Y, SZ=3 (16x128)
	attribute_mgy:
			db		128					; MGY
	attribute_color:
			db		0x80				; Transparent(2), ReverseY(1), ReverseX(1), Palette Set(4)
	attribute_x:
			dw		24 | (0 << 12)		; X
	attribute_mgx:
			db		16					; MGX
	attribute_pattern:
			db		0					; PatternY(4), PatternX(4)
			endscope

; =============================================================================
;	スプライトジェネレーターにロゴを描く
;	input:
;		none
;	output:
;		none
;	break:
;		all
;	comment:
;		none
; =============================================================================
			scope	rotate_logo
rotate_logo::
			; 回転角に対応するテーブルを引く
			ld		hl, [theta]
			ld		h, 0
			add		hl, hl
			add		hl, hl
			add		hl, hl
			ld		de, vector_table
			add		hl, de
			; -- VX
			ld		e, [hl]
			inc		hl
			ld		d, [hl]
			inc		hl
			ld		[command_vx], de
			; -- VY
			ld		e, [hl]
			inc		hl
			ld		d, [hl]
			inc		hl
			ld		[command_vy], de
			; -- SX
			ld		e, [hl]
			inc		hl
			ld		d, [hl]
			inc		hl
			ld		[command_sx], de
			; -- SY
			ld		e, [hl]
			inc		hl
			ld		d, [hl]
			inc		hl
			ld		[command_sy], de
			; コマンドの実行完了待ち
			call	wait_command
			; コマンドを発行する
			ld		hl, rotate_vector
			ld		a, 47
			ld		b, 12
			call	run_command
			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			; 次の角度へ
			ld		a, [theta]
			inc		a
			jr		nz, skip
			ld		a, 128
		skip:
			ld		[theta], a
			jp		rotate_logo

			call	wait_command
			ret
	rotate_vector::
	command_vx:
			dw		256			; VX
	command_vy:
			dw		0			; VY
			dw		0			; WSX
			dw		0 + 256		; WSY
			dw		207			; WEX
			dw		78 + 256	; WEY
	data:
	command_sx:
			dw		0			; SX
	command_sy:
			dw		256			; SY
			dw		0			; DX
			dw		128 + 256	; DY
			dw		208			; NX (dummy)
			dw		208			; NY
			db		0			; CLR (dummy)
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0x30		; CMD (LRMM)
	theta:
			db		0
	vector_table:
			include "resource/rotate.txt"
			endscope

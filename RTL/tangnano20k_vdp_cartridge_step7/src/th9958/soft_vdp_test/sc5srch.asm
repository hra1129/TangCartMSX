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
			call	test011
			call	test012
			call	test013
			call	test014
			call	test015
			call	test016
			call	test017
			call	test018
			call	test019
			call	test020
			call	test021
			call	test022

			xor		a, a
			ld		e, 15
			call	write_control_register
			ei

			; 後始末
			call	clear_key_buffer

			scope	result_dump1
			; 結果を表示
			ld		hl, test001_result
			ld		b, 19
	result_loop:
			push	bc
			; dump S#2 1st CE=0
			push	hl
			ld		l, [hl]		; +0 S#2 1st CE=0
			call	put_l
			pop		hl
			inc		hl

			; dump S#2 2nd
			push	hl
			ld		l, [hl]		; +1 S#2 2nd
			call	put_l
			pop		hl
			inc		hl

			; dump BX
			ld		e, [hl]		; +2 BX 1st LSB
			inc		hl
			ld		a, [hl]		; +3 S#2 3rd
			inc		hl
			ld		d, [hl]		; +4 BX 1st MSB
			inc		hl
			push	hl
			push	af
			ex		de, hl
			call	put_hl
			pop		af

			ld		l, a		;    S#2 3rd
			call	put_l
			pop		hl

			push	hl
			ld		l, [hl]		; +5 S#2 4th
			call	put_l
			pop		hl
			inc		hl

			ld		e, [hl]		; +6 BX 2nd LSB
			inc		hl
			ld		d, [hl]		; +7 BX 2nd MSB
			inc		hl
			push	hl
			ex		de, hl
			call	put_hl
			pop		hl

			; dump S#2 5th
			push	hl
			ld		l, [hl]		; +8 S#2 5th
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
			endscope

			scope	result_dump2
			; 結果を表示
			ld		hl, test020_result
			ld		b, 3
	result_loop:
			push	bc
			; dump S#2 1st CE=0
			push	hl
			ld		l, [hl]		; +0 S#2 1st CE=0
			call	put_l
			pop		hl
			inc		hl

			; dump S#2 2nd
			push	hl
			ld		l, [hl]		; +1 S#2 2nd
			call	put_l
			pop		hl
			inc		hl

			; dump BX
			ld		e, [hl]		; +2 BX 1st LSB
			inc		hl
			ld		a, [hl]		; +3 S#2 3rd
			inc		hl
			ld		d, [hl]		; +4 BX 1st MSB
			inc		hl
			push	hl
			push	af
			ex		de, hl
			call	put_hl
			pop		af

			ld		l, a		;    S#2 3rd
			call	put_l
			pop		hl

			push	hl
			ld		l, [hl]		; +5 S#2 4th
			call	put_l
			pop		hl
			inc		hl

			ld		e, [hl]		; +6 BX 2nd LSB
			inc		hl
			ld		d, [hl]		; +7 BX 2nd MSB
			inc		hl
			push	hl
			ex		de, hl
			call	put_hl
			pop		hl

			; dump S#2 5th
			push	hl
			ld		l, [hl]		; +8 S#2 5th
			call	put_l
			pop		hl
			inc		hl

			; dump S#2 6th
			push	hl
			ld		l, [hl]		; +9 S#2 6th
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
			endscope

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
			ld		hl, (20 >> 1) + (30 * 128)		;	( 20, 30 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data1
			ld		b, 15
			call	write_data

			ld		hl, (20 >> 1) + (33 * 128)		;	( 20, 33 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data2
			ld		b, 8
			call	write_data

			ld		hl, (20 >> 1) + (36 * 128)		;	( 20, 36 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data3
			ld		b, 10
			call	write_data

			ld		hl, (20 >> 1) + (39 * 128)		;	( 20, 39 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data4
			ld		b, 10
			call	write_data

			ld		hl, (20 >> 1) + (42 * 128)		;	( 20, 42 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data5
			ld		b, 15
			call	write_data

			ld		hl, (20 >> 1) + (45 * 128)		;	( 20, 45 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data6
			ld		b, 15
			call	write_data

			ld		hl, (20 >> 1) + (48 * 128)		;	( 20, 48 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data7
			ld		b, 15
			call	write_data

			ld		hl, (20 >> 1) + (51 * 128)		;	( 20, 51 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data8
			ld		b, 15
			call	write_data

			ld		hl, 113 + (60 * 128)		;	( 226, 60 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data11
			ld		b, 15
			call	write_data

			ld		hl, 120 + (63 * 128)		;	( 240, 63 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data12
			ld		b, 8
			call	write_data

			ld		hl, 118 + (66 * 128)		;	( 236, 66 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data13
			ld		b, 10
			call	write_data

			ld		hl, 118 + (69 * 128)		;	( 236, 69 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data14
			ld		b, 10
			call	write_data

			ld		hl, 0 + (72 * 128)		;	( 0, 72 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data15
			ld		b, 15
			call	write_data

			ld		hl, 0 + (75 * 128)		;	( 0, 75 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data16
			ld		b, 15
			call	write_data

			ld		hl, 0 + (78 * 128)		;	( 0, 78 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data17
			ld		b, 15
			call	write_data

			ld		hl, 0 + (81 * 128)		;	( 0, 81 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data18
			ld		b, 15
			call	write_data

			ld		hl, 0 + (83 * 128)		;	( 0, 83 ) にアドレスセット
			call	set_vram_write_address
			ld		hl, data19
			ld		b, 90
			call	write_data
			ret

	write_data:
			ld		a, [hl]
			call	write_vram
			inc		hl
			djnz	write_data
			ret

	data1:	;	( 20, 30 )
			db		0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF	; 15byte
	data2:	;	( 20, 33 )
			db		0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0												; 8byte
	data3:	;	( 20, 36 )
			db		0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0xAA									; 10byte
	data4:	;	( 20, 39 )
			db		0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x5A									; 10byte
	data5:	;	( 20, 42 )
			db		0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF	; 15byte
	data6:	;	( 20, 45 )
			db		0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0	; 15byte
	data7:	;	( 20, 48 )
			db		0x44, 0x44, 0x44, 0x44, 0x44, 0xAA, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33	; 15byte
	data8:	;	( 20, 51 )
			db		0x44, 0x44, 0x44, 0x44, 0x44, 0xA5, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55	; 15byte
	data11:	;	( 226, 60 )
			db		0x11, 0x22, 0x33, 0x44, 0x55, 0x00, 0x77, 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF	; 15byte
	data12:	;	( 240, 63 )
			db		0x12, 0x34, 0x56, 0x78, 0x9A, 0xBB, 0xDE, 0xF0												; 8byte
	data13:	;	( 236, 66 )
			db		0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33									; 10byte
	data14:	;	( 236, 69 )
			db		0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55									; 10byte
	data15:	;	( 0, 72 )
			db		0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, 0x76, 0xCC, 0xDD, 0xEE, 0xFF	; 15byte
	data16:	;	( 0, 75 )
			db		0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x12, 0x34, 0x56, 0x58, 0x9A, 0xBC, 0xDE, 0xF0	; 15byte
	data17:	;	( 0, 78 )
			db		0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x30	; 15byte
	data18:	;	( 0, 81 )
			db		0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55	; 15byte
	data19:	;	( 0, 83 )
			db		0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55	; 15byte
			db		0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55	; 30byte
			db		0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55	; 45byte
			db		0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55	; 60byte
			db		0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55	; 75byte
			db		0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x5A	; 90byte
			endscope

; =============================================================================
;	ステータスレジスタの読みだしと結果格納
; =============================================================================
			scope	read_status_bx
read_status_bx::
			;	S#2 CE=0
			ld		a, [last_s2]
			and		a, 0x11
			ld		[hl], a				; +0 write
			inc		hl					; +1

			;	S#2 2nd
			ld		e, 2
			call	read_status_register
			ld		a, e
			and		a, 0x11
			ld		[hl], a				; +1 write
			inc		hl					; +2

			;	BX 1st LSB
			ld		e, 8
			call	read_status_register
			ld		[hl], e				; +2 write
			inc		hl					; +3

			;	S#2 3rd
			ld		e, 2
			call	read_status_register
			ld		a, e
			and		a, 0x11
			ld		[hl], a				; +3 write
			inc		hl					; +4

			;	BX 1st MSB
			ld		e, 9
			call	read_status_register
			ld		[hl], e				; +4 write
			inc		hl					; +5

			;	S#2 4th
			ld		e, 2
			call	read_status_register
			ld		a, e
			and		a, 0x11
			ld		[hl], a				; +5 write
			inc		hl					; +6

			;	BX 2nd LSB
			ld		e, 8
			call	read_status_register
			ld		[hl], e				; +6 write
			inc		hl					; +7
			;	BX 2nd MSB
			ld		e, 9
			call	read_status_register
			ld		[hl], e				; +7 write
			inc		hl					; +8

			;	S#2 5th
			ld		e, 2
			call	read_status_register
			ld		a, e
			and		a, 0x11
			ld		[hl], a				; +8 write
			ret
			endscope

; =============================================================================
;	HL の値を表示
; =============================================================================
			scope	put_hl
put_hl::
			ld		a, h
			push	hl
			call	put_hex
			pop		hl
put_l::
			ld		a, l
			call	put_hex

			ld		e, ' '
			ld		c, 2
			call	bdos
			ret

	put_hex:
			ld		b, a
			push	bc
			rrca
			rrca
			rrca
			rrca
			call	put_one
			pop		af
	put_one:
			and		a, 0x0F
			add		a, '0'
			cp		a, '9'+1
			jr		c, skip
			add		a, 'A'-('9'+1)
	skip:
			ld		e, a
			ld		c, 2
			call	bdos
			ret
			endscope

; =============================================================================
;	右探索 境界色
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
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test001_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		20			; SX
			dw		30			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		6			; CLR
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
			scope	test002
test002::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test002_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		20			; SX
			dw		33			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		12			; CLR
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
;	左探索 境界色
; =============================================================================
			scope	test003
test003::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test003_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		49			; SX
			dw		42			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		11			; CLR
			db		0b0000100	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
			scope	test004
test004::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test004_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		49			; SX
			dw		45			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		7			; CLR
			db		0b0000100	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
;	右探索 境界色以外
; =============================================================================
			scope	test005
test005::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test005_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		20			; SX
			dw		36			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		3			; CLR
			db		0b0000010	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
			scope	test006
test006::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test006_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		20			; SX
			dw		39			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		5			; CLR
			db		0b0000010	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
;	左探索 境界色以外
; =============================================================================
			scope	test007
test007::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test007_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		49			; SX
			dw		48			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		3			; CLR
			db		0b0000110	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
			scope	test008
test008::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test008_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		49			; SX
			dw		51			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		5			; CLR
			db		0b0000110	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
;	右探索 始点が画面外
; =============================================================================
			scope	test009
test009::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test009_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		345			; SX
			dw		123			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		15			; CLR
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
;	左探索 始点が画面外
; =============================================================================
			scope	test010
test010::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test010_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		456			; SX
			dw		346			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		12			; CLR
			db		0b0000110	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
;	右探索 境界色
; =============================================================================
			scope	test011
test011::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test011_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		226			; SX
			dw		60			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		6			; CLR
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
			scope	test012
test012::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test012_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		240			; SX
			dw		63			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		12			; CLR
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
;	左探索 境界色
; =============================================================================
			scope	test013
test013::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test013_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		28			; SX
			dw		72			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		11			; CLR
			db		0b0000100	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
			scope	test014
test014::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test014_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		29			; SX
			dw		75			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		7			; CLR
			db		0b0000100	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
;	右探索 境界色以外
; =============================================================================
			scope	test015
test015::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test015_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		236			; SX
			dw		66			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		3			; CLR
			db		0b0000010	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
			scope	test016
test016::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test016_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		236			; SX
			dw		69			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		5			; CLR
			db		0b0000010	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
;	左探索 境界色以外
; =============================================================================
			scope	test017
test017::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test017_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		28			; SX
			dw		78			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		3			; CLR
			db		0b0000110	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
			scope	test018
test018::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test018_result
			call	read_status_bx
			call	wait_push_space_key
			ret
	data:
			dw		29			; SX
			dw		81			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		5			; CLR
			db		0b0000110	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
;	右探索 境界色 → 右探索 未検出
; =============================================================================
			scope	test0
test019::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data1				; BD=1 になるコマンド
			ld		a, 32
			ld		b, 15
			call	run_command

			; Wait finish SRCH command (NOT READ S#2!!)
			ld		b, 0
	wait_loop1:
			nop
			djnz	wait_loop1
			; BD = 1

			ld		hl, data2				; BD=0 になるコマンド
			ld		a, 32
			ld		b, 15
			call	run_command

			; Wait finish SRCH command (NOT READ S#2!!)
			ld		b, 0
	wait_loop2:
			nop
			djnz	wait_loop2
			; Not detect border

			;	S#2 CE=0
			ld		e, 2
			call	read_status_register
			ld		a, e
			ld		[last_s2],a 

			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test019_result
			call	read_status_bx
			call	wait_push_space_key
			ret

	data1:
			dw		20			; SX
			dw		30			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		6			; CLR
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)

	data2:
			dw		226			; SX
			dw		60			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		6			; CLR
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
;	右探索 BD=1 → 境界色 → 即ステータスリード
; =============================================================================
			scope	test020
test020::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		a, 2
			ld		e, 15
			call	write_control_register

			ld		hl, data1				; BD=1 になるコマンド
			ld		a, 32
			ld		b, 15
			call	run_command

			; Wait finish SRCH command (NOT READ S#2!!)
			; S#2 を読みだすと、BD bit (bit4)がクリアされるのではないか？という疑惑のために、S#2 を読まないで対処
			; 実際のところ、S#2 を読んでも、BD bit はクリアされないことが分かった。
			ld		b, 0
	wait_loop1:
			nop
			djnz	wait_loop1
			; BD = 1

			ld		hl, data2
			ld		a, 32
			ld		b, 15
			call	run_command

			; Read S#2
			ld		a, [io_vdp_port1]
			ld		c, a
			in		a, [c]
			and		a, 0x11
			push	af

			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test020_result
			call	read_status_bx

			pop		af
			ld		[test020_result + 9], a

			ld		a, 0
			ld		e, 15
			call	write_control_register

			call	wait_push_space_key
			ret

	data1:
			dw		20			; SX
			dw		30			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		6			; CLR
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)

	data2:
			dw		0			; SX
			dw		83			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		1			; CLR
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
;	右探索 BD=0 → 境界色 → 即ステータスリード
; =============================================================================
			scope	test021
test021::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			;	S#9 BX MSB (Clear BD)
			ld		e, 9
			call	read_status_register
			; BD = 0

			ld		a, 2
			ld		e, 15
			call	write_control_register

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command

			; Read S#2
			ld		a, [io_vdp_port1]
			ld		c, a
			in		a, [c]
			and		a, 0x11
			push	af

			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test021_result
			call	read_status_bx

			pop		af
			ld		[test021_result + 9], a

			call	wait_push_space_key
			ret

	data:
			dw		0			; SX
			dw		83			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		1			; CLR
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
;	右探索 BD=0 → 境界色 → 即ステータスリード
; =============================================================================
			scope	test022
test022::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		a, 2
			ld		e, 15
			call	write_control_register

			ld		hl, data1
			ld		a, 32
			ld		b, 15
			call	run_command

			; Wait finish SRCH command (NOT READ S#2!!)
			ld		b, 0
	wait_loop1:
			nop
			djnz	wait_loop1
			; BD = 0

			ld		hl, data2
			ld		a, 32
			ld		b, 15
			call	run_command

			; Read S#2
			ld		a, [io_vdp_port1]
			ld		c, a
			in		a, [c]
			and		a, 0x11
			push	af

			call	wait_command
			; ステータスレジスタを読んで、結果保管場所に書き込む
			ld		hl, test022_result
			call	read_status_bx

			pop		af
			ld		[test022_result + 9], a

			call	wait_push_space_key
			ret

	data1:
			dw		226			; SX
			dw		60			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		6			; CLR
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)

	data2:
			dw		0			; SX
			dw		83			; SY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		1			; CLR
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-] EQ=0: 不一致でインクリメント, EQ=1: 一致でインクリメント
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
			scope	results
test001_result::
			db		0,0,0,0,0,0,0,0,0
test002_result::
			db		0,0,0,0,0,0,0,0,0
test003_result::
			db		0,0,0,0,0,0,0,0,0
test004_result::
			db		0,0,0,0,0,0,0,0,0
test005_result::
			db		0,0,0,0,0,0,0,0,0
test006_result::
			db		0,0,0,0,0,0,0,0,0
test007_result::
			db		0,0,0,0,0,0,0,0,0
test008_result::
			db		0,0,0,0,0,0,0,0,0
test009_result::
			db		0,0,0,0,0,0,0,0,0
test010_result::
			db		0,0,0,0,0,0,0,0,0
test011_result::
			db		0,0,0,0,0,0,0,0,0
test012_result::
			db		0,0,0,0,0,0,0,0,0
test013_result::
			db		0,0,0,0,0,0,0,0,0
test014_result::
			db		0,0,0,0,0,0,0,0,0
test015_result::
			db		0,0,0,0,0,0,0,0,0
test016_result::
			db		0,0,0,0,0,0,0,0,0
test017_result::
			db		0,0,0,0,0,0,0,0,0
test018_result::
			db		0,0,0,0,0,0,0,0,0
test019_result::
			db		0,0,0,0,0,0,0,0,0
test020_result::
			db		0,0,0,0,0,0,0,0,0,0
test021_result::
			db		0,0,0,0,0,0,0,0,0,0
test022_result::
			db		0,0,0,0,0,0,0,0,0,0
			endscope

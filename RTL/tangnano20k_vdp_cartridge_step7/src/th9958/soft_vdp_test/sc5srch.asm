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
			call	test001

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
			call	wait_push_space_key
			ret

	write_data:
			ld		a, [hl]
			call	write_vram
			inc		hl
			djnz	write_data
			ret

	data1:
			db		0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF	; 15byte
	data2:
			db		0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0												; 8byte
	data3:
			db		0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0xAA									; 10byte
	data4:
			db		0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x5A									; 10byte
	data5:
			db		0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF	; 15byte
	data6:
			db		0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x44, 0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0	; 15byte
	data7:
			db		0x44, 0x44, 0x44, 0x44, 0x44, 0xAA, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33	; 15byte
	data8:
			db		0x44, 0x44, 0x44, 0x44, 0x44, 0xA5, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55, 0x55	; 15byte
			endscope

; =============================================================================
;	右探索
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
			ld		e, 8
			call	read_status_register
			ld		[test001_result + 0], a
			ld		e, 9
			call	read_status_register
			ld		[test001_result + 1], a
			ret
	data:
			dw		20			; DX
			dw		30			; DY
			dw		0			; DX (dummy)
			dw		0			; DY (dummy)
			dw		0			; NX (dummy)
			dw		0			; NY (dummy)
			db		15			; CLR
			db		0b0000000	; ARG [-][-][-][-][-][DIX][EQ][-]
			db		0x60		; CMD (SRCH)
			endscope

; =============================================================================
			scope	results
test001_result:
			dw		0
			endscope

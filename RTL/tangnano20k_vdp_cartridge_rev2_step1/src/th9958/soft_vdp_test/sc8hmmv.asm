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
			call	screen8

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
;	SCREEN8
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen8
screen8::
			; R#0 = 0x0E
			ld		a, 0x0E
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
			; R#8 = 0x0A
			ld		a, 0x0A					; スプライト非表示
			ld		e, 8
			call	write_control_register
			; R#9 = 0x00
			ld		a, 0x00					; 192line
			ld		e, 9
			call	write_control_register
			; Pattern Name Table R#2 = 0b00p11111 : p = page
			ld		a, 0b00011111
			ld		e, 2
			call	write_control_register
			; Sprite Attribute Table
			ld		hl, 0xFA00
			call	set_sprite_attribute_table
			; Sprite Pattern Generator Table
			ld		hl, 0xF000
			call	set_sprite_pattern_generator_table
			; Pattern Name Table をクリア
			ld		hl, 0x0000
			call	set_vram_write_address

			xor		a, a
			ld		b, 4
	loop_blue_block_width:
			push	bc						; -- 4ループカウンタ保存
			push	af

			ld		b, 8
	loop_green_block_width:
			push	bc						; -- 8ループカウンタ保存

			ld		b, 6
	loop_red_line:
			push	bc						; -- 6ループカウンタ保存
			push	af

			ld		b, 8					; 水平に8ブロック並ぶ
	loop_red_increment:
			push	bc						; -- 8ループカウンタ保存

			ld		b, 32					; 1ブロック（同じ色の塊）は水平 32画素
	loop_red_block_width:
			call	write_vram
			djnz	loop_red_block_width

			pop		bc						; -- 8ループカウンタ復帰
			add		a, 0x04
			djnz	loop_red_increment

			pop		af
			pop		bc						; -- 6ループカウンタ復帰
			djnz	loop_red_line

			pop		bc						; -- 8ループカウンタ復帰
			add		a, 0x20
			djnz	loop_green_block_width

			pop		af
			pop		bc						; -- 4ループカウンタ復帰
			inc		a
			djnz	loop_blue_block_width

			call	wait_push_space_key
			ret
			endscope

; =============================================================================
;	シンプルな描画
; =============================================================================
			scope	test001
test001::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		0			; DX
			dw		0			; DY
			dw		16			; NX
			dw		16			; NY
			db		123			; CLR
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xC0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test002
test002::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		31			; DX
			dw		0			; DY
			dw		16			; NX
			dw		16			; NY
			db		234			; CLR
			db		0b0000100	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xC0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test003
test003::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		32			; DX
			dw		15			; DY
			dw		16			; NX
			dw		16			; NY
			db		210			; CLR
			db		0b0001000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xC0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test004
test004::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		63			; DX
			dw		15			; DY
			dw		16			; NX
			dw		16			; NY
			db		50			; CLR
			db		0b0001100	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xC0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test005
test005::
			ld		a, 2
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		100			; DX
			dw		16			; DY
			dw		16			; NX
			dw		100			; NY
			db		123			; CLR
			db		0b0001000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xC0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test006
test006::
			ld		a, 4
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		120			; DX
			dw		400			; DY
			dw		16			; NX
			dw		200			; NY
			db		234			; CLR
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xC0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test007
test007::
			ld		a, 8
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		30			; DX
			dw		40			; DY
			dw		200			; NX
			dw		16			; NY
			db		210			; CLR
			db		0b0000100	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xC0		; CMD (HMMC)
			endscope

; =============================================================================
			scope	test008
test008::
			ld		a, 10
			ld		e, 7
			call	write_control_register

			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	wait_push_space_key
			ret
	data:
			dw		240			; DX
			dw		31			; DY
			dw		190			; NX
			dw		16			; NY
			db		50			; CLR
			db		0b0000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xC0		; CMD (HMMC)
			endscope

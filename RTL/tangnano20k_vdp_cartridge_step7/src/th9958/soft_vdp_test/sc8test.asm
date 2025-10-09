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
			call	s8_vscroll
			call	s8_hscroll
			call	s8_display_adjust
			call	s8_random_boxfill
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
			; -- R#5 = 0x00
			ld		a, 0x00
			ld		e, 5
			call	write_control_register
			; -- R#11 = 0x2
			ld		a, 0x02
			ld		e, 11
			call	write_control_register
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
;	[SCREEN8] 垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s8_vscroll
s8_vscroll::
			jp		vscroll
			endscope

; =============================================================================
;	[SCREEN8] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s8_hscroll
s8_hscroll::
			jp		hscroll
			endscope

; =============================================================================
;	[SCREEN8] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s8_display_adjust
s8_display_adjust::
			jp		display_adjust
			endscope

; =============================================================================
;	[SCREEN8] ランダムに矩形を 65000個表示するテスト
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s8_random_boxfill
s8_random_boxfill::
			ld		bc, 65000
	loop:
			push	bc
			call	random
			ld		[data_dx], a
			call	random
			ld		[data_dy], a
			call	random
			ld		[data_nx], a
			call	random
			ld		[data_ny], a
			call	random
			ld		[data_clr], a
			call	wait_command
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			pop		bc
			dec		bc
			ld		a, c
			or		a, b
			jr		nz, loop
			call	wait_push_space_key
			ret
	data:
	data_dx:
			dw		0			; DX
	data_dy:
			dw		0			; DY
	data_nx:
			dw		0			; NX
	data_ny:
			dw		0			; NY
	data_clr:
			db		0			; CLR
			db		0			; ARG
			db		0xC0		; CMD (HMMV)
			endscope

			scope	random
random::
			ld		a, [data1]
			add		a, 19
			xor		a, 17
			rlca
			ld		[data1], a
			add		a, 209
			ret
	data1:
			db		0x12
			endscope

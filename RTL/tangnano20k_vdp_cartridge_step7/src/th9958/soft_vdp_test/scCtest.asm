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
			call	screen12
			call	s12_vscroll
			call	s12_hscroll
			call	s12_display_adjust
			call	s12_gradient_fill
			ei
			; 後始末
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include		"lib.asm"

; =============================================================================
;	SCREEN12
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	SCREEN12
SCREEN12::
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
			; R#25 = 0x08
			ld		a, 0x08					; YJK=1
			ld		e, 25
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
;	[SCREEN12] 垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s12_vscroll
s12_vscroll::
			jp		vscroll
			endscope

; =============================================================================
;	[SCREEN12] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s12_hscroll
s12_hscroll::
			jp		hscroll
			endscope

; =============================================================================
;	[SCREEN12] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s12_display_adjust
s12_display_adjust::
			jp		display_adjust
			endscope

; =============================================================================
;	[SCREEN12] gradient fill
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s12_gradient_fill
s12_gradient_fill::
			ld		h, 0		; DX
			ld		b, 32		; loop counter
	loop:
			ld		a, h
			ld		[data_dx], a
			ld		[data_color], a
			add		a, 8
			ld		h, a
			push	hl
			push	bc
			call	wait_command
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			pop		bc
			pop		hl
			djnz	loop
			call	wait_push_space_key

			; 色を付ける
	fill_color:
			ld		bc, 16			; Y座標
			ld		l, -32			; K (Cb)
			ld		e, 0			; J (Cr)
			call	set_color
			ld		bc, 32			; Y座標
			ld		l, 31			; K (Cb)
			ld		e, 0			; J (Cr)
			call	set_color
			ld		bc, 48			; Y座標
			ld		l, 0			; K (Cb)
			ld		e, -32			; J (Cr)
			call	set_color
			ld		bc, 64			; Y座標
			ld		l, 0			; K (Cb)
			ld		e, 31			; J (Cr)
			call	set_color
			ld		bc, 80			; Y座標
			ld		l, -32			; K (Cb)
			ld		e, -32			; J (Cr)
			call	set_color
			ld		bc, 96			; Y座標
			ld		l, 31			; K (Cb)
			ld		e, 31			; J (Cr)
			call	set_color
			ld		bc, 112			; Y座標
			ld		l, 31			; K (Cb)
			ld		e, -32			; J (Cr)
			call	set_color
			ld		bc, 128			; Y座標
			ld		l, -32			; K (Cb)
			ld		e, 31			; J (Cr)
			call	set_color
			ld		bc, 144			; Y座標
			ld		l, 15			; K (Cb)
			ld		e, -16			; J (Cr)
			call	set_color
			ld		bc, 160			; Y座標
			ld		l, -16			; K (Cb)
			ld		e, 15			; J (Cr)
			call	set_color
			ld		bc, 176			; Y座標
			ld		l, 8			; K (Cb)
			ld		e, -16			; J (Cr)
			call	set_color
			ld		bc, 192			; Y座標
			ld		l, -16			; K (Cb)
			ld		e, 8			; J (Cr)
			call	set_color
			ld		bc, 208			; Y座標
			ld		l, -32			; K (Cb)
			ld		e, 4			; J (Cr)
			call	set_color
			call	wait_push_space_key
			ret

	set_color:
			; 色を付ける (見えない位置の 4dot に色を付ける)
			ld		[data3_dy], bc
			ld		[data4_sy], bc
			inc		bc
			ld		[data4_dy], bc
			; JK のビット並びを合わせる
			ld		h, l
			ld		a, l
			and		a, 0b00000111
			ld		l, a
			ld		a, h
			rrca
			rrca
			rrca
			and		a, 0b00000111
			ld		h, a

			ld		d, e
			ld		a, e
			and		a, 0b00000111
			ld		e, a
			ld		a, d
			rrca
			rrca
			rrca
			and		a, 0b00000111
			ld		d, a

			push	hl
			push	de
			ld		hl, 212 * 256
			xor		a, a
			ld		[vram_bit16], a
			call	set_vram_write_address
			pop		de
			pop		hl
			ld		a, l
			call	write_vram
			ld		a, h
			call	write_vram
			ld		a, e
			call	write_vram
			ld		a, d
			call	write_vram
			; 4dot を水平 1ラインに広げる
			call	wait_command
			ld		hl, data2
			ld		a, 32
			ld		b, 15
			call	run_command
			; 作ったラインを、目的の位置へコピー(OR)する
			call	wait_command
			ld		hl, data3
			ld		a, 32
			ld		b, 15
			call	run_command
			; それを 16ラインに複製する
			call	wait_command
			ld		hl, data4
			ld		a, 32
			ld		b, 15
			call	run_command
			ret
	data:
	data_dx:
			dw		0			; DX
			dw		0			; DY
			dw		8			; NX
			dw		256			; NY
	data_color:
			db		0			; CLR
			db		0b00000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xC0		; CMD (HMMV)
	data2:
			dw		0			; SX
			dw		212			; SY
			dw		4			; DX
			dw		212			; DY
			dw		252			; NX
			dw		1			; NY
			db		0			; CLR
			db		0b00000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xD0		; CMD (HMMM)
	data3:
			dw		0			; SX
			dw		212			; SY
			dw		0			; DX
	data3_dy:
			dw		0			; DY
			dw		256			; NX
			dw		1			; NY
			db		0			; CLR
			db		0b00000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0x92		; CMD (LMMM, OR)
	data4:
			dw		0			; SX
	data4_sy:
			dw		0			; SY
			dw		0			; DX
	data4_dy:
			dw		0			; DY
			dw		256			; NX
			dw		15			; NY
			db		0			; CLR
			db		0b00000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xD0		; CMD (HMMM)
			endscope

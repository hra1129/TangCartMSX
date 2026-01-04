; =============================================================================
;	SRCH
; -----------------------------------------------------------------------------
;	Programmed by t.hara
; =============================================================================

vdp_port0	= 0x98
vdp_port1	= 0x99
vdp_port2	= 0x9A
vdp_port3	= 0x9B
bdos		= 0x0005
calslt		= 0x001C
chgmod		= 0x005F
cls			= 0x00C3
scrmod		= 0xFCAF
exttbl		= 0xFCC1
dos_strout	= 0x09

			org		0x100
start::
			call	set_screen7
			call	test001

			call	set_screen1
			call	put_result

			di
			halt

			ld		c, 0
			jp		bdos

; -----------------------------------------------------------------------------
;	test001
;	input:
;		none
;	output:
;		none
;	break:
;		all
;	note:
;		SRCH_R で左端から右端までの動作をチェックする
; -----------------------------------------------------------------------------
			scope	test001
test001::
			ld		hl, 0
	loop:
			; 点を打つ
			push	hl
			ld		e, 5
			ld		a, 15
			call	pset
			; 探索する
			pop		hl
			push	hl
			ld		e, 5
			ld		a, 15
			call	srch_r
			; 比較
			pop		de
			push	de
			ld		a, e
			xor		a, l
			ld		c, a
			ld		a, d
			xor		a, h
			or		a, c
			jr		z, no_error
	has_error:
			; 不一致した場合に結果を保存する
			pop		hl
			push	hl
			ld		de, result
			add		hl, de
			ld		[hl], 'X'
	no_error:
			; 点を消す
			pop		hl
			push	hl
			ld		e, 5
			ld		a, 4
			call	pset
			; 次へ
			pop		hl
			inc		hl
			bit		1, h
			jp		z, loop
			ret
			endscope

; -----------------------------------------------------------------------------
;	put_result
;	input:
;		none
;	output:
;		none
;	break:
;		all
;	note:
;		
; -----------------------------------------------------------------------------
			scope	put_result
put_result::
			di
			ld		c, vdp_port1
			xor		a, a
			out		[c], a
			ld		a, 0x40 | 0x18
			out		[c], a
			;
			ld		b, 0
			ld		hl, result
			dec		c
			otir
			otir
			ei
			endscope

; -----------------------------------------------------------------------------
;	Write VDP Register
;	input:
;		C ... register#
;		B ... value
;	output:
;		none
;	break:
;		C ... vdp_port1
;	note:
;		割り込み禁止状態で呼ぶ必要がある
; -----------------------------------------------------------------------------
			scope	write_vdp
write_vdp::
			ld		a, c
			or		a, 0x80
			ld		c, vdp_port1
			out		[c], b
			out		[c], a
			ret
			endscope

; -----------------------------------------------------------------------------
;	Set screen 7
;	input:
;		none
;	output:
;		none
;	break:
;		AF, BC, D, HL
;	note:
;		実行後に割り込み許可する
; -----------------------------------------------------------------------------
			scope	set_screen7
set_screen7::
			di
			ld		d, 37
			ld		hl, regs_data
	loop:
			ld		c, [hl]
			inc		hl
			ld		b, [hl]
			inc		hl
			call	write_vdp
			dec		d
			jr		z, loop
			ei
			ld		a, 7
			ld		[scrmod], a
			ret
	regs_data:
			db		0, 0x0A		;	Mode0
			db		1, 0x40		;	Mode1
			db		2, 0x1F		;	Pattern Name Table = 0x00000
			db		3, 0x80		;	Color Table (L) = 0x02000
			db		4, 0x00		;	Pattern Generator Table = 0x0000
			db		5, 0xF7		;	Sprite Attribute Table (L) = 0xFA00
			db		6, 0x1E		;	Sprite Pattern Generator Table = 0xF000
			db		7, 0x07		;	Background Color = 0x07
			db		8, 0x08		;	Mode2
			db		9, 0x80		;	Mode3
			db		10, 0		;	Color Table (H) = 0x02000
			db		11, 0x01	;	Sprite Attribute Table (H) = 0xFA00
			db		12, 0		;	Text Color/Back Color
			db		13, 0		;	Blink Period
			db		14, 0		;	VRAM Address
			db		15, 0		;	Status Register Pointer
			db		16, 0		;	Palette Pointer
			db		17, 0		;	Control Register Pointer
			db		18, 0		;	Screen Positon
			db		19, 0		;	Interrupt Line
			db		20, 0		;	Mode5
			db		21, 0		;	Mode6
			db		23, 0		;	Display Offset
			db		25, 0		;	Mode4
			db		26, 0		;	Horizontal Offset by character
			db		27, 0		;	Horizontal Offset by dot
			db		36, 0		;	SX(L)
			db		37, 0		;	SX(H)
			db		38, 0		;	SY(L)
			db		39, 0		;	SY(H)
			db		40, 0		;	NX(L)
			db		41, 0		;	NX(H)
			db		42, 0		;	NY(L)
			db		43, 0		;	NY(H)
			db		44, 0x44	;	CLR
			db		45, 0		;	ARG
			db		46, 0xC0	;	CMD:HMMV
			endscope

; -----------------------------------------------------------------------------
;	Set screen 0
;	input:
;		none
;	output:
;		none
;	break:
;		all
;	note:
;		
; -----------------------------------------------------------------------------
			scope	set_screen1
set_screen1::
			ld		iy, [exttbl - 1]
			ld		ix, chgmod
			ld		a, 1
			call	calslt

			ld		iy, [exttbl - 1]
			ld		ix, cls
			call	calslt

			ei
			ret
			endscope

; -----------------------------------------------------------------------------
;	Wait VDP command
;	input:
;		none
;	output:
;		none
;	break:
;		AF, BC
;	note:
;		実行後に割り込み許可する
; -----------------------------------------------------------------------------
			scope	wait_vdp_command
wait_vdp_command::
			di
			ld		bc, (2 << 8) | 15
			call	write_vdp
	loop:
			in		a, [c]
			rrca
			jp		c, loop
			ld		bc, (0 << 8) | 15
			call	write_vdp
			ei
			ret
			endscope

; -----------------------------------------------------------------------------
;	PSET
;	input:
;		HL .... X座標
;		E ..... Y座標
;		A ..... 色
;	output:
;		none
;	break:
;		AF, BC
;	note:
;		実行後に割り込み許可する
; -----------------------------------------------------------------------------
			scope	pset
pset::
			push	af
			call	wait_vdp_command

			di
			ld		bc, (36 << 8) | 17
			call	write_vdp
			inc		c
			inc		c
			xor		a, a
			ld		b, a
			out		[c], l				; DX
			out		[c], h
			out		[c], e				; DY
			out		[c], a
			out		[c], a				; NX (dummy)
			out		[c], a
			out		[c], a				; NY (dummy)
			out		[c], a
			pop		af
			out		[c], a				; CLR
			out		[c], b				; ARG
			ld		a, 0x50
			out		[c], a				; CMD: PSET
			ret
			endscope

; -----------------------------------------------------------------------------
;	SRCH_R
;	input:
;		HL .... X座標
;		E ..... Y座標
;		A ..... 色
;	output:
;		Zf .... 1: 未検出, 0: 検出
;		HL .... 検出したX座標
;	break:
;		AF, BC
;	note:
;		実行後に割り込み許可する
; -----------------------------------------------------------------------------
			scope	srch_r
srch_r::
			push	af
			call	wait_vdp_command

			di
			ld		bc, (32 << 8) | 17
			call	write_vdp
			inc		c
			inc		c
			xor		a, a
			ld		b, a
			out		[c], l				; SX
			out		[c], h
			out		[c], e				; SY
			out		[c], a
			out		[c], a				; DX (dummy)
			out		[c], a
			out		[c], a				; DY (dummy)
			out		[c], a
			out		[c], a				; NX (dummy)
			out		[c], a
			out		[c], a				; NY (dummy)
			out		[c], a
			pop		af
			out		[c], a				; CLR
			xor		a, a
			out		[c], a				; ARG
			ld		a, 0x60
			out		[c], a				; CMD: SRCH

			dec		c
			dec		c
			ld		a, 2
			ld		b, 0x80 | 15
			out		[c], a
			out		[c], b
	loop:
			in		a, [c]
			bit		0, a
			jr		nz, loop
			and		a, 0x40
			ld		d, a
			ld		a, 8
			out		[c], a
			out		[c], b
			in		l, [c]				; S#8
			inc		a
			out		[c], a
			out		[c], b				; S#9
			in		a, [c]
			and		a, 1
			ld		h, a
			xor		a, a
			out		[c], a
			out		[c], b				; S#0
			ei
			inc		d
			dec		d
			ret
			endscope

; -----------------------------------------------------------------------------
;	SRCH_L
;	input:
;		HL .... X座標
;		E ..... Y座標
;		A ..... 色
;	output:
;		Zf .... 1: 未検出, 0: 検出
;		HL .... 検出したX座標
;	break:
;		AF, BC
;	note:
;		実行後に割り込み許可する
; -----------------------------------------------------------------------------
			scope	srch_l
srch_l::
			push	af
			call	wait_vdp_command

			di
			ld		bc, (32 << 8) | 17
			call	write_vdp
			inc		c
			inc		c
			xor		a, a
			ld		b, a
			out		[c], l				; SX
			out		[c], h
			out		[c], e				; SY
			out		[c], a
			out		[c], a				; DX (dummy)
			out		[c], a
			out		[c], a				; DY (dummy)
			out		[c], a
			out		[c], a				; NX (dummy)
			out		[c], a
			out		[c], a				; NY (dummy)
			out		[c], a
			pop		af
			out		[c], a				; CLR
			ld		a, 0x04				; DIX = 1
			out		[c], a				; ARG
			ld		a, 0x60
			out		[c], a				; CMD: SRCH

			dec		c
			dec		c
			ld		a, 2
			ld		b, 0x80 | 15
			out		[c], a
			out		[c], b
	loop:
			in		a, [c]
			bit		0, a
			jr		nz, loop
			and		a, 0x40
			ld		d, a
			ld		a, 8
			out		[c], a
			out		[c], b
			in		l, [c]				; S#8
			inc		a
			out		[c], a
			out		[c], b				; S#9
			in		a, [c]
			and		a, 1
			ld		h, a
			xor		a, a
			out		[c], a
			out		[c], b				; S#0
			ei
			inc		d
			dec		d
			ret
			endscope

; -----------------------------------------------------------------------------
;	result
; -----------------------------------------------------------------------------
result::
			space	512, 'O'

; =============================================================================
;	LMMM
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
			call	set_screen5
			call	draw_test_pattern
			call	test001

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
;		none
; -----------------------------------------------------------------------------
			scope	test001
test001::
			ld		hl, 0
			ld		de, 16
	loop:
			ld		bc, (16 << 8) | 16
			push	hl
			push	de
			exx
			ld		hl, 0
			ld		de, 0
			exx
			call	lmmm
			call	wait_vdp_command
			pop		de
			ld		hl, 16
			add		hl, de
			pop		de
			ex		de, hl
			inc		hl
			ld		a, e
			cp		a, 196
			jr		c, skip
			ld		e, 0
	skip:
			bit		0, h
			jr		z, loop
			ret
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
;	Set screen 5
;	input:
;		none
;	output:
;		none
;	break:
;		AF, BC, D, HL
;	note:
;		実行後に割り込み許可する
; -----------------------------------------------------------------------------
			scope	set_screen5
set_screen5::
			ld		iy, [exttbl - 1]
			ld		ix, chgmod
			ld		a, 5
			call	calslt

			ld		iy, [exttbl - 1]
			ld		ix, cls
			call	calslt

			di
			ld		d, 11
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
			call	wait_vdp_command
			ret
	regs_data:
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
;	draw_test_pattern
;	input:
;		none
;	output:
;		none
;	break:
;		all
;	note:
;		テストパターンを描画する
; -----------------------------------------------------------------------------
			scope	draw_test_pattern
draw_test_pattern::
			ld		hl, 0
			ld		de, 0
			ld		bc, (32 << 8) | 16
			ld		a, 1
	loop:
			push	af
			push	hl
			push	de
			push	bc
			call	lmmv
			call	wait_vdp_command
			pop		bc
			pop		de
			pop		hl
			pop		af
			inc		hl
			inc		de
			inc		a
			dec		b
			dec		b
			dec		c
			dec		c
			jr		nz, loop
			ret
			endscope

; -----------------------------------------------------------------------------
;	lmmv
;	input:
;		HL ..... X座標
;		DE ..... Y座標
;		B ...... 幅
;		C ...... 高さ
;		A ...... 色
;	output:
;		none
;	break:
;		all
;	note:
;		矩形塗りつぶし
; -----------------------------------------------------------------------------
			scope	lmmv
lmmv::
			push	bc
			ld		c, vdp_port1
			ld		b, 36
			di
			out		[c], b
			ld		b, 0x80 + 17
			out		[c], b
			ld		bc, vdp_port3
			out		[c], l				; DX
			out		[c], h
			out		[c], e				; DY
			out		[c], d
			pop		de
			out		[c], d				; NX
			out		[c], b
			out		[c], e				; NY
			out		[c], b
			out		[c], a				; CLR
			out		[c], b				; ARG
			ld		a, 0x80				; LMMV
			ei
			out		[c], a				; CMD
			ret
			endscope

; -----------------------------------------------------------------------------
;	lmmm
;	input:
;		HL' .... X座標(転送元)
;		DE' .... Y座標(転送元)
;		HL ..... X座標(転送先)
;		DE ..... Y座標(転送先)
;		B ...... 幅
;		C ...... 高さ
;	output:
;		none
;	break:
;		all
;	note:
;		矩形塗りつぶし
; -----------------------------------------------------------------------------
			scope	lmmm
lmmm::
			push	bc
			ld		c, vdp_port1
			ld		b, 32
			di
			out		[c], b
			ld		b, 0x80 + 17
			out		[c], b
			ld		bc, vdp_port3
			exx
			ld		c, vdp_port3
			out		[c], l				; SX
			out		[c], h
			out		[c], e				; SY
			out		[c], d
			exx
			out		[c], l				; DX
			out		[c], h
			out		[c], e				; DY
			out		[c], d
			pop		de
			out		[c], d				; NX
			out		[c], b
			out		[c], e				; NY
			out		[c], b
			out		[c], b				; CLR
			out		[c], b				; ARG
			ld		a, 0x90				; LMMM
			ei
			out		[c], a				; CMD
			ret
			endscope

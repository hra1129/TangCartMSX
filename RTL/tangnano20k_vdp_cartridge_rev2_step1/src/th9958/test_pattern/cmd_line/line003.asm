; =============================================================================
;	LINE
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
			ld		hl, regs
			ld		bc, ((15 * 2) << 8) | vdp_port1
			di
			otir
			ei
			ret
	regs:
			db		0	, 0x80 | 32		; SX(L) dummy
			db		0	, 0x80 | 33		; SX(H) dummy
			db		0x48, 0x80 | 34		; SY(L) dummy
			db		0x01, 0x80 | 35		; SY(H) dummy
			db		0xF8, 0x80 | 36		; DX(L)
			db		0	, 0x80 | 37		; DX(H)
			db		0x12, 0x80 | 38		; DY(L)
			db		0	, 0x80 | 39		; DY(H)
			db		0x11, 0x80 | 40		; NX(L)
			db		0	, 0x80 | 41		; NX(H)
			db		0	, 0x80 | 42		; NY(L)
			db		0	, 0x80 | 43		; NY(H)
			db		0x0E, 0x80 | 44		; CLR
			db		0x01, 0x80 | 45		; ARG
			db		0x70, 0x80 | 46		; CMD:LINE
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
;	Set screen 1
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

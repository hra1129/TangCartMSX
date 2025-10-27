; =============================================================================
;	V9958 software test program
; -----------------------------------------------------------------------------
;	Programmed by t.hara (HRA!)
; =============================================================================

			org		0x100

vdp_port0		:= 0x98
vdp_port1		:= 0x99
vdp_port2		:= 0x9A
vdp_port3		:= 0x9B
_TERM0			:= 0x00
bdos			:= 0x0005


start:
			di
			call	screen5

			ld		a, 2
			ld		e, 14
			call	write_control_register

			xor		a, a
			out		[vdp_port1], a
			ld		a, 0x40
			out		[vdp_port1], a

			ld		a, 0xFF
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			ld		a, 0xDD
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
			out		[vdp_port0], a
	loop:
			jp		loop

			; 後始末
			ei
			ld		c, _TERM0
			jp		bdos

			scope	write_control_register
write_control_register::
			out		[vdp_port1], a
			ld		a, e
			and		a, 0x3F
			or		a, 0x80
			out		[vdp_port1], a
			ret
			endscope

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
			ld		a, 0x02					; スプライト非表示
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
			ret
			endscope

; -----------------------------------------------------------------------------
;  Hello, world! for cZ80 step1 test program
; =============================================================================
;  Programmed by t.hara
; -----------------------------------------------------------------------------

UART		:= 0x10
SWAP_ROM	:= 0x11

			org		0x0000

			di
			jp		start

			align 0x0005
bdos:
			jp		puts

start:
			; Block transfer to RAM from ROM
			ld		hl, 0x0000
			ld		de, 0x4000
			ld		bc, 0x4000
			ldir
			; SWAP RAM and ROM
			ld		a, 1
			out		[SWAP_ROM], a
			ld		sp, 0x4000
			ld		a, 0x76					; halt
			ld		[0x0000], a
wait_key:
			call	getkey
			and		a, 1
			jr		z, wait_key

			jp		0x100

; -----------------------------------------------------------------------------
;	getkey
;	input:
;		none
;	output:
;		A ..... button information
;			bit0 ... button[0]
;			bit1 ... button[1]
;	break:
;		B, C, F
; -----------------------------------------------------------------------------
			scope	getkey
getkey::
			in		a, [UART]
			rlca
			rlca
			ret
			endscope

; -----------------------------------------------------------------------------
;	puts
;	input:
;		DE ...... target string address ( '$' terminated )
;	output:
;		none
;	break:
;		A, B, C, D, E, H, F
; -----------------------------------------------------------------------------
			scope	puts
puts::
			push	af
loop:
			ld		a, [de]
			inc		de
			cp		a, '$'
			jr		z, exit
			call	putc
			jr		loop
exit:
			pop		af
			ret
			endscope

; -----------------------------------------------------------------------------
;	putc
;	input:
;		A ...... send byte
;	output:
;		none
;	break:
;		B, C, F
; -----------------------------------------------------------------------------
			scope	putc
putc::
			ld		c, UART
	wait_loop:
			in		b, [c]
			rr		b
			jr		c, wait_loop
			out		[c], a
			ret
			endscope

; -----------------------------------------------------------------------------
			align	0x100
			binary_link				"zexall/zexall.com"

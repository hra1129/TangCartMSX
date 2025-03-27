; -----------------------------------------------------------------------------
;  Hello, world! for cZ80 step1 test program
; =============================================================================
;  Programmed by t.hara
; -----------------------------------------------------------------------------

UART		:= 0x10

			org		0x0000

			di
			jp		start

			align 0x0005
bdos:
			jp		puts

start:
			ld		sp, 0x4000
wait_key:
			call	getkey
			and		a, 1
			jr		z, wait_key

			ld		de, s_hello
			call	puts
			jp		wait_key

s_hello:
			db		"Hello, world!", 0x0D, 0x0A, 0

; -----------------------------------------------------------------------------
;	getkey
;	input:
;		none
;	output:
;		A ..... button information
;			bit0 ... button[0]
;			bit1 ... button[1]
;			bit2 ... button[2]
;			bit3 ... button[3]
;			bit4 ... button[4]
;	break:
;		B, C, F
; -----------------------------------------------------------------------------
			scope	getkey
getkey::
			in		a, [UART]
			ret
			endscope

; -----------------------------------------------------------------------------
;	puts
;	input:
;		DE ...... target string address ( '\0' terminated )
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
			or		a, a
			jr		z, exit
			out		[UART], a
			jr		loop
exit:
			pop		af
			ret
			endscope

; -----------------------------------------------------------------------------
;  Hello, world! for cZ80 step1 test program
; =============================================================================
;  Programmed by t.hara
; -----------------------------------------------------------------------------

UART := 0x10

			org		0x0000

			di
			ld		sp, 0x8000

wait_key_release:
			call	getkey
			or		a, a
			jr		nz, wait_key_release

main_loop:
			call	getkey
			or		a, a
			jr		z, main_loop

			rrca
			jr		c, put_button0_message
			rrca
			jr		c, put_button1_message

put_button0_message:
			ld		hl, s_button0_message
			call	puts
			jr		wait_key_release

put_button1_message:
			ld		hl, s_button1_message
			call	puts
			jr		wait_key_release

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
;	puts
;	input:
;		HL ...... target string address ( 0 terminated )
;	output:
;		HL ...... next address
;	break:
;		A, B, C, F
; -----------------------------------------------------------------------------
			scope	puts
puts::
			ld		a, [hl]
			inc		hl
			or		a, a
			ret		z
			call	putc
			jr		puts
			endscope

; -----------------------------------------------------------------------------
;	datas
; -----------------------------------------------------------------------------
s_button0_message::
			ds		"Pressed BUTTON0!! Thank you!"
			db		0x0D, 0x0A, 0

s_button1_message::
			ds		"Pressed BUTTON1!! Hello!!"
			db		0x0D, 0x0A, 0

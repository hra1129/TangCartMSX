; -----------------------------------------------------------------------------
;  Hello, world! for cZ80 step1 test program
; =============================================================================
;  Programmed by t.hara
; -----------------------------------------------------------------------------

REG_PATTERN_MODE	:= 0x10
REG_KEY_STATE		:= 0x10
MODE_VALUE			:= 0xF400

			org		0x0000

			di
			ld		sp, 0
			xor		a, a
			ld		[MODE_VALUE], a
			out		[REG_PATTERN_MODE], a

wait_key_release:
			call	getkey
			or		a, a
			jr		nz, wait_key_release

main_loop:
			call	getkey
			or		a, a
			jr		z, main_loop

			rrca
			jr		c, press_button0
			rrca
			jr		c, press_button1

press_button0:
			ld		a, [MODE_VALUE]
			inc		a
			ld		[MODE_VALUE], a
			out		[REG_PATTERN_MODE], a
			jr		wait_key_release

press_button1:
			ld		a, [MODE_VALUE]
			dec		a
			ld		[MODE_VALUE], a
			out		[REG_PATTERN_MODE], a
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
			in		a, [REG_KEY_STATE]
			rlca
			rlca
			ret
			endscope

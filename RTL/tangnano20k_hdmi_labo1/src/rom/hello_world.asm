; -----------------------------------------------------------------------------
;  Hello, world! for cZ80 step1 test program
; =============================================================================
;  Programmed by t.hara
; -----------------------------------------------------------------------------

REG_KEY_STATE		:= 0x10

REG_PALETTE_ADDR	:= 0x20
REG_PALETTE_COLOR	:= 0x21
REG_VRAM_ADDR		:= 0x22
REG_VRAM_DATA		:= 0x23

			org		0x0000

			di
			ld		sp, 0

			xor		a, a
			out		[REG_PALETTE_ADDR], a
palette_loop:
			push	af
			out		[REG_PALETTE_COLOR], a		; R
			srl		a
			out		[REG_PALETTE_COLOR], a		; G
			srl		a
			out		[REG_PALETTE_COLOR], a		; B
			pop		af
			inc		a
			jr		nz, palette_loop

			ld		bc, 0
main_loop:
			ld		de, 0
			ld		hl, 360
y_loop:
			xor		a, a
			out		[REG_VRAM_ADDR], a
			ld		a, e
			out		[REG_VRAM_ADDR], a
			ld		a, d
			out		[REG_VRAM_ADDR], a

			push	hl
			ld		hl, 640
			push	bc
x_loop:
			ld		a, b
			add		a, c
			inc		b
			out		[REG_VRAM_DATA], a
			dec		hl
			ld		a, l
			or		a, h
			jr		nz, x_loop

			ld		hl, 1024 >> 8
			add		hl, de
			ex		de, hl

			pop		bc
			pop		hl
			dec		hl
			ld		a, l
			or		a, h
			inc		c
			jr		nz, y_loop

			inc		b
			jp		main_loop

;wait_key_release:
;			call	getkey
;			or		a, a
;			jr		nz, wait_key_release
;
;main_loop:
;			call	getkey
;			or		a, a
;			jr		z, main_loop
;
;			rrca
;			jr		c, press_button0
;			rrca
;			jr		c, press_button1
;
;press_button0:
;			jr		wait_key_release
;
;press_button1:
;			jr		wait_key_release

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

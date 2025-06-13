; -----------------------------------------------------------------------------
;  LED Chika Chika for TangConsole step3 test program
; =============================================================================
;  Programmed by t.hara
; -----------------------------------------------------------------------------

LED_PORT	:= 0x10
END_MARK	:= 0b11101001

			org		0x0000

			di
			ld		sp, 0x8000
start:
			ld		hl, led_data
	main_loop:
			ld		a, [hl]
			cp		a, END_MARK
			jr		z, start
			out		[LED_PORT], a
			inc		hl
			call	wait_time
			jr		main_loop

; -----------------------------------------------------------------------------
wait_time:
			ld		hl, 0xFFFF
	wait_loop:
			push	hl
			dec		hl
			ld		a, l
			or		a, h
			pop		hl
			jr		nz, wait_loop
			ret

; -----------------------------------------------------------------------------
led_data:
			db		0b00000001
			db		0b00000010
			db		0b00000100
			db		0b00001000
			db		0b00010000
			db		0b00100000
			db		0b01000000
			db		0b10000000
			db		0b01000000
			db		0b00100000
			db		0b00010000
			db		0b00001000
			db		0b00000100
			db		0b00000010
			db		0b00000001
			db		0b10000001
			db		0b01000010
			db		0b00100100
			db		0b00011000
			db		0b00011000
			db		0b00100100
			db		0b01000010
			db		0b10000001
			db		END_MARK

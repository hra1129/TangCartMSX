; =============================================================================
;	線の形状の確認テスト
; =============================================================================

			org		0x100

			call	initial_process
			call	set_graphic4
			call	lmmv001
			jp		finish_process

; =============================================================================
			scope	set_graphic4
set_graphic4::
			; R#17
			ld		a, 0
			ld		e, 17
			call	write_control_register

			ld		a, [io_vdp_port3]
			ld		c, a
			ld		b, 20
			ld		hl, parameters
			otir
			call	cls
			ret
	parameters:
			db		0x06			; R#0  = Mode0
			db		0x40			; R#1  = Mode1
			db		0x1F			; R#2  = Pattern Name Table
			db		0x00			; R#3  = Color Table (L)
			db		0x00			; R#4  = Pattern Generator Table
			db		0x00			; R#5  = Sprite Attribute Table (L)
			db		0x00			; R#6  = Sprite Pattern Generator Table
			db		0x07			; R#7  = Background Color
			db		0x0A			; R#8  = Mode2
			db		0x00			; R#9  = Mode3
			db		0x00			; R#10 = Color Table (High)
			db		0x00			; R#11 = Sprite Attribute Table (H)
			db		0x00			; R#12 = Text Color/Back Color Register
			db		0x00			; R#13 = Blink Period Register
			db		0x00			; R#14 = VRAM Address (H)
			db		0x00			; R#15 = Status Register Pointer
			db		0x00			; R#16 = Palette Register Pointer
			db		0x00			; R#17 = Control Register Pointer
			db		0x00			; R#18 = Adjust Position
			db		0x00			; R#19 = Interrupt Line Register
			endscope

; =============================================================================
			scope	cls
cls::
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			ret
	data:
			dw		0				; DX
			dw		0				; DY
			dw		256				; NX
			dw		512				; NY
			db		0x44			; CLR
			db		0b0000000		; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xC0			; CMD (HMMV)
			endscope

; =============================================================================
			scope	lmmv001
lmmv001::
			call	cls
			ld		hl, data1
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command

			ld		hl, data2
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command

			ld		hl, data3
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command

			ld		hl, data4
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command

			call	wait_push_space_key
			ret
	data1:
			dw		1			; DX
			dw		1			; DY
			dw		30			; NX
			dw		20			; NY
			db		10			; CLR
			db		0			; ARG
			db		0x80		; CMD (LMMV)
	data2:
			dw		32			; DX
			dw		0			; DY
			dw		32			; NX
			dw		20			; NY
			db		9			; CLR
			db		0			; ARG
			db		0x80		; CMD (LMMV)

	data3:
			dw		80			; DX
			dw		0			; DY
			dw		32			; NX
			dw		1			; NY
			db		8			; CLR
			db		0			; ARG
			db		0x80		; CMD (LMMV)

	data4:
			dw		0			; DX
			dw		40			; DY
			dw		1			; NX
			dw		32			; NY
			db		2			; CLR
			db		0			; ARG
			db		0x80		; CMD (LMMV)
			endscope

			include	"../lib.asm"

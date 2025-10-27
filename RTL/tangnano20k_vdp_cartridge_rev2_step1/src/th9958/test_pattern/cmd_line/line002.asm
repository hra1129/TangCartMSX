; =============================================================================
;	線の形状の確認テスト
; =============================================================================

			org		0x100

			call	initial_process
			call	set_graphic4
			call	line001
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
			scope	line001
line001::
			call	cls
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command

			ld		a, 90		; DX
			ld		e, 36
			call	write_control_register
			ld		a, 30		; NX
			ld		e, 40
			call	write_control_register
			ld		a, 8		; CLR
			ld		e, 44
			call	write_control_register
			ld		a, 0x70		; CMD (LINE)
			ld		e, 46
			call	write_control_register
			call	wait_command

			call	wait_push_space_key
			ret
	data:
			dw		30			; DX
			dw		30			; DY
			dw		60			; NX
			dw		0			; NY
			db		10			; CLR
			db		0			; ARG
			db		0x70		; CMD (LINE)
			endscope

			include	"../lib.asm"

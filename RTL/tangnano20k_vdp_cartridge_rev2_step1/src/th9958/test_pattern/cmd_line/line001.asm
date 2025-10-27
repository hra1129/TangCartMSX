; =============================================================================
;	ê¸ÇÃå`èÛÇÃämîFÉeÉXÉg
; =============================================================================

			org		0x100

			call	initial_process
			call	set_graphic4
			call	line001
			call	line002
			call	line003
			call	line004
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
			scope	zoom
zoom::
			; êÖïΩï˚å¸Ç…ägëÂ
			ld		hl, 0
			ld		[data_sx], hl
			ld		[data_sy], hl
			ld		[data_dx], hl
			ld		[data_dy], hl
			ld		hl, 224
			ld		[data_nx], hl
			ld		hl, 24
			ld		[data_ny], hl

			ld		b, 32
	horz_loop:
			push	bc
			ld		l, b
			ld		h, 0
			ld		[data_dx], hl
			dec		hl
			ld		[data_sx], hl

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command

			ld		hl, [data_sx]
			ld		[data_dx], hl
			ld		hl, [data_nx]
			ld		bc, 7
			or		a, a
			sbc		hl, bc
			ld		[data_nx], hl
			pop		bc
			djnz	horz_loop

			; êÇíºï˚å¸Ç…ägëÂ
			ld		hl, 0
			ld		[data_sx], hl
			ld		[data_dx], hl
			ld		hl, 24
			ld		[data_dy], hl
			ld		hl, 256
			ld		[data_nx], hl
			ld		hl, 168
			ld		[data_ny], hl

			ld		b, 24
	vart_loop:
			push	bc
			ld		l, b
			ld		h, 0
			ld		[data_dy], hl
			dec		hl
			ld		[data_sy], hl

			ld		hl, data
			ld		a, 32
			ld		b, 15
			call	run_command
			call	wait_command

			ld		hl, [data_sy]
			ld		[data_dy], hl
			ld		hl, [data_ny]
			ld		bc, 7
			or		a, a
			sbc		hl, bc
			ld		[data_ny], hl
			pop		bc
			djnz	vart_loop

			; êÇíºê¸Çï`âÊ
			ld		hl, 7
			ld		[line_dx], hl
			ld		hl, 0
			ld		[line_dy], hl
			ld		[line_ny], hl
			ld		hl, 191
			ld		[line_nx], hl
			ld		a, 1
			ld		[line_arg], a

			ld		b, 32
	horz_line_loop:
			push	bc

			ld		hl, line_dx
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command

			ld		hl, [line_dx]
			ld		bc, 8
			add		hl, bc
			ld		[line_dx], hl

			pop		bc
			djnz	horz_line_loop

			; êÖïΩê¸Çï`âÊ
			ld		hl, 7
			ld		[line_dy], hl
			ld		hl, 0
			ld		[line_dx], hl
			ld		[line_ny], hl
			ld		hl, 255
			ld		[line_nx], hl
			xor		a, a
			ld		[line_arg], a

			ld		b, 24
	vert_line_loop:
			push	bc

			ld		hl, line_dx
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command

			ld		hl, [line_dy]
			ld		bc, 8
			add		hl, bc
			ld		[line_dy], hl

			pop		bc
			djnz	vert_line_loop
			ret
	data:
	data_sx:
			dw		0			; SX
	data_sy:
			dw		0			; SY
	data_dx:
			dw		0			; DX
	data_dy:
			dw		0			; DY
	data_nx:
			dw		0			; NX
	data_ny:
			dw		0			; NY
			db		0			; CLR
			db		0			; ARG
			db		0x90		; CMD (LMMM)

	line_dx:
			dw		0			; DX
	line_dy:
			dw		0			; DY
	line_nx:
			dw		0			; NX
	line_ny:
			dw		0			; NY
			db		15			; CLR
	line_arg:
			db		0			; ARG
			db		0x70		; CMD (LINE)
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
			call	zoom
			call	wait_push_space_key
			ret
	data:
			dw		0			; DX
			dw		0			; DY
			dw		31			; NX
			dw		18			; NY
			db		10			; CLR
			db		0			; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	line002
line002::
			call	cls
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	zoom
			call	wait_push_space_key
			ret
	data:
			dw		0			; DX
			dw		0			; DY
			dw		31			; NX
			dw		18			; NY
			db		2			; CLR
			db		1			; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	line003
line003::
			call	cls
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	zoom
			call	wait_push_space_key
			ret
	data:
			dw		31			; DX
			dw		0			; DY
			dw		31			; NX
			dw		18			; NY
			db		7			; CLR
			db		4			; ARG
			db		0x70		; CMD (LINE)
			endscope

; =============================================================================
			scope	line004
line004::
			call	cls
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			call	wait_command
			call	zoom
			call	wait_push_space_key
			ret
	data:
			dw		0			; DX
			dw		31			; DY
			dw		31			; NX
			dw		18			; NY
			db		9			; CLR
			db		9			; ARG
			db		0x70		; CMD (LINE)
			endscope

			include	"../lib.asm"

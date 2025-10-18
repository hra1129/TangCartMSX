; =============================================================================
;	Port#3経由で R#17 に書き込みが出来ないことを確認するテスト
; =============================================================================

			org		0x100

			call	initial_process
			call	set_graphic1
			call	set_text1
			call	set_graphic1
			call	set_text1
			jp		finish_process

; =============================================================================
			scope	set_graphic1
set_graphic1::
			; R#17
			ld		a, 0
			ld		e, 17
			call	write_control_register

			ld		a, [io_vdp_port3]
			ld		c, a
			ld		b, 20
			ld		hl, parameters
			otir

			ld		hl, 0x1800
			ld		bc, 32 * 24
			ld		e, ' '
			call	fill_vram

			ld		hl, 0x0000
			call	set_font

			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			call	wait_push_space_key
			ret
	s_message:
			db		"Changed to SCREEN1."
			db		0
	parameters:
			db		0x00			; R#0  = Mode0
			db		0x40			; R#1  = Mode1
			db		0x1800 >> 10	; R#2  = Pattern Name Table
			db		0x2000 >> 6		; R#3  = Color Table (L)
			db		0x0000 >> 11	; R#4  = Pattern Generator Table
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
			scope	set_text1
set_text1::
			; R#17
			ld		a, 0
			ld		e, 17
			call	write_control_register

			ld		a, [io_vdp_port3]
			ld		c, a
			ld		b, 20
			ld		hl, parameters
			otir

			ld		hl, 0x0000
			ld		bc, 40 * 24
			ld		e, ' '
			call	fill_vram

			ld		hl, 0x0800
			call	set_font

			ld		hl, 0x0000
			ld		de, s_message
			call	puts
			call	wait_push_space_key
			ret
	s_message:
			db		"Changed to SCREEN0."
			db		0
	parameters:
			db		0x00			; R#0  = Mode0
			db		0x50			; R#1  = Mode1
			db		0x0000 >> 10	; R#2  = Pattern Name Table
			db		0x0000 >> 6		; R#3  = Color Table (L)
			db		0x0800 >> 11	; R#4  = Pattern Generator Table
			db		0x00			; R#5  = Sprite Attribute Table (L)
			db		0x00			; R#6  = Sprite Pattern Generator Table
			db		0xF4			; R#7  = Background Color
			db		0x0A			; R#8  = Mode2
			db		0x00			; R#9  = Mode3
			db		0x00			; R#10 = Color Table (High)
			db		0x00			; R#11 = Sprite Attribute Table (H)
			db		0x7F			; R#12 = Text Color/Back Color Register
			db		0x00			; R#13 = Blink Period Register
			db		0x00			; R#14 = VRAM Address (H)
			db		0x00			; R#15 = Status Register Pointer
			db		0x00			; R#16 = Palette Register Pointer
			db		0x00			; R#17 = Control Register Pointer
			db		0x00			; R#18 = Adjust Position
			db		0x00			; R#19 = Interrupt Line Register
			endscope

			include	"../lib.asm"

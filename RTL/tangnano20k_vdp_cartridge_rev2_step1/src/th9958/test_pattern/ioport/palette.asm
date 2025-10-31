; =============================================================================
;	HSYNC, VSYNC, Line Interrupt の挙動を確認するテスト
; =============================================================================

			org		0x100

			call	initial_process
			call	set_graphic4
			call	line_interrupt_test
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

			ld		hl, 0x7600
			ld		bc, 4 * 32
			ld		e, 216
			call	fill_vram

			ld		hl, 0x0000
			ld		bc, 128 * 212
			ld		e, 0xF4
			call	fill_vram
			ret
	parameters:
			db		0x06			; R#0  = Mode0
			db		0x60			; R#1  = Mode1
			db		0x1F			; R#2  = Pattern Name Table
			db		0x80			; R#3  = Color Table (L)
			db		0x00			; R#4  = Pattern Generator Table
			db		0xEF			; R#5  = Sprite Attribute Table (L)
			db		0x0F			; R#6  = Sprite Pattern Generator Table
			db		0x07			; R#7  = Background Color
			db		0x08			; R#8  = Mode2
			db		0x80			; R#9  = Mode3
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
			db		0x00			; R#20
			db		0x00			; R#21
			endscope

; =============================================================================
			scope	line_interrupt_test
line_interrupt_test::
			; line #69 で割込
			di
			ld		a, 1
			out		[0x99], a
			ld		a, 15 + 0x80
			out		[0x99], a
	loop:
			ld		a, 69
			out		[0x99], a
			ld		a, 19 + 0x80
			out		[0x99], a

	wait_fh1:
			in		a, [0x99]
			and		a, 1
			jr		z, wait_fh1

			; Palette #4 の色を変える
			ld		a, 4
			out		[0x99], a
			ld		a, 16 + 0x80
			out		[0x99], a
			ld		a, 0x70
			out		[0x9A], a
			xor		a, a
			out		[0x9A], a

			ld		a, 185
			out		[0x99], a
			ld		a, 19 + 0x80
			out		[0x99], a

	wait_fh2:
			in		a, [0x99]
			and		a, 1
			jr		z, wait_fh2

			; Palette #4 の色を変える
			ld		a, 4
			out		[0x99], a
			ld		a, 16 + 0x80
			out		[0x99], a
			ld		a, 0x07
			out		[0x9A], a
			xor		a, a
			out		[0x9A], a
			jp		loop
			endscope

			include	"../lib.asm"

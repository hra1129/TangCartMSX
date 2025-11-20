; =============================================================================
;	VRAM の連続リード・連続ライト
; =============================================================================

			org		0x100

			call	initial_process
			call	set_graphic6
			call	vram_io_test
			call	vram_io_test2
			jp		finish_process

; =============================================================================
			scope	set_graphic6
set_graphic6::
			; R#17
			ld		a, 0
			ld		e, 17
			call	write_control_register

			ld		a, [io_vdp_port3]
			ld		c, a
			ld		b, 20
			ld		hl, parameters
			otir
			ret
	parameters:
			db		0x0A			; R#0  = Mode0
			db		0x40			; R#1  = Mode1
			db		0x1F			; R#2  = Pattern Name Table
			db		0x80			; R#3  = Color Table (L)
			db		0x00			; R#4  = Pattern Generator Table
			db		0xF7			; R#5  = Sprite Attribute Table (L)
			db		0x1E			; R#6  = Sprite Pattern Generator Table
			db		0x07			; R#7  = Background Color
			db		0x0A			; R#8  = Mode2
			db		0x80			; R#9  = Mode3
			db		0x00			; R#10 = Color Table (High)
			db		0x01			; R#11 = Sprite Attribute Table (H)
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
;	VRAM に対して INIR, OTIR で連続アクセスするテスト
; =============================================================================
			scope	vram_io_test
vram_io_test::
			; first draw
			; set VRAM address 0x10000
			ld		a, 0x04
			out		[vdp_port1], a
			ld		a, 0x80 + 14
			out		[vdp_port1], a
			xor		a, a
			out		[vdp_port1], a
			ld		a, 0x40
			out		[vdp_port1], a
			ld		hl, font_data
			ld		bc, (64 << 8) | vdp_port0
			otir
			; loop
			xor		a, a
			out		[vdp_port1], a
			ld		a, 0x80 + 14
			out		[vdp_port1], a
			ld		bc, (32 << 8) | 0
			ld		de, 0
	loop:
			; line に対応する font の VRAMアドレスを計算する
			push	bc
			ld		a, 0x04
			out		[vdp_port1], a
			ld		a, 0x80 + 14
			out		[vdp_port1], a

			ld		a, c
			and		a, 7
			add		a, a
			add		a, a
			add		a, a
			out		[vdp_port1], a
			xor		a, a
			out		[vdp_port1], a
			ld		hl, read_buffer
			ld		bc, (8 << 8) | vdp_port0
			inir
			; 書き込む VRAMアドレスを計算する
			ld		a, d
			rlca
			rlca
			and		a, 0x03
			out		[vdp_port1], a
			ld		a, 0x80 + 14
			out		[vdp_port1], a

			ld		a, e
			out		[vdp_port1], a
			ld		a, d
			and		a, 0x3F
			or		a, 0x40
			out		[vdp_port1], a
			ld		hl, 8
			add		hl, de
			ex		de, hl
			ld		hl, read_buffer
			ld		bc, (8 << 8) | vdp_port0
			otir
			pop		bc
			djnz	loop
			ld		b, 32
			inc		c
			ld		a, c
			cp		a, 212
			jp		nz, loop
			call	wait_push_space_key
			ret
	read_buffer:
			db		0, 0, 0, 0, 0, 0, 0, 0
	font_data:
			db		0x44, 0x44, 0xFF, 0xFF, 0xFF, 0xFF, 0xCC, 0xCC
			db		0x44, 0xFF, 0x55, 0x55, 0x55, 0x55, 0xFF, 0xCC
			db		0x4F, 0x55, 0x5F, 0xFF, 0xFF, 0xF5, 0x55, 0xFC
			db		0xF5, 0x55, 0xF5, 0xF5, 0x5F, 0x5F, 0x55, 0x5F
			db		0xF5, 0x55, 0xF5, 0x5F, 0xF5, 0x5F, 0x55, 0x5F
			db		0xCF, 0x55, 0x5F, 0xFF, 0xFF, 0xF5, 0x55, 0xF4
			db		0xCC, 0xFF, 0x55, 0x55, 0x55, 0x55, 0xFF, 0x44
			db		0xCC, 0xCC, 0xFF, 0xFF, 0xFF, 0xFF, 0x44, 0x44
			endscope

; =============================================================================
;	VDPコマンド稼働中に VRAM に対して INIR, OTIR で連続アクセスするテスト
; =============================================================================
			scope	vram_io_test2
vram_io_test2::
			; HMMV で page1 を color = 2 で塗りつぶす
			ld		a, 36
			out		[vdp_port1], a
			ld		a, 0x80 + 17
			out		[vdp_port1], a
			ld		hl, command
			ld		bc, (11 << 8) | vdp_port3
			otir

			; first draw
			; set VRAM address 0x10000
			ld		a, 0x04
			out		[vdp_port1], a
			ld		a, 0x80 + 14
			out		[vdp_port1], a
			xor		a, a
			out		[vdp_port1], a
			ld		a, 0x40
			out		[vdp_port1], a
			ld		hl, font_data
			ld		bc, (64 << 8) | vdp_port0
			otir
			; loop
			xor		a, a
			out		[vdp_port1], a
			ld		a, 0x80 + 14
			out		[vdp_port1], a
			ld		bc, (32 << 8) | 0
			ld		de, 0
	loop:
			; line に対応する font の VRAMアドレスを計算する
			push	bc
			ld		a, 0x04
			out		[vdp_port1], a
			ld		a, 0x80 + 14
			out		[vdp_port1], a

			ld		a, c
			and		a, 7
			add		a, a
			add		a, a
			add		a, a
			out		[vdp_port1], a
			xor		a, a
			out		[vdp_port1], a
			ld		hl, read_buffer
			ld		bc, (8 << 8) | vdp_port0
			inir
			; 書き込む VRAMアドレスを計算する
			ld		a, d
			rlca
			rlca
			and		a, 0x03
			out		[vdp_port1], a
			ld		a, 0x80 + 14
			out		[vdp_port1], a

			ld		a, e
			out		[vdp_port1], a
			ld		a, d
			and		a, 0x3F
			or		a, 0x40
			out		[vdp_port1], a
			ld		hl, 8
			add		hl, de
			ex		de, hl
			ld		hl, read_buffer
			ld		bc, (8 << 8) | vdp_port0
			otir
			pop		bc
			djnz	loop
			ld		b, 32
			inc		c
			ld		a, c
			cp		a, 212
			jp		nz, loop
			call	wait_push_space_key

			ld		a, 0x3F
			out		[vdp_port1], a
			ld		a, 0x80 + 2
			out		[vdp_port1], a
			call	wait_push_space_key
			ret
	read_buffer:
			db		0, 0, 0, 0, 0, 0, 0, 0
	font_data:
			db		0x88, 0x88, 0xBB, 0xBB, 0xBB, 0xBB, 0xAA, 0xAA
			db		0x88, 0xBB, 0xDD, 0xDD, 0xDD, 0xDD, 0xBB, 0xAA
			db		0x8B, 0xDD, 0xDB, 0xBB, 0xBB, 0xBD, 0xDD, 0xBA
			db		0xBD, 0xDD, 0xBD, 0xBD, 0xDB, 0xDB, 0xDD, 0xDB
			db		0xBD, 0xDD, 0xBD, 0xDB, 0xBD, 0xDB, 0xDD, 0xDB
			db		0xAB, 0xDD, 0xDB, 0xBB, 0xBB, 0xBD, 0xDD, 0xB8
			db		0xAA, 0xBB, 0xDD, 0xDD, 0xDD, 0xDD, 0xBB, 0x88
			db		0xAA, 0xAA, 0xBB, 0xBB, 0xBB, 0xBB, 0x88, 0x88
	command:
			dw		0				; DX
			dw		257				; DY
			dw		512				; NX
			dw		255				; NY
			db		0x22			; CLR
			db		0				; ARG
			db		0xC0			; CMD : HMMV
			endscope

			include	"../lib.asm"

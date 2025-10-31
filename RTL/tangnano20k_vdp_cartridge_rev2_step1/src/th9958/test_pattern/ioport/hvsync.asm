; =============================================================================
;	HSYNC, VSYNC, Line Interrupt の挙動を確認するテスト
; =============================================================================

			org		0x100

			call	initial_process
			call	copy_rom_font
			call	set_graphic1
			call	check_hsync
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
			endscope

; =============================================================================
;	HSYNC のタイミングを調べる
; =============================================================================
			scope	check_hsync
check_hsync::
			; Space = 0x20 のパターンを変える
			ld		hl, 8 * 0x20
			call	set_vram_write_address
			ld		b, 8
			ld		a, [io_vdp_port0]
			ld		c, a
			ld		hl, pattern
			otir
			; R#15 を S#2 に変更
			ld		a, 2
			ld		e, 15
			call	write_control_register
			di
	loop:
			; VRAM書き込みアドレスを Pattern Name Table の先頭に移動
			ld		hl, 0x1800
			call	set_vram_write_address
			; VSYNCの立ち上がり が来るまで待機
			ld		a, [io_vdp_port1]
			ld		c, a
			ld		b, 0
			ld		d, 3
			ld		e, 0x60
	wait_vsync1:
			in		a, [c]
			and		a, 0x40
			jp		nz, wait_vsync1
	wait_vsync2:
			in		a, [c]
			and		a, 0x40
			jp		z, wait_vsync2
			; VSYNC の立ち上がりタイミングから 768回読む
	dump_loop:
			in		a, [c]
			dec		c
			and		a, e
			out		[c], a
			inc		c
			djnz	dump_loop
			dec		d
			jp		nz, dump_loop
			jp		loop

			ei
			call	wait_push_space_key
			ret
	pattern:
			db		0b00000010
			db		0b00000010
			db		0b00000100
			db		0b11000100
			db		0b00101000
			db		0b00101000
			db		0b00010000
			db		0b00000000
			endscope

			include	"../lib.asm"

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
			call	fill_increment

			ld		hl, 0x0000
			call	set_font
			ret
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
			di
			ld		a, [0x0038]
			ld		hl, [0x0039]
			ld		[backup + 0], a
			ld		[backup + 1], hl
			ld		a, 0xC3
			ld		hl, interrupt_handler
			ld		[0x0038], a
			ld		[0x0039], hl

			ld		a, 0x10
			ld		e, 0
			call	write_control_register
			ld		a, 0x60
			ld		e, 1
			call	write_control_register
			ld		a, 100
			ld		e, 19
			call	write_control_register
			ei
	loop:
			ld		hl, [count]
			ld		a, h
			or		a, l
			jr		nz, loop

			di
			ld		a,  [backup + 0]
			ld		hl, [backup + 1]
			ld		[0x0038], a
			ld		[0x0039], hl

			ld		a, 0x00
			ld		e, 0
			call	write_control_register
			ei
			ret
backup:
			db		0, 0, 0
count:
			dw		60000

interrupt_handler:
			push	af
			push	hl
			in		a, [vdp_port1]
			rlca
			jr		nc, hsync_interrupt
	vsinc_interrupt:
			;	パレットを青くする
			ld		a, 0x04
			out		[vdp_port1], a
			ld		a, 0x80 + 16
			out		[vdp_port1], a
			ld		a, 0x07
			out		[vdp_port2], a
			xor		a, a
			out		[vdp_port2], a
			;		カウントダウン
			ld		hl, [count]
			ld		a, h
			or		a, l
			jr		z, skip
			dec		hl
			ld		[count], hl
	skip:
			pop		hl
			pop		af
			ei
			reti
	hsync_interrupt:
			;	パレットを赤くする
			ld		a, 0x04
			out		[vdp_port1], a
			ld		a, 0x80 + 16
			out		[vdp_port1], a
			ld		a, 0x70
			out		[vdp_port2], a
			xor		a, a
			out		[vdp_port2], a
			;	ステータスを読んで FH をクリアする
			ld		a, 1
			out		[vdp_port1], a
			ld		a, 0x80 + 15
			out		[vdp_port1], a
			in		a, [vdp_port1]
			xor		a, a
			out		[vdp_port1], a
			ld		a, 0x80 + 15
			out		[vdp_port1], a
			pop		hl
			pop		af
			ei
			reti
			endscope

			include	"../lib.asm"

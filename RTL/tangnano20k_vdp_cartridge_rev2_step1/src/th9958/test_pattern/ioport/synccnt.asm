; =============================================================================
;	HSYNC, VSYNC の長さを確認するテスト
; =============================================================================

			org		0x100

			call	initial_process
			call	copy_rom_font
			call	set_graphic1
			call	sync_count1
			call	sync_count2
			call	interrupt_timing1
			call	interrupt_timing2
			call	interrupt_timing3
			call	interrupt_timing4
			call	interrupt_timing5

			di
			xor		a, a
			out		[c], a
			ld		a, 0x80 + 15
			ei
			out		[c], a					; R#15 = S#0

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
			scope	sync_count1
sync_count1::
			di
			ld		c, 0x99

			ld		a, 0x00
			out		[c], a
			ld		a, 0x80 + 9
			out		[c], a					; R#9 = 0x00 (192line mode)

			ld		a, 2
			out		[c], a
			ld		a, 15 + 0x80
			out		[c], a
			ld		de, 0x20
	wait_hr_0:
			in		a, [c]
			and		a, e
			jp		nz, wait_hr_0
	wait_hr_1:
			in		a, [c]
			and		a, e
			jp		z, wait_hr_1
	count_hr:
			in		a, [c]
			inc		d
			and		a, e
			jp		nz, count_hr
			ld		a, d
			ld		[ hr_count ], a

			ld		de, 0x40
	wait_vr_0:
			in		a, [c]
			and		a, e
			jp		nz, wait_vr_0
	wait_vr_1:
			in		a, [c]
			and		a, e
			jp		z, wait_vr_1
	count_vr:
			in		a, [c]
			inc		d
			and		a, e
			jp		nz, count_vr
			ld		a, d
			ld		[ vr_count ], a

			ld		hl, 0x1820
			ld		de, s_message1
			call	puts

			ld		hl, 0x1820 + 4
			ld		a, [ hr_count ]
			call	put_hex

			ld		hl, 0x1840
			ld		de, s_message2
			call	puts

			ld		hl, 0x1840 + 4
			ld		a, [ vr_count ]
			call	put_hex

			call	wait_push_space_key
			ret

s_message1:
			db		"HR: ", 0
s_message2:
			db		"VR: ", 0
hr_count:
			db		0
vr_count:
			db		0
			endscope

; =============================================================================
			scope	sync_count2
sync_count2::
			di
			ld		c, 0x99

			ld		a, 0x80
			out		[c], a
			ld		a, 0x80 + 9
			out		[c], a					; R#9 = 0x80 (212line mode)

			ld		a, 2
			out		[c], a
			ld		a, 15 + 0x80
			out		[c], a
			ld		de, 0x20
	wait_hr_0:
			in		a, [c]
			and		a, e
			jp		nz, wait_hr_0
	wait_hr_1:
			in		a, [c]
			and		a, e
			jp		z, wait_hr_1
	count_hr:
			in		a, [c]
			inc		d
			and		a, e
			jp		nz, count_hr
			ld		a, d
			ld		[ hr_count ], a

			ld		de, 0x40
	wait_vr_0:
			in		a, [c]
			and		a, e
			jp		nz, wait_vr_0
	wait_vr_1:
			in		a, [c]
			and		a, e
			jp		z, wait_vr_1
	count_vr:
			in		a, [c]
			inc		d
			and		a, e
			jp		nz, count_vr
			ld		a, d
			ld		[ vr_count ], a

			ld		hl, 0x1820
			ld		de, s_message1
			call	puts

			ld		hl, 0x1820 + 4
			ld		a, [ hr_count ]
			call	put_hex

			ld		hl, 0x1840
			ld		de, s_message2
			call	puts

			ld		hl, 0x1840 + 4
			ld		a, [ vr_count ]
			call	put_hex

			call	wait_push_space_key
			ret

s_message1:
			db		"HR: ", 0
s_message2:
			db		"VR: ", 0
hr_count:
			db		0
vr_count:
			db		0
			endscope

; =============================================================================
			scope	interrupt_timing1
interrupt_timing1::
			ld		iy, [0xFCC1 - 1]
			ld		ix, 0x00D8				; GTTRIG
			xor		a, a
			call	0x001C					; CALSLT
			or		a, a
			jp		nz, interrupt_timing1

			ld		hl, 0x1800
			ld		bc, 768
			ld		e, '#'
			call	fill_vram

			di
			; 垂直同期割込のタイミング待ち
			ld		c, 0x99

			ld		a, 0x00
			out		[c], a
			ld		a, 0x80 + 9
			out		[c], a					; R#9 = 0x00 (192line mode)

			xor		a, a
			out		[c], a
			ld		a, 0x80 + 15
			out		[c], a					; R#15 = S#0
			in		a, [c]					; 既に立ってる場合があるので空読みしてクリア
	main_loop:
			ld		de, 0x8706
	wait_f1:
			in		a, [c]
			rlca
			jp		nc, wait_f1				; F (bit7) が立つのを待つ

			out		[c], e
			out		[c], d					; R#7 = 6 (赤くする)

			ld		b, 61					; 8clock
	loop2:
			ld		d, 20					; 8clock
	loop1:
			dec		d						; 5clock
			jr		nz, loop1				; NZ=13clock, Z=8clock
			dec		b						; 5clock
			jr		nz, loop2				; NZ=13clock, Z=8clock

			ld		de, 0x8707
			out		[c], e
			out		[c], d					; R#7 = 7 (水色にする)

			ld		iy, [0xFCC1 - 1]
			ld		ix, 0x00D8				; GTTRIG
			xor		a, a
			call	0x001C					; CALSLT
			or		a, a
			jp		nz, exit

			di
			jp		main_loop

	exit:
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	interrupt_timing2
interrupt_timing2::
			ld		iy, [0xFCC1 - 1]
			ld		ix, 0x00D8				; GTTRIG
			xor		a, a
			call	0x001C					; CALSLT
			or		a, a
			jp		nz, interrupt_timing2

			di
			; 垂直同期割込のタイミング待ち
			ld		c, 0x99

			ld		a, 0x80
			out		[c], a
			ld		a, 0x80 + 9
			out		[c], a					; R#9 = 0x80 (212line mode)

			xor		a, a
			out		[c], a
			ld		a, 0x80 + 15
			out		[c], a					; R#15 = S#0
			in		a, [c]					; 既に立ってる場合があるので空読みしてクリア
	main_loop:
			ld		de, 0x8706
	wait_f1:
			in		a, [c]
			rlca
			jp		nc, wait_f1				; F (bit7) が立つのを待つ

			out		[c], e
			out		[c], d					; R#7 = 6 (赤くする)

			ld		b, 61					; 8clock
	loop2:
			ld		d, 20					; 8clock
	loop1:
			dec		d						; 5clock
			jr		nz, loop1				; NZ=13clock, Z=8clock
			dec		b						; 5clock
			jr		nz, loop2				; NZ=13clock, Z=8clock

			ld		de, 0x8707
			out		[c], e
			out		[c], d					; R#7 = 7 (水色にする)

			ld		iy, [0xFCC1 - 1]
			ld		ix, 0x00D8				; GTTRIG
			xor		a, a
			call	0x001C					; CALSLT
			or		a, a
			jp		nz, exit

			di
			jp		main_loop

	exit:
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	interrupt_timing3
interrupt_timing3::
			ld		iy, [0xFCC1 - 1]
			ld		ix, 0x00D8				; GTTRIG
			xor		a, a
			call	0x001C					; CALSLT
			or		a, a
			jp		nz, interrupt_timing3

			ld		hl, 0x1800
			ld		bc, 768
			ld		e, '#'
			call	fill_vram

			di
			; VR立ち上がりのタイミング待ち
			ld		c, 0x99

			ld		a, 0x00
			out		[c], a
			ld		a, 0x80 + 9
			out		[c], a					; R#9 = 0x00 (192line mode)

			ld		a, 2
			out		[c], a
			ld		a, 0x80 + 15
			out		[c], a					; R#15 = S#0
			in		a, [c]					; 既に立ってる場合があるので空読みしてクリア
	main_loop:
			ld		de, 0x870C
	wait_f1:
			in		a, [c]
			and		a, 0x40
			jp		z, wait_f1				; VR (bit6) が立つのを待つ

			out		[c], e
			out		[c], d					; R#7 = 12 (緑にする)

			ld		de, 0x8707
	wait_f2:
			in		a, [c]
			and		a, 0x40
			jp		nz, wait_f2				; VR (bit6) が降りるのを待つ

			out		[c], e
			out		[c], d					; R#7 = 7 (水色にする)

			ld		iy, [0xFCC1 - 1]
			ld		ix, 0x00D8				; GTTRIG
			xor		a, a
			call	0x001C					; CALSLT
			or		a, a
			jp		nz, exit

			di
			jp		main_loop

	exit:
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	interrupt_timing4
interrupt_timing4::
			ld		iy, [0xFCC1 - 1]
			ld		ix, 0x00D8				; GTTRIG
			xor		a, a
			call	0x001C					; CALSLT
			or		a, a
			jp		nz, interrupt_timing4

			ld		hl, 0x1800
			ld		bc, 768
			ld		e, '#'
			call	fill_vram

			di
			; VR立ち上がりのタイミング待ち
			ld		c, 0x99

			ld		a, 0x80
			out		[c], a
			ld		a, 0x80 + 9
			out		[c], a					; R#9 = 0x00 (212line mode)

			ld		a, 2
			out		[c], a
			ld		a, 0x80 + 15
			out		[c], a					; R#15 = S#0
			in		a, [c]					; 既に立ってる場合があるので空読みしてクリア
	main_loop:
			ld		de, 0x870C
	wait_f1:
			in		a, [c]
			and		a, 0x40
			jp		z, wait_f1				; VR (bit6) が立つのを待つ

			out		[c], e
			out		[c], d					; R#7 = 12 (緑にする)

			ld		de, 0x8707
	wait_f2:
			in		a, [c]
			and		a, 0x40
			jp		nz, wait_f2				; VR (bit6) が降りるのを待つ

			out		[c], e
			out		[c], d					; R#7 = 7 (水色にする)

			ld		iy, [0xFCC1 - 1]
			ld		ix, 0x00D8				; GTTRIG
			xor		a, a
			call	0x001C					; CALSLT
			or		a, a
			jp		nz, exit

			di
			jp		main_loop

	exit:
			call	wait_push_space_key
			ret
			endscope

; =============================================================================
			scope	interrupt_timing5
interrupt_timing5::
			ld		iy, [0xFCC1 - 1]
			ld		ix, 0x00D8				; GTTRIG
			xor		a, a
			call	0x001C					; CALSLT
			or		a, a
			jp		nz, interrupt_timing5

			ld		hl, 0x1800
			ld		bc, 768
			ld		e, '$'
			call	fill_vram

			di
			; HR立ち上がりのタイミング待ち
			ld		c, 0x99

			ld		a, 0x00
			out		[c], a
			ld		a, 0x80 + 9
			out		[c], a					; R#9 = 0x00 (192line mode)

			ld		a, 2
			out		[c], a
			ld		a, 0x80 + 15
			out		[c], a					; R#15 = S#0
			in		a, [c]					; 既に立ってる場合があるので空読みしてクリア
	main_loop:
			ld		de, 0x870C
	wait_f1:
			in		a, [c]
			and		a, 0x20
			jp		z, wait_f1				; HR (bit5) が立つのを待つ

			out		[c], e
			out		[c], d					; R#7 = 12 (緑にする)

			ld		de, 0x8707
	wait_f2:
			in		a, [c]
			and		a, 0x20
			jp		nz, wait_f2				; VR (bit5) が降りるのを待つ

			out		[c], e
			out		[c], d					; R#7 = 7 (水色にする)
			jp		main_loop

	exit:
			call	wait_push_space_key
			ret
			endscope

			include	"../lib.asm"

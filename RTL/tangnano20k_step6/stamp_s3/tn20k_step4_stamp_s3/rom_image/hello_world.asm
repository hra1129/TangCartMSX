; -----------------------------------------------------------------------------
;  Hello, world! for cZ80 step1 test program
; =============================================================================
;  Programmed by t.hara
; -----------------------------------------------------------------------------

uart		:= 0x10
vdp_port0	:= 0x98
vdp_port1	:= 0x99
vdp_port2	:= 0x9a
vdp_port3	:= 0x9b
ppi_port	:= 0xa8

rdvrm		:= 0x004a
wrvrm		:= 0x004d
setwrt		:= 0x0053
filvrm		:= 0x0056
chgmod		:= 0x005f
ldirvm		:= 0x005c
jiffy		:= 0xfc9e
font_adr	:= 0x0004

			org		0x4000

			db		"AB"
			dw		entry
			dw		0x0000
			dw		0x0000
			dw		0x0000
			dw		0x0000
			dw		0x0000
			dw		0x0000

			jp		entry
entry:
			; SCREEN2
			ld		a, 2
			call	chgmod
			; 画面を ' ' で敷き詰める
			ld		a, ' '
			ld		hl, 0x1800
			ld		bc, 256 * 3
			call	filvrm
			; フォントをPCGに転送する
			call	set_font
			; フォントに色を付ける
			call	set_color

			; Set Name Table
			ld		hl, name_table1
			ld		de, 0x1800
			ld		bc, name_table1_end - name_table1
			call	ldirvm

			; Set Name Table
			ld		hl, name_table1
			ld		de, 0x1900
			ld		bc, name_table1_end - name_table1
			call	ldirvm

			; Set Name Table
			ld		hl, name_table1
			ld		de, 0x1A00
			ld		bc, name_table1_end - name_table1
			call	ldirvm

			ld		hl, 0x1802
			call	rdvrm
			call	wrvrm
			di
			halt

main_loop:
			; Set Name Table
			ld		hl, name_table1
			ld		de, 0x1800
			ld		bc, name_table1_end - name_table1
			call	ldirvm
			call	wait_time

			; Set Name Table
			ld		hl, name_table1
			ld		de, 0x1900
			ld		bc, name_table1_end - name_table1
			call	ldirvm
			call	wait_time

			; Set Name Table
			ld		hl, name_table1
			ld		de, 0x1A00
			ld		bc, name_table1_end - name_table1
			call	ldirvm
			call	wait_time

			; Set Name Table
			ld		hl, name_table2
			ld		de, 0x1800
			ld		bc, name_table2_end - name_table2
			call	ldirvm
			call	wait_time

			; Set Name Table
			ld		hl, name_table2
			ld		de, 0x1900
			ld		bc, name_table2_end - name_table2
			call	ldirvm
			call	wait_time

			; Set Name Table
			ld		hl, name_table2
			ld		de, 0x1A00
			ld		bc, name_table2_end - name_table2
			call	ldirvm
			call	wait_time
			jp		main_loop

;------------------------------------------------------------------------------
			scope	set_font
set_font::
			ld		hl, 0x0000
			call	setwrt
			call	set_loop
			call	set_loop
	set_loop:
			ld		hl, [font_adr]
			ld		bc, 256 * 8
	loop:
			ld		a, [hl]
			ld		e, a
			rrca
			or		a, e
			rrca
			or		a, e
			out		[vdp_port0], a
			inc		hl
			dec		bc
			ld		a, c
			or		a, b
			jr		nz, loop
			ret
			endscope

;------------------------------------------------------------------------------
			scope	set_color
set_color::
			ld		hl, 0x2000
			call	setwrt
			ld		hl, color0
			call	set_loop
			ld		hl, color1
			call	set_loop
			ld		hl, color2
	set_loop:
			ld		c, 0
	loop_char:
			push	hl
			ld		b, 8
	loop_line:
			ld		a, [hl]
			out		[vdp_port0], a
			inc		hl
			djnz	loop_line
			pop		hl
			dec		c
			jr		nz, loop_char
			ret
	color0:
			db		0x71, 0xF1, 0xF1, 0x71, 0x41, 0x51, 0x51, 0x41
	color1:
			db		0x31, 0xF1, 0xF1, 0x31, 0x21, 0xC1, 0xC1, 0x21
	color2:
			db		0x81, 0xF1, 0xF1, 0x81, 0x91, 0x61, 0x61, 0x91
			endscope

;------------------------------------------------------------------------------
			scope	wait_time
wait_time::
			ld		hl, [jiffy]
			ld		de, 4
			add		hl, de
	loop:
			or		a, a
			ld		de, [jiffy]
			ex		de, hl
			sbc		hl, de
			ex		de, hl
			ret		nc
			jr		loop
			endscope

name_table1::	;	 01234567890123456789012345678901
			db		"  Hello, world!                 "
			db		"                                "
			db		"  This is FPGA-MSX              "
			db		"  (MSX2++ prototype)            "
			db		"  ", 255
name_table1_end::

name_table2::	;	 01234567890123456789012345678901
			db		"  HELLO, WORLD!                 "
			db		"                                "
			db		"  This is fpga-msx              "
			db		"  (MSX    p r o t o t y p e)    "
			db		"  ", 255
name_table2_end::

; -----------------------------------------------------------------------------
;  Hello, world! for cZ80 step1 test program
; =============================================================================
;  Programmed by t.hara
; -----------------------------------------------------------------------------

UART		:= 0x10
VDP_PORT0	:= 0x98
VDP_PORT1	:= 0x99
VDP_PORT2	:= 0x9A
VDP_PORT3	:= 0x9B

			org		0x0000

			di
			jp		entry
			align	0x100
entry:
			ld		sp, 0x8000
			; キー入力待ち
wait_key:
			call	getkey
			and		a, 1
			jr		z, wait_key
			; 開始メッセージ
			ld		hl, s_start
			call	puts
			ld		hl, s_set_mode
			call	puts
			; VDP R#0 : Mode register 0 : SCREEN 1
			ld		bc, 0x0000
			call	wrtvdp
			; VDP R#1 : Mode register 1 : SCREEN 1
			ld		bc, 0x6301
			call	wrtvdp
			; VDP R#2 : Pattern Name Table = 0x1800
			ld		bc, 0x0602
			call	wrtvdp
			; VDP R#3 : Color Table = 0x2000
			ld		bc, 0x8003
			call	wrtvdp
			; VDP R#4 : Pattern Generator Table = 0x0000
			ld		bc, 0x0004
			call	wrtvdp
			; VDP R#5 : Sprite Attribute Table = 0x1B00
			ld		bc, 0x3605
			call	wrtvdp
			; VDP R#6 : Sptite Generator Table = 0x3800
			ld		bc, 0x0706
			call	wrtvdp
			; VDP R#7 : Set Color
			ld		bc, 0xF707
			call	wrtvdp
			; VDP R#8 : Mode Register 2
			ld		bc, 0x0808
			call	wrtvdp
			; VDP R#9 : Mode Register 3
			ld		bc, 0x0009
			call	wrtvdp
			; VDP R#16: Palette Register
			ld		bc, 0x0010
			call	wrtvdp
			; 開始メッセージ
			ld		hl, s_set_color_palette
			call	puts
			; Palette
			ld		c, VDP_PORT2
			ld		a, 0x00			; Palette #0
			out		[c], a
			ld		a, 0x00
			out		[c], a
			ld		a, 0x00			; Palette #1
			out		[c], a
			ld		a, 0x00
			out		[c], a
			ld		a, 0x11			; Palette #2
			out		[c], a
			ld		a, 0x06
			out		[c], a
			ld		a, 0x33			; Palette #3
			out		[c], a
			ld		a, 0x07
			out		[c], a
			ld		a, 0x17			; Palette #4
			out		[c], a
			ld		a, 0x01
			out		[c], a
			ld		a, 0x27			; Palette #5
			out		[c], a
			ld		a, 0x03
			out		[c], a
			ld		a, 0x51			; Palette #6
			out		[c], a
			ld		a, 0x01
			out		[c], a
			ld		a, 0x27			; Palette #7
			out		[c], a
			ld		a, 0x06
			out		[c], a
			ld		a, 0x71			; Palette #8
			out		[c], a
			ld		a, 0x01
			out		[c], a
			ld		a, 0x73			; Palette #9
			out		[c], a
			ld		a, 0x03
			out		[c], a
			ld		a, 0x61			; Palette #10
			out		[c], a
			ld		a, 0x06
			out		[c], a
			ld		a, 0x64			; Palette #11
			out		[c], a
			ld		a, 0x06
			out		[c], a
			ld		a, 0x11			; Palette #12
			out		[c], a
			ld		a, 0x04
			out		[c], a
			ld		a, 0x65			; Palette #13
			out		[c], a
			ld		a, 0x02
			out		[c], a
			ld		a, 0x55			; Palette #14
			out		[c], a
			ld		a, 0x05
			out		[c], a
			ld		a, 0x77			; Palette #15
			out		[c], a
			ld		a, 0x07
			out		[c], a
			; メッセージ
			ld		hl, s_clear_vram
			call	puts
			; VRAM all clear
			ld		hl, 0x0000
			ld		bc, 0x4000
			xor		a, a
			call	filvrm
			; Color table
			ld		hl, 0x2000
			ld		bc, 32
			ld		a, 0xF4
			call	filvrm
			; Set Font Data
			ld		hl, msxfont
			ld		de, 0x0000
			ld		bc, 256 * 8
			call	ldirvm
			; Set Name Table
			ld		hl, name_table
			ld		de, 0x1800
			ld		bc, name_table_end - name_table
			call	ldirvm
			; 終了メッセージ
			ld		hl, s_finish
			call	puts
			halt

; -----------------------------------------------------------------------------
;	getkey
;	input:
;		none
;	output:
;		A ..... button information
;			bit0 ... button[0]
;			bit1 ... button[1]
;	break:
;		B, C, F
; -----------------------------------------------------------------------------
			scope	getkey
getkey::
			in		a, [UART]
			rlca
			rlca
			ret
			endscope

; -----------------------------------------------------------------------------
;	putc
;	input:
;		A ...... send byte
;	output:
;		none
;	break:
;		B, C, F
; -----------------------------------------------------------------------------
			scope	putc
putc::
			ld		c, UART
	wait_loop:
			in		b, [c]
			rr		b
			jr		c, wait_loop
			out		[c], a
			ret
			endscope

; -----------------------------------------------------------------------------
;	puts
;	input:
;		HL ...... target string address ( 0 terminated )
;	output:
;		HL ...... next address
;	break:
;		A, B, C, F
; -----------------------------------------------------------------------------
			scope	puts
puts::
			ld		a, [hl]
			inc		hl
			or		a, a
			ret		z
			call	putc
			jr		puts
			endscope

; -----------------------------------------------------------------------------
;	WRTVDP
;	input:
;		C ... レジスタ番号
;		B ... 書き込む値
;	break:
;		A, b, c, f
; -----------------------------------------------------------------------------
			scope	wrtvdp
wrtvdp::
			ld		a, b
			out		[VDP_PORT1], a
			ld		a, c
			or		a, 0x80
			out		[VDP_PORT1], a
			ret
			endscope

; -----------------------------------------------------------------------------
;	SETWRT
;	input:
;		HL ... 書き込み用にセットする VRAM アドレス
;	break:
;		a, f
; -----------------------------------------------------------------------------
			scope	setwrt
setwrt::
			ld		a, l
			out		[VDP_PORT1], a
			ld		a, h
			and		a, 0x3F
			or		a, 0x40
			out		[VDP_PORT1], a
			ret
			endscope

; -----------------------------------------------------------------------------
;	FILVRM
;	input:
;		HL ... 塗りつぶす VRAM の先頭アドレス
;		BC ... 塗りつぶす BYTE数
;		A .... 塗りつぶす値
;	break:
;		a, b, c, f
; -----------------------------------------------------------------------------
			scope	filvrm
filvrm::
			push	af
			call	setwrt
			pop		af
			push	hl
			ld		l, a
	loop:
			ld		a, l
			out		[VDP_PORT0], a
			dec		bc
			ld		a, c
			or		a, b
			jr		nz, loop
			pop		hl
			ret
			endscope

; -----------------------------------------------------------------------------
;	LDIRVM
;	input:
;		HL ... 転送元の RAMアドレス
;		DE ... 転送先の VRAMアドレス
;		BC ... 転送する長さ
;	break:
;		すべて
; -----------------------------------------------------------------------------
			scope	ldirvm
ldirvm::
			ex		de, hl
			call	setwrt
			ex		de, hl
	loop:
			ld		a, [hl]
			inc		hl
			out		[VDP_PORT0], a
			dec		bc
			ld		a, c
			or		a, b
			jr		nz, loop
			ret
			endscope

s_start:
			db		"Start DEMO", 0x0D, 0x0A, 0
s_set_mode:
			db		"-- set SCREEN1", 0x0D, 0x0A, 0
s_set_color_palette:
			db		"-- set COLOR PALETTE", 0x0D, 0x0A, 0
s_clear_vram:
			db		"-- clear VRAM", 0x0D, 0x0A, 0
s_finish:
			db		"Finish.", 0x0D, 0x0A, 0

name_table::	;	 01234567890123456789012345678901
			db		"  MSX-BASIC version 5.0         "
			db		"  Copyright 2025 by Microsoft   "
			db		"  IoT Media Lab 2025            "
			db		"  MSX Licensing Corp 2025       "
			db		"  25271 Bytes free              "
			db		"  Disk BASIC version 3.00       "
			db		"  Ok                            "
			db		"  ", 255
name_table_end::

msxfont::
			binary_link		"msxfont.rom"

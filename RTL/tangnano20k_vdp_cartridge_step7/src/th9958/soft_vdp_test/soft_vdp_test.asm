; =============================================================================
;	V9958 software test program
; -----------------------------------------------------------------------------
;	Programmed by t.hara (HRA!)
; =============================================================================

			org		0x100

font_ptr		:= 0x0004
bdos			:= 0x0005
calslt			:= 0x001C
enaslt			:= 0x0024
rom_version		:= 0x002D
chgmod			:= 0x005F
gttrig			:= 0x00D8
kilbuf			:= 0x0156
chgcpu			:= 0x0180

command_line	:= 0x005D
ramad0			:= 0xF341
ramad1			:= 0xF342
ramad2			:= 0xF343
ramad3			:= 0xF344
main_rom_slot	:= 0xFCC1

vdp_port0		:= 0x98
vdp_port1		:= 0x99
vdp_port2		:= 0x9A
vdp_port3		:= 0x9B

font_data		:= 0x8000

func_term		:= 0x00

start:
			; 準備
			call	vdp_io_select
			call	copy_rom_font
			; テスト
			call	screen0_w40
			call	s0w40_font_test
			call	s0w40_color
			call	s0w40_palette
			call	s0w40_vscroll
			call	s0w40_hscroll
			call	s0w40_display_adjust
			call	s0w40_interlace

			call	screen1
			call	s1_font_test
			call	s1_color
			call	s1_vscroll
			call	s1_hscroll
			call	s1_display_adjust
			call	s1_interlace

			; 後始末
			call	clear_key_buffer
			ld		c, func_term
			jp		bdos

; =============================================================================
;	VDP の I/O アドレスを選択する
;	input:
;		none
;	output:
;		none
;	break:
;		AF, B, DE, HL
;	comment:
;		VDPアクセス関連のサブルーチンを 88h, 98h のどちらかに設定する
; =============================================================================
			scope	vdp_io_select
vdp_io_select::
			; check command line option
			ld		hl, command_line
			ld		b, 16
	search_loop:
			dec		b
			jr		z, exit_search
			ld		a, [hl]
			inc		hl
			cp		a, ' '
			jr		z, search_loop
	exit_search:
			cp		a, '8'
			ret		nz
			; modify I/O address to 88h
			ld		hl, update_table
	update_loop:
			; テーブルから1エントリ読みだす
			ld		e, [hl]
			inc		hl
			ld		d, [hl]
			inc		hl
			; 読みだした結果が 0 か？、0 なら終わり。
			ld		a, e
			or		a, d
			ret		z
			; 0 でなければ、その値のアドレスに andマスク 0x8F を掛ける。
			ex		de, hl
			ld		a, [hl]
			and		a, 0x8F
			ld		[hl], a
			ex		de, hl
			jr		update_loop
	update_table:
			dw		p_vdp_port0
			dw		p_vdp_port1
			dw		p_vdp_port2
			dw		p_vdp_port3
			dw		p_vdp_port4
			dw		p_vdp_port5
			dw		p_vdp_port6
			dw		p_vdp_port7
			dw		p_vdp_port8
			dw		p_vdp_port9
			dw		p_vdp_port10
			dw		p_vdp_port11
			dw		0				; end mark
			endscope

; =============================================================================
;	書き込み用 VRAM アドレスセット
;	input:
;		HL .... 0x0000~0x3FFF VRAM address
;	output:
;		none
;	break:
;		AF
;	comment:
;		書き込み用に設定する
; =============================================================================
			scope	set_vram_write_address
set_vram_write_address::
			di
			ld		a, l
p_vdp_port0	:= $ + 1
			out		[ vdp_port1 ], a
			ld		a, h
			and		a, 0x3F
			or		a, 0x40
p_vdp_port1	:= $ + 1
			out		[ vdp_port1 ], a
			ei
			ret
			endscope

; =============================================================================
;	読みだし用 VRAM アドレスセット
;	input:
;		HL .... 0x0000~0x3FFF VRAM address
;	output:
;		none
;	break:
;		AF
;	comment:
;		書き込み用に設定する
; =============================================================================
			scope	set_vram_read_address
set_vram_read_address::
			di
			ld		a, l
p_vdp_port2	:= $ + 1
			out		[ vdp_port1 ], a
			ld		a, h
			and		a, 0x3F
p_vdp_port3	:= $ + 1
			out		[ vdp_port1 ], a
			ei
			ret
			endscope

; =============================================================================
;	コントロールレジスタへの書き込み
;	input:
;		A .... 書き込む値
;		E .... コントロールレジスタ番号
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	write_control_register
write_control_register::
			di
p_vdp_port4	:= $ + 1
			out		[ vdp_port1 ], a
			ld		a, e
			and		a, 0x3F
			or		a, 0x80
p_vdp_port5	:= $ + 1
			out		[ vdp_port1 ], a
			ei
			ret
			endscope

; =============================================================================
;	パレットの書き込み
;	input:
;		A .... R, B
;		E ....    G
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	write_palette
write_palette::
p_vdp_port6	:= $ + 1
			out		[ vdp_port2 ], a
			ld		a, e
p_vdp_port7	:= $ + 1
			out		[ vdp_port2 ], a
			ret
			endscope

; =============================================================================
;	ステータスレジスタのリード
;	input:
;		none
;	output:
;		A .... 読みだした値
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	read_status_register
read_status_register::
p_vdp_port8	:= $ + 1
			in		a, [ vdp_port1 ]
			ret
			endscope

; =============================================================================
;	VRAM のリード
;	input:
;		none
;	output:
;		A .... 読みだした値
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	read_vram
read_vram::
p_vdp_port9	:= $ + 1
			in		a, [ vdp_port0 ]
			ret
			endscope

; =============================================================================
;	VRAM のライト
;	input:
;		A .... 書き込む値
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	write_vram
write_vram::
p_vdp_port10	:= $ + 1
			out		[ vdp_port0 ], a
			ret
			endscope

; =============================================================================
;	VDP コントロールレジスタへの間接書き込み
;	input:
;		A .... 書き込む値
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	write_register
write_register::
p_vdp_port11	:= $ + 1
			out		[ vdp_port3 ], a
			ret
			endscope

; =============================================================================
;	Pattern Name Table
;	input:
;		HL .... Pattern Name Table Address
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	set_pattern_name_table
set_pattern_name_table::
			; A = HL >> 10
			ld		a, h
			srl		a
			srl		a
			ld		e, 2
			jp		write_control_register
			endscope

; =============================================================================
;	Color table
;	input:
;		HL .... Color Table Address
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	set_color_table
set_color_table::
			srl		h
			rr		l
			srl		h
			rr		l
			srl		h
			rr		l
			srl		h
			rr		l
			srl		h
			rr		l
			srl		h
			rr		l
			ld		a, l
			ld		e, 3
			call	write_control_register
			ld		a, h
			ld		e, 10
			jp		write_control_register
			endscope

; =============================================================================
;	Sprite attribute table
;	input:
;		HL .... Sprite attribute Table Address
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	set_sprite_attribute_table
set_sprite_attribute_table::
			srl		h
			rr		l
			srl		h
			rr		l
			srl		h
			rr		l
			srl		h
			rr		l
			srl		h
			rr		l
			srl		h
			rr		l
			srl		h
			rr		l
			ld		a, l
			ld		e, 5
			call	write_control_register
			ld		a, h
			ld		e, 11
			jp		write_control_register
			endscope

; =============================================================================
;	Sprite pattern generator table
;	input:
;		HL .... Sprite pattern generator Table Address
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	set_sprite_pattern_generator_table
set_sprite_pattern_generator_table::
			srl		h
			srl		h
			srl		h
			ld		a, h
			ld		e, 6
			jp		write_control_register
			endscope

; =============================================================================
;	Pattern Generator Table
;	input:
;		HL .... Pattern Generator Table Address
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	set_pattern_generator_table
set_pattern_generator_table::
			; A = HL >> 11
			ld		a, h
			srl		a
			srl		a
			srl		a
			ld		e, 4
			jp		write_control_register
			endscope

; =============================================================================
;	copy ROM Font 
;	input:
;		none
;	output:
;		none
;	break:
;		all
;	comment:
;		MAIN-ROM にある ROMフォントを C000h にコピーする
; =============================================================================
			scope	copy_rom_font
copy_rom_font::
			; page0 を RAM に戻す ENASLT を DOS版で上書き ( BIOS の ENASLT は page0 を変更すると暴走する )
			ld		hl, [enaslt + 1]
			ld		[call_enaslt + 1], hl
			; page2 に転送プログラムを転送する
			ld		hl, copy_program
			ld		de, 0x7F00
			ld		bc, copy_program_end - copy_program
			ldir
			jp		0x7F00
	copy_program:
			; SLOT を MAIN-ROM に切り替える
			di
			ld		a, [main_rom_slot]
			ld		h, 0x00
			call	enaslt
			; もし turboR なら Z80モードに切り替える
			ld		a, [rom_version]
			cp		a, 3
			jr		c, skip
			ld		a, 0x80
			call	chgcpu
	skip:
			; Font の格納アドレスを得る
			ld		hl, [font_ptr]
			; 転送先
			ld		de, font_data
			; 256文字, 1文字 8byte
			ld		bc, 256 * 8
			ldir
			; SLOT を RAM に戻す
			ld		a, [ramad0]
			ld		h, 0x00
	call_enaslt:
			call	enaslt
			ret
	copy_program_end:
			endscope

; =============================================================================
;	set Font 
;	input:
;		HL .... ROMフォントを書き込むVRAM上の先頭アドレス
;	output:
;		none
;	break:
;		all
;	comment:
;		copy_rom_font を事前に実行しておく必要がある
; =============================================================================
			scope	set_font
set_font::
			call	set_vram_write_address
			ld		hl, font_data
			ld		bc, 256 * 8
	loop:
			ld		a, [hl]
			inc		hl
			call	write_vram
			dec		bc
			ld		a, c
			or		a, b
			jp		nz, loop
			ret
			endscope

; =============================================================================
;	fill VRAM
;	input:
;		HL .... 対象のVRAMの先頭アドレス
;		BC .... サイズ
;		E ..... 塗りつぶす値
;	output:
;		none
;	break:
;		all
;	comment:
;		none
; =============================================================================
			scope	fill_vram
fill_vram::
			call	set_vram_write_address
	loop:
			ld		a, e
			call	write_vram
			dec		bc
			ld		a, c
			or		a, b
			jp		nz, loop
			ret
			endscope

; =============================================================================
;	Space Key が押されるのを待つ
;	input:
;		none
;	output:
;		none
;	break:
;		all
;	comment:
;		none
; =============================================================================
			scope	wait_push_space_key
wait_push_space_key::
			; まずスペースキーが押されていれば、解放されるのを待つ
	wait_free_loop:
			ld		iy, [main_rom_slot - 1]
			ld		ix, gttrig
			xor		a, a
			call	calslt
			or		a, a
			jr		nz, wait_free_loop
			; スペースキーが押されるのを待つ
	wait_press_loop:
			ld		iy, [main_rom_slot - 1]
			ld		ix, gttrig
			xor		a, a
			call	calslt
			or		a, a
			jr		z, wait_press_loop
			ei
			ret
			endscope

; =============================================================================
;	キーバッファをクリアする
;	input:
;		none
;	output:
;		none
;	break:
;		all
;	comment:
;		none
; =============================================================================
			scope	clear_key_buffer
clear_key_buffer::
			di
			ld		iy, [main_rom_slot - 1]
			ld		ix, kilbuf
			call	calslt
			ld		iy, [main_rom_slot - 1]
			ld		ix, chgmod
			ld		a, 0
			call	calslt
			ei
			ret
			endscope

; =============================================================================
;	文字列を表示(PCG系)
;	input:
;		HL .... VRAMアドレス
;		DE .... 文字列のアドレス
;	output:
;		none
;	break:
;		all
;	comment:
;		none
; =============================================================================
			scope	puts
puts::
			call	set_vram_write_address
	loop:
			ld		a, [de]
			inc		de
			or		a, a
			ret		z
			call	write_vram
			jr		loop
			endscope

; =============================================================================
;	SCREEN0 (WIDTH40)
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen0_w40
screen0_w40::
			; R#0 = 0
			xor		a, a
			ld		e, a
			call	write_control_register
			; R#1 = 0x50
			ld		a, 0x50
			ld		e, 1
			call	write_control_register
			; R#7 = 0xF4
			ld		a, 0xF4					; 前景 15, 背景 4
			ld		e, 7
			call	write_control_register
			; Pattern Name Table
			ld		hl, 0
			call	set_pattern_name_table
			; Pattern Name Table をクリア
			ld		hl, 0
			ld		bc, 40 * 26
			ld		a, ' '
			call	fill_vram
			; Pattern Generator Table
			ld		hl, 0x800
			call	set_pattern_generator_table
			; Font をセット
			ld		hl, 0x800
			call	set_font
			ret
			endscope

; =============================================================================
;	SCREEN1
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen1
screen1::
			; R#0 = 0
			xor		a, a
			ld		e, a
			call	write_control_register
			; R#1 = 0x40
			ld		a, 0x40
			ld		e, 1
			call	write_control_register
			; R#7 = 0x07
			ld		a, 0x07					; 周辺色 7
			ld		e, 7
			call	write_control_register
			; Pattern Name Table
			ld		hl, 0x1800
			call	set_pattern_name_table
			; Color Table
			ld		hl, 0x2000
			call	set_color_table
			; Sprite Attribute Table
			ld		hl, 0x1B00
			call	set_sprite_attribute_table
			; Sprite Pattern Generator Table
			ld		hl, 0x3800
			call	set_sprite_pattern_generator_table
			; Pattern Generator Table
			ld		hl, 0x0000
			call	set_pattern_generator_table
			; Pattern Name Table をクリア
			ld		hl, 0x1800
			ld		bc, 32 * 26
			ld		e, ' '
			call	fill_vram
			; Font をセット
			ld		hl, 0x0000
			call	set_font
			; Fontの色をセット
			ld		hl, 0x2000
			ld		bc, 256 / 8
			ld		e, 0xF4
			call	fill_vram
			ret
			endscope

; =============================================================================
;	[SCREEN0W40] 文字フォントが期待通りに表示される・40桁、24行表示される
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_font_test
s0w40_font_test::
			; Pattern Name Table にインクリメントデータを敷き詰める
			ld		hl, 0
			ld		bc, 40 * 24
			call	fill_increment
			; Put test name
			ld		hl, 0
			ld		de, s_message
			call	puts
			; キー待ち
			call	wait_push_space_key
			ret
	s_message:
			db		"[S0W40] FONT TEST ", 0
			endscope

; =============================================================================
;	[SCREEN1] 文字フォントが期待通りに表示される・32桁、24行表示される
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s1_font_test
s1_font_test::
			; Pattern Name Table にインクリメントデータを敷き詰める
			ld		hl, 0x1800
			ld		bc, 32 * 24
			call	fill_increment
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			; キー待ち
			call	wait_push_space_key
			ret
	s_message:
			db		"[S1] FONT TEST ", 0
			endscope

; =============================================================================
;	[SCREEN0W40] 文字の色を変える
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_color
s0w40_color::
			; Put test name
			ld		hl, 0
			ld		de, s_message
			call	puts
			ld		hl, color_table
	loop:
			; set color
			ld		a, [hl]
			or		a, a
			ret		z							; finish
			ld		e, 7
			call	write_control_register
			; put message
			inc		hl
			ex		de, hl
			ld		hl, 40
			call	puts
			ex		de, hl
			call	wait_push_space_key
			jr		loop
	s_message:
			db		"[S0W40] COLOR TEST ", 0
	color_table:
			db		0xF0, "FG=WHITE, BG=TRANS ", 0
			db		0xE1, "FG=GRAY,  BG=BLACK ", 0
			db		0xD1, "FG=PINK,  BG=BLACK ", 0
			db		0xC3, "FG=GREEN, BG=LITE GREEN ", 0
			db		0xB6, "FG=CREAM, BG=RED       ", 0
			db		0xA8, "FG=YELLOW,BG=LITE RED", 0
			db		0x91, "FG=RED,   BG=BLACK   ", 0
			db		0x74, "FG=CYAN,  BG=BLUE ", 0
			db		0x57, "FG=BLUE,  BG=CYAN ", 0
			db		0xF4, "FG=WHITE, BG=BLUE ", 0
			db		0xF4, "                  ", 0
			db		0
			endscope

; =============================================================================
;	[SCREEN1] 文字の色を変える
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s1_color
s1_color::
			; Pattern Name Table にインクリメントデータを敷き詰める
			ld		hl, 0x1800
			ld		bc, 32 * 24
			call	fill_increment
			; 色データをコピー
			ld		hl, color_table
			ld		de, 0x2000
			ld		bc, 32
			call	block_copy
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			; キー待ち
			call	wait_push_space_key
			ret
	color_table:
			db		0xF4, 0xE5, 0xF6, 0xE7, 0xF2, 0xE3, 0x17, 0x71
			db		0xBC, 0x23, 0xF8, 0x7F, 0xF3, 0xD4, 0x27, 0x72
			db		0xA6, 0x45, 0xE9, 0xF7, 0xE2, 0xB5, 0x37, 0x73
			db		0xB4, 0x68, 0xE6, 0xE4, 0xA3, 0xC6, 0x47, 0x74
	s_message:
			db		"[S1] COLOR TEST ", 0
			endscope


; =============================================================================
;	[SCREEN0W40] パレットを変える
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_palette
s0w40_palette::
			; Put test name
			ld		hl, 0
			ld		de, s_message
			call	puts
			ld		hl, palette_table
	palette_loop:
			ld		a, [hl]
			inc		a
			ret		z
	color_loop:
			ld		a, [hl]
			inc		hl
			inc		a
			jr		z, key_wait
			dec		a
			ld		e, 16
			call	write_control_register		; R#16 = palette number
			ld		a, [hl]
			inc		hl
			ld		e, [hl]
			inc		hl
			call	write_palette
			jr		color_loop
	key_wait:
			call	wait_push_space_key
			jr		palette_loop
	s_message:
			db		"[S0W40] PALETTE TEST ", 0
	palette_table:
			db		0x04, 0x07, 0x00, 0x0F, 0x77, 0x07, 0xFF
			db		0x04, 0x06, 0x01, 0x0F, 0x66, 0x07, 0xFF
			db		0x04, 0x15, 0x02, 0x0F, 0x55, 0x06, 0xFF
			db		0x04, 0x14, 0x03, 0x0F, 0x44, 0x06, 0xFF
			db		0x04, 0x23, 0x04, 0x0F, 0x33, 0x05, 0xFF
			db		0x04, 0x22, 0x05, 0x0F, 0x22, 0x05, 0xFF
			db		0x04, 0x31, 0x06, 0x0F, 0x11, 0x04, 0xFF
			db		0x04, 0x30, 0x07, 0x0F, 0x00, 0x04, 0xFF
			db		0x04, 0x07, 0x00, 0x0F, 0x77, 0x07, 0xFF
			db		0xFF
			endscope

; =============================================================================
;	VRAM をインクリメント値で埋める
;	input:
;		HL .... VRAMアドレス
;		BC .... 埋めるサイズ [byte]
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	fill_increment
fill_increment::
			call	set_vram_write_address
			ld		e, 0
	loop:
			ld		a, e
			call	write_vram
			inc		e
			dec		bc
			ld		a, c
			or		a, b
			jr		nz, loop
			ret
			endscope

; =============================================================================
;	VRAM をインクリメント値で埋める
;	input:
;		HL .... 転送元アドレス
;		DE .... 転送先VRAMアドレス
;		BC .... サイズ [byte]
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	block_copy
block_copy::
			ex		de, hl
			call	set_vram_write_address
			ex		de, hl
	loop:
			ld		a, [hl]
			inc		hl
			call	write_vram
			dec		bc
			ld		a, c
			or		a, b
			jr		nz, loop
			ret
			endscope

; =============================================================================
;	垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	vscroll
vscroll::
			ld		d, 0
	loop:
			ld		a, d
			ld		e, 23
			call	write_control_register		; R#23 = D

			xor		a, a
	wait_loop1:
			ld		e, 50
	wait_loop2:
			dec		e
			jr		nz, wait_loop2
			dec		a
			jr		nz, wait_loop1

			inc		d							; D++
			jr		nz, loop

			xor		a, a
			ld		e, 23
			call	write_control_register		; R#23 = 0
			jp		wait_push_space_key
			endscope

; =============================================================================
;	水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	hscroll
hscroll::
			ld		d, 0
	loop:
			ld		a, d
			and		a, 7
			xor		a, 7
			ld		e, 27
			call	write_control_register		; R#27 = D
			ld		a, d
			rrca
			rrca
			rrca
			and		a, 0x1F
			ld		e, 26
			call	write_control_register		; R#26 = D

			xor		a, a
	wait_loop1:
			ld		e, 50
	wait_loop2:
			dec		e
			jr		nz, wait_loop2
			dec		a
			jr		nz, wait_loop1

			inc		d							; D++
			jr		nz, loop

			xor		a, a
			ld		e, 26
			call	write_control_register		; R#26 = 0
			xor		a, a
			ld		e, 27
			call	write_control_register		; R#27 = 0
			jp		wait_push_space_key
			endscope

; =============================================================================
;	画面位置調整
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	display_adjust
display_adjust::
			ld		hl, adjust_table
	loop:
			ld		a, [hl]
			ld		e, 18
			call	write_control_register		; R#18 = [HL]
			xor		a, a
	wait_loop1:
			ld		e, 50
	wait_loop2:
			dec		e
			jr		nz, wait_loop2
			dec		a
			jr		nz, wait_loop1

			ld		a, [hl]
			inc		hl
			or		a, a
			jr		nz, loop
			jp		wait_push_space_key

adjust_table:
			db		0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77
			db		0x76, 0x75, 0x74, 0x73, 0x72, 0x71, 0x70
			db		0x7F, 0x7E, 0x7D, 0x7C, 0x7B, 0x7A, 0x79
			db		0x78, 0x68, 0x58, 0x48, 0x38, 0x28, 0x18
			db		0x08, 0xF8, 0xE8, 0xD8, 0xC8, 0xB8, 0xA8
			db		0x98, 0x88, 0x99, 0xAA, 0xBB, 0xCC, 0xDD
			db		0xEE, 0xFF, 0x00
			endscope

; =============================================================================
;	[SCREEN0W40] 垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_vscroll
s0w40_vscroll::
			; Put test name
			ld		hl, 0
			ld		de, s_message
			call	puts
			jp		vscroll
	s_message:
			db		"[S0W40] V-SCROLL TEST ", 0
			endscope

; =============================================================================
;	[SCREEN1] 垂直スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s1_vscroll
s1_vscroll::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		vscroll
	s_message:
			db		"[S1] V-SCROLL TEST ", 0
			endscope

; =============================================================================
;	[SCREEN0W40] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_hscroll
s0w40_hscroll::
			; Put test name
			ld		hl, 0
			ld		de, s_message
			call	puts
			jp		hscroll
	s_message:
			db		"[S0W40] H-SCROLL TEST ", 0
			endscope

; =============================================================================
;	[SCREEN1] 水平スクロールレジスタ
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s1_hscroll
s1_hscroll::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		hscroll
	s_message:
			db		"[S1] H-SCROLL TEST ", 0
			endscope

; =============================================================================
;	[SCREEN0W40] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_display_adjust
s0w40_display_adjust::
			; Put test name
			ld		hl, 0
			ld		de, s_message
			call	puts
			jp		display_adjust
	s_message:
			db		"[S0W40] DISPLAY ADJUST TEST ", 0
			endscope

; =============================================================================
;	[SCREEN1] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s1_display_adjust
s1_display_adjust::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		display_adjust
	s_message:
			db		"[S1] DISPLAY ADJUST TEST ", 0
			endscope

; =============================================================================
;	[SCREEN0W40] interlace mode
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s0w40_interlace
s0w40_interlace::
			; Put test name
			ld		hl, 0
			ld		de, s_message1
			call	puts
			; R#9 = 0b00001000 ... IL=1: Interlace: NT=0: NTSC
			ld		a, 0x08
			ld		e, 9
			call	write_control_register
			call	wait_push_space_key

			; Put test name
			ld		hl, 0
			ld		de, s_message2
			call	puts
			; R#9 = 0b00000010 ... IL=0: Non Interlace, NT=1: PAL
			ld		a, 0x02
			ld		e, 9
			call	write_control_register
			call	wait_push_space_key

			; Put test name
			ld		hl, 0
			ld		de, s_message3
			call	puts
			; R#9 = 0b00001010 ... IL=1: Interlace, NT=1: PAL
			ld		a, 0x0A
			ld		e, 9
			call	write_control_register
			call	wait_push_space_key

			; R#9 = 0b00000000 ... IL=0: Non Interlace, NT=0: NTSC
			ld		a, 0x0A
			ld		e, 9
			jp		write_control_register

	s_message1:
			db		"[S0W40] INTERLACE TEST      ", 0
	s_message2:
			db		"[S0W40] PAL TEST      ", 0
	s_message3:
			db		"[S0W40] INTERLACE/PAL TEST ", 0
			endscope

; =============================================================================
;	[SCREEN1] interlace mode
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s1_interlace
s1_interlace::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message1
			call	puts
			; R#9 = 0b00001000 ... IL=1: Interlace: NT=0: NTSC
			ld		a, 0x08
			ld		e, 9
			call	write_control_register
			call	wait_push_space_key

			; Put test name
			ld		hl, 0x1800
			ld		de, s_message2
			call	puts
			; R#9 = 0b00000010 ... IL=0: Non Interlace, NT=1: PAL
			ld		a, 0x02
			ld		e, 9
			call	write_control_register
			call	wait_push_space_key

			; Put test name
			ld		hl, 0x1800
			ld		de, s_message3
			call	puts
			; R#9 = 0b00001010 ... IL=1: Interlace, NT=1: PAL
			ld		a, 0x0A
			ld		e, 9
			call	write_control_register
			call	wait_push_space_key

			; R#9 = 0b00000000 ... IL=0: Non Interlace, NT=0: NTSC
			ld		a, 0x0A
			ld		e, 9
			jp		write_control_register

	s_message1:
			db		"[S1] INTERLACE TEST      ", 0
	s_message2:
			db		"[S1] PAL TEST      ", 0
	s_message3:
			db		"[S1] INTERLACE/PAL TEST ", 0
			endscope

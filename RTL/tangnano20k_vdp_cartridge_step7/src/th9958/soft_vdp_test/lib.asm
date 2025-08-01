; =============================================================================
;	V9958 software test program
; -----------------------------------------------------------------------------
;	Programmed by t.hara (HRA!)
; =============================================================================

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

font_data		:= 0x4000		; 256 * 8 = 0x800 bytes

; BDOS function call
_TERM0		:= 0x00
_CONIN		:= 0x01
_CONOUT		:= 0x02
_AUXIN		:= 0x03
_AUXOUT		:= 0x04
_LSTOUT		:= 0x05
_DIRIO		:= 0x06
_DIRIN		:= 0x07
_INNOE		:= 0x08
_STROUT		:= 0x09
_BUFIN		:= 0x0A
_CONST		:= 0x0B
_CPMVER		:= 0x0C
_DSKRST		:= 0x0D
_SELDSK		:= 0x0E
_FOPEN		:= 0x0F
_FCLOSE		:= 0x10
_SFIRST		:= 0x11
_SNEXT		:= 0x12
_FDEL		:= 0x13
_RDSEQ		:= 0x14
_WRSEQ		:= 0x15
_FMAKE		:= 0x16
_FREN		:= 0x17
_LOGIN		:= 0x18
_CURDRV		:= 0x19
_SETDTA		:= 0x1A
_ALLOC		:= 0x1B
_RDRND		:= 0x21
_WRRND		:= 0x22
_FSIZE		:= 0x23
_SETRND		:= 0x24
_WRBLK		:= 0x26
_RDBLK		:= 0x27
_WRSER		:= 0x28
_GDATE		:= 0x2A
_SDATE		:= 0x2B
_GTIME		:= 0x2C
_STIME		:= 0x2D
_VERIFY		:= 0x2E
_RDABS		:= 0x2F
_WRABS		:= 0x30
_DPARM		:= 0x31
_FFIRST		:= 0x40
_FNEXT		:= 0x41
_FNEW		:= 0x42

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
			push	de
			xor		a, a
			ld		e, 14
			call	write_control_register
			pop		de
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
			push	de
			xor		a, a
			ld		e, 14
			call	write_control_register
			pop		de
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
;	VRAM をインクリメント値で埋める
;	input:
;		HL .... VRAMアドレス
;		BC .... 埋めるサイズ [byte]
;	output:
;		none
;	break:
;		AF, BC, E
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
;		HL .... VRAMアドレス
;		BC .... 埋めるサイズ [byte]
;	output:
;		none
;	break:
;		AF, BC, DE
;	comment:
;		none
; =============================================================================
			scope	fill_random
fill_random::
			call	set_vram_write_address
			ld		e, 19
			ld		d, 133
	loop:
			ld		a, e
			add		a, d
			xor		a, 0x5A
			inc		a
			ld		e, d
			ld		d, a
			call	write_vram
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
;		AF, BC, DE, HL
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

; =============================================================================
;	V9968 software test program
; -----------------------------------------------------------------------------
;	Programmed by t.hara (HRA!)
; =============================================================================

			org		0x100

h_keyi		:= 0xFD9A

start:
			; 準備
			call	vdp_io_select
			call	copy_rom_font
			; テスト
			di
			call	screen1
			call	sc1_interrupt
			ei
			; 後始末
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include "lib.asm"

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
			; R#8 = 0x02
			ld		a, 0x02					; スプライト非表示
			ld		e, 8
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
			call	fill_increment
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
;	SCREEN1 interrupt test
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	sc1_interrupt
sc1_interrupt::
			di
			; 本体側の VDP が割り込みを発生させないように禁止にする
			ld		c, 0x99
			; 垂直同期割込を禁止する(R#1)
			ld		a, 0x40
			out		[c], a
			ld		a, 0x81
			out		[c], a
			; 走査線割り込みを禁止する(R#0)
			ld		a, 0x00
			out		[c], a
			ld		a, 0x80
			out		[c], a
			; 割り込み処理ルーチンを 4000h へ転送する (H_KEYI を呼ぶときに page0 は MAIN-ROM に切り替わっている)
			ld		hl, h_keyi_new_org
			ld		de, h_keyi_new
			ld		bc, h_keyi_new_end - h_keyi_new
			ldir
			; 走査線割り込みのライン番号を指定する
			ld		a, [io_vdp_port1]
			ld		[my_vdp_port1], a
			ld		c, a
			ld		a, 100
			out		[c], a
			ld		a, 0x80 + 19
			out		[c], a
			; 垂直同期割込を許可する(R#1)
			ld		a, 0x60
			out		[c], a
			ld		a, 0x81
			out		[c], a
			; 割り込みフックを設定
			ld		a, 0xC3			; JP
			ld		hl, h_keyi_new
			ld		[h_keyi + 0], a
			ld		[h_keyi + 1], hl
			; ボタン押し待ち
			ei
			call	wait_push_space_key
			di
			; 走査線割り込みを許可する(R#0)
			ld		a, 0x10
			out		[c], a
			ld		a, 0x80
			out		[c], a
			; ボタン押し待ち
			ei
			call	wait_push_space_key
			di
			; 割り込みフックを停止
			ld		a, 0xC9			; RET
			ld		[h_keyi + 0], a
			; 走査線割り込みを禁止する(R#0)
			ld		a, 0x00
			out		[c], a
			ld		a, 0x80
			out		[c], a
			; 垂直同期割込を禁止する(R#1)
			ld		a, 0x40
			out		[c], a
			ld		a, 0x81
			out		[c], a
			ret

	h_keyi_new_org:
			org		0x4000
	h_keyi_new:
			; 走査線割り込みかどうかをチェック
			; S#2
			ld		a, [my_vdp_port1]
			ld		c, a
			ld		a, 1
			out		[c], a
			ld		a, 0x8F
			out		[c], a
			in		a, [c]
			and		a, 1
			jp		nz, line_interrupt
			; R#15 = 0 に戻す
			out		[c], a
			ld		a, 0x8F
			out		[c], a
			; S#0 を読む
			in		a, [c]
			and		a, 0x80
			ret		z
			; 垂直同期割込
	frame_interrupt:
			; スクロール位置を動かす
			ld		a, [scroll1]
			inc		a
			ld		[scroll1], a

			ld		b, a
			rrca
			rrca
			rrca
			cpl
			and		a, 0x1F
			out		[c], a
			ld		a, 0x80 + 26
			out		[c], a
			out		[c], b
			ld		a, 0x80 + 27
			out		[c], a
			ret
			; 走査線割込
	line_interrupt:
			; スクロール位置を動かす
			ld		a, [scroll2]
			dec		a
			ld		[scroll2], a

			ld		b, a
			rrca
			rrca
			rrca
			cpl
			and		a, 0x1F
			out		[c], a
			ld		a, 0x80 + 26
			out		[c], a
			out		[c], b
			ld		a, 0x80 + 27
			out		[c], a
			; R#15 = 0 に戻す
			xor		a, a
			out		[c], a
			ld		a, 0x8F
			out		[c], a
			ret
	my_vdp_port1:
			db		0
	scroll1:
			db		0
	scroll2:
			db		0
	h_keyi_new_end:
			org		h_keyi_new_org + (h_keyi_new_end - h_keyi_new)
			endscope

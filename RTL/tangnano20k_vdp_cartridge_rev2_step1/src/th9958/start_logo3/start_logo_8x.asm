; -----------------------------------------------------------------------------
; Start Logo Program
; 
; Copyright (c) 2021 HRA!
;
; -----------------------------------------------------------------------------

				org			0x0100

bdos			:=			0x0005

vdp_port0		:=			0x88
vdp_port1		:=			0x89
vdp_port2		:=			0x8A
vdp_port3		:=			0x8B
vdp_port4		:=			0x8C

rtc_address		:=			0xB4
rtc_data		:=			0xB5

calslt			:=			0x001C
main_rom_slot	:=			0xFCC1
kilbuf			:=			0x0156
chgmod			:=			0x005F

; -----------------------------------------------------------------------------
; Initialize VDP
; -----------------------------------------------------------------------------
				scope		init_vdp
init_vdp::
				di
				call		write_vdp_regs

vdp_init_data::
				db			0x80 |  1, 0x63				; R#1  = モードレジスタ SCREEN6, 画面表示, 垂直同期割り込み許可
				db			0x80 |  0, 0x08				; R#0  = モードレジスタ SCREEN6
				db			0x80 |  2, 0x1F | (0 << 5)	; R#2  : パターンネームテーブル (表示ページ 0)
				db			0x80 |  5, 0x7600 >> 7		; R#5  : スプライトアトリビュートテーブルの下位
				db			0x80 |  6, 0x8000 >> 11		; R#6  : スプライトパターンジェネレータテーブルのアドレス
				db			0x80 |  7, 0x00				; R#7  : 背景色 
				db			0x80 |  8, 0x2A				; R#8  = モードレジスタ palette0は不透明, スプライト非表示
				db			0x80 |  9, 0x00				; R#9  : モードレジスタ
				db			0x80 | 11, 0x00				; R#11 : スプライトアトリビュートテーブルの上位
				db			0x80 | 15, 2				; R#15 : ステータスレジスタ 2
				db			0x80 | 16, 0				; R#16 : パレットレジスタ 0
				db			0x80 | 20, 0xFF				; R#20 : VDP Command 高速モード
				db			0x80 | 25, 3				; R#25 : モードレジスタ
				db			0x80 | 26, 0				; R#26 : 水平スクロールレジスタ
				db			0x80 | 27, 0				; R#27 : 水平スクロールレジスタ
				db			0x80 | 36, 0				; R#36 : DX  = 0
				db			0x80 | 37, 0				; R#37 :
				db			0x80 | 38, 0				; R#38 : DY  = 0
				db			0x80 | 39, 0				; R#39 :
				db			0x80 | 40, 0				; R#40 : NX  = 512
				db			0x80 | 41, 2				; R#41 :
				db			0x80 | 42, 0				; R#42 : NY  = 512
				db			0x80 | 43, 2				; R#43 :
				db			0x80 | 44, 0x00				; R#44 : CLR = 0x00
				db			0x80 | 45, 0				; R#45 : ARG = 0
				db			0x80 | 46, 0b11000000		; R#46 : CMR = HMMV
				db			0x80 | 51, 0				; R#51 : WSXl
				db			0x80 | 52, 0				; R#52 : WSXh
				db			0x80 | 53, 192				; R#53 : WSYl
				db			0x80 | 54, 0				; R#54 : WSYh
				db			0x80 | 55, 511 & 255		; R#55 : WEXl
				db			0x80 | 56, 511 >> 8			; R#56 : WEXh
				db			0x80 | 57, 307 & 255		; R#57 : WEYl
				db			0x80 | 58, 307 >> 8			; R#58 : WEYh
				db			0x00

wait_vdp_command:
				in			a, [vdp_port1]
				rrca
				jr			c, wait_vdp_command
				endscope


; -----------------------------------------------------------------------------
; Initialize VDP palette
; -----------------------------------------------------------------------------
				scope		init_palette
init_palette::
				ld			a, 13				; read ModeRegister(R#13) of RTC
				out			[rtc_address], a
				in			a, [rtc_data]
				and			a, 0x0C
				or			a, 0x02				; [X][X][1][0]
				out			[rtc_data], a		; Set BLOCK2

				ld			a, 0x0B
				out			[rtc_address], a	; Logo Screen設定
				in			a, [rtc_data]
				and			a, 0x03
				add			a, a
				ld			b, a
				add			a, a
				add			a, b

				ld			h, 0xFF & (color_data1 >> 8)
				add			a, 0xFF & color_data1
				ld			l, a

				ld			bc, ((3 * 2) << 8) | vdp_port2		; R,G,B 3byte が 2組
				otir

				ld			l, 0xFF & color_data2
				ld			b, 3 * 2							; R,G,B 3byte が 2組
				endscope

; -----------------------------------------------------------------------------
; decompress logo image
; -----------------------------------------------------------------------------
				scope		decompress_logo_image
decompress_logo_image::
				call		otir_and_write_vdp_regs
_run_lmcm_command:								; dummy execution
				db			0x80 | 46, 0xA0
_run_lmmc_command:
				db			0x80 | 17, 36		; R#17 = 36
				db			0x00

				ld			bc, (logo_draw_command_size << 8) | vdp_port3

				call		otir_and_write_vdp_regs

				db			0x80 | 17, 0x80 | 44	; R#17 = 0x80 | 44 (非オートインクリメント)
				db			0x00

				; RLEを展開する
				; HL ... 圧縮データのアドレス
				; A .... 着目位置の圧縮データの値
				; C .... VDP port#3
_decompress_loop:
				; 圧縮データを得る
				ld			a, [hl]
				ld			b, a
				; 色コードを得る
				rlca
				rlca
				and			a, 3
				ld			e, a
				; 長さを得る
				ld			a, b
				and			a, 0x3F
				inc			a
				ld			b, a
				; 指定の長さだけドットを打つ
_run_length_loop:
				in			a, [vdp_port1]
				rrca
				jr			nc, _lmmc_end
				out			[c], e							; output current color
				djnz		_run_length_loop
				inc			hl
				jr			_decompress_loop
				endscope

				scope		finish
_lmmc_end::
				; ブロック転送
				ld			hl, h_keyi_base
				ld			de, h_keyi
				ld			bc, h_keyi_end - h_keyi
				ldir
				; 割り込みフック
				ld			a, 0xC3
				ld			hl, h_keyi
				ld			[0xFD9A + 0], a
				ld			[0xFD9A + 1], hl
				; R#15 = S#0
				xor			a, a
				out			[vdp_port1], a
				ld			a, 0x8F
				out			[vdp_port1], a
				ei
				; 1回待つ
				ld			a, 1
				ld			[wait_flag], a
	wait_loop1:
				ld			a, [wait_flag]
				or			a, a
				jr			nz, wait_loop1

; -----------------------------------------------------------------------------
; Main loop
; -----------------------------------------------------------------------------
	start_main:
				ld			a, 0x04
				out			[vdp_port4], a
				; アニメーションの初期化
				ld			hl, animation_data
	main_loop:
				; 1V待ちフラグを立てる
				ld			a, 1
				ld			[wait_flag], a

				; VX, VY をセット
				ld			bc, vdp_port3 | (4 << 8)
				di
				ld			a, 47
				out			[vdp_port1], a
				ld			a, 0x80 + 17
				out			[vdp_port1], a
				otir
				; SX, SY をセット
				ld			b, 4
				ld			a, 32
				out			[vdp_port1], a
				ld			a, 0x80 + 17
				out			[vdp_port1], a
				otir
				push		hl
				; DX, DY, NX, NY, CLR, ARG, CMD
				ld			b, 11
				ld			hl, lrmm_command
				otir
				; VDP完了待ち
	wait_command:
				in			a, [vdp_port4]
				and			a, 0x04
				jp			z, wait_command
				out			[vdp_port4], a
				ei
				; V-Sync完了待ち
	wait_vsync:
				ld			a, [wait_flag]
				or			a, a
				jr			nz, wait_vsync

				ld			a, [frame_count]
				dec			a
				ld			[frame_count], a
				pop			hl
				jp			nz, main_loop

				; 2秒待ち
				ld			b, 120
	wait_time1:
				ld			a, 1
				ld			[wait_flag], a
	wait_time2:
				ld			a, [wait_flag]
				or			a, a
				jr			nz, wait_time2
				djnz		wait_time1

	exit_main_loop:
				; 割り込み禁止にする
				di
				ld			a, 0x43
				out			[vdp_port1], a
				ld			a, 0x81
				out			[vdp_port1], a
				xor			a, a
				out			[vdp_port1], a
				ld			a, 0x8F
				out			[vdp_port1], a
				; 割り込みフックを戻す
				ld			hl, 0xC9C9
				ld			[0xFD9A + 0], hl
				ld			[0xFD9A + 2], hl
				ei
				; 後始末
				call		clear_key_buffer
				; 終了
				ld			c, 0
				call		5

; -----------------------------------------------------------------------------
; Interrupt routine
; -----------------------------------------------------------------------------
h_keyi_base:
				org			0x4000
h_keyi::
				;	割り込み要因をチェック
				in			a, [vdp_port4]
				and			a, 1						; 垂直同期割込か？
				ret			z							; 違うなら戻る
				out			[vdp_port4], a				; 垂直同期割込要因クリア

				xor			a, a
				ld			[wait_flag], a				; フラグをクリア
				ret
wait_flag::
				db			0
h_keyi_end:
				org			h_keyi_base + h_keyi_end - h_keyi
				endscope

; -----------------------------------------------------------------------------
; VDPのコントロールレジスタへ値を書き込む
;
; input:
;	呼び出し元の次のコード領域に書き込むデータ列を配置する
; break:
;	A,E,F
; comment:
;	割り込み禁止で呼ぶこと。
; -----------------------------------------------------------------------------
				scope		write_vdp_regs
otir_and_write_vdp_regs::
				otir
write_vdp_regs::
				ex			[sp], hl
				jr			start1
loop1:
				ld			e, a
				ld			a, [hl]
				inc			hl
				out			[vdp_port1], a
				ld			a, e
				out			[vdp_port1], a
start1:
				ld			a, [hl]
				inc			hl
				or			a, a
				jr			nz, loop1
				ex			[sp], hl
				ret
				endscope

; -----------------------------------------------------------------------------
;	fill vram
;
; input:
;	HL .... 書き込みアドレス Address[15:0] ※Address[16] は 0 に設定される
;	BC .... 書き込むバイト数補正後(バイト数が256の倍数ではない場合256を加算)
;	E ..... 書き込む値
; output:
;	none
; break:
;	A,B,C,F,A',F'
; comment:
;	割り込み禁止で呼ぶこと。
; -----------------------------------------------------------------------------
				scope		fill_vram
fill_vram::
				call		set_write_vram_address

				ld			a, e
loop:
				out			[vdp_port0], a
				dec			c
				jr			nz, loop
				djnz		loop
				ret
				endscope


; -----------------------------------------------------------------------------
;	set write vram address
;
; input:
;	HL .... 書き込みアドレス Address[15:0] ※Address[16] は 0 に設定される
; output:
;	none
; break:
;	A,F,A',F'
; comment:
;	割り込み禁止で呼ぶこと。
; -----------------------------------------------------------------------------
				scope		set_write_vram_address
set_write_vram_address::
				ld			a, h
				and			a, 0x3F
				or			a, 0x40
				ex			af, af'
				ld			a, h
				rlca
				rlca
				and			a, 0x03
				out			[vdp_port1], a
				ld			a, 0x80 | 14
				out			[vdp_port1], a
				ld			a, l
				out			[vdp_port1], a
				ex			af, af'
				out			[vdp_port1], a
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
			xor		a, a
			out		[vdp_port1], a
			ld		a, 0x80 | 20
			out		[vdp_port1], a

			xor		a, a
			out		[vdp_port1], a
			ld		a, 0x80 | 14
			out		[vdp_port1], a

			ld		iy, [main_rom_slot - 1]
			ld		ix, kilbuf
			call	calslt
			ld		iy, [main_rom_slot - 1]
			ld		ix, chgmod
			ld		a, 1
			call	calslt
			ld		iy, [main_rom_slot - 1]
			ld		ix, chgmod
			ld		a, 0
			call	calslt
			ei
			ret
			endscope

; -----------------------------------------------------------------------------
; 色設定データ
;	[palette#0 RB], [palette#0 G], [palette#1 RB], [palette#1 G]
;	[palette#0 R], [palette#0 G], [palette#0 B]
; -----------------------------------------------------------------------------
				align		256
color_data1::
				; Logo Screen 設定が 0 の場合の色
				db			0, 0, 31				; 周辺色
				db			0, 0, 0					; ロゴ背景色
				; Logo Screen 設定が 1 の場合の色
				db			0, 0, 31				; 周辺色
				db			0, 0, 0					; ロゴ背景色
				; Logo Screen 設定が 2 の場合の色
				db			0, 0, 31				; 周辺色
				db			0, 0, 0					; ロゴ背景色
				; Logo Screen 設定が 3 の場合の色
				db			0, 0, 31				; 周辺色
				db			0, 0, 0					; ロゴ背景色

color_data2::
				; palette#2 : gray
				db			15, 15, 15				; ロゴ前景色(中間色)
				; palette#3 : white
				db			31, 31, 31				; ロゴ前景色

; -----------------------------------------------------------------------------
; ロゴデータ描画用 LMMCコマンド
; -----------------------------------------------------------------------------
logo_draw_command::
				dw			45							; R#36, 37: DX
				dw			192							; R#38, 39: DY
				dw			422							; R#40, 41: NX
				dw			80							; R#42, 43: NY
				db			0							; R#44: CLR
				db			0							; R#45: ARG
				db			0b1011_0000					; R#46: CMD    LMMC command
logo_draw_command_end:

logo_draw_command_size := logo_draw_command_end - logo_draw_command

; -----------------------------------------------------------------------------
; ロゴデータ
; -----------------------------------------------------------------------------
logo_data::
				binary_link "logo_data/logo.bin"

; -----------------------------------------------------------------------------
; アニメーションデータ
; -----------------------------------------------------------------------------
	frame_count:
				db		61
	lrmm_command::
				dw		0			; DX
				dw		0			; DY
				dw		512			; NX (dummy)
				dw		144			; NY				128 NG, 160 OK
				db		0			; CLR (dummy)
				db		0b01000000	; ARG [-][XHR][-][-][DIY][DIX][-][-]
				db		0x30		; CMD (LRMM)

				;		VX, VY, SX, SY
	animation_data::
				dw		853, -1, -598, -8
				dw		820, 37, -527, -13
				dw		788, 71, -462, -15
				dw		757, 101, -402, -16
				dw		727, 129, -347, -16
				dw		697, 153, -297, -15
				dw		669, 174, -252, -13
				dw		642, 191, -212, -11
				dw		617, 205, -176, -9
				dw		593, 216, -144, -7
				dw		571, 225, -115, -5
				dw		551, 230, -91, -3
				dw		533, 232, -69, -2
				dw		516, 232, -51, -1
				dw		502, 230, -35, 0
				dw		489, 226, -23, 0
				dw		478, 219, -24, 11
				dw		468, 211, -28, 23
				dw		459, 200, -35, 35
				dw		452, 189, -44, 48
				dw		446, 175, -54, 61
				dw		441, 161, -65, 75
				dw		436, 145, -77, 89
				dw		431, 128, -88, 103
				dw		427, 111, -99, 117
				dw		422, 92, -109, 131
				dw		417, 74, -118, 145
				dw		412, 55, -126, 159
				dw		406, 36, -131, 172
				dw		400, 18, -136, 184
				dw		393, 0, -138, 196
				dw		386, -18, -140, 206
				dw		378, -35, -140, 215
				dw		370, -50, -140, 223
				dw		361, -65, -138, 230
				dw		352, -78, -137, 235
				dw		344, -90, -135, 239
				dw		335, -100, -134, 242
				dw		326, -109, -132, 243
				dw		318, -117, -131, 243
				dw		310, -123, -130, 242
				dw		303, -127, -130, 240
				dw		296, -130, -129, 237
				dw		291, -132, -129, 234
				dw		286, -132, -128, 229
				dw		281, -131, -127, 224
				dw		278, -128, -116, 228
				dw		275, -125, -105, 231
				dw		272, -120, -95, 233
				dw		271, -114, -86, 233
				dw		269, -107, -78, 232
				dw		268, -99, -70, 229
				dw		267, -90, -62, 225
				dw		267, -80, -56, 220
				dw		266, -70, -49, 214
				dw		265, -59, -42, 206
				dw		264, -48, -35, 198
				dw		262, -36, -27, 189
				dw		261, -24, -19, 179
				dw		258, -12, -10, 169
				dw		256, -1, -1, 160

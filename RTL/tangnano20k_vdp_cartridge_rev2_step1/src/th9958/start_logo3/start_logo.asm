; -----------------------------------------------------------------------------
; Start Logo Program
; 
; Copyright (c) 2021 HRA!
;
; -----------------------------------------------------------------------------

				org			0x0100

bdos			:=			0x0005

vdp_port0		:=			0x98
vdp_port1		:=			0x99
vdp_port2		:=			0x9A
vdp_port3		:=			0x9B
vdp_port4		:=			0x9C

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
				; アニメーションの初期化
				ld			hl, animation_data
	main_loop:
				; 1V待ちフラグを立てる
				ld			a, 1
				ld			[wait_flag], a

				; VX, VY をセット
				ld			bc, vdp_port1 | (4 << 8)
				ld			a, 47
				out			[c], a
				ld			a, 0x80 + 17
				out			[c], a
				inc			c
				inc			c
				otir
				dec			c
				dec			c
				; SX, SY をセット
				ld			b, 4
				ld			a, 32
				out			[c], a
				ld			a, 0x80 + 17
				out			[c], a
				inc			c
				inc			c
				otir
				; DX, DY, NX, NY, CLR, ARG, CMD
				push		hl
				ld			b, 11
				ld			hl, lrmm_command
				otir
				pop			hl
				; V-Sync完了待ち
				ld			b, 5
	debug_loop:
				ld			a, 1
				ld			[wait_flag], a
	wait_vsync:
				ld			a, [wait_flag]
				or			a, a
				jr			nz, wait_vsync
				djnz		debug_loop

				ld			a, [frame_count]
				dec			a
				ld			[frame_count], a
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
				dw		192			; NY
				db		0			; CLR (dummy)
				db		0b01000000	; ARG [-][XHR][-][-][DIY][DIX][-][-]
				db		0x30		; CMD (LRMM)

				;		VX, VY, SX, SY
	animation_data::
				dw		853, -1, -598, -8
				dw		818, 74, -521, -36
				dw		778, 141, -444, -58
				dw		736, 202, -368, -77
				dw		693, 254, -294, -91
				dw		648, 299, -224, -101
				dw		604, 337, -159, -107
				dw		561, 367, -99, -110
				dw		520, 390, -45, -110
				dw		483, 407, 2, -108
				dw		449, 418, 42, -104
				dw		420, 425, 74, -99
				dw		395, 426, 100, -93
				dw		375, 424, 119, -86
				dw		359, 419, 131, -79
				dw		349, 410, 137, -72
				dw		342, 399, 137, -64
				dw		340, 384, 132, -57
				dw		341, 368, 122, -49
				dw		344, 348, 107, -40
				dw		351, 327, 88, -31
				dw		359, 302, 67, -21
				dw		367, 275, 43, -10
				dw		376, 246, 17, 2
				dw		385, 215, -9, 16
				dw		392, 181, -35, 30
				dw		398, 146, -60, 46
				dw		401, 110, -84, 64
				dw		401, 73, -105, 82
				dw		399, 36, -124, 101
				dw		393, 0, -138, 121
				dw		385, -35, -149, 141
				dw		374, -69, -157, 160
				dw		360, -99, -161, 180
				dw		344, -127, -161, 198
				dw		328, -152, -158, 215
				dw		310, -174, -152, 231
				dw		292, -192, -145, 245
				dw		275, -207, -136, 257
				dw		259, -219, -127, 268
				dw		244, -228, -117, 277
				dw		231, -234, -107, 283
				dw		220, -238, -98, 288
				dw		211, -240, -91, 292
				dw		205, -239, -84, 293
				dw		201, -237, -78, 293
				dw		199, -233, -74, 292
				dw		199, -227, -72, 288
				dw		202, -219, -70, 284
				dw		206, -209, -68, 278
				dw		212, -198, -68, 271
				dw		218, -185, -67, 262
				dw		225, -170, -66, 253
				dw		233, -153, -64, 242
				dw		240, -135, -60, 231
				dw		246, -115, -55, 219
				dw		252, -93, -49, 207
				dw		255, -71, -40, 195
				dw		257, -47, -29, 182
				dw		257, -24, -16, 171
				dw		256, -1, -1, 160

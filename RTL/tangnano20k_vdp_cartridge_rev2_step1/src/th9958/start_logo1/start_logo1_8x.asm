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

main_rom_slot	:=			0xFCC1
calslt			:=			0x001C
chgmod			:=			0x005F
kilbuf			:=			0x0156

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
				db			0x80 |  7, 0x05				; R#7  : 背景色 
				db			0x80 |  8, 0x28				; R#8  = モードレジスタ palette0は不透明, スプライト表示
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
				otir
				endscope

; -----------------------------------------------------------------------------
; Initialize VRAM
; -----------------------------------------------------------------------------
				scope		init_vram

				push		hl

				ld			hl, 0x7600			; sprite attribute table
				call		set_write_vram_address

				pop			hl
				ld			bc, (sprite_attrib_size << 8) | vdp_port0
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

				; ==============================================================
				; メインループ
				; ==============================================================
	main_loop:
				; 1V待ちフラグを立てる
				ld			a, 1
				ld			[wait_flag], a
				; 完了カウントをクリアする
				xor			a, a
				ld			[complete_count], a
				; 順番に処理するための初期化
				ld			hl, 0x7600			; sprite attribute table
				call		set_write_vram_address
				ld			hl, animation_state
				ld			c, vdp_port0
	sprite_loop:
				; Y座標を得る
				ld			e, [hl]			; Yl
				inc			e
				jr			z, exit_sprite_loop
				dec			e
				inc			hl				; +1
				ld			d, [hl]			; Yh
				dec			hl				; +0
				push		hl
				ld			hl, -128
				or			a, a
				sbc			hl, de
				jr			c, over_m128
	under_m128:
				; -- まだ -128 に到達していないので単純にインクリメント
				inc			de
				pop			hl
				ld			[hl], e			; Yl
				inc			hl				; +1
				ld			[hl], d			; Yh
				inc			hl				; +2
				inc			hl				; +3
				ld			a, -128
				out			[c], a
				ld			a, 0xC3
				out			[c], a
				ld			a, 128
				out			[c], a
				jr			set_mode
	over_m128:
				; -- -128 を超えているので、テーブルから引く
				pop			hl
				inc			hl				; +1
				inc			hl				; +2
				ld			a, [hl]
				ld			e, a
				cp			a, 50 * 3		; index = 50 * 3 超えたか？
				jr			c, skip1
				ld			a, [complete_count]
				inc			a
				ld			[complete_count], a
				jr			skip2
	skip1:
				add			a, 3			; 50 * 3 超えてないので 2 足す
				ld			[hl], a
	skip2:
				inc			hl				; +3
				ld			d, 0			; DE = index
				push		hl
				ld			hl, animation_pos_y
				add			hl, de			; HL = &animation_pos_y[index]
				ld			a, [hl]			; Yl
				out			[c], a
				inc			hl
				ld			a, [hl]			; Yh
				or			a, 0xC0			; size = 3 (16x128)
				out			[c], a
				inc			hl
				ld			a, [hl]			; MGY
				out			[c], a
				pop			hl
	set_mode:
				xor			a, a
				out			[c], a
	set_x:
				ld			a, [hl]			; Xl
				out			[c], a
				inc			hl				; +4
				ld			a, [hl]			; Xh
				out			[c], a
				inc			hl				; +5
	set_mgx:
				ld			a, 16
				out			[c], a
	set_pattern:
				ld			a, [hl]
				out			[c], a
				inc			hl				; +6
				jr			sprite_loop
	exit_sprite_loop:
				; 終了チェック
				ld			a, [complete_count]
				cp			a, 14
				jr			nc, exit_main_loop
				; V-Sync完了待ち
	wait_vsync:
				ld			a, [wait_flag]
				or			a, a
				jr			nz, wait_vsync
				jp			main_loop

	exit_main_loop:
				; 2秒待つ
				ld			b, 120
	wait_1sec_loop:
				; 1V待ちフラグを立てる
				ld			a, 1
				ld			[wait_flag], a
	wait_vsync2:
				ld			a, [wait_flag]
				or			a, a
				jr			nz, wait_vsync2
				djnz		wait_1sec_loop
				; 割り込み禁止にする
				di
				ld			a, 0x43
				out			[vdp_port1], a
				ld			a, 0x81
				out			[vdp_port1], a
				; 割り込みフックを戻す
				ld			a, 0xC9
				ld			[0xFD9A], a
				ei
				; 画面モードを戻す
				ld			iy, [main_rom_slot - 1]
				ld			ix, kilbuf
				call		calslt

				di
				xor			a, a
				out			[vdp_port1], a
				ld			a, 0x80 + 20
				out			[vdp_port1], a
				xor			a, a
				out			[vdp_port1], a
				ld			a, 0x80 + 21
				out			[vdp_port1], a
				ei

				ld			iy, [main_rom_slot - 1]
				ld			ix, chgmod
				ld			a,1
				call		calslt
				ld			iy, [main_rom_slot - 1]
				ld			ix, chgmod
				xor			a, a
				call		calslt
				; 終了
				ld			c, 0
				call		5

h_keyi_base:
				org			0x4000
h_keyi::
				in			a, [vdp_port4]
				and			a, 1
				ret			z
				out			[vdp_port4], a

				xor			a, a
				ld			[wait_flag], a
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
; スプライトアトリビュートテーブル初期化データ
; -----------------------------------------------------------------------------
sprite_attrib::
				; Plane#0
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x0010						; X
				db			16							; MGX
				db			0							; Pattern
				; Plane#1
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x0020						; X
				db			16							; MGX
				db			1							; Pattern
				; Plane#2
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x0030						; X
				db			16							; MGX
				db			2							; Pattern
				; Plane#3
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x0040						; X
				db			16							; MGX
				db			3							; Pattern
				; Plane#4
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x0050						; X
				db			16							; MGX
				db			4							; Pattern
				; Plane#5
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x0060						; X
				db			16							; MGX
				db			5							; Pattern
				; Plane#6
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x0070						; X
				db			16							; MGX
				db			6							; Pattern
				; Plane#7
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x0080						; X
				db			16							; MGX
				db			7							; Pattern
				; Plane#8
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x0090						; X
				db			16							; MGX
				db			8							; Pattern
				; Plane#9
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x00A0						; X
				db			16							; MGX
				db			9							; Pattern
				; Plane#10
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x00B0						; X
				db			16							; MGX
				db			10							; Pattern
				; Plane#11
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x00C0						; X
				db			16							; MGX
				db			11							; Pattern
				; Plane#12
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x00D0						; X
				db			16							; MGX
				db			12							; Pattern
				; Plane#13
				dw			(-128 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x00E0						; X
				db			16							; MGX
				db			13							; Pattern
				; Plane#14
				dw			(216 & 0x3FF) | (3 << 14)	; Y
				db			128							; MGY
				db			0							; Mode
				dw			0x00F0						; X
				db			16							; MGX
				db			0							; Pattern
sprite_attrib_end::

sprite_attrib_size	:= sprite_attrib_end - sprite_attrib

; -----------------------------------------------------------------------------
; ロゴデータ描画用 LMMCコマンド
; -----------------------------------------------------------------------------
logo_draw_command::
				dw			19							; R#36, 37: DX
				dw			256							; R#38, 39: DY
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
animation_state::
				; Plane#0
				dw			-129						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 1						; +3, +4: X
				db			0							; +5: Pattern
				; Plane#1
				dw			-135						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 2						; +3, +4: X
				db			1							; +5: Pattern
				; Plane#2
				dw			-140						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 3						; +3, +4: X
				db			2							; +5: Pattern
				; Plane#3
				dw			-141						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 4						; +3, +4: X
				db			3							; +5: Pattern
				; Plane#4
				dw			-144						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 5						; +3, +4: X
				db			4							; +5: Pattern
				; Plane#5
				dw			-150						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 6						; +3, +4: X
				db			5							; +5: Pattern
				; Plane#6
				dw			-165						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 7						; +3, +4: X
				db			6							; +5: Pattern
				; Plane#7
				dw			-155						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 8						; +3, +4: X
				db			7							; +5: Pattern
				; Plane#8
				dw			-143						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 9						; +3, +4: X
				db			8							; +5: Pattern
				; Plane#9
				dw			-139						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 10						; +3, +4: X
				db			9							; +5: Pattern
				; Plane#10
				dw			-170						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 11						; +3, +4: X
				db			10							; +5: Pattern
				; Plane#11
				dw			-165						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 12						; +3, +4: X
				db			11							; +5: Pattern
				; Plane#12
				dw			-169						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 13						; +3, +4: X
				db			12							; +5: Pattern
				; Plane#13
				dw			-172						; +0, +1: Y
				db			0							; +2: animation_pos_y index
				dw			16 * 14						; +3, +4: X
				db			13							; +5: Pattern

				dw			255							; Endmark

animation_pos_y::
				dw			-248
				db			0
				dw			-246
				db			255
				dw			-244
				db			254
				dw			-241
				db			252
				dw			-238
				db			250
				dw			-233
				db			247
				dw			-229
				db			244
				dw			-223
				db			240
				dw			-216
				db			235
				dw			-209
				db			230
				dw			-200
				db			224
				dw			-191
				db			218
				dw			-183
				db			212
				dw			-174
				db			206
				dw			-163
				db			199
				dw			-153
				db			192
				dw			-142
				db			185
				dw			-131
				db			178
				dw			-120
				db			171
				dw			-108
				db			164
				dw			-97
				db			157
				dw			-86
				db			151
				dw			-75
				db			145
				dw			-64
				db			139
				dw			-53
				db			133
				dw			-42
				db			128
				dw			-32
				db			123
				dw			-22
				db			118
				dw			-13
				db			114
				dw			-5
				db			111
				dw			3
				db			108
				dw			10
				db			105
				dw			17
				db			103
				dw			23
				db			101
				dw			28
				db			100
				dw			32
				db			100
				dw			35
				db			100
				dw			39
				db			100
				dw			41
				db			101
				dw			42
				db			102
				dw			44
				db			103
				dw			45
				db			105
				dw			45
				db			107
				dw			45
				db			109
				dw			44
				db			112
				dw			43
				db			114
				dw			42
				db			117
				dw			40
				db			120
				dw			39
				db			122
				dw			37
				db			125
				dw			35
				db			128

complete_count:
				db			0

				if (color_data1 & 0xFF00) != (color_data2 & 0xFF00)
					error "color_data1 と color_data2 の上位 8bit は一致している必要があります"
				endif

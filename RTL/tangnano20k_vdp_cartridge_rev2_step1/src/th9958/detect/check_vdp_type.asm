; =============================================================================
;	V9968 Detect Sample Code
;	Copyright(C)2025 t.hara
; -----------------------------------------------------------------------------
;	MIT License
; =============================================================================

vdp_read_port		:= 0x0006
vdp_write_port		:= 0x0007
rg7sav				:= 0xF3E6

; =============================================================================
;	check_vdp_type
;	input:
;		none
;	output:
;		A ...... 0: TMS9918, 1: V9938, 2: V9958, 3: V9968, 4: V9978
;	break:
;		A, B, C, D, E, F
;	comment:
;		本体の VDP が V9968/V9978 であるかを調べる
;		page0 が MAIN-ROM である前提
;		R#21 は V9938/V9958 では 0b00111010, V9968/V9978 では 0b00111011 になる
; =============================================================================
			scope		check_vdp_type
check_vdp_type::
			; 本体側が TMS9918 か V99x8 か区別する
			ld			de, [vdp_read_port]
			inc			d							; VDP Port#1 for write
			inc			e							; VDP Port#1 for read
			ld			c, d
			ld			b, 0x80 + 15
			di

	loop:
			in			a, [c]						; S#0 bit7 が 1 になるまで待機。下記の[★]の直前で bit7 が 1 になるのを避けるため。
			jp			p, loop

			ld			a, 4						; R#15 = S#4
			out			[c], a
			out			[c], b						; もし TMS9918 なら R#15 が存在しないため、R#7 が書き換わる
			ld			c, e						; VDP Port#1 for read
			in			a, [c]						; TMS9918なら S#0 を読む (bit7 が 1 になっているかもしれない)。V99x8 なら S#4 を読む。
			in			a, [c]						; TMS9918なら S#0 を読む (bit7 が確実に 0)。V99x8 なら S#4 を読む(bit7 が確実に 1)。
			ex			af, af'
			ld			c, d						; VDP Port#1 for write
			xor			a, a						; R#15 = S#0
			out			[c], a
			out			[c], b
			; TMS9918 だった場合の R#7復元処理
			ld			a, [rg7sav]
			out			[c], a
			ld			a, 0x80 + 7
			ei
			out			[c], a
			ex			af, af'
			; S#4 の読みだし結果を調べる
			and			a, 0x80						; bit7 を調べる。TMS9918 なら S#0 の bit7 なので 0
			ret			z							; TMS9918 なら A=0 で戻る
			di
			; V99x8 の判別
			ld			a, 0b00111011				; V9938 初期値。V9968/V9978 では FID=1
			out			[c], a
			ld			a, 0x80 + 21
			out			[c], a
			; S#1 を読む
			ld			a, 1						; R#15 = S#1
			out			[c], a
			out			[c], b
			ld			c, e						; VDP Port#1 for read
			in			a, [c]						; S#1 を読む
			; VDP-ID を調べる
			ld			c, d						; VDP Port#1 for write
			rrca
			and			a, 0x1F
			jr			z, skip
			; FID=0 にして、V9958, V9968, V9978 を区別する
			ld			a, 0b00111010				; V9958 では無効。V9968/V9978 では FID=0
			out			[c], a
			ld			a, 0x80 + 21
			out			[c], a
			; S#1 を読む
			ld			a, 1						; R#15 = S#1
			out			[c], a
			out			[c], b
			ld			c, e						; VDP Port#1 for read
			in			a, [c]						; S#1 を読む
			; VDP-ID を取得
			rrca
			and			a, 0x1F
			dec			a
		skip:
			inc			a
			ld			e, a
			; R#15 = S#0
			ld			c, d						; VDP Port#1 for write
			xor			a, a						; R#15 = S#0
			out			[c], a
			ei
			out			[c], b
			ld			a, e
			ret
			endscope

; =============================================================================
;	check_2nd_vdp_type
;	input:
;		none
;	output:
;		A ...... 0: none, 1: V9938, 2: V9958, 3: V9968, 4: V9978
;	break:
;		A, B, C, D, E, F
;	comment:
;		2nd VDP の種類を調べる
;		R#21 は V9938/V9958 では 0b00111010, V9968/V9978 では 0b00111011 になる
;		ただし、一部の「データバスに PullUp が付いていない機種」で誤認する場合が
;		有り得る
;		割り込みは停止状態(IE0, IE1 = 0) である前提
; =============================================================================
			scope		check_2nd_vdp_type
check_2nd_vdp_type::
			ld			de, 0x8989
			ld			c, e
			ld			b, 0x80 + 15
			di
			in			a, [c]						; 未接続なら 0xFF を読む。V99x8 なら S#0 を読む(bit7 は状況に応じて 0 か 1)。
			in			a, [c]						; 未接続なら 0xFF を読む。V99x8 なら S#0 を読む(bit7 が確実に 0)。[★]
			ld			c, d						; VDP Port#1 for write
			; S#4 の読みだし結果を調べる
			and			a, 0x80						; bit7 を調べる。TMS9918 なら S#0 の bit7 なので 0
			ret			z							; TMS9918 なら A=0 で戻る
			di
			; V99x8 の判別
			ld			a, 0b00111011				; V9938 初期値。V9968/V9978 では FID=1
			out			[c], a
			ld			a, 0x80 + 21
			out			[c], a
			; S#1 を読む
			ld			a, 1						; R#15 = S#1
			out			[c], a
			out			[c], b
			ld			c, e						; VDP Port#1 for read
			in			a, [c]						; S#1 を読む
			; VDP-ID を調べる
			ld			c, d						; VDP Port#1 for write
			rrca
			and			a, 0x1F
			jr			z, skip
			; FID=0 にして、V9958, V9968, V9978 を区別する
			ld			a, 0b00111010				; V9958 では無効。V9968/V9978 では FID=0
			out			[c], a
			ld			a, 0x80 + 21
			out			[c], a
			; S#1 を読む
			ld			a, 1						; R#15 = S#1
			out			[c], a
			out			[c], b
			ld			c, e						; VDP Port#1 for read
			in			a, [c]						; S#1 を読む
			; VDP-ID を取得
			rrca
			and			a, 0x1F
			dec			a
		skip:
			inc			a
			ld			e, a
			; R#15 = S#0
			ld			c, d						; VDP Port#1 for write
			xor			a, a						; R#15 = S#0
			out			[c], a
			ei
			out			[c], b
			ld			a, e
			ret
			endscope

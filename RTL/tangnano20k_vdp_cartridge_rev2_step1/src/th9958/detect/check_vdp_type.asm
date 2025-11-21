; =============================================================================
;	V9968 Detect Sample Code
;	Copyright(C)2025 t.hara
; -----------------------------------------------------------------------------
;	MIT License
; =============================================================================

vdp_read_port		:= 0x0006
vdp_write_port		:= 0x0007
rdslt				:= 0x000C
msx_version			:= 0x002D
rg7sav				:= 0xF3E6
main_rom_slot		:= 0xFCC1

; =============================================================================
;	check_vdp_type
;	input:
;		none
;	output:
;		A ...... 0: TMS9918, 1: V9938, 2: V9958, 3: V9968, 4: V9978, 255: unknown
;		C ...... VDP I/O Port#1 (unknown の場合は無意味な値)
;	break:
;		A, B, C, D, E, F
;	comment:
;		本体の VDP が V9968/V9978 であるかを調べる
;		R#21 は V9938/V9958 では 0b00111010, V9968/V9978 では 0b00111011 になる
; =============================================================================
			scope		check_vdp_type
check_vdp_type::
			; MAIN-ROM の VDP Port (0x0006, 0x0007) を調べる
			ld			hl, vdp_read_port
			ld			a, [main_rom_slot]
			call		rdslt
			push		af
			ld			hl, vdp_write_port
			ld			a, [main_rom_slot]
			call		rdslt
			ld			c, a
			pop			af
			cp			a, c
			jr			nz, is_unknown				; 0x0006 と 0x0007 の値が異なっている場合は未知。
			inc			c							; VDP Port#1
			push		bc
			; MSX Version をチェック ( 1以上なら TMS9918 は有り得ない )
			ld			hl, msx_version
			ld			a, [main_rom_slot]
			call		rdslt
			pop			bc
			or			a, a
			jr			nz, check_v99x8
	check_tms9918:
			ld			b, 0x80 + 15
			di
			ld			a, 4						; R#15 = S#4
			out			[c], a
			out			[c], b						; もし TMS9918 なら R#15 が存在しないため、R#7 が書き換わる
			in			a, [c]						; TMS9918なら S#0 を読む (bit7 が 1 になっているかもしれない)。V99x8 なら S#4 を読む。
			jp			p, is_tms9918
			in			a, [c]						; TMS9918なら S#0 を読む (bit7 が確実に 0)。V99x8 なら S#4 を読む(bit7 が確実に 1)。
			jp			p, is_tms9918
			xor			a, a						; R#15 = S#0
			out			[c], a
			out			[c], b
			; V99x8 の判別
	check_v99x8::
			di
			ld			b, 0x80 + 15
			ld			hl, ((0x80 + 21) << 8) | 0b00111011
			out			[c], l						; V9938 ではこれ以外を設定厳禁。V9938 初期値。V9968/V9978 では FID=1
			out			[c], h
			; S#1 を読む
			ld			a, 1						; R#15 = S#1
			out			[c], a
			out			[c], b
			in			a, [c]						; S#1 を読む
			; VDP-ID を調べる
			rrca
			and			a, 0x1F
			jr			z, is_v9938					; 0 なら V9938確定。
			; FID=0 にして、V9958, V9968, V9978 を区別する
			dec			l							; V9938 では設定禁止の値(ごく一部のコンポジットビデオ出力を使ってる機種で乱れる)。
			out			[c], l						; V9958 では無効。V9968/V9978 では FID=0
			out			[c], h
			; S#1 を読む
			in			a, [c]						; S#1 を読む
			; VDP-ID を取得
			rrca
			and			a, 0x1F						; 2: V9958, 3: V9968, 4: V9978
			dec			a
	is_v9938:
			inc			a
			ld			e, a
			; R#15 = S#0
			xor			a, a						; R#15 = S#0
			out			[c], a
			ei
			out			[c], b
			ld			a, e
			ret
	is_unknown:
			; 0x0006, 0x0007 が異なっているので未知
			ld			a, 255
			ret
	is_tms9918:
			; TMS9918 だった場合の R#7復元処理
			ld			a, [rg7sav]
			out			[c], a
			ld			a, 0x80 + 7
			ei
			out			[c], a
			xor			a, a
			ret
			endscope

; =============================================================================
;	check_2nd_vdp_type
;	input:
;		none
;	output:
;		A ...... 0: none, 1: V9938, 2: V9958, 3: V9968, 4: V9978
;		C ...... 0x89 (VDP I/O Port#1)
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
			ld			c, 0x89
			di
			in			a, [c]						; 未接続なら 0xFF を読む。V99x8 なら S#0 を読む(bit7 は状況に応じて 0 か 1)。
			jp			p, check_v99x8
			in			a, [c]						; 未接続なら 0xFF を読む。V99x8 なら S#0 を読む(bit7 が確実に 0)。[★]
			jp			p, check_v99x8
			; 未接続
			ei
			xor			a, a
			ret
			endscope

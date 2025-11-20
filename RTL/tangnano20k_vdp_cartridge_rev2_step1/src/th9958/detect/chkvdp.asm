; =============================================================================
;	VDP Checker
; -----------------------------------------------------------------------------
;	Copyright 2025, t.hara (HRA!)
; =============================================================================

bdos			:=		0x0005
rdslt			:=		0x000C

mainrom			:=		0xFCC1

				org		0x0100
start:
				; メッセージ表示
				ld		c, 9
				ld		de, s_title
				call	bdos
				; MAIN-ROM の 0x0006, 0x0007 のフリをさせるために元の値を一時退避
				ld		hl, [ 0x0006 ]
				ld		[ backup ], hl
				; MAIN-ROM の 0x0006, 0x0007 を読む
				ld		a, [mainrom]
				ld		hl, 0x0006
				call	rdslt
				ld		[hl], a
				ld		[vdp1st + 0], a

				ld		a, [mainrom]
				ld		hl, 0x0007
				call	rdslt
				ld		[hl], a
				ld		[vdp1st + 1], a
				; 1st VDP
				call	check_vdp_type
				; 0x0006, 0x0007 の元の値を復元
				ld		hl, [ backup ]
				ld		[ 0x0006 ], hl
				; 得られた番号を VDP名文字列に変換
				cp		a, 5
				jr		c, valid_vdp
				ld		a, 5
	valid_vdp:
				ld		l, a
				ld		h, 0
				add		hl, hl
				ld		de, a_table
				add		hl, de
				ld		e, [hl]
				inc		hl
				ld		d, [hl]
				; VDP名表示
				ld		c, 9
				call	bdos
				; テーブル更新
				ld		hl, s_none
				ld		[a_table + 0 * 2], hl
				; メッセージ
				ld		c, 9
				ld		de, s_2nd
				call	bdos
				; 1つ目の VDP が、0x8? であれば、バージョンアップアダプターの可能性
				ld		a, [vdp1st]
				and		a, 0xF0
				cp		a, 0x80
				ld		a, 0
				jp		z, valid_vdp2
				; 2nd VDP
				call	check_2nd_vdp_type
				cp		a, 5
				jr		c, valid_vdp2
				xor		a, a
	valid_vdp2:
				ld		l, a
				ld		h, 0
				add		hl, hl
				ld		de, a_table
				add		hl, de
				ld		e, [hl]
				inc		hl
				ld		d, [hl]
				; VDP名表示
				ld		c, 9
				call	bdos
				; 終了
				ld		c, 0
				jp		bdos
	vdp1st:
				dw		0
	backup:
				dw		0
	a_table:
				dw		s_tms9918
				dw		s_v9938
				dw		s_v9958
				dw		s_v9968
				dw		s_v9978
				dw		s_unkown
	s_tms9918:
				db		"TMS9918", 13, 10, '$'
	s_v9938:
				db		"V9938", 13, 10, '$'
	s_v9958:
				db		"V9958", 13, 10, '$'
	s_v9968:
				db		"V9968", 13, 10, '$'
	s_v9978:
				db		"V9978", 13, 10, '$'
	s_unkown:
				db		"?????", 13, 10, '$'
	s_none:
				db		"NONE", 13, 10, '$'
	s_title:
				db		"VDP Checker", 13, 10
				db		"Programmed by t.hara", 13, 10
				db		"--------------------", 13, 10
				db		"1st VDP:", '$'
	s_2nd:
				db		"2nd VDP:", '$'
	s_crlf:
				db		13, 10, '$'
				include	"check_vdp_type.asm"

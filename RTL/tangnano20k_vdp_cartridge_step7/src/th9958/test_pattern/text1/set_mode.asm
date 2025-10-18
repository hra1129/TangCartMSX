; =============================================================================
;	SCREEN0 (WIDTH40)
;	input:
;		none
;	output:
;		none
;	break:
;		all
;	comment:
;		none
; =============================================================================
			scope	set_text1
set_text1::
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
			; R#8 = 0x08
			ld		a, 0x08					; スプライト非表示
			ld		e, 8
			call	write_control_register
			; R#9 = 0x00
			ld		a, 0x00					; 192lines, non-interlace
			ld		e, 9
			call	write_control_register
			; R#20 = 0x00
			ld		a, 0
			ld		e, 20
			call	write_control_register
			; R#21 = 0x00
			ld		a, 0
			ld		e, 21
			call	write_control_register
			; R#23 = 0x00
			ld		a, 0
			ld		e, 23
			call	write_control_register
			; R#25 = 0x00
			ld		a, 0
			ld		e, 25
			call	write_control_register
			; R#26 = 0x00
			ld		a, 0
			ld		e, 26
			call	write_control_register
			; R#27 = 0x00
			ld		a, 0
			ld		e, 27
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


; =============================================================================
;	V9958 software test program
; -----------------------------------------------------------------------------
;	Programmed by t.hara (HRA!)
; =============================================================================

			org		0x100

start:
			; ����
			call	vdp_io_select
			call	copy_rom_font
			; �e�X�g
			di
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

			call	screen2
			call	s2_vscroll
			call	s2_hscroll
			call	s2_display_adjust

			call	screen3
			call	s3_vscroll
			call	s3_hscroll
			call	s3_display_adjust

			call	screen4
			call	s4_vscroll
			call	s4_hscroll
			call	s4_display_adjust
			ei
			; ��n��
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include "lib.asm"

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
			ld		a, 0xF4					; �O�i 15, �w�i 4
			ld		e, 7
			call	write_control_register
			; Pattern Name Table
			ld		hl, 0
			call	set_pattern_name_table
			; Pattern Name Table ���N���A
			ld		hl, 0
			ld		bc, 40 * 26
			ld		a, ' '
			call	fill_vram
			; Pattern Generator Table
			ld		hl, 0x800
			call	set_pattern_generator_table
			; Font ���Z�b�g
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
			ld		a, 0x07					; ���ӐF 7
			ld		e, 7
			call	write_control_register
			; R#8 = 0x02
			ld		a, 0x02					; �X�v���C�g��\��
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
			; Pattern Name Table ���N���A
			ld		hl, 0x1800
			ld		bc, 32 * 26
			ld		e, ' '
			call	fill_vram
			; Font ���Z�b�g
			ld		hl, 0x0000
			call	set_font
			; Font�̐F���Z�b�g
			ld		hl, 0x2000
			ld		bc, 256 / 8
			ld		e, 0xF4
			call	fill_vram
			ret
			endscope

; =============================================================================
;	SCREEN2
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen2
screen2::
			; R#0 = 0x02
			ld		a, 2
			ld		e, 0
			call	write_control_register
			; R#1 = 0x40
			ld		a, 0x40
			ld		e, 1
			call	write_control_register
			; R#7 = 0x07
			ld		a, 0x07					; ���ӐF 7
			ld		e, 7
			call	write_control_register
			; R#8 = 0x02
			ld		a, 0x02					; �X�v���C�g��\��
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
			; Pattern Name Table ���N���A
			ld		hl, 0x1800
			ld		bc, 32 * 26
			call	fill_increment
			; Font ���Z�b�g
			ld		hl, 0x0000
			call	set_font
			ld		hl, 0x0800
			call	set_font
			ld		hl, 0x1000
			call	set_font
			; Font�̐F���Z�b�g
			ld		hl, 0x2000
			ld		bc, 256 * 8 * 3
			call	fill_increment
			ret
			endscope

; =============================================================================
;	SCREEN3
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen3
screen3::
			; R#0 = 0x00
			xor		a, a
			ld		e, a
			call	write_control_register
			; R#1 = 0x48
			ld		a, 0x48
			ld		e, 1
			call	write_control_register
			; R#7 = 0x07
			ld		a, 0x07					; ���ӐF 7
			ld		e, 7
			call	write_control_register
			; R#8 = 0x02
			ld		a, 0x02					; �X�v���C�g��\��
			ld		e, 8
			call	write_control_register
			; Pattern Name Table
			ld		hl, 0x0800
			call	set_pattern_name_table
			; Sprite Attribute Table
			ld		hl, 0x1B00
			call	set_sprite_attribute_table
			; Sprite Pattern Generator Table
			ld		hl, 0x3800
			call	set_sprite_pattern_generator_table
			; Pattern Generator Table
			ld		hl, 0x0000
			call	set_pattern_generator_table
			; Pattern Name Table ���N���A
			ld		hl, 0x0800
			ld		bc, 32 * 26
			call	fill_increment
			; �F���Z�b�g
			ld		hl, 0x0000
			ld		bc, 256 * 8
			call	fill_increment
			ret
			endscope

; =============================================================================
;	SCREEN4
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	screen4
screen4::
			; R#0 = 0x04
			ld		a, 4
			ld		e, 0
			call	write_control_register
			; R#1 = 0x40
			ld		a, 0x40
			ld		e, 1
			call	write_control_register
			; R#7 = 0x07
			ld		a, 0x07					; ���ӐF 7
			ld		e, 7
			call	write_control_register
			; R#8 = 0x02
			ld		a, 0x02					; �X�v���C�g��\��
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
			; Pattern Name Table ���N���A
			ld		hl, 0x1800
			ld		bc, 32 * 26
			call	fill_increment
			; Font ���Z�b�g
			ld		hl, 0x0000
			call	set_font
			ld		hl, 0x0800
			call	set_font
			ld		hl, 0x1000
			call	set_font
			; Font�̐F���Z�b�g
			ld		hl, 0x2000
			ld		bc, 256 * 8 * 3
			call	fill_increment
			ret
			endscope

; =============================================================================
;	[SCREEN0W40] �����t�H���g�����Ғʂ�ɕ\�������E40���A24�s�\�������
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
			; Pattern Name Table �ɃC���N�������g�f�[�^��~���l�߂�
			ld		hl, 0
			ld		bc, 40 * 24
			call	fill_increment
			; Put test name
			ld		hl, 0
			ld		de, s_message
			call	puts
			; �L�[�҂�
			call	wait_push_space_key
			ret
	s_message:
			db		"[S0W40] FONT TEST ", 0
			endscope

; =============================================================================
;	[SCREEN1] �����t�H���g�����Ғʂ�ɕ\�������E32���A24�s�\�������
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
			; Pattern Name Table �ɃC���N�������g�f�[�^��~���l�߂�
			ld		hl, 0x1800
			ld		bc, 32 * 24
			call	fill_increment
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			; �L�[�҂�
			call	wait_push_space_key
			ret
	s_message:
			db		"[S1] FONT TEST ", 0
			endscope

; =============================================================================
;	[SCREEN0W40] �����̐F��ς���
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
;	[SCREEN1] �����̐F��ς���
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
			; Pattern Name Table �ɃC���N�������g�f�[�^��~���l�߂�
			ld		hl, 0x1800
			ld		bc, 32 * 24
			call	fill_increment
			; �F�f�[�^���R�s�[
			ld		hl, color_table
			ld		de, 0x2000
			ld		bc, 32
			call	block_copy
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			; �L�[�҂�
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
;	[SCREEN0W40] �p���b�g��ς���
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
;	[SCREEN0W40] �����X�N���[�����W�X�^
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
;	[SCREEN1] �����X�N���[�����W�X�^
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
;	[SCREEN2] �����X�N���[�����W�X�^
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s2_vscroll
s2_vscroll::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		vscroll
	s_message:
			db		"[S2] V-SCROLL TEST ", 0
			endscope

; =============================================================================
;	[SCREEN3] �����X�N���[�����W�X�^
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s3_vscroll
s3_vscroll::
			jp		vscroll
			endscope

; =============================================================================
;	[SCREEN4] �����X�N���[�����W�X�^
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s4_vscroll
s4_vscroll::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		vscroll
	s_message:
			db		"[S4] V-SCROLL TEST ", 0
			endscope


; =============================================================================
;	[SCREEN0W40] �����X�N���[�����W�X�^
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
;	[SCREEN1] �����X�N���[�����W�X�^
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
;	[SCREEN2] �����X�N���[�����W�X�^
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s2_hscroll
s2_hscroll::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		hscroll
	s_message:
			db		"[S2] H-SCROLL TEST ", 0
			endscope

; =============================================================================
;	[SCREEN3] �����X�N���[�����W�X�^
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s3_hscroll
s3_hscroll::
			jp		hscroll
			endscope

; =============================================================================
;	[SCREEN4] �����X�N���[�����W�X�^
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s4_hscroll
s4_hscroll::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		hscroll
	s_message:
			db		"[S4] H-SCROLL TEST ", 0
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
;	[SCREEN2] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s2_display_adjust
s2_display_adjust::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		display_adjust
	s_message:
			db		"[S2] DISPLAY ADJUST TEST ", 0
			endscope

; =============================================================================
;	[SCREEN3] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s3_display_adjust
s3_display_adjust::
			jp		display_adjust
			endscope

; =============================================================================
;	[SCREEN4] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s4_display_adjust
s4_display_adjust::
			; Put test name
			ld		hl, 0x1800
			ld		de, s_message
			call	puts
			jp		display_adjust
	s_message:
			db		"[S4] DISPLAY ADJUST TEST ", 0
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

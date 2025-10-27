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
			call	screen12
			call	s12_vscroll
			call	s12_hscroll
			call	s12_display_adjust
			call	s12_gradient_fill
			ei
			; ��n��
			call	clear_key_buffer
			ld		c, _TERM0
			jp		bdos

include		"lib.asm"

; =============================================================================
;	SCREEN12
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	SCREEN12
SCREEN12::
			; R#0 = 0x0E
			ld		a, 0x0E
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
			; R#8 = 0x0A
			ld		a, 0x0A					; �X�v���C�g��\��
			ld		e, 8
			call	write_control_register
			; R#9 = 0x00
			ld		a, 0x00					; 192line
			ld		e, 9
			call	write_control_register
			; R#25 = 0x08
			ld		a, 0x08					; YJK=1
			ld		e, 25
			call	write_control_register
			; Pattern Name Table R#2 = 0b00p11111 : p = page
			ld		a, 0b00011111
			ld		e, 2
			call	write_control_register
			; Sprite Attribute Table
			ld		hl, 0xFA00
			call	set_sprite_attribute_table
			; Sprite Pattern Generator Table
			ld		hl, 0xF000
			call	set_sprite_pattern_generator_table
			; Pattern Name Table ���N���A
			ld		hl, 0x0000
			call	set_vram_write_address

			xor		a, a
			ld		b, 4
	loop_blue_block_width:
			push	bc						; -- 4���[�v�J�E���^�ۑ�
			push	af

			ld		b, 8
	loop_green_block_width:
			push	bc						; -- 8���[�v�J�E���^�ۑ�

			ld		b, 6
	loop_red_line:
			push	bc						; -- 6���[�v�J�E���^�ۑ�
			push	af

			ld		b, 8					; ������8�u���b�N����
	loop_red_increment:
			push	bc						; -- 8���[�v�J�E���^�ۑ�

			ld		b, 32					; 1�u���b�N�i�����F�̉�j�͐��� 32��f
	loop_red_block_width:
			call	write_vram
			djnz	loop_red_block_width

			pop		bc						; -- 8���[�v�J�E���^���A
			add		a, 0x04
			djnz	loop_red_increment

			pop		af
			pop		bc						; -- 6���[�v�J�E���^���A
			djnz	loop_red_line

			pop		bc						; -- 8���[�v�J�E���^���A
			add		a, 0x20
			djnz	loop_green_block_width

			pop		af
			pop		bc						; -- 4���[�v�J�E���^���A
			inc		a
			djnz	loop_blue_block_width

			call	wait_push_space_key
			ret
			endscope

; =============================================================================
;	[SCREEN12] �����X�N���[�����W�X�^
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s12_vscroll
s12_vscroll::
			jp		vscroll
			endscope

; =============================================================================
;	[SCREEN12] �����X�N���[�����W�X�^
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s12_hscroll
s12_hscroll::
			jp		hscroll
			endscope

; =============================================================================
;	[SCREEN12] display position adjust
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s12_display_adjust
s12_display_adjust::
			jp		display_adjust
			endscope

; =============================================================================
;	[SCREEN12] gradient fill
;	input:
;		none
;	output:
;		none
;	break:
;		AF
;	comment:
;		none
; =============================================================================
			scope	s12_gradient_fill
s12_gradient_fill::
			ld		h, 0		; DX
			ld		b, 32		; loop counter
	loop:
			ld		a, h
			ld		[data_dx], a
			ld		[data_color], a
			add		a, 8
			ld		h, a
			push	hl
			push	bc
			call	wait_command
			ld		hl, data
			ld		a, 36
			ld		b, 11
			call	run_command
			pop		bc
			pop		hl
			djnz	loop
			call	wait_push_space_key

			; �F��t����
	fill_color:
			ld		bc, 16			; Y���W
			ld		l, -32			; K (Cb)
			ld		e, 0			; J (Cr)
			call	set_color
			ld		bc, 32			; Y���W
			ld		l, 31			; K (Cb)
			ld		e, 0			; J (Cr)
			call	set_color
			ld		bc, 48			; Y���W
			ld		l, 0			; K (Cb)
			ld		e, -32			; J (Cr)
			call	set_color
			ld		bc, 64			; Y���W
			ld		l, 0			; K (Cb)
			ld		e, 31			; J (Cr)
			call	set_color
			ld		bc, 80			; Y���W
			ld		l, -32			; K (Cb)
			ld		e, -32			; J (Cr)
			call	set_color
			ld		bc, 96			; Y���W
			ld		l, 31			; K (Cb)
			ld		e, 31			; J (Cr)
			call	set_color
			ld		bc, 112			; Y���W
			ld		l, 31			; K (Cb)
			ld		e, -32			; J (Cr)
			call	set_color
			ld		bc, 128			; Y���W
			ld		l, -32			; K (Cb)
			ld		e, 31			; J (Cr)
			call	set_color
			ld		bc, 144			; Y���W
			ld		l, 15			; K (Cb)
			ld		e, -16			; J (Cr)
			call	set_color
			ld		bc, 160			; Y���W
			ld		l, -16			; K (Cb)
			ld		e, 15			; J (Cr)
			call	set_color
			ld		bc, 176			; Y���W
			ld		l, 8			; K (Cb)
			ld		e, -16			; J (Cr)
			call	set_color
			ld		bc, 192			; Y���W
			ld		l, -16			; K (Cb)
			ld		e, 8			; J (Cr)
			call	set_color
			ld		bc, 208			; Y���W
			ld		l, -32			; K (Cb)
			ld		e, 4			; J (Cr)
			call	set_color
			call	wait_push_space_key
			ret

	set_color:
			; �F��t���� (�����Ȃ��ʒu�� 4dot �ɐF��t����)
			ld		[data3_dy], bc
			ld		[data4_sy], bc
			inc		bc
			ld		[data4_dy], bc
			; JK �̃r�b�g���т����킹��
			ld		h, l
			ld		a, l
			and		a, 0b00000111
			ld		l, a
			ld		a, h
			rrca
			rrca
			rrca
			and		a, 0b00000111
			ld		h, a

			ld		d, e
			ld		a, e
			and		a, 0b00000111
			ld		e, a
			ld		a, d
			rrca
			rrca
			rrca
			and		a, 0b00000111
			ld		d, a

			push	hl
			push	de
			ld		hl, 212 * 256
			xor		a, a
			ld		[vram_bit16], a
			call	set_vram_write_address
			pop		de
			pop		hl
			ld		a, l
			call	write_vram
			ld		a, h
			call	write_vram
			ld		a, e
			call	write_vram
			ld		a, d
			call	write_vram
			; 4dot �𐅕� 1���C���ɍL����
			call	wait_command
			ld		hl, data2
			ld		a, 32
			ld		b, 15
			call	run_command
			; ��������C�����A�ړI�̈ʒu�փR�s�[(OR)����
			call	wait_command
			ld		hl, data3
			ld		a, 32
			ld		b, 15
			call	run_command
			; ����� 16���C���ɕ�������
			call	wait_command
			ld		hl, data4
			ld		a, 32
			ld		b, 15
			call	run_command
			ret
	data:
	data_dx:
			dw		0			; DX
			dw		0			; DY
			dw		8			; NX
			dw		256			; NY
	data_color:
			db		0			; CLR
			db		0b00000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xC0		; CMD (HMMV)
	data2:
			dw		0			; SX
			dw		212			; SY
			dw		4			; DX
			dw		212			; DY
			dw		252			; NX
			dw		1			; NY
			db		0			; CLR
			db		0b00000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xD0		; CMD (HMMM)
	data3:
			dw		0			; SX
			dw		212			; SY
			dw		0			; DX
	data3_dy:
			dw		0			; DY
			dw		256			; NX
			dw		1			; NY
			db		0			; CLR
			db		0b00000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0x92		; CMD (LMMM, OR)
	data4:
			dw		0			; SX
	data4_sy:
			dw		0			; SY
			dw		0			; DX
	data4_dy:
			dw		0			; DY
			dw		256			; NX
			dw		15			; NY
			db		0			; CLR
			db		0b00000000	; ARG [-][-][-][-][DIY][DIX][-][-]
			db		0xD0		; CMD (HMMM)
			endscope

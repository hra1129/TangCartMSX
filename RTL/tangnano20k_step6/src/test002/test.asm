; =============================================================================
;	SSG Access Test
; -----------------------------------------------------------------------------
;	2025/01/07th	t.hara
; =============================================================================

psg_reg_adr	:= 0xA0
psg_reg_wr	:= 0xA1
psg_reg_rd	:= 0xA2

			org		0x0000
entry:
			di

			ld		a, 7
			out		[psg_reg_adr], a
			ld		a, 0b10111111
			out		[psg_reg_wr], a

			ld		a, 15
			out		[psg_reg_adr], a
			xor		a, a
			out		[psg_reg_wr], a

			ld		a, 14
			out		[psg_reg_adr], a
loop:
			in		a, [psg_reg_rd]
			jp		loop

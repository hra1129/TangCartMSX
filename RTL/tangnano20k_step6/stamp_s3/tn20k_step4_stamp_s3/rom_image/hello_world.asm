; -----------------------------------------------------------------------------
;  Hello, world! for cZ80 step1 test program
; =============================================================================
;  Programmed by t.hara
; -----------------------------------------------------------------------------

UART		:= 0x10
VDP_PORT0	:= 0x98
VDP_PORT1	:= 0x99
VDP_PORT2	:= 0x9A
VDP_PORT3	:= 0x9B
PPI_PORT	:= 0xA8

CHGMOD		:= 0x005F
LDIRVM		:= 0x005C

			org		0x4000

			db		"AB"
			dw		entry
			dw		0x0000
			dw		0x0000
			dw		0x0000
			dw		0x0000
			dw		0x0000
			dw		0x0000

			jp		entry
entry:
			; SCREEN1
			ld		a, 1
			call	chgmod
			; Set Name Table
			ld		hl, name_table
			ld		de, 0x1800
			ld		bc, name_table_end - name_table
			call	ldirvm
			di
			halt

name_table::	;	 01234567890123456789012345678901
			db		"  Hello, world!                 "
			db		"                                "
			db		"  This is FPGA-MSX              "
			db		"  (MSX2++ prototype)            "
			db		"  ", 255
name_table_end::

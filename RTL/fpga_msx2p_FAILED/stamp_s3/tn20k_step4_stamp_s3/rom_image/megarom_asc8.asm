; -----------------------------------------------------------------------------
;  Hello, world! for cZ80 step1 test program
; =============================================================================
;  Programmed by t.hara
; -----------------------------------------------------------------------------

enaslt		:=		0x0024
bank0reg	:=		0x6000
bank1reg	:=		0x6800
bank2reg	:=		0x7000
bank3reg	:=		0x7800

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
			ld		hl, msg_title
			call	puts

			ld		a, 29
			call	put_num

			; Ç‹Ç∏ page2 Ç slot1 Ç…êÿÇËë÷Ç¶ÇÈ
			ld		a, 0x01
			ld		h, 0x80
			call	enaslt

			ld		a, 37
			call	put_num

			ld		a, 1
			ld		[bank1reg], a

			ld		a, 43
			call	put_num

			ld		a, 2
			ld		[bank2reg], a

			ld		a, 49
			call	put_num

			ld		a, 3
			ld		[bank3reg], a

			ld		a, 55
			call	put_num

			ld		a, [0x6000 + 4]
			cp		a, '1'
			call	put_ok_or_ng
			ld		a, [0x8000 + 4]
			cp		a, '2'
			call	put_ok_or_ng
			ld		a, [0xA000 + 4]
			cp		a, '3'
			call	put_ok_or_ng

			ld		hl, 0x6000
			call	puts
			ld		hl, 0x8000
			call	puts
			ld		hl, 0xA000
			call	puts
loop:
			jp		loop

; -----------------------------------------------------------------------------
			scope	put_ok_or_ng
put_ok_or_ng::
			ld		hl, msg_ok
			jr		z, skip
			ld		hl, msg_ng
	skip:
			jp		puts
			endscope

; -----------------------------------------------------------------------------
			scope	put_num
put_num::
			ld		b, 0
	loop_100:
			sub		a, 100
			jr		c, exit_100
			inc		b
			jr		loop_100
	exit_100:
			add		a, 100
			push	af
			ld		a, b
			add		a, '0'
			rst		0x18

			pop		af
			ld		b, 0
	loop_10:
			sub		a, 10
			jr		c, exit_10
			inc		b
			jr		loop_10
	exit_10:
			add		a, 10
			push	af
			ld		a, b
			add		a, '0'
			rst		0x18

			pop		af
			add		a, '0'
			rst		0x18

			ld		a, ' '
			rst		0x18
			ret
			endscope

; -----------------------------------------------------------------------------
msg_title::
			db		"MegaROM ASC8 Checker", 0x0D, 0x0A, 0
msg_ok::
			db		"OK", 0x0D, 0x0A, 0
msg_ng::
			db		"NG", 0x0D, 0x0A, 0

; -----------------------------------------------------------------------------
;	puts
;	input:
;		HL .... ï∂éöóÒÇÃÉAÉhÉåÉX 
; -----------------------------------------------------------------------------
			scope	puts
puts::
			ld		a, [hl]
			or		a, a
			ret		z
			rst		0x18
			inc		hl
			jr		puts
			endscope

			align	8192
			db		"BANK1", 0x0D, 0x0A, 0

			align	8192
			db		"BANK2", 0x0D, 0x0A, 0

			align	8192
			db		"BANK3", 0x0D, 0x0A, 0

			align	8192
			db		"BANK4", 0x0D, 0x0A, 0

			align	8192
			db		"BANK5", 0x0D, 0x0A, 0

			align	8192
			db		"BANK6", 0x0D, 0x0A, 0

			align	8192
			db		"BANK7", 0x0D, 0x0A, 0

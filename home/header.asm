SECTION "Vectors", ROM0[$0000]
Reset:
	jp _Reset

POP_HLDEBCAF_RET:
	pop hl
POP_DEBCAF_RET:
	pop de
POP_BCAF_RET:
	pop bc
	pop af
	ret

BankSwitch:
	ld [MBC5RomBank], a
	ldh [hROMBank], a
	ret

	ds 2
FarCall:
	push af
	push af
	push hl
	ld hl, sp+5
	jp _FarCall

MemCpy::
	inc b
	inc c
	jp _MemCpy.loop

	ds 3
MemFill::
	inc b
	inc c
	jp _MemFill.loop

	ds 3
_rst28:
	ret

	ds $30 - @
_rst30:
	ret

	ds $38 - @
_rst38:
	di
	jp Crash_rst38

	ds $40 - @
_VBlank:
	push af
	push bc
	push de
	push hl
	jp VBlank

	ds $48 - @
_LCD:
	push af
	jp LCD

	ds $50 - @
_Timer:
	reti

CheckColorHardware::
	ldh a, [hConsoleType]
	cp HW_CGB
	ret

	ds $58 - @
_Serial:
	push af
	push bc
	push de
	push hl
	jp Serial

	ds $60 - @
_Joypad:
	jp Crash_JoypadInt



SECTION "Low ROM", ROM0[$0063]

INCLUDE "home/copy.asm"
INCLUDE "home/lcd_onoff.asm"
INCLUDE "home/speed.asm"
INCLUDE "home/delay.asm"

	ds $ED - @

BuildString:
PUSHC
SETCHARMAP ascii
	db STRFMT("%04u-%02u-%02u %02u:%02u:%02u", __UTC_YEAR__, __UTC_MONTH__, __UTC_DAY__, __UTC_HOUR__, __UTC_MINUTE__, __UTC_SECOND__)
POPC

SECTION "Home", ROM0[$0100]

Start::
	nop
	jp _Start

	ds $150 - @

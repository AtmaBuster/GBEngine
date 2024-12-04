_Start::
; check hardware: DMG, SGB, or CGB
	cp $11
	jr z, .cgb
	ld a, c
	cp $14
	jr z, .sgb
	xor a ; ld a, HW_DMG
	jr .done_hw_check

.sgb
	ld a, HW_SGB
	jr .done_hw_check

.cgb
	bit 0, b
	jr nz, .agb
	ld a, HW_CGB
	jr .done_hw_check

.agb
	ld a, HW_AGB

.done_hw_check
	ldh [hConsoleType], a

_Reset::
; clear first 2 pages of WRAM
; don't use the stack, it's not set up yet. also, this would clear it
	ld hl, $C000
	ld bc, $0200
.clear_loop
	xor a
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .clear_loop

; set up stack
	ld sp, wStackPointer

; clear HRAM
	ld hl, $FF81 ; don't clear hConsoleType
	ld bc, $007E
	xor a
	call MemFill

; clear the rest of WRAM
	ld hl, $C200
	ld bc, $E000 - $C200
	xor a
	call MemFill

	call CheckColorHardware
	jr c, .skip_clear_cgb_wram

	ld a, 7
.clear_cgb_wram_loop
	ldh [rSVBK], a
	ld hl, $D000
	ld bc, $1000
	push af
	xor a
	call MemFill
	pop af
	dec a
	cp 1
	jr nz, .clear_cgb_wram_loop

	ldh [rSVBK], a
.skip_clear_cgb_wram
; clear VRAM
	call DisableLCD

	ld hl, $8000
	ld bc, $2000
	xor a
	call MemFill

	call CheckColorHardware
	jr c, .skip_clear_cgb_vram

	ld a, 1
	ldh [rVBK], a
	ld hl, $8000
	ld bc, $2000
	xor a
	call MemFill
	; a is still 0
	ldh [rVBK], a

.skip_clear_cgb_vram
; set up OAM DMA routine
	call CopyDMARoutine

; init sound engine
	farcall DSX_Init

; seed RNG
	ld a, 1
	ldh [hRandomA], a

; load bank 1 by default
	ld a, 1
	rst BankSwitch

	jp Test_SpriteTest

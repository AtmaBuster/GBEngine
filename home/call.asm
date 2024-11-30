; ================================================
; FarCall
; ================================================
; Calls routine at <a>:<hl>
; ================================================
; code for this routine starts in home/header.asm, for space optimization
; ================================================
_FarCall::
	ldh a, [hROMBank]
	ld [hl], a
	pop hl
	pop af
	rst BankSwitch
	call .jp_hl
	pop af
	rst BankSwitch
	ret

.jp_hl
	jp hl

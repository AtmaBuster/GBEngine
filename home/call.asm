; These lines are at rst_10, for space efficiency
;	push af
;	push af
;	push hl
;	ld hl, sp+5
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

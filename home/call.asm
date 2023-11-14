; These lines are at rst_10, for space efficiency
;	ldh [hFarCallStoreA], a
;	ldh a, [hROMBank]
;	push af
_FarCall:
	ldh a, [hFarCallStoreA]
	rst BankSwitch
	call .jp_hl
	pop af
	rst BankSwitch
	ret

.jp_hl
	jp hl

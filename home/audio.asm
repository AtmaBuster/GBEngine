PlaySong::
	ldh a, [hROMBank]
	push af
	rst BankSwitch

	call DSX_PlaySong

	pop af
	rst BankSwitch
	ret

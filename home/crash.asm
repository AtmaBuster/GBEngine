Crash_rst38::
	ldh [hCrashStoreAF + 1], a
	ld a, ERR_RST38 ; don't optimize, keep flags
	jr CrashHandler

Crash_div0::
	di
	ldh [hCrashStoreAF + 1], a
	ld a, ERR_DIV0

; fallthrough
CrashHandler::
	ldh [hCrashType], a
	ld a, BANK(_CrashHandler)
	ld [MBC5RomBank], a
	jp _CrashHandler

; ================================
; WaitBGMap
; ================================
; Waits for the entire tile map (and attr map on CGB) to be copied to VRAM
; ================================
WaitBGMap::
	ld a, 1
	ldh [hCopyWRAMTileMap], a

	ldh a, [hConsoleType]
	cp HW_CGB
	ld c, 3
	jr c, .do_wait
	ld c, 6
.do_wait
	call DelayFrames

	xor a
	ldh [hCopyWRAMTileMap], a
	ret

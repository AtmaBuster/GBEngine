CopyDMARoutine::
	ld de, DMARoutine_ROM
	ld hl, hOAMDMA
	ld bc, DMARoutine_ROM_End - DMARoutine_ROM
	jp MemCpy

RunDMARoutine::
	ld a, HIGH(wOAMRAM)
	lb bc, 40, LOW(rDMA)
	jp hOAMDMA

DMARoutine_ROM:
LOAD "OAM DMA Routine", HRAM
hOAMDMA::
	ldh [c], a
.wait
	dec b
	jr nz, .wait
	ret z ; 1 machine cycle faster than just ret
ENDL
DMARoutine_ROM_End:

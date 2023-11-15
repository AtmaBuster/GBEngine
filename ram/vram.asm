SECTION "VRAM", VRAM[$8000], BANK[0]

vTiles0:: ds $80 tiles
vTiles1:: ds $80 tiles
vTiles2:: ds $80 tiles
vBGMap0:: ds 32 * 32
vBGMap1:: ds 32 * 32

SECTION "VRAM CGB", VRAM[$8000], BANK[1]

vTiles3:: ds $80 tiles
vTiles4:: ds $80 tiles
vTiles5:: ds $80 tiles
vAttrMap0:: ds 32 * 32
vAttrMap1:: ds 32 * 32

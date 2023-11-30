LoadFont::
	ld hl, vTiles0 tile FIRST_PRINTABLE_CHAR
	ld de, FontGFX
	ld b, (FontGFX.end - FontGFX) / 8
	jp MemCpy1BPP

FontGFX::
IF FONT_USE_ASCII_ORDER
IF FONT_USE_EXTENDED_ASCII
	INCBIN "gfx/ascii_font_full.1bpp"
ELSE
	INCBIN "gfx/ascii_font.1bpp"
ENDC
ELSE
	INCBIN "gfx/font.1bpp",8
ENDC
.end

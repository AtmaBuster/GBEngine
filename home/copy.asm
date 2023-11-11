; ================================================
; MemCpy
; ================================================
; Copies <bc> bytes from <de> to <hl>
; ================================================
;   input
;       bc - num. bytes
;       de - source
;       hl - destination
;   output
;       a  - last byte copied
;       bc - 0
;       de - de.in + bc.in
;       hl - hl.in + bc.in
MemCpy:
	inc b
	inc c
	jr .loop
.put
	ld a, [de]
	inc de
	ld [hli], a
.loop
	dec c
	jr nz, .put
	dec b
	jr nz, .put
	ret

; ================================================
; MemFill
; ================================================
; Fills <bc> bytes at <hl> to <a>
; ================================================
;   input
;       a  - fill byte
;       bc - num. bytes
;       hl - destination
;   output
;       bc - 0
;       hl - hl.in + bc.in
MemFill:
; fills bc bytes at hl with a
	inc b
	inc c
	jr .loop
.put
	ld [hli], a
.loop
	dec c
	jr nz, .put
	dec b
	jr nz, .put
	ret

; ================================================
; MemCpy1BPP
; ================================================
; copies <b> tiles of 1bpp graphics data from <de> to <hl>
; ================================================
;   input
;       b  - num. tiles
;       de - source
;       hl - destination
;   output
;       a  - last byte copied
;       bc - 0
;       de - de.in + b.in * 8
;       hl - hl.in + b.in * 16
MemCpy1BPP:
.tile_loop
	ld c, 8
.put
	ld a, [de]
	inc de
	ld [hli], a
	ld [hli], a
.loop
	dec c
	jr nz, .put
	dec b
	jr nz, .tile_loop
	ret

; ================================================
; MemCpy2BPP
; ================================================
; copies <b> tiles of 2bpp graphics data from <de> to <hl>
; ================================================
;   input
;       b  - num. tiles
;       de - source
;       hl - destination
;   output
;       a  - last byte copied
;       bc - 0
;       de - de.in + b.in * 16
;       hl - hl.in + b.in * 16
MemCpy2BPP:
.tile_loop
	ld c, 16
.put
	ld a, [de]
	inc de
	ld [hli], a
.loop
	dec c
	jr nz, .put
	dec b
	jr nz, .tile_loop
	ret

; ================================================
; StrCpy
; ================================================
; copies a "\0" terminated string from <de> to <hl>
; ================================================
;   input
;       de - source
;       hl - destination
;   output
;       a  - 0
;       de - de.in + <length of string>
;       hl - hl.in + <length of string>
StrCpy:
; copies a \0 terminated string from de to hl
.loop
	ld a, [de]
	and a
	ret z
	ld [hli], a
	inc de
	jr .loop

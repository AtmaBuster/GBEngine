Serial:
	ldh a, [rSB]
	ldh [hSerialGet], a
	;ldh a, [hSerialSend]
	;ldh [rSB], a
	ld hl, hSerialTransferStatus
	set F_SERIAL_GET, [hl]
	pop hl
	pop de
	pop bc
	pop af
	reti

Serial_WaitForByte:
.loop
	halt
	nop
	ldh a, [hSerialTransferStatus]
	bit F_SERIAL_GET, a
	jr nz, .ok
	inc a
	ldh [hSerialTransferStatus], a
	and SERIAL_TIMER_MASK
	cp 60
	jr c, .loop
; timeout
	xor a
	ret

.ok
	xor a
	ldh [hSerialTransferStatus], a
	ldh a, [hSerialGet]
	scf
	ret

Serial_EstablishConnection::
	xor a
	ldh [hSerialConnectionStatus], a

	ld hl, rIE
	set SERIAL, [hl]

	ld a, $AB ; handshake
	ld hl, rSB
	ld [hli], a

	xor a
	ldh [hSerialTransferStatus], a

	res rSC_CLOCK, [hl]
	set rSC_ON, [hl]

REPT 5
	call Serial_WaitForByte
	jr c, .got_byte
ENDR

	res rSC_ON, [hl]
	set rSC_CLOCK, [hl]
	set rSC_ON, [hl]

	call Serial_WaitForByte
	cp $FF ; disconnected
	jr z, Serial_LinkDisconnected

.got_byte
	cp $AB ; handshake
	jr nz, Serial_LinkError

	xor a
	ldh [hSerialTransferStatus], a

	ld a, [hl] ; copy clock status to hSerialConnectionStatus
	and %00000001
	or (1 << F_SERIAL_CONNECTION_OK)
	ldh [hSerialConnectionStatus], a

	ret

Serial_SendAndReceiveByte::
	xor a
	ldh [hSerialTransferStatus], a

	ldh a, [hSerialSend]
	ldh [rSB], a

	ldh a, [rSC]
	bit rSC_CLOCK, a
	call nz, .Pause
	and (1 << rSC_CLOCK) | (1 << rSC_CGB)
	ldh [rSC], a
	or (1 << rSC_ON)
	ldh [rSC], a

	call Serial_WaitForByte
	ret c
	call Serial_LinkTimeout
	and a
	ret

.Pause
	push af
	ld a, -1
:	dec a
	jr nz, :-
	pop af
	ret

Serial_LinkTimeout:
Serial_LinkError:
Serial_LinkDisconnected:
Serial_CloseConnection:
	ld hl, rIE
	res SERIAL, [hl]
	ld hl, hSerialConnectionStatus
	res F_SERIAL_CONNECTION_OK, [hl]
	ret

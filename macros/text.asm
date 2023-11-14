MACRO text
	db \1
ENDM

MACRO line
	db "\n"
IF _NARG == 1
	db \1
ENDC
ENDM

MACRO text_end
	db 0
ENDM

MACRO str
	db \1
	db 0
ENDM

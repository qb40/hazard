;--------------------------------------------------------------------------------
;				ERROR MAROS
;--------------------------------------------------------------------------------
; Part of HAZARD Library
; (a game/software programming library for QuickBasic 4.5 or similar)
; 
; Version: first
; Designed for:		WolfRAM
; developed by:		Subhajit Sahu
;
; For more details go through the README file
;********************************************************************************





RunDOSfunction				MACRO
INT	_dosinterrupt
ENDM



DOSfunction				MACRO	function1
MOV	AX, function1
RunDOSfunction
ENDM



ProcessDOSerror				MACRO
Zero	BX
PUSH5	CX, DX, SI, BP, DS
DOSfunction	_dos_get_extended_error_information
POP5	CX, DX, SI, BP, DS
ENDM





;--------------------------------------------------------------------------------
;				DOS MACROS
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







RunDOSfunction			MACRO
INT	_dos_interrupt
ENDM


DOSfunction			MACRO	function1
MOV	AX, function1
RunDOSfunction
ENDM




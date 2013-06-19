;--------------------------------------------------------------------------------
;				MEMORY MACROS
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




RunEMSfunction				MACRO
INT	_ems_interrupt
ENDM



EMSfunction				MACRO	function1
MOV	AH, function1
RunEMSfunction
ENDM



RunXMSinterrupt				MACRO
INT	_xms_interrupt
ENDM



XMSinterrupt				MACRO	function1
MOV	AX, function1
RunXMSInterrupt
ENDM



RunXMSfunction				MACRO
call	XMSdriver
ENDM



XMSfunction				MACRO	function1
mov	ah, function1
RunXMSfunction
ENDM




;--------------------------------------------------------------------------------
;				ERROR CALLABLE ROUTINES
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







.MODEL Large, BASIC

.386

;General INCLUDE File
INCLUDE	Includes.inc



;SHARED data



.STACK 200h



;External Variables
EXTRN	ErrorCode:WORD
EXTRN	ErrorAction:WORD




;CONST




.DATA




;INCLUDE Files
INCLUDE		err_incl.inc




.CODE



;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; HZDerrorCode	FUNCTION
;
; Purpose:
;   Gives the Error Code of the last error code that occured.
;
; Declaration:
;   DECLARE FUNCTION HZDerrorCode%()
;
; Returns:
;   Error Code
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC HZDerrorCode
HZDerrorCode PROC

CALL	hProcessError
MOV	AX, ErrorCode
RETF

HZDerrorCode ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>







;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; HZDerrorPreferAction	FUNCTION
;
; Purpose:
;   Gives the action that should be performed on encountering error.
;
; Declaration:
;   DECLARE FUNCTION HZDerrorPreferAction%()
;
; Returns:
;   Error Code
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC HZDerrorPreferAction
HZDerrorPreferAction PROC

CALL	hProcessError
MOV	AX, ErrorAction
RETF

HZDerrorPreferAction ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>






;String of error


END
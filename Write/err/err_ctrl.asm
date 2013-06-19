;--------------------------------------------------------------------------------
;				ERROR CONTROL
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
PUBLIC	ErrorCode, ErrorAction



.STACK 200h



;External Variables




;CONST




.DATA
ErrorCode			DW	?
ErrorAction			DW	?



;INCLUDE Files
INCLUDE	err_data.inc
INCLUDE	err_macr.inc
INCLUDE	err_vals.inc






.CODE



;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hStartError	INTERNAL FUNCTION
;
; Purpose:
;   Start Error facility.
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hStartError
hStartError PROC

;Clean Variables
Zerox	ErrorCode
Zerox	ErrorAction
RETF

hStartError ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>







;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hStopError	INTERNAL FUNCTION
;
; Purpose:
;   Stop Error facility.
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hStartError
hStartError PROC

RETF

hStartError ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>







;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hProcessError	INTERNAL FUNCTION
;
; Purpose:
;   Process the error that occured(if it is a DOS error)
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hProcessError
hProcessError PROC

PUSH2	AX, BX
MOV	AX, ErrorCode
CMP	AH, _error_dos
JNE	processerr01
ProcessDOSerror
MOV	AH, BH
Zero	BH
MOV	ErrorCode, AX
MOV	ErrorAction, BX

processerr01:
POP2	AX, BX
RETF

hProcessError ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>




;String of error


END
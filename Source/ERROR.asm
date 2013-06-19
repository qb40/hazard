;--------------------------------------------------------------------------------
;			ERROR MACHINE
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







.MODEL Large, Basic

.386

INCLUDE	Includes.inc


;SHARED
PUBLIC	LastError, LastErrorPlace




.STACK 200h

EXTRN	LibReadHandle:FAR





;CONST




.DATA
InternalError		DB	0
LastError			DW	0
LastErrorPlace		DW	0
LastErrorClass		DW	0


;External SUBS



.CODE

; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------



; -----------------------------------------------------------------------------------------------------------------------------
; ReportError	INTERNAL FUNCTION
;
; Purpose:
;   If an error occurs then this function must be called which reports the error to the
;   main program by creating a "Division by zero" error. Then error must be handled
;   by the error handler in the main program. The error must be handled as follows:
;
;   IF (HZDinternalError) THEN
;   errorcode% = HZDerror
;   errormessage$ = HZDerrorMessage
;   errorlocation% = HZDerrorLocation
;   errorlocationname$ = HZDerrorLocationName
;   'Handle the HZD library internal error
;   ELSE
;   errorcode% = ERR
;   errormessage$ = "ERROR!"
;   errorlocation% = ERL
;   'Handle the Main program error
;   END IF
;   RESUME NEXT
;
;
;
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC ReportError
ReportError PROC
mov	InternalError, 1
test	LastError, 0FF00h
jnz	notdoserror
push4	ax, bx, cx, dx
push5	ds, si, es, di, bp
mov	ah, 59h
int	21h
pop5	ds, si, es, di, bp
mov	LastError, ax
mov	bl, bh
xor	bh, bh
mov	LastErrorClass, bx
xor	bx, bx
div	bl
pop4	ax, bx, cx, dx
retf

notdoserror:
push	bx
xor	bx, bx
div	bl
pop	bx
retf
ReportError ENDP












; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------





; -----------------------------------------------------------------------------------------------------------------------------
; HZDinternalError		FUNCTION
;
; Purpose:
;   Tells whether error handler was called because of HZD library internal error
;   or due to an error that occured in the Qbasic program.
;
; Declaration:
;   DECLARE FUNCTION HZDinternalError%()
;
; Returns:
;   whether an error within HZD library(1) or not(0)
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDinternalError
HZDinternalError PROC
xor	ax, ax
mov	al, InternalError
retf
HZDinternalError ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDerror		FUNCTION
;
; Purpose:
;   Gives the error code of the error ocurred.
;
; Declaration:
;   DECLARE FUNCTION HZDerror%
;
; Returns:
;   error code number
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDerror
HZDerror PROC
mov	ax, LastError
retf
HZDerror ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDerrorMessage		FUNCTION
;
; Purpose:
;   Gives the error message of the error ocurred.
;
; Declaration:
;   DECLARE FUNCTION HZDerrorMessage$()
;
; Returns:
;   error message string
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDerrorMessage
HZDerrorMessage PROC
;Give error message
retf
HZDerrorMessage ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; HZDerrorLocation		FUNCTION
;
; Purpose:
;   Gives the location where the error ocurred. It is a number which indicates in which part
;   of the library the error ocurred.
;
; Declaration:
;   DECLARE FUNCTION HZDerrorLocation%()
;
; Returns:
;   error location in number which indicates the subroutine where error ocurred
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDerrorLocation
HZDerrorLocation PROC
;Give error location
retf
HZDerrorLocation ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDerrorLocationName	FUNCTION
;
; Purpose:
;   Gives the location where the error ocurred. It is a number which indicates in which part
;   of the library the error ocurred.
;
; Declaration:
;   DECLARE FUNCTION HZDerrorLocationName$()
;
; Returns:
;   exact subroutine name where error ocurred in HZD library
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDerrorLocationName
HZDerrorLocationName PROC
;Give error location name
retf
HZDerrorLocationName ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDerrorClass	FUNCTION
;
; Purpose:
;   Gives the class or category of error.
;
; Declaration:
;   DECLARE FUNCTION HZDerrorClass%()
;
; Returns:
;   error class number
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDerrorClass
HZDerrorClass PROC
;Give error class
retf
HZDerrorClass ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDerrorClassName	FUNCTION
;
; Purpose:
;   Gives the class name or category name of error.
;
; Declaration:
;   DECLARE FUNCTION HZDerrorClassName$()
;
; Returns:
;   error class name string
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDerrorClassName
HZDerrorClassName PROC
;Give error class name
retf
HZDerrorClassName ENDP















END

;--------------------------------------------------------------------------------
;			FONT MACHINE
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





.STACK 200h

EXTRN	LastError:WORD
EXTRN	VideoTask:BYTE





;CONST
fontOFF		equ	0




.DATA
FontSEG		DW	2
FontClipping	DB	0
FontGapping	DW	0
FontColour	DB	1




;External SUBS
EXTRN	CopyMemEE:FAR
EXTRN	GetMemE:FAR
EXTRN	CopyMem:FAR



.CODE

; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------



; -----------------------------------------------------------------------------------------------------------------------------
; StartFont	INTERNAL FUNCTION
;
; Purpose:
;   Start the font machine.
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StartFont
StartFont PROC
push5	fs, esi, es, di, cx
mov	fs, LibReadHandle
mov	esi, deffontADRS
mov	es, FontSEG
mov	di, fontOFF
mov	cx, deffontSIZE
call	CopyMemFE
pop5	fs, esi, es, di, cx
retf
StartFont ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; StopFont	INTERNAL FUNCTION
;
; Purpose:
;   Stop the font machine
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StopFont
StopFont PROC
push	ax
mov	ax, FontSEG
mov	FontPage, ax
mov	FontDirectFileADRS, 0
pop	ax
retf
StopFont ENDP


















; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------





; -----------------------------------------------------------------------------------------------------------------------------
; HZDselectFont	SUB
;
; Purpose:
;   Select a font.(0=font0, 1=font1, 3=direct file font)
;   In case of direct file font, font is used direct from the file, without loading it into the
;   memory. This feature may be used when there is requirement for usage of large fonts.
;
; Declaration:
;   DECLARE SUB HZDselectFont(BYVAL font%, BYVAL ifFileThenItsOFF&)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDselectFont
HZDselectFont PROC
UseParam
mov	bx, param3
cmp	bx, 3
je	chdrtfilemd
and	bx, 1
shl	bx, 1
mov	bx, FontSEG[bx]
mov	FontPage, bx

over78:
EndParam
retf	6

chdrtfilemd:
push	eax
mov	FontPage, 0		;direct file mode
mov	eax, param1
mov	FontDirectFileADRS, eax
pop	eax
jmp	over78
HZDselectFont ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDsetFontColour		SUB
;
; Purpose:
;   Set the colour of the font.
;
; Declaration:
;   DECLARE SUB HZDsetFontColour(BYVAL colour%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDsetFontColour
HZDsetFontColour PROC
UseParam
mov	al, param1
mov	FontColour, al
EndParam
retf	2
HZDsetFontColour ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDloadDefFont	SUB
;
; Purpose:
;   Load the default font to font0 or font1.
;
; Declaration:
;   DECLARE SUB HZDloadDefFont(BYVAL font%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDloadDefFont
HZDloadDefFont PROC
UseParam
push4	fs, esi, es, di
mov	bx, param1
and	bx, 1
shl	bx, 1
mov	fs, LibReadHandle
mov	esi, deffontADRS
mov	es, FontSEG[bx]
mov	di, fontOFF
mov	cx, deffontSIZE
call	CopyMemFE
pop4	fs, esi, es, di
EndParam
retf	2
HZDloadDefFont ENDP






END

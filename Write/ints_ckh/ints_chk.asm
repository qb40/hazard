;--------------------------------------------------------------------------------
;			INTERRUPT CHECK
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




;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCheckInterruptExistence	INTERNAL FUNCTION
;
; Purpose:
;   Checks if an interrupt exists
;
; Input:
;   ax=interrupt number
;
; Returns:
;   ax=TRUE if found, else FALSE
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCheckInterruptExistence
hCheckInterruptExistence PROC
push2	bx, es
mov	bx, ax
shl	bx, 2
xor	ax, ax
mov	es, ax
mov	ax, es:[bx+2]
mov	bx, es:[bx]
mov	es, ax
mov	al, es:[bx]
mov	bx, OFFSET iretaddress
mov	ah, cs:[bx]
cmp	ah, al
mov	ax, TRUE
je	interruptexists
mov	ax, FALSE

interruptexists:
pop2	bx, es
retf
hCheckInterruptExistence ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>





;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hGetInterrupt			INTERNAL FUNCTION
;
; Purpose:
;   Get an interrupts address
;
; Input:
;   ax=interrupt number
;
; Returns:
;   es=Interrupt segment, bx=Interrupt offset
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hGetInterrupt
hGetInterrupt PROC
push	ax
mov	bx, ax
shl	bx, 2
xor	ax, ax
mov	es, ax
mov	ax, es:[bx+2]
mov	bx, es:[bx]
mov	es, ax
pop	ax
retf
hGetInterrupt ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>





;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hSetInterrupt			INTERNAL FUNCTION
;
; Purpose:
;   Set an interrupts address
;
; Input:
;   ax=interrupt number, es=Interrupt segment, bx=Interrupt offset
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hSetInterrupt
hSetInterrupt PROC
push	ds, si
xor	si, si
mov	ds, si
mov	si, ax
shl	si, 2
mov	[si], bx
mov	[si+2], es
pop2	ds, si
retf
hSetInterrupt ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>






END

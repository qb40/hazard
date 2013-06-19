;--------------------------------------------------------------------------------
;			DRAWING MACHINE
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
EXTRN	GraphicsPage:WORD
EXTRN	BoundaryX1:WORD
EXTRN	BoundaryY1:WORD
EXTRN	BoundaryX2:WORD
EXTRN	BoundaryY2:WORD




;CONST




.DATA
DrawBoxControl			DW	OFFSET bhorizdraw, SEG bhorizdraw, OFFSET bvertdraw, SEG bvertdraw





;External SUBS
EXTRN	GetMemE:FAR




.CODE







; -----------------------------------------------------------------------------------------------------------------------------
;		MACROS
; -----------------------------------------------------------------------------------------------------------------------------
IsBoundaryWithin	MACRO	x, y, notwithin
mov	ax, x
cmp	ax, BoundaryX1
jb	notwithin
cmp	ax, BoundaryX2
ja	notwithin
mov	ax, y
cmp	ax, BoundaryY1
jb	notwithin
cmp	ax, BoundaryY2
ja	notwithin
ENDM




RearrangeXY		MACRO	x1, y1, x2, y2
mov	ax, x1
cmp	ax, x2
jle	x1lex2
xchg	ax, x2
mov	x1, ax

x1lex2:
mov	ax, y1
cmp	ax, y2
jle	y1ley2
xchg	ax, y2
mov	y1, ax

y1ley2:
ENDM






BringWithinDefault	MACRO	x1, y1, x2, y2
cmp	x1, 320
jbe	x1ok
mov	x1, 320

x1ok:
cmp	x2, 320
jbe	x2ok
mov	x2, 320

x2ok:
cmp	y1, 200
jbe	y1ok
mov	y1, 200

y1ok:
cmp	y2, 200
jbe	y2ok
mov	y2, 200

y2ok:
ENDM





BringWithinBoundaryX	MACRO	x
mov	ax, x
cmp	ax, BoundaryX1
jae	xok1
mov	ax, BoundaryX1

xok1:
cmp	ax, BoundaryX2
jbe	xok2
mov	ax, BoundaryX2

xok2:
mov	x, ax
ENDM




BringWithinBoundaryY	MACRO	y
mov	ax, y
cmp	ax, BoundaryY1
jae	yok1
mov	ax, BoundaryY1

yok1:
cmp	ax, BoundaryY2
jbe	yok2
mov	ax, BoundaryY2

yok2:
mov	y, ax
ENDM




BringWithinBoundary	MACRO	x1, y1, x2, y2
BringWithinBoundaryX	x1
BringWithinBoundaryY	y1
BringWithinBoundaryX	x2
BringWithinBoundaryY	y2
ENDM



GetPixelAddress		MACRO	x, y
push	ax
xor	ax, ax
xor	bx, bx
mov	ah, y
mov	bh, ah
shr	ax, 2
add	bx, ax
add	bx, x
pop	ax
ENDM















; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------







; -----------------------------------------------------------------------------------------------------------------------------
; DrawBoxFill	INTERNAL FUNCTION
;
; Purpose:
;   Draws a filled box
;
; Usage:
;   ax=x1, bx=y1, cx=x2, dx=y2, si=clr
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC DrawBoxFill
DrawBoxFill PROC
;Internally used constants
;......................................................................
	bfstackspace		equ	6
	bfx1			equ	[bp]
	bfy1			equ	[bp+2]
	bfxcount			equ	[bp+4]
;......................................................................
push7	ax, bx, cx, dx, si, es, di
push	bp
sub	sp, bfstackspace
mov	bp, sp
cmp	cx, BoundaryX1
jl	bfover45
cmp	ax, BoundaryX2
jg	bfover45
cmp	dx, BoundaryY1
jl	bfover45
cmp	bx, BoundaryY2
jg	bfover45
cmp	ax, BoundaryX1
jge	bfx1ok
mov	ax, BoundaryX1

bfx1ok:
cmp	bx, BoundaryY1
jge	bfy1ok
mov	bx, BoundaryY1

bfy1ok:
cmp	cx, BoundaryX2
jle	bfx2ok
mov	cx, BoundaryX2

bfx2ok:
cmp	dx, BoundaryY2
jle	bfy2ok
mov	dx, BoundaryY2

bfy2ok:
mov	bfx1, ax
mov	bfy1, bx
GetPixelAddress	bfx1, bfy1
sub	cx, bfx1
inc	cx
mov	bfxcount, cx
sub	dx, bfy1
inc	dx
mov	ax, GraphicsPage
call	GetMemE
mov	es, ax
mov	ax, si
mov	di, bx
cld

bfyloop:

bfxloop:
stosb
dec	cx
jnz	bfxloop
add	bx, 320
mov	di, bx
mov	cx, bfxcount
dec	dx
jnz	bfyloop

bfover45:
add	sp, bfstackspace
pop	bp
pop7	ax, bx, cx, dx, si, es, di
retf
DrawBoxFill ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; DrawBox	INTERNAL FUNCTION
;
; Purpose:
;   Draws a box
;
; Usage:
;   ax=x1, bx=y1, cx=x2, dx=y2, si=clr
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC DrawBox
DrawBox PROC
;Internally used constants
;......................................................................
	bstackspace		equ	12
	bx1			equ	[bp]
	by1			equ	[bp+2]
	bx2			equ	[bp+4]
	by2			equ	[bp+6]
	blinedraw			equ	[bp+8]
	brough			equ	[bp+10]
	bLUd			equ	1b
	bLDd			equ	10b
	bLLd			equ	100b
	bLRd			equ	1000b
;......................................................................
push7	ax, bx, cx, dx, si, es, di
push	bp
sub	sp, bstackspace
mov	bp, sp
mov	BYTE PTR blinedraw, 1111b
cmp	cx, BoundaryX1
jl	bover45
cmp	ax, BoundaryX2
jg	bover45
cmp	dx, BoundaryY1
jl	bover45
cmp	bx, BoundaryY2
jg	bover45
cmp	ax, BoundaryX1
jge	bx1ok
mov	ax, BoundaryX1
xor	BYTE PTR blinedraw, bLLd

bx1ok:
cmp	bx, BoundaryY1
jge	by1ok
mov	bx, BoundaryY1
xor	BYTE PTR blinedraw, bLUd

by1ok:
cmp	cx, BoundaryX2
jle	bx2ok
mov	cx, BoundaryX2
xor	BYTE PTR blinedraw, bLRd

bx2ok:
cmp	dx, BoundaryY2
jle	by2ok
mov	dx, BoundaryY2
xor	BYTE PTR blinedraw, bLDd

by2ok:
mov	bx1, ax
mov	by1, bx
mov	bx2, cx
mov	by2, dx
mov	ax, GraphicsPage
call	GetMemE
mov	es, ax
test	BYTE PTR blinedraw, bLUd
jz	bnoLUd
mov	ax, by1
call	DWORD PTR DrawBoxControl

bnoLUd:
test	BYTE PTR blinedraw, bLDd
jz	bnoLDd
mov	ax, by2
call	DWORD PTR DrawBoxControl

bnoLDd:
test	BYTE PTR blinedraw, bLLd
jz	bnoLLd
mov	ax, bx1
call	DWORD PTR DrawBoxControl[4]

bnoLLd:
test	BYTE PTR blinedraw, bLRd
jz	bnoLRd
mov	ax, bx2
call	DWORD PTR DrawBoxControl[4]

bnoLRd:

bover45:
add	sp, bstackspace
pop	bp
pop7	ax, bx, cx, dx, si, es, di
retf

bhorizdraw:
mov	brough, ax
GetPixelAddress	bx1, brough
mov	cx, bx2
sub	cx, bx1
inc	cx
mov	ax, si
mov	di, bx
cld

bhloop01:
stosb
dec	cx
jnz	bhloop01
retf

bvertdraw:
mov	brough, ax
GetPixelAddress	brough, by1
mov	cx, by2
sub	cx, by1
inc	cx
mov	ax, si

bvloop01:
mov	es:[bx], al
add	bx, 320
dec	cx
jnz	bvloop01
retf
DrawBox ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; DrawLine	INTERNAL FUNCTION
;
; Purpose:
;   Draws a line
;
; Usage:
;   ax=x1, bx=y1, cx=x2, dx=y2, si=clr
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC DrawLine
DrawLine PROC
;Internally used constants
;......................................................................
	lnstackspace		equ	28
	lnx1			equ	[bp]
	lny1			equ	[bp+2]
	lnx2			equ	[bp+4]
	lny2			equ	[bp+6]
	lnslope			equ	[bp+12]
	lnstep			equ	[bp+16]
	lnx			equ	[bp+18]
	lny			equ	[bp+20]
	lncolour			equ	[bp+22]
	lnslopeaccuracy		equ	16
	lndelx			equ	[bp+8]
	lndely			equ	[bp+24]
;......................................................................
push6	eax, ebx, ecx, dx, si, es
push	bp
sub	sp, lnstackspace
mov	bp, sp
mov	lnx1, ax
mov	lny1, bx
mov	lnx2, cx
mov	lny2, dx
mov	lncolour, si
sub	cx, ax
mov	ax, cx
cwd
mov	lndelx, eax
sub	dx, bx
mov	ax, dx
cwd
mov	lndely, eax
mov	ax, GraphicsPage
call	GetMemE
mov	es, ax

;assume all is ok
jmp	liney2ok01

or	cx, cx
jnz	lnatleast1notzero
or	dx, dx
jz	lndrawpointonly

lnatleast1notzero:
xor	eax, eax
xor	ebx, ebx
mov	ax, lnx1
cmp	ax, BoundaryX1
jge	linex1ok01
cmp	WORD PTR lndelx, 0
jz	lnover34
mov	ax, BoundaryX1
sub	ax, lnx1
mov	bx, lndely
imul	ebx
mov	bx, lndelx
idiv	ebx
add	lnx1, ax

linex1ok01:
mov	ax, lny1
cmp	ax, BoundaryY1
jge	liney1ok01
cmp	WORD PTR lndely, 0
jz	lnover34
mov	ax, BoundaryY1
sub	ax, lny1
mov	bx, lndelx
imul	ebx
mov	bx, lndely
idiv	ebx
add	lny1, ax

liney1ok01:
mov	ax, lnx2
sub	ax, BoundaryX2
jle	linex2ok01
cmp	WORD PTR lndelx, 0
jz	lnover34
mov	bx, lndely
imul	ebx
mov	bx, lndelx
idiv	ebx
sub	lnx2, ax

linex2ok01:
mov	ax, lny2
sub	ax, BoundaryY2
jle	liney2ok01
cmp	WORD PTR lndely, 0
jz	lnover34
mov	bx, lndelx
imul	ebx
mov	bx, lndely
idiv	ebx
sub	lny2, ax

liney2ok01:
cmp	cx, dx
jl	lnslopedxbydy

lnslopedybydx:
xor	eax, eax
xor	ebx, ebx
xor	ecx, ecx
mov	eax, lndely
sal	eax, lnslopeaccuracy
mov	ebx, lndelx
idiv	ebx
mov	lnslope, eax
cmp	WORD PTR lndelx, 0
mov	WORD PTR lnstep, 1
jg	lnstpok01
mov	WORD PTR lnstep, -1

lnstpok01:
mov	si, lnx1

lndoloop01:
mov	ax, si
sub	ax, lnx1
cwd
mov	ecx, lnslope
imul	ecx
sar	eax, lnslopeaccuracy
add	ax, lny1
mov	lnx, si
mov	lny, ax
IsBoundaryWithin	lnx, lny, lnnotwt01
GetPixelAddress	lnx, lny
mov	dl, lncolour
mov	es:[bx], dl

lnnotwt01:
cmp	si, lnx2
je	lndoloopover01
add	si, lnstep
jmp	lndoloop01

lndoloopover01:
jmp	lnover34


lnslopedxbydy:
xor	eax, eax
xor	ebx, ebx
xor	ecx, ecx
mov	eax, lndelx
sal	eax, lnslopeaccuracy
mov	ebx, lndely
idiv	ebx
mov	lnslope, eax
cmp	WORD PTR lndely, 0
mov	WORD PTR lnstep, 1
jg	lnstpok01
mov	WORD PTR lnstep, -1

lnstpok02:
mov	si, lny1

lndoloop02:
mov	ax, si
sub	ax, lny1
cwd
mov	ecx, lnslope
imul	ecx
sar	eax, lnslopeaccuracy
add	ax, lnx1
mov	lnx, ax
mov	lny, si
IsBoundaryWithin	lnx, lny, lnnotwt02
GetPixelAddress	lnx, lny
mov	dl, lncolour
mov	es:[bx], dl

lnnotwt02:
cmp	si, lny2
je	lndoloopover02
add	si, lnstep
jmp	lndoloop02

lndoloopover02:
jmp	lnover34

lndrawpointonly:
IsBoundaryWithin	lnx1, lny1, lnnotwt03
GetPixelAddress	lnx1, lny1
mov	dl, lncolour
mov	es:[bx], dl

lnnotwt03:

lnover34:
add	sp, lnstackspace
pop	bp
pop6	eax, ebx, ecx, dx, si, es
retf
DrawLine ENDP



















; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------




; -----------------------------------------------------------------------------------------------------------------------------
; HZDdrawBoxFill	SUB
;
; Purpose:
;   Draws a filled box on the graphics page
;
; Declaration:
;   DECLARE SUB HZDdrawBoxFill(BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL clr%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDdrawBoxFill
HZDdrawBoxFill PROC
UseParam
push	si
RearrangeXY	param5, param4, param3, param2
mov	ax, param5
mov	bx, param4
mov	cx, param3
mov	dx, param2
mov	si, param1
call	DrawBoxFill
pop	si
EndParam
retf	10
HZDdrawBoxFill ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDdrawBox	SUB
;
; Purpose:
;   Draws a box on the graphics page
;
; Declaration:
;   DECLARE SUB HZDdrawBox(BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL clr%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDdrawBox
HZDdrawBox PROC
UseParam
push	si
RearrangeXY	param5, param4, param3, param2
mov	ax, param5
mov	bx, param4
mov	cx, param3
mov	dx, param2
mov	si, param1
call	DrawBox
pop	si
EndParam
retf	10
HZDdrawBox ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDdrawLine	SUB
;
; Purpose:
;   Draws a line on the graphics page
;
; Declaration:
;   DECLARE SUB HZDdrawLine(BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL clr%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDdrawLine
HZDdrawLine PROC
UseParam
push	si
mov	ax, param5
mov	bx, param4
mov	cx, param3
mov	dx, param2
mov	si, param1
call	DrawLine
pop	si
EndParam
retf	10
HZDdrawLine ENDP












END

;--------------------------------------------------------------------------------
;			VIDEO MACHINE
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




;CONST
maxvideo				equ	4
videodataOFF			equ	0
videodataSIZE			equ	64







;STRUCTURES
ntype				equ	0
nmemtype				equ	1
nmemseg				equ	2
nmemoff				equ	4
nvideopage			equ	8
ntotalslides			equ	10
nxres				equ	14
nyres				equ	18
nslidesize				equ	22
nwaittimeleft			equ	26
noffset				equ	28
nslidenumber			equ	32
nx1				equ	36
ny1				equ	38
npixeladdress			equ	40
nimageaddress			equ	42
nxstart				equ	46
nystart				equ	50
nxcount				equ	54
nycount				equ	56
nnowycount			equ	58
nreserved				equ	58
ENDS








.DATA
NumOfVideosActive			DB	0




;External SUBS




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
jbe	x1lex2
xchg	ax, x2
mov	x1, ax

x1lex2:
mov	ax, y1
cmp	ax, y2
jbe	y1ley2
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



GetPixelAddress		MACRO	x, y
xor	ax, ax
xor	bx, bx
mov	ah, y
mov	bh, ah
shr	ax, 2
add	bx, ax
add	bx, x
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
; StartVideo	INTERNAL FUNCTION
;
; Purpose:
;   Starts the video machine
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StartVideo
StartVideo PROC
retf
StartVideo ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; StopVideo	INTERNAL FUNCTION
;
; Purpose:
;   Stops the video machine
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StopVideo
StopVideo PROC
push	ax
mov	ax, VideoDataSEG
call	GetMemE
mov	es, ax
xor	al, al
mov	es:[videodataOFF+0*videodataSIZE+ntype], al
mov	es:[videodataOFF+1*videodataSIZE+ntype], al
mov	es:[videodataOFF+2*videodataSIZE+ntype], al
mov	es:[videodataOFF+3*videodataSIZE+ntype], al
mov	NumOfVideosActive, al
pop	ax
retf
StopVideo ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; VideoISR	INTERNAL FUNCTION
;
; Purpose:
;   Plays the videos
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC VideoISR
VideoISR PROC
push8	fs, esi, es, di, gs, eax, bx, cx
cmp	NumOfVideosActive, 0
jz	visrover
mov	ax, VideoDataSEG
call	GetMemE
mov	gs, ax
xor	bx, bx
mov	cx, maxvideo

visrfindactivevideo:
cmp	gs:[videodataOFF+bx+ntype], 0
jz	visrnotactive01
cmp	gs:[videodataOFF+bx+nvideopage], ax
jne	visrvideocantdisplay

videocandisplay:
call	DisplayVideo

visrvideocantdisplay:
cmp	gs:[videodataOFF+bx+nwaittimeleft], 0
jz	visrreadnextoff
dec	gs:[videodataOFF+bx+waittimeleft]
jmp	visrincslidefree

visrreadnextoff:
push	eax
mov	ah, gs:[videodataOFF+bx+nmemtype]
mov	fs, gs:[videodataOFF+bx+nmemseg]
mov	esi, gs:[videodataOFF+bx+noffset]
mov	di, ss
mov	es, di
mov	di, sp
mov	ah, gs:[videodataOFF+bx+nmemtype]
mov	al, 0
mov	cx, 4
call	CopyMem
pop	eax
add	esi, eax
inc	esi
mov	gs:[videodataOFF+bx+noffset], esi
dec	esi
push	eax
call	CopyMem
pop	eax
mov	gs:[videodataOFF+bx+nwaitimeleft], al

visrincslidefree:
inc	gs:[videodataOFF+bx+nslidenumber]

notactive01:
add	bx, videodataSIZE
dec	cx
jnz	visrfindactivevideo

visrover:
pop8	fs, esi, es, di,gs,  eax, bx, cx
retf
VideoISR ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; DisplayVideo	INTERNAL FUNCTION
;
; Purpose:
;   Displays a slide of the video
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC DisplayVideo
DisplayVideo PROC
pushx
push	bp
sub	sp, videodataSIZE
mov	bp, sp
mov	fs, EMSseg
mov	si, videodataOFF
add	si, bx
mov	di, ss
mov	es, di
mov	di, bp
mov	cx, videodataSIZE
call	CopyMemCC
mov	fs, [bp+nmemseg]
mov	edx, [bp+noffset]
xor	cx, cx
mov	cl, gs:[bp+ntype]
dec	cl
mov	si, cx
call	DWORD PTR DisplayVideoControl[4*si]

dvidmode1:
mov	ax, GraphicsPage
call	GetMemE
mov	es, ax
mov	ah, [bp+nmemtype]
mov	al, 0
add	edx, [bp+nimageaddress]
mov	cx, [bp+nycount]
mov	[bp+nnowycount]. cx
mov	di, [bp+npixeladdress]

dvidloop01:
mov	esi, edx
mov	cx, [bp+nxcount]
call	CopyMem
add	edx, [bp+nxres]
add	di, 320
dec	[bp+nnowycount]
jnz	dvidloop01
retf

dvidmode2:
xor	ecx, ecx
mov	[bp+nimageaddressreached], 0
[bp+nbytesleft], 256
[bp+nmodebytesleft], modesize
[bp+ncurrentmode], nowmode



mov	esi, edx
mov	ah, [bp+nmemtype]
mov	al, 0
mov	di, @DATA
mov	es, di
mov	di, OFFSET FreeConv
mov	cx, freeconvSIZE
mov	[bp+nbytesleft], cx
call	CopyMem

xor	bx, bx
add	edx, ecx
cmp	[bp+nmodebytesleft], 0
jnz	dvidm2ongoingmode
mov	al, FreeConv[bx]
mov	[bp+ncurrentmode], al
inc	bx
mov	eax, FreeConv[bx]
mov	[bp+nmodebytesleft], eax
xor	ax, ax
mov	al, [bp+ncurrentmode]
shl	ax, 2
mov	si, ax
call	DWORD PTR DispVidMode2Control[si]



dvidm2ongoingmode:
mov	di, @DATA
mov	es, di
mov	di, OFFSET FreeConv
mov	cx, VideoNxcount[2*bx]
call	CopyMem












; -----------------------------------------------------------------------------------------------------------------------------
; LaunchVideo	INTERNAL FUNCTION
;
; Purpose:
;   Launch(start) a video on a particular graphics page at a particular position on the page
;
; Usage:
;   ah:fs:si=video address, bx=video page on which to display
;   cx=x1, dx=y1
;
; Returns:
;   Offset to palette(if in file)
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC LaunchVideo
LaunchVideo PROC
;Internally used constants
;......................................................................
	lvidstackspace	equ	18
;......................................................................
pushx
push	bp
sub	sp, lvidstackspace
mov	bp, sp
mov	lvidmemtype, ax
mov	lvidmemseg, fs
mov	lvidmemoff, esi
mov	al, 0
mov	di, ss
mov	es, di
mov	di, bp
add	bp, lvidloaddatastart
mov	cx, lvidloaddatasize
call	CopyMem

LaunchVideo ENDP









; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------


; -----------------------------------------------------------------------------------------------------------------------------
; HZDselectGraphicsPage	SUB
;
; Purpose:
;   Select a graphics page from the four 
;   available graphics pages(0-3)
;
; Declaration:
;   DECLARE SUB HZDselectGraphicsPage(BYVAL page%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDselectGraphicsPage
HZDselectGraphicsPage PROC
UseParam
mov	ax, param1
and	ax, 3
add	ax, VideoSEG
mov	GraphicsPage, ax
EndParam
retf	2
HZDselectGraphicsPage ENDP











END

;--------------------------------------------------------------------------------
;			GRAPHICS MACHINE
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
PUBLIC	GraphicsActive, GraphicsPage, BoundaryX1, BoundaryY1, BoundaryX2, BoundaryY2




.STACK 200h

EXTRN	LastError:WORD
EXTRN	VideoSEG:WORD
EXTRN	PaletteSEG:WORD
EXTRN	UsrPaletteOFF:WORD
EXTRN	RoughSEG:WORD
EXTRN	LibReadHandle:WORD
EXTRN	FreeConv:BYTE





;CONST
verticalretraceport			equ	3DAh
onesecondtime			equ	1192755-5	;delay time
palettesize			equ	768
videopagestart			equ	13



.DATA
VideoArea			DW	0A000h
GraphicsActive			DB	0
GraphicsPage			DW	videopagestart
GraphicsFrequency			DB	60
MicroTimeAdd			DW	0
ReqMicroTime			DW	0
BoundaryX1			DW	0
BoundaryY1			DW	0
BoundaryX2			DW	319
BoundaryY2			DW	199







;External SUBS
EXTRN	GetMemE:FAR
EXTRN	CopyMem:FAR
EXTRN	GetMicroTime:FAR
EXTRN	CopyMemCC:FAR
EXTRN	WriteFile:FAR
EXTRN	CopyMemEC:FAR
EXTRN	CopyMemCF:FAR
EXTRN	CopyMemFC:FAR
EXTRN	CopyMemEE:FAR



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



BringWithinDefaultValue	MACRO	x, lowrange, highrange, xok1, xok2
cmp	WORD PTR x, lowrange
jge	xok1
mov	WORD PTR x, lowrange

xok1:
cmp	WORD PTR x, highrange
jle	xok2
mov	WORD PTR x, highrange

xok2:
ENDM



BringWithinDefault	MACRO	x1, y1, x2, y2
BringWithinDefaultValue	x1, 0, 319, a1, b1
BringWithinDefaultValue	x2, 0, 319, a2, b2
BringWithinDefaultValue	y1, 0, 199, a3, b3
BringWithinDefaultValue	y2, 0, 199, a4, b4
ENDM






BringWithinBoundaryX	MACRO	x, xok1, xok2
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




BringWithinBoundaryY	MACRO	y, yok1, yok2
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
; SetRefreshRate	INTERNAL FUNCTION
;
; Purpose:
;   Set the refresh rate
;
; Usage:
;   al=refresh rate(in Hz)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC SetRefreshRate
SetRefreshRate PROC
cmp	al, 60
jne	refreshnot60
mov	MicroTimeAdd, onesecondtime/60
mov	GraphicsFrequency, 60
retf

refreshnot60:
cmp	al, 30
jne	refreshnot6030
mov	MicroTimeAdd, onesecondtime/30
jmp	refreshcom

refreshnot6030:
cmp	al, 20
jne	refreshnotany
mov	MicroTimeAdd, onesecondtime/20

refreshcom:
mov	GraphicsFrequency, al
call	GetMicroTime
;ax=GetMicroTime();			;EXTRN
add	ax, MicroTimeAdd
mov	ReqMicroTime, ax
retf

refreshnotany:
mov	LastError, errimproperrefreshrate
retf
SetRefreshRate ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; StartGraphics	INTERNAL FUNCTION
;
; Purpose:
;   Starts the graphics machine
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StartGraphics
StartGraphics PROC
cmp	GraphicsActive, 1
jne	donestart
push	ax
mov	ax, 13h
int	10h
mov	al, 60
call	SetRefreshRate
mov	GraphicsActive, 1
pop	ax

donestart:
retf
StartGraphics ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; StopGraphics	INTERNAL FUNCTION
;
; Purpose:
;   Stops the graphics machine
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StopGraphics
StopGraphics PROC
cmp	GraphicsActive, 0
jne	notgraphstart
push	ax
mov	ax, 3h
int	10h
pop	ax
mov	BoundaryX1, 0
mov	BoundaryY1, 0
mov	BoundaryX2, 320
mov	BoundaryY2, 200
mov	ax, VideoSEG
mov	GraphicsPage, ax
mov	GraphicsActive, 0

notgraphstart:
retf
StopGraphics ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; DisplayGraphics	INTERNAL FUNCTION
;
; Purpose:
;   Displays the graphics when vertical retrace occurs
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC DisplayGraphics
DisplayGraphics PROC
push7	fs, si, es, di, ax, cx, dx
cmp	GraphicsFrequency, 60
je	waittillstop

findagain1:
call	GetMicroTime
cmp	ax, ReqMicroTime
jl	findagain1
add	ax, MicroTimeAdd
mov	ReqMicroTime, ax
jmp	waittillstart

waittillstop:
mov	dx, verticalretraceport
Vretover:
in	al, dx
and	al, 8
jnz	Vretover

waittillstart:
mov	dx, verticalretraceport
Vretstart:
in	al, dx
and	al, 8
jz	Vretstart
mov	ax, GraphicsPage
call	GetMemE
mov	fs, ax
xor	si, si
mov	es, VideoArea
xor	di, di
mov	cx, 64000
call	CopyMemCC
pop7	fs, si, es, di, ax, cx, dx
retf
DisplayGraphics ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; ClearPage	INTERNAL FUNCTION
;
; Purpose:
;   Clears a particular page(similar to CLS)
;   This clears the whole page regardless
;   of the boundary set
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC ClearPage
ClearPage PROC
push4	es, di, eax, cx
mov	ax, GraphicsPage
call	GetMemE
mov	es, ax
xor	di, di
xor	eax, eax
mov	cx, 16000
cld
rep	stosd
pop4	es, di, eax, cx
retf
ClearPage ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; TakeScreenshot	INTERNAL FUNCTION
;
; Purpose:
;   Take screenshot of the display page to a file
;
; Usage:
;   al=des type(3 only), es:edi=des memory, bh=x-pixelsize, bl=y-pixelsize
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC TakeScreenshot
TakeScreenshot PROC
push8	eax, bx, ecx, dx, fs, si, es, esi
push	bp
sub	sp, 20
mov	bp, sp
cmp	al, 3
jne	notfiletype
mov	stack0, ax
mov	stack2, es
mov	stack4, di
mov	ax, RoughSEG[2]
call	GetMemE
mov	es, ax
mov	stack6, ax
mov	di, 0
mov	fs, LibReadHandle
mov	esi, screenshotdataADRS
mov	cx, screenshotdataSIZE
call	CopyMemFC
mov	fs, ax
mov	si, 0
mov	ax, 320
xor	ch, ch
mov	cl, bh
mul	cx
mov	fs:[screenshotxresOFF], ax
mov	fs:[screenshotxresOFF+2], dx
mov	ax, 200
xor	ch, ch
mov	cl, bl
mul	cx
mov	fs:[screenshotyresOFF], ax
mov	fs:[screenshotyresOFF+2], dx
mov	eax, fs:[screenshotxresOFF]
mov	ecx, fs:[screenshotyresOFF]
mul	ecx
add	eax, screenshotheaderSIZE
mov	fs:[screenshotfilesizeOFF], eax
xor	ecx, ecx
mov	es, stack2
mov	di, stack4
mov	cx, screenshotheaderSIZE
call	CopyMemCF
mov	fs, PaletteSEG
mov	si, UsrPaletteOFF
mov	es, stack6
mov	di, 0
mov	cx, palettesize
call	CopyMemEC
mov	cx, 768

loopdo1:
mov	al, es:[di]
shl	al, 2
mov	es:[di], al
inc	di
dec	cx
jnz	loopdo1
;Palette at 0
;data at palettesize req.
mov	al, bh
mul	bl
mov	cx, 160
mul	cx
mov	stack8, ax
mov	fs, VideoArea
xor	si, si
mov	di, palettesize
mov	stack10, bh
mov	stack11, bl
;Loops begin here
;Here the main operation is performed
mov	WORD PTR stack12, 0

looph1:
cmp	WORD PTR stack12, 400
jae	looph1over
mov	cx, 160
call	CopyMemCC
push2	si, di
mov	si, palettesize
mov	di, palettesize+160
mov	BYTE PTR stack14, 0

loopi1:
mov	al, stack11
cmp	stack14, al
jae	loopi1over
mov	BYTE PTR stack15, 0

loopj1:
cmp	BYTE PTR stack15, 160
jae	loopj1over
mov	bx, [si]
inc	si
mov	ax, bx
shl	ax, 1
add	bx, ax
mov	ax, es:[bx]
mov	stack16, ax
mov	al, es:[bx+2]
mov	stack18, al
mov	BYTE PTR stack19, 0

loopk1:
mov	al, stack10
cmp	stack19, al
jae	loopk1over
mov	ax, stack16
mov	es:[di], ax
inc	di
inc	di
mov	al, stack18
mov	es:[di], al
inc	di
jmp	loopk1

loopk1over:
jmp	loopj1

loopj1over:
jmp	loopi1

loopi1over:
mov	fs, stack6
mov	si, palettesize+160
mov	ax, stack2
mov	cx, stack8
call	WriteFile
jmp	looph1

looph1over:

allover:
add	sp, 20
pop	bp
pop8	eax, bx, ecx, dx, fs, si, es, esi
retf

notfiletype:
mov	LastError, errfilenotused
jmp	allover
TakeScreenshot ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; GetPart	INTERNAL FUNCTION
;
; Purpose:
;   Get a part of the graphics page
;
; Usage:
;   al=des type, es:di=des offset, bx=x1, cx=y1, dx=x2, si=y2
;
; Returns:
;   Data in memory as follows
;   D[GetPutID], D[Total Size], W[Xsize], W[Ysize], B[Data]
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetPart
GetPart PROC
;Internally used constants
;......................................................................
	getpstackspace	equ	18
	getpmemtype	equ	[bp]
	getpx1		equ	[bp+2]
	getpy1		equ	[bp+4]
	getpxsize		equ	[bp+10]
	getpysize		equ	[bp+12]
	getpxstart	equ	[bp+14]
	getpystart	equ	[bp+16]
	getpdatatype	equ	[bp+2]
	getpdatasize0	equ	[bp+6]
	getpdatasize1	equ	[bp+8]
	getpdatastart	equ	2
	getpdatasizetotal	equ	12
;......................................................................
push7	fs, si, edi, ax, bx, ecx, dx
push	bp
sub	sp, getpstackspace
mov	bp, sp
mov	getpmemtype, ax
mov	WORD PTR getpxstart, 0
mov	WORD PTR getpystart, 0
mov	ax, dx
sub	ax, bx
inc	ax
mov	getpxsize, ax
mov	ax, si
sub	ax, cx
inc	ax
mov	getpysize, ax
cmp	bx, BoundaryX1
jge	gpx1isok01
mov	ax, BoundaryX1
sub	ax, bx
mov	getpxstart, ax

gpx1isok01:
cmp	cx, BoundaryY1
jge	gpy1isok01
mov	ax, BoundaryY1
sub	ax, cx
mov	getpystart, ax

gpy1isok01:
cmp	dx, BoundaryX2
jle	gpx2isok01
mov	ax, dx
sub	ax, BoundaryX2
sub	getpxsize, ax

gpx2isok01:
cmp	si, BoundaryY2
jle	gpy2isok01
mov	ax, si
sub	ax, BoundaryY2
sub	getpysize, ax

gpy2isok01:
mov	ax, getpxsize
sub	ax, getpxstart
mov	getpxsize, ax
mov	ax, getpysize
sub	ax, getpxstart
mov	getpxsize, ax
add	bx, getpxstart
add	cx, getpystart
mov	getpx1, bx
mov	getpy1, cx
GetPixelAddress		getpx1, getpy1
mov	ax, getpxsize
mov	cx, getpysize
mul	cx
add	ax, 4
adc	dx, 0
mov	DWORD PTR getpdatatype, datatypegetput
mov	getpdatasize0, ax
mov	getpdatasize1, dx
mov	si, ss
mov	fs, si
mov	si, bp
add	si, getpdatastart
mov	cx, getpdatasizetotal
mov	ax, getpmemtype
mov	ah, 0
call	CopyMem
add	edi, getpdatasizetotal
mov	ax, GraphicsPage
call	GetMemE
mov	fs, ax
mov	si, bx
mov	ax, getpmemtype
mov	ah, 0
xor	ecx, ecx
mov	cx, getpxsize
mov	dx, getpysize

loopdo:
call	CopyMem
add	si, 320
add	edi, ecx
dec	dx
jnz	loopdo
add	sp, getpstackspace
pop	bp
pop7	fs, si, edi, ax, bx, ecx, dx
retf
GetPart ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; PutPart	INTERNAL FUNCTION
;
; Purpose:
;   Put a part to the graphics page
;
; Usage:
;   ah=src type, fs:si=src offset, bx=max xsz, cx=max ysz, dx=x, di=y
;   Data in memory as follows
;   D[GetPutID], D[Total Size], W[Xsize], W[Ysize], B[Data]
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC PutPart
PutPart PROC
;Internally used constants
;......................................................................
	putpstackspace	equ	30
	putpmemtype	equ	[bp]
	putpx1		equ	[bp+18]
	putpy1		equ	[bp+20]
	putpxcount	equ	[bp+6]
	putpycount	equ	[bp+8]
	putpxsize		equ	[bp+10]
	putpysize		equ	[bp+12]
	putpxstart	equ	[bp+14]
	putpystart	equ	[bp+16]
	putpdatatype	equ	[bp+2]
	putpdatasize0	equ	[bp+6]
	putpdatasize1	equ	[bp+8]
	putpdatastart	equ	2
	putpdatasizetotal	equ	12
	putpxsizedw	equ	bp+22
	putpxstartdw	equ	bp+26
;......................................................................
push7	esi, es, edi, ax, ebx, ecx, dx
push	bp
sub	sp, putpstackspace
mov	bp, sp
mov	putpmemtype, ax
mov	WORD PTR putpxstart, 0
mov	WORD PTR putpystart, 0
cmp	bx, BoundaryX1
jge	ppx1isok01
mov	ax, BoundaryX1
sub	ax, bx
mov	putpxstart, ax

ppx1isok01:
cmp	cx, BoundaryY1
jge	ppy1isok01
mov	ax, BoundaryY1
sub	ax, cx
mov	putpystart, ax

ppy1isok01:
mov	putpx1, bx
mov	putpy1, cx
mov	di, ss
mov	es, di
mov	di, bp
add	di, putpdatastart
mov	ax, putpmemtype
mov	al, 0
mov	cx, putpdatasizetotal
call	CopyMem
cmp	DWORD PTR putpdatatype, datatypegetput
jne	getputover
mov	ax, putpxsize
sub	ax, putpxstart
mov	putpxcount, ax
mov	ax, putpysize
sub	ax, putpystart
mov	putpycount, ax
mov	ax, putpx1
add	ax, putpxsize
dec	ax
cmp	ax, BoundaryX2
jle	ppx2isok01
sub	ax, BoundaryX2
sub	putpxcount, ax

ppx2isok01:
mov	ax, putpy1
add	ax, putpysize
dec	ax
cmp	ax, BoundaryY2
jle	ppy2isok01
sub	ax, BoundaryY2
sub	putpycount, ax

ppy2isok01:
mov	ax, putpx1
add	ax, putpxstart
mov	putpx1, ax
mov	ax, putpy1
add	ax, putpystart
mov	putpy1, ax
add	esi, putpdatasizetotal
mov	ax, putpysize
mov	bx, putpycount
mul	bx
mov	stack2, esi
add	stack2, ax
adc	stack4, dx
mov	esi, stack2
GetPixelAddress		putpx1, putpy1
mov	ax, GraphicsPage
call	GetMemE
mov	es, ax
xor	ecx, ecx
mov	cx, putpxcount
mov	dx, putpycount
mov	di, bx
mov	ax, putpxsize
mov	[putpxsizedw], ax
mov	ax, putpxstart
mov	[putpxstartdw], ax
xor	ax, ax
mov	[putpxsizedw+2], ax
mov	[putpxstartdw+2], ax
mov	ax, putpmemtype
mov	al, 0

loopdo:
mov	ebx, esi
add	esi, [putpxstartdw]
call	CopyMem
mov	esi, ebx
add	esi, [putpxsizedw]
add	di, 320
dec	dx
jnz	loopdo

over1:
add	sp, putpstackspace
pop	bp
pop7	esi, es, edi, ax, ebx, ecx, dx
retf

getputover:
mov	LastError, errgetputdata
jmp	over1
PutPart ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; SavePage	INTERNAL FUNCTION
;
; Purpose:
;   Save the graphics page to a file
;   Similar to BSAVE
;
; Usage:
;   al=des type, es:di=offset where to save graphics page
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC SavePage
SavePage PROC
push4	fs, esi, ax, cx
mov	esi, 64000
push	esi
mov	esi, datatypegraphicspage
push	esi
xor	esi, esi
mov	si, ss
mov	fs, si
mov	si, sp
mov	cx, 8
mov	ah, 0
call	CopyMem
pop	esi
pop	esi
mov	fs, GraphicsPage
mov	esi, 0
add	edi, 8
mov	ah, 1
mov	cx, 64000
call	CopyMem
sub	edi, 8
pop4	fs, esi, ax, cx
retf
SavePage ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; LoadPage	INTERNAL FUNCTION
;
; Purpose:
;   Load the graphics page from a file
;   Similar to BLOAD
;
; Usage:
;   ah=src type, fs:si=offset where to load graphics page
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC LoadPage
LoadPage PROC
push4	es, edi, ax, cx
sub	sp, 8
mov	di, ss
mov	es, di
mov	di, sp
mov	cx, 8
mov	al, 0
call	CopyMem
pop	edi
cmp	edi, datatypegraphicspage
pop	edi
jne	notgraphicspage
cmp	edi, 64000
jne	notgraphicspage
mov	es, GraphicsPage
mov	di, 0
add	esi, 8
mov	al, 1
mov	cx, 64000
call	CopyMem
sub	esi, 8

over0:
pop4	es, edi, ax, cx
retf

notgraphicspage:
mov	LastError, errnotgraphicspage
jmp	over0
LoadPage ENDP




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




; -----------------------------------------------------------------------------------------------------------------------------
; HZDcopyGraphicsPage	SUB
;
; Purpose:
;   Copy a graphics page to another
;
; Declaration:
;   DECLARE SUB HZDcopyGraphicsPage(BYVAL srcpage%, BYVAL despage%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDcopyGraphicsPage
HZDcopyGraphicsPage PROC
UseParam
push4	fs, si, es, di
mov	ax, param2
and	ax, 3
add	ax, VideoSEG
mov	fs, ax
mov	ax, param1
and	ax, 3
add	ax, VideoSEG
mov	es, ax
xor	si, si
xor	di, di
mov	cx, 64000
call	CopyMemEE
pop4	fs, si, es, di
EndParam
retf	4
HZDcopyGraphicsPage ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDcopyGraphicsPageTrans	SUB
;
; Purpose:
;   Copy a graphics page to another transparently(copy all colours except 0)
;
; Declaration:
;   DECLARE SUB HZDcopyGraphicsPageTrans(BYVAL srcpage%, BYVAL despage%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDcopyGraphicsPageTrans
HZDcopyGraphicsPageTrans PROC
UseParam
push4	fs, si, es, di
mov	ax, param2
and	ax, 3
add	ax, VideoSEG
mov	param2, ax
mov	ax, param1
and	ax, 3
add	ax, VideoSEG
mov	param1, ax
cld
xor	bx, bx
mov	dx, 64000

copyallbytes01:
mov	fs, param2
mov	ax, @DATA
mov	es, ax
mov	si, bx
mov	di, OFFSET FreeConv
mov	cx, 256
call	CopyMemEC
mov	ax, param1
call	GetMemE
mov	es, ax
mov	si, 0
mov	cx, 256

copy256bytes01:
mov	al, FreeConv[si]
or	al, al
jz	dontcopy01
mov	es:[bx+si], al

dontcopy01:
inc	si
dec	cx
jnz	copy256bytes01
add	bx, 256
sub	dx, 256
jnz	copyallbytes01
pop4	fs, si, es, di
EndParam
retf	4
HZDcopyGraphicsPageTrans ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDsetRefreshRate	SUB
;
; Purpose:
;   Set the refresh rate. This does not change the actual refresh
;   rate of the monitor, but changes it in a psuedo way.
;   The only supported refresh rates are 60HZ, 30HZ, 20Hz.
;   Default is 30Hz.
;
; Declaration:
;   DECLARE SUB HZDsetRefreshRate(BYVAL rate%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDsetRefreshRate
HZDsetRefreshRate PROC
UseParam
mov	al, param1
call	SetRefreshRate
EndParam
retf	2
HZDsetRefreshRate ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDsetGraphicsRange	SUB
;
; Purpose:
;   Set the graphics range [(x1,y1)-(x2,y2)]
;
; Declaration:
;   DECLARE SUB HZDsetGraphicsRange(BYVAL x1%, BYVAL y1%, BYVAL x2%,
;				    BYVAL y2%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDsetGraphicsRange
HZDsetGraphicsRange PROC
UseParam
RearrangeXY		param4, param3, param2, param1
BringWithinDefault	param4, param3, param2, param1
mov	ax, param4
mov	BoundaryX1, ax
mov	ax, param3
mov	BoundaryY1, ax
mov	ax, param2
mov	BoundaryX2, ax
mov	ax, param1
mov	BoundaryY2, ax
EndParam
retf	8
HZDsetGraphicsRange ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDpset	SUB
;
; Purpose:
;   Draw a pixel(similar to PSET)
;
; Declaration:
;   DECLARE SUB HZDpset(BYVAL x%, BYVAL y%, BYVAL colour%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDpset
HZDpset PROC
UseParam
IsBoundaryWithin	param3, param2, nopset
mov	ax, GraphicsPage
call	GetMemE
mov	es, ax
GetPixelAddress		param3, param2
mov	al, param1
mov	es:[bx], al

nopset:
EndParam
retf	6
HZDpset ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDpoint	FUNCTION
;
; Purpose:
;   Get the colour of a pixel(similar to POINT)
;
; Declaration:
;   DECLARE FUNCTION HZDpoint%(BYVAL x%, BYVAL y%)
;
; Returns:
;   colour of pixel
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDpoint
HZDpoint PROC
UseParam
IsBoundaryWithin	param2, param1, nopoint
mov	ax, GraphicsPage
call	GetMemE
mov	es, ax
GetPixelAddress		param3, param2
mov	al, param1
mov	al, es:[bx]
xor	ah, ah

over:
EndParam
retf	4

nopoint:
mov	ax, -1
jmp	over
HZDpoint ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDdisplayGraphics	SUB
;
; Purpose:
;   Displays the graphics at a particular frequency
;
; Declaration:
;   DECLARE SUB HZDdisplayGraphics()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDdisplayGraphics
HZDdisplayGraphics PROC
call	DisplayGraphics
retf
HZDdisplayGraphics ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDclearPage		SUB
;
; Purpose:
;   Clears a particular page(similar to CLS)
;   This clears the whole page regardless of the boundary set
;
; Declaration:
;   DECLARE SUB HZDclearPage()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDclearPage
HZDclearPage PROC
call	ClearPage
retf
HZDclearPage ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDtakeScreenshot		SUB
;
; Purpose:
;   Take screenshot of the display page to a file
;
; Declaration:
;   DECLARE SUB HZDtakeScreenshot(BYVAL destype%, BYVAL desSEG%,
;				  BYVAL desOFF&, BYVAL xpixsize%,
;				  BYVAL ypixsize%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDtakeScreenshot
HZDtakeScreenshot PROC
UseParam
push	edi
mov	al, param6
mov	es, param5
mov	edi, param3
mov	bh, param2
mov	bl, param1
call	TakeScreenshot
pop	edi
EndParam
retf	12
HZDtakeScreenshot ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDsavePage			SUB
;
; Purpose:
;   Save the graphics page to a file (Similar to BSAVE)
;
; Declaration:
;   DECLARE SUB HZDsavePage(BYVAL destype%, BYVAL desSEG%, BYVAL desOFF&)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDsavePage
HZDsavePage PROC
UseParam
push	edi
mov	al, param4
mov	es, param3
mov	edi, param1
call	SavePage
pop	edi
EndParam
retf	8
HZDsavePage ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDloadPage			SUB
;
; Purpose:
;   Load the graphics page from a file (Similar to BLOAD)
;
; Declaration:
;   DECLARE SUB HZDloadPage(BYVAL srctype%, BYVAL srcSEG%, BYVAL srcOFF&)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDloadPage
HZDloadPage PROC
UseParam
push2	fs, esi
mov	ah, param4
mov	fs, param3
mov	esi, param1
call	LoadPage
pop2	fs, esi
EndParam
retf	8
HZDloadPage ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetPart			SUB
;
; Purpose:
;   Get a part of the graphics page
;
; Declaration:
;   DECLARE SUB HZDgetPart(BYVAL destype%, BYVAL desSEG%, BYVAL desOFF&,
;			   BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetPart
HZDgetPart PROC
UseParam
push2	si, edi
RearrangeXY	param4, param3, param2, param1
mov	al, param8
mov	es, param7
mov	edi, param5
mov	bx, param4
mov	cx, param3
mov	dx, param2
mov	si, param1
call	GetPart
pop2	si, edi
EndParam
retf	16
HZDgetPart ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDputPart			SUB
;
; Purpose:
;   Put a part to the graphics page
;
; Declaration:
;   DECLARE SUB HZDputPart(BYVAL srctype%, BYVAL srcSEG%, BYVAL srcOFF&,
;			   BYVAL x%, BYVAL y%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDputPart
HZDputPart PROC
UseParam
push3	fs, esi, di
mov	ah, param6
mov	fs, param5
mov	esi, param3
mov	bx, param2
mov	cx, param1
call	PutPart
pop3	fs, esi, di
EndParam
retf	12
HZDputPart ENDP
















END



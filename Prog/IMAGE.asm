;--------------------------------------------------------------------------------
;			IMAGE MACHINE
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




;
;=====================GLOBAL IMAGE FORMAT=====================
;
;[Size of image]			DWORD
;[X resolution]				WORD
;[Y resolution]				WORD
;[Palette int/ext]			BYTE
;[Offset to palette/palette number]	DWORD
;[Offset to image]			DWORD
;???					??
;[Raw Image data]			BYTE x Size
;
;
;=====================GLOBAL IMAGE FORMAT=====================
;








.MODEL Large, Basic

.386

INCLUDE	Includes.inc


;SHARED





.STACK 200h

EXTRN	LastError:WORD




;CONST
verticalretraceport			equ	3DAh




.DATA
ImageProcessing			DW	OFFSET imgprcsmode4, SEG imgprcsmode4, OFFSET imgprcsmode5, SEG imgprcsmode5
				DW	OFFSET imgprcsmode6, SEG imgprcsmode6, OFFSET imgprcsmode7, SEG imgprcsmode7



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
; StartImage	INTERNAL FUNCTION
;
; Purpose:
;   Starts the image machine(load general PICs)
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StartImage
StartImage PROC
push	ax
mov	ax, 13h
int	10h
pop	ax
retf
StartImage ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; StopImage	INTERNAL FUNCTION
;
; Purpose:
;   Stops the graphics machine
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StopImage
StopImage PROC
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
retf
StopImage ENDP




;   0=normal, 1=clipped, 2=colour normal, 3=colour clipped, 4=add normal
;   5=flipped, 6=rotated, 7=sized
;   ah:fs:si=image address, bh=perform on image, bl=image mode, cx=control value
;   0=normal, 1=clipped, 2=colour normal, 3=colour clipped, 4=add normal
;   5=flipped, 6=rotated, 7=sized

; -----------------------------------------------------------------------------------------------------------------------------
; DisplayImage	INTERNAL FUNCTION
;
; Purpose:
;   Displays an Image from memory
;
; Usage:
;   ah:fs:si=image address, bl=image mode, bh=add control, ecx=size control(lo)-rotation control(hi)
;   dx=xposition, di=yposition
;   bit0=clipped(1), bit1=add(1), bit2=sized(1), bit3=rotated(1)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC DisplayImage
DisplayImage PROC
;Internally used constants
;......................................................................
	dimgstackspace	equ	36
	dimgmemtype	equ	[bp]
	dimgx		equ	[bp+18]
	dimgy		equ	[bp+20]
	dimgimgmode	equ	[bp+22]
	dimgaddctrl	equ	[bp+23]
	dimgsizectrl	equ	[bp+24]
	dimgrotatectrl	equ	[bp+26]
	dimgxsizedw	equ	bp+28
	dimgxstartdw	equ	bp+32
	dimgimgtype	equ	[bp+2]
	dimgimgsize	equ	[bp+6]
	dimgpaladdr	equ	[bp+10]
	dimgxsize		equ	[bp+14]
	dimgysize		equ	[bp+16]
	dimgxstart	equ	[bp+2]
	dimgystart	equ	[bp+4]
	dimgxcount	equ	[bp+6]
	dimgycount	equ	[bp+8]
	dimgdatastart	equ	2
	dimgdatasizetotal	equ	16
;......................................................................
push7	fs, si, edi, ax, bx, ecx, dx
push	bp
sub	sp, dimgstackspace
mov	bp, sp
mov	dimgmemtype, ax
mov	dimgimgmode, bl
mov	dimgaddctrl, bh
mov	dimgsizectrl, ecx
mov	dimgx, dx
mov	dimgy, di
mov	di, ss
mov	es, di
mov	di, bp
mov	di, dimgdatastart
mov	al, 0
mov	cx, dimgdatasizetotal
call	CopyMem
cmp	dimgimgtype, datatypenormalimage
jne	dispimgover
mov	bl, dimgimgmode
xor	bh, bh
shl	bx, 2
jmp	ImageDisplayControl[bx]

imagedisplayover:
mov	ecx, imgpaladdr
mov	stack2, ecx
mov	ax, stack2
mov	dx, stack4

over09:
add	sp, dimgstackspace
pop	bp
pop7	esi, es, edi, ax, ebx, ecx, dx
retf

getputover:
mov	LastError, errdatatypewrong
xor	ax, ax
xor	dx, dx
jmp	over09


;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                   IMAGE MODES
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;
; MODE 00
; NORMAL IMAGE MODE
; (NO CLIPPING)
imagemode00:
mov	bx, dimgx
mov	cx, dimgy
mov	WORD PTR dimgxstart, 0
mov	WORD PTR dimgystart, 0
cmp	bx, BoundaryX1
jge	dix1isok01
mov	ax, BoundaryX1
sub	ax, bx
mov	dimgxstart, ax

dix1isok01:
cmp	cx, BoundaryY1
jge	diy1isok01
mov	ax, BoundaryY1
sub	ax, cx
mov	dimgystart, ax

diy1isok01:
mov	ax, dimgxsize
sub	ax, dimgxstart
mov	dimgxcount, ax
mov	ax, dimgysize
sub	ax, dimgystart
mov	dimgycount, ax
mov	ax, dimgx
add	ax, dimgxsize
dec	ax
cmp	ax, BoundaryX2
jle	dix2isok01
sub	ax, BoundaryX2
sub	dimgxcount, ax

dix2isok01:
mov	ax, dimgy
add	ax, dimgysize
dec	ax
cmp	ax, BoundaryY2
jle	diy2isok01
sub	ax, BoundaryY2
sub	dimgycount, ax

diy2isok01:
mov	ax, dimgx
add	ax, dimgxstart
mov	dimgx, ax
mov	ax, dimgy
add	ax, dimgystart
mov	dimgy, ax
add	esi, dimgdatasizetotal
mov	ax, dimgysize
mov	bx, dimgycount
mul	bx
mov	stack2, esi
add	stack2, ax
adc	stack4, dx
mov	esi, stack2
GetPixelAddress		dimgx, dimgy
mov	ax, GraphicsPage
call	GetMemE
mov	es, ax
xor	ecx, ecx
mov	cx, dimgxcount
mov	dx, dimgycount
mov	di, bx
mov	ax, dimgxsize
mov	[dimgxsizedw], ax
mov	ax, dimgxstart
mov	[dimgxstartdw], ax
xor	ax, ax
mov	[dimgxsizedw+2], ax
mov	[dimgxstartdw+2], ax
mov	ax, dimgmemtype
mov	al, 0

loopdo:
mov	ebx, esi
add	esi, [dimgxstartdw]
call	CopyMem
mov	esi, ebx
add	esi, [dimgxsizedw]
add	di, 320
dec	dx
jnz	loopdo
jmp	imagedisplayover
DisplayImage ENDP









; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------


; -----------------------------------------------------------------------------------------------------------------------------
; HZDdisplayImage		FUNCTION
;
; Purpose:
;   Displays an image and returns offset to palette datapack
;
; Declaration:
;   DECLARE FUNCTION HZDdisplayImage&(BYVAL srcTYPE%, BYVAL srcSEG%, BYVAL srcOFF&, BYVAL imgX%, BYVAL imgY%,
;				      BYVAL imgMode%, BYVAL addCtrl%, BYVAL sizeCtrl%, BYVAL rotateCtrl%)
;
; Usage:
;   imgModes:	bit0=clipped(1), bit1=add(1), bit2=sized(1), bit3=rotated(1)
;   addCtrl:	Colour to be added to all colours(-1) except 0
;   sizeCtrl:	Size of image(default size 1.0 is used as 1000)
;   rotateCtrl:	Rotaion of image ->0 ^90 <-180, etc.(360 degree written as 36000)
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDdisplayImage
HZDdisplayImage PROC
UseParam
push4	fs, esi, di, ecx
mov	ah, param10
mov	fs, param9
mov	esi, param7
mov	dx, param6
mov	di, param5
mov	bl, param4
mov	bh, param3
mov	cx, param1
shl	ecx, 16
mov	cx, param2
call	DisplayImage'
push4	fs, esi, di, ecx
EndParam
retf	20
HZDdisplayImage ENDP











END

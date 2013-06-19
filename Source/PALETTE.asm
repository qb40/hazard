;--------------------------------------------------------------------------------
;			PALETTE MACHINE
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
PUBLIC	UsrPaletteOFF




.STACK 200h

EXTRN	LastError:WORD
EXTRN	EMSseg:WORD
EXTRN	VideoTask:BYTE
EXTRN	LibReadHandle:WORD
EXTRN	LibSaveHandle:WORD
EXTRN	PaletteSEG:WORD




;CONST
setpaletteport	equ	3C8h
getpaletteport	equ	3C7h
palettecolours	equ	256
palettesize	equ	3*palettecolours
nowpaletteOFF	equ	0
defbrightness	equ	0 ;32 for QB
defcontrast	equ	32





.DATA
UsrPaletteOFF	DW	1*palettesize
Brightness		DB	defbrightness
Contrast		DB	defcontrast




;External SUBS
EXTRN	CopyMemEE:FAR
EXTRN	CopyMemCF:FAR
EXTRN	CopyMemFE:FAR
EXTRN	GetMemE:FAR
EXTRN	CopyMem:FAR



.CODE

; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------



; -----------------------------------------------------------------------------------------------------------------------------
; LoadDefPalette	INTERNAL FUNCTION
;
; Purpose:
;   Loads the default to the given palette location.
;
; Usage:
;   ax=palette location(1-15)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC LoadDefPalette
LoadDefPalette PROC
push8	fs, si, es, di, ax, bx, ecx, dx
mov	bx, palettesize
mul	bx
mov	fs, LibReadHandle
mov	esi, defpaletteADRS
mov	es, PaletteSEG
mov	di, ax
mov	ecx, palettesize
call	CopyMemFE
pop8	fs, si, es, di, ax, bx, ecx, dx
retf
LoadDefPalette ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; ActivatePalette	INTERNAL FUNCTION
;
; Purpose:
;   Activates the current palette during vertical retrace period.
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC ActivatePalette
ActivatePalette PROC
push5	ds, si, ax, bx, dx
mov	ax, PaletteSEG
call	GetMemE
mov	ds, ax
mov	si, nowpaletteOFF
xor	bx, bx
cld

actclrs:
mov	dx, setpaletteport
mov	al, bl
out	dx, al
inc	dx
lodsw
out	dx, al
mov	al, ah
out	dx, al
lodsb
out	dx, al
inc	bx
cmp	bx, palettecolours
jb	actclrs
pop5	ds, si, ax, bx, dx
retf
ActivatePalette	ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; SelectPalette	INTERNAL FUNCTION
;
; Purpose:
;   Select a palette from the available palettes.
;   It does not set the brightness/contrast automatically.
;   These can be applied by calling CreateNowPalette()
;
; Usage:
;   ax=palette location(1-15)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC SelectPalette
SelectPalette PROC
push8	fs, si, es, di, ax, bx, ecx, dx
mov	bx, palettesize
mul	bx
mov	fs, PaletteSEG
mov	si, ax
mov	UsrPaletteOFF, ax
mov	es, PaletteSEG
mov	di, nowpaletteOFF
mov	ecx, palettesize
call	CopyMemEE
or	VideoTask, 1		;VideoTask = b1-draw screen, b0-activate palette
pop8	fs, si, es, di, ax, bx, ecx, dx
retf
SelectPalette	ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; StartPalette	INTERNAL FUNCTION
;
; Purpose:
;   Starts the palette machine. It saves old palette and loads the
;   default palette.
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StartPalette
StartPalette PROC
push5	es, di, ax, bx, dx
mov	UsrPaletteOFF, 768
mov	Brightness, defbrightness
mov	Contrast, defcontrast
mov	ax, PaletteSEG
call	GetMemE
mov	es, ax
mov	di, 768
xor	bx, bx
cld

actclrs:
mov	dx, getpaletteport
mov	al, bl
out	dx, al
inc	dx
inc	dx
in	al, dx
stosb
in	al, dx
stosb
in	al, dx
stosb
cmp	bx, palettecolours
jb	actclrs
mov	fs, EMSseg
mov	si, nowpaletteOFF
mov	es, LibSaveHandle
mov	edi, oldpaletteADRS
mov	ecx, palettesize
call	CopyMemCF
mov	ax, 1
call	LoadDefPalette
call	SelectPalette
xor	VideoTask, 1
call	ActivatePalette
pop5	es, di, ax, bx, dx
retf
StartPalette ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; CreateNowPalette	INTERNAL FUNCTION
;
; Purpose:
;   Create the palette to be activated from the set palette.
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CreateNowPalette
CreateNowPalette PROC
push6	ds, si, es, di, ax, bx
push	cx
mov	ax, PaletteSEG
call	GetMemE
mov	ds, ax
mov	si, UsrPaletteOFF
mov	es, ax
mov	di, nowpaletteOFF
xor	ax, ax
mov	cx, palettesize

createnowpal:
lodsb
sub	al, 32
mov	bl, Contrast
imul	bl
shr	ax, 5
add	ax, 32
add	al, Brightness
cmp	ax, 0
jge	clrok1
mov	ax, 0

clrok1:
cmp	ax, 63
jle	clrok2
mov	al, 63

clrok2:
stosb
dec	cx
jnz	createnowpal
or	VideoTask, 1
pop	cx
pop6	ds, si, es, di, ax, bx
retf
CreateNowPalette ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; LoadPalette	INTERNAL FUNCTION
;
; Purpose:
;   Load a palette from CONV/EMS/XMS/FILE in a palette location.
;
; Usage:
;   ax=palette location(1-15), bl=srctype, fs:esi=srcaddress
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC LoadPalette
LoadPalette PROC
push5	es, di, ax, ecx, dx
mov	cx, palettesize
mul	cx
mov	es, PaletteSEG
mov	di, ax
mov	ah, bl
mov	al, 1
mov	ecx, palettesize
call	CopyMem
pop5	es, di, ax, ecx, dx
retf
LoadPalette	ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; StopPalette	INTERNAL FUNCTION
;
; Purpose:
;   Stops the palette machine. It reloads the old palette.
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StopPalette
StopPalette PROC
push4	fs, esi, ax, bx
mov	ax, 1
mov	bl, 3
mov	fs, LibSaveHandle
mov	esi, oldpaletteADRS
call	LoadPalette
call	SelectPalette
xor	VideoTask, 1
call	ActivatePalette
pop4	fs, esi, ax, bx
retf
StopPalette ENDP






; -----------------------------------------------------------------------------------------------------------------------------
;		MACROS
; -----------------------------------------------------------------------------------------------------------------------------
Check1to15	MACRO	data, notok
cmp	data, 1
jb	notok
cmp	data, 15
ja	notok
ENDM


Badboy		MACRO	notok
mov	LastError, errwrongpalettelocation
jmp	notok
ENDM







; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------


; -----------------------------------------------------------------------------------------------------------------------------
; HZDloadDefPalette	SUB
;
; Purpose:
;   Load the default palette to a particular palette location(1-15).
;
; Declaration:
;   DECLARE SUB HZDloadDefPalette(BYVAL location%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDloadDefPalette
HZDloadDefPalette PROC
UseParam
mov	ax, param1
Check1to15	ax, bad
call	LoadDefPalette

over:
EndParam
retf	2

bad:
Badboy	over
HZDloadDefPalette ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDloadPalette	SUB
;
; Purpose:
;   Load a new palette to a particular palette loaction.
;
; Declaration:
;   DECLARE SUB HZDloadPalette(BYVAL loaction%, BYVAL srctype%, BYVAL srcSeg%,
;			       BYVAL srcOff&)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDloadPalette
HZDloadPalette PROC
UseParam
mov	ax, param5
Check1to15	ax, bad
push2	fs, esi
mov	bl, param4
mov	fs, param3
mov	esi, param1
call	LoadPalette
pop2	fs, esi

over:
EndParam
retf	10

bad:
Badboy	over	
HZDloadPalette ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; HZDselectPalette	SUB
;
; Purpose:
;   Select a palette from the available palettes.
;   It does not set the brightness/contrast automatically.
;   These can be applied by calling HZDapplyPalette()
;
; Declaration:
;   DECLARE SUB HZDselectPalette(BYVAL loaction%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDselectPalette
HZDselectPalette PROC
UseParam
mov	ax, param1
Check1to15	ax, bad
call	SelectPalette

over:
EndParam
retf	2

bad:
Badboy	over
HZDselectPalette	ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDapplyPalette	SUB
;
; Purpose:
;   Applies the brightness/contrast to the palette.
;
; Declaration:
;   DECLARE SUB HZDapplyPalette()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDapplyPalette
HZDapplyPalette PROC
call	CreateNowPalette
retf
HZDapplyPalette	ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; HZDsetBrightness	SUB
;
; Purpose:
;   Set brightness.
;
; Declaration:
;   DECLARE SUB HZDsetBrightness(BYVAL brightness%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDsetBrightness
HZDsetBrightness PROC
UseParam
mov	ax, param1
cmp	ax, 0
jge	brlowok
mov	ax, 0

brlowok:
cmp	ax, 63
jle	brhighok
mov	ax, 63

brhighok:
sub	ax, 32
mov	Brightness, al
call	CreateNowPalette
EndParam
retf	2
HZDsetBrightness ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDsetContrast	SUB
;
; Purpose:
;   Set contrast.
;
; Declaration:
;   DECLARE SUB HZDsetContrast(BYVAL contrast%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDsetContrast
HZDsetContrast PROC
UseParam
mov	ax, param1
cmp	ax, 0
jge	brlowok
mov	ax, 0

brlowok:
cmp	ax, 63
jle	brhighok
mov	ax, 63

brhighok:
mov	Contrast, al
call	CreateNowPalette
EndParam
retf	2
HZDsetContrast ENDP




END

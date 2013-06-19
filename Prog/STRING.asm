;--------------------------------------------------------------------------------
;			STRING MACHINE
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
EXTRN	RoughSEG:WORD
EXTRN	FreeConv:BYTE




;CONST
qbstringmaxsize		equ	256




.DATA
StringLength		DW	0





;External SUBS
EXTRN	CopyMem:FAR




.CODE


; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------




; -----------------------------------------------------------------------------------------------------------------------------
; CompareStringsCC		INTERNAL FUNCTION
;
; Purpose:
;   Compare two strings(both in CONV)
;
; Usage:
;   fs:si=string1, es:di=string2
;
; Returns:
;   ax=0 if equal, ax=-1 if not equal
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CompareStringsCC
CompareStringsCC PROC
push5	ds, si, di, cx, dx
mov	ax, fs
mov	ds, ax
mov	dx, fs:[si]
cmp	dx, es:[di]
jne	notequal
mov	cx, dx
shr	cx, 2
repe	cmpsd
jne	notequal
mov	cx, dx
and	cx, 3
repe	cmpsb
jne	notequal
xor	ax, ax

over0:
pop5	ds, si, di, cx, dx
retf

notequal:
mov	ax, -1
jmp	over0
CompareStringsCC ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; AscizToLasciz		INTERNAL FUNCTION
;
; Purpose:
;   Convert an ASCIZ string to LASCIZ string
;
; Usage:
;   fs:si=string address in CONV(must be >=2)
;
; Returns:
;   fs:si=converted string(si=si-2)
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC AscizToLasciz
AscizToLasciz PROC
push2	ax, cx
push2	ds, si
mov	ax, fs
mov	ds, ax
xor	cx, cx
cld

readnext01:
lodsb
or	al, al
jz	over66
inc	cx
jmp	readnext01

over66:
pop2	ds, si
sub	si, 2
mov	[si], cx
pop2	ax, cx
retf
AscizToLasciz ENDP





; -----------------------------------------------------------------------------------------------------------------------------
;CopyString	INTERNAL FUNCTION
;
; Purpose:
;   Copy string from ALL to ALL.
;
; Usage:
;   fs:si=source, es:di=dest, ah=srctype, al=desttype
;   0-CONV, 1-EMS, 2-XMS, 3-FILE
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyString
CopyString PROC
push	cx
push3	ax, es, edi
mov	di, SEG StringLength
mov	es, di
mov	edi, OFFSET StringLength
mov	cx, 2
xor	al, al
call	CopyMem
mov	cx, es:[di]
add	cx, 3
pop3	ax, es, edi
call	CopyMem
pop	cx
retf
CopyString ENDP




; -----------------------------------------------------------------------------------------------------------------------------
;PutStringAny	INTERNAL FUNCTION
;
; Purpose:
;   Put a QBasic string to general string
;
; Usage:
;   bx=NEAR offset to QBasic string, es:edi=des string, al=des type
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC PutStringAny
PutStringAny PROC
push6	ax, cx, fs, si, es, edi
mov	cx, ds
mov	fs, cx
mov	si, bx
mov	cx, 2
mov	ah, 0
call	CopyMem
mov	cx, [bx]
mov	si, [bx+2]
add	edi, 2
or	cx, cx
jz	stringtoosmall0
call	CopyMem

stringtoosmall0:
push	cx
xor	ecx, ecx
pop	cx
add	edi, ecx
xor	cx, cx
push	cx
mov	si, ss
mov	fs, si
mov	si, sp
mov	cx, 1
call	CopyMem
pop	cx
pop6	ax, cx, fs, si, es, edi
retf
PutStringAny ENDP



; -----------------------------------------------------------------------------------------------------------------------------
;PutStringRough	INTERNAL FUNCTION
;
; Purpose:
;   Put a QBasic string to general string in RoughSEG[2]
;
; Usage:
;   ax=NEAR offset to QBasic string
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC PutStringRough
PutStringRough PROC
push4	ax, bx, es, edi
mov	bx, ax
mov	al, 1
mov	es, RoughSEG[2]
mov	edi, roughOFF
call	PutStringAny
pop4	ax, bx, es, edi
retf
PutStringRough ENDP






; -----------------------------------------------------------------------------------------------------------------------------
;StringToQBany	INTERNAL FUNCTION
;
; Purpose:
;   Puts a string from ANY to QBasic string
;
; Usage:
;   fs:esi=string, ah=src type
;
; Returns:
;   ax=NEAR offset to string
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StringToQBany
StringToQBany PROC
push3	cx, es, di
sub	sp, 2
mov	di, ss
mov	es, di
mov	di, sp
mov	al, 0
mov	cx, 2
call	CopyMem
pop	cx
cmp	cx, qbstringmaxsize
ja	stringtoolarge
add	esi, 2
mov	di, @DATA
mov	es, di
mov	di, OFFSET FreeConv
add	di, 4
or	cx, cx
jz	stringtoosmall
call	CopyMem

stringtoosmall:
sub	esi, 2
mov	WORD PTR FreeConv, cx
mov	WORD PTR FreeConv[2], di
mov	ax, OFFSET FreeConv

over469:
pop3	cx, es, di
retf

stringtoolarge:
mov	LastError, errstringtoolarge
mov	ax, 0
jmp	over469
StringToQBany ENDP





; -----------------------------------------------------------------------------------------------------------------------------
;StringToQBrough	INTERNAL FUNCTION
;
; Purpose:
;   Puts a string from RoughSEG[2] to QBasic string
;
; Usage:
;   none
;
; Returns:
;   ax=NEAR offset to QB string
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StringToQBrough
StringToQBrough PROC
pop2	fs, si
mov	fs, RoughSEG[2]
mov	si, roughOFF
mov	ah, 1
call	StringToQBany
pop2	fs, si
retf
StringToQBrough ENDP




















; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------





; -----------------------------------------------------------------------------------------------------------------------------
; HZDcompareStrings	FUNCTION
;
; Purpose:
;   Compare two strings(both in CONV)
;
; Declaration:
;   DECLARE FUNCTION HZDcompareStrings%(BYVAL srcSEG%, BYVAL srcOFF%,
;				        BYVAL desSEG%, BYVAL desOFF%)
;
; Returns:
;   true if equal, false if not equal
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDcompareStrings
HZDcompareStrings PROC
UseParam
push4	fs, si, es, di
mov	fs, param4
mov	si, param3
mov	es, param2
mov	di, param1
call	CompareStringsCC
not	ax
pop4	fs, si, es, di
EndParam
retf	8
HZDcompareStrings ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDcopyString	SUB
;
; Purpose:
;   Copy CONV/EMS/XMS/FILE string to CONV/EMS/XMS/FILE string.
;   0-CONV, 1-EMS, 2-XMS, 3-FILE
;
; Declaration:
;   DECLARE SUB HZDcopyString(BYVAL srctype%, BYVAL srcSeg%, BYVAL srcOff&,
;			      BYVAL desttype%, BYVAL destSeg%, BYVAL destOff&)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDcopyString
HZDcopyString PROC
UseParam
push4	fs, esi, es, edi
mov	ah, param8
mov	fs, param7
mov	esi, param5
mov	al, param4
mov	es, param3
mov	edi, param1
call	CopyString
pop4	fs, esi, es, edi
EndParam
retf	16
HZDcopyString ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetString	FUNCTION
;
; Purpose:
;   Get string from CONV/EMS/XMS/FILE.
;   0-CONV, 1-EMS, 2-XMS, 3-FILE
;
; Declaration:
;   DECLARE FUNCTION HZDgetString$(BYVAL srctype%, BYVAL srcSeg%, BYVAL srcOff&)
;
; Returns:
;   The string
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetString
HZDgetString PROC
UseParam
push2	fs, esi
mov	ah, param4
mov	fs, param3
mov	esi, param1
call	StringToQBany
pop2	fs, esi
EndParam
retf	8
HZDgetString ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; HZDputString	SUB
;
; Purpose:
;   Put string to CONV/EMS/XMS/FILE.
;   0-CONV, 1-EMS, 2-XMS, 3-FILE
;
; Declaration:
;   DECLARE SUB HZDputString(String1$, BYVAL destype%, BYVAL desSeg%,
;			     BYVAL desOff&)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDputString
HZDputString PROC
UseParam
push4	fs, si, es, edi
mov	ax, param5
call	PutStringRough
mov	fs, RoughSEG[2]
mov	si, roughOFF
mov	es, param3
mov	edi, param1
mov	ah, 1
mov	al, param4
call	CopyString
pop4	fs, si, es, edi
EndParam
retf	10
HZDputString ENDP




END

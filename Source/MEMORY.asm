;--------------------------------------------------------------------------------
;			MEMORY MACHINE
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
PUBLIC	EMSseg, EMSpage, FreeConv





.STACK 200h



;External Variables
EXTRN	LastError:WORD
EXTRN	XMSuseSEG:WORD
EXTRN	FILEuseSEG:WORD
EXTRN	RoughSEG:WORD






;CONST
emsint			equ	67h
emstag			equ	emsint*4
emsamount		equ	255
xmsamount		equ	255
roughOFF			equ	0




.DATA
EMMid		DB	'EMMXXXX0'
EMShandle	DW	0
EMSpage		DW	0
EMSseg		DW	0
MEMusage	DB	18 DUP(0)
XMSdriver	DD	0
XMShandle	DW	0
GetMemPage	DW	0
MEMCOPYmapping	DW	OFFSET CopyMemCC, SEG CopyMemCC, OFFSET CopyMemCE, SEG CopyMemCE
		DW	OFFSET CopyMemCX, SEG CopyMemCX, OFFSET CopyMemCF, SEG CopyMemCF
		DW	OFFSET CopyMemEC, SEG CopyMemEC, OFFSET CopyMemEE, SEG CopyMemEE
		DW	OFFSET CopyMemEX, SEG CopyMemEX, OFFSET CopyMemEF, SEG CopyMemEF
		DW	OFFSET CopyMemXC, SEG CopyMemXC, OFFSET CopyMemXE, SEG CopyMemXE
		DW	OFFSET CopyMemXX, SEG CopyMemXX, OFFSET CopyMemXF, SEG CopyMemXF
		DW	OFFSET CopyMemFC, SEG CopyMemFC, OFFSET CopyMemFE, SEG CopyMemFE
		DW	OFFSET CopyMemFX, SEG CopyMemFX, OFFSET CopyMemFF, SEG CopyMemFF
MEMGETmapping	DW	OFFSET getover,   SEG getover,   OFFSET GetMemE,   SEG GetMemE
		DW	OFFSET GetMemX,   SEG GetMemX,   OFFSET GetMemF,   SEG GetMemF
FreeConv		DB	260 DUP(0)		;256+4




;External SUBS
EXTRN	GetFileHandle:FAR
EXTRN	SeekFile:FAR
EXTRN	ReadFile:FAR
EXTRN	WriteFile:FAR






.CODE

; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------



; -----------------------------------------------------------------------------------------------------------------------------
; StartMem	INTERNAL FUNCTION
;
; Purpose:
;   Start Memory facility.
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StartMem
StartMem PROC
push4	ax, bx, cx, edx
push3	es, si, di
mov	ah, 35h
mov	al, 67h
int	21h
mov	di, 0Ah
mov	si, OFFSET EMMid
mov	cx, 8
cld
repe	cmpsb
jne	noems
xor	bx, bx
mov	ah, 42h
int	67h
cmp	bx, emsamount
jb	lowems

stilltryems:
mov	ah, 43h
mov	bx, emsamount
int	67h
or	ah, ah
jnz	noems
mov	EMShandle, dx
mov	ah, 41h
int	67h
or	ah, ah
jnz	noems
mov	EMSseg, bx

tryxms:
mov	ax, 4300h
int	2Fh
cmp	al, 80h
jne	noxms
mov	ax, 4310h
int	2Fh
mov	WORD PTR XMSdriver, bx
mov	WORD PTR XMSdriver[2], es
mov	ah, 8h			;free xms memory
call	DWORD PTR XMSdriver
mov	edx, xmsamount
mov	ah, 9h
call	DWORD PTR XMSdriver
or	ax, ax
jnz	lowxms

stilltryxms:
mov	XMShandle, dx

memstarte:
pop3	es, si, di
pop4	ax, bx, cx, edx
retf

noems:
mov	LastError, errnoems
jmp	tryxms

lowems:
mov	LastError, errlowems
jmp	stilltryems

noxms:
mov	LastError, errnoxms
jmp	memstarte

lowxms:
mov	LastError, errlowxms
jmp	stilltryxms
StartMem ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; StopMem	INTERNAL FUNCTION
;
; Purpose:
;   Stop Memory facility.
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StopMem
StopMem PROC
push2	ax, dx
mov	ah, 45h
mov	dx, EMShandle
int	67h
mov	ah, 0Ah
mov	dx, XMShandle
call	DWORD PTR XMSdriver
pop2	ax, dx
retf
StopMem	ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; GetMemE	INTERNAL FUNCTION
;
; Purpose:
;   Get an EMS page.
;
; Usage:
;   ax=EMS page
;
; Returns:
;   ax=CONV page
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetMemE
GetMemE PROC
cmp	ax, EMSpage
je	mapped
push2	bx, dx
mov	EMSpage, ax
shl	ax, 2
mov	dx, EMShandle
mov	bx, ax
xor	al, al

mappagefull0:
mov	ah, 44h
int	67h
inc	al
inc	bx
cmp	al, 4
jb	mappagefull0
pop2	bx, dx

mapped:
mov	ax, EMSseg
retf
GetMemE	ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; CopyMemCC	INTERNAL FUNCTION
;
; Purpose:
;   Copy from CONV to CONV.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemCC
CopyMemCC PROC
push4	ds, si, di, bx, cx
mov	bx, fs
mov	ds, bx
or	cx, cx
jz	full65536
mov	bx, cx
shr	cx, 2

ok:
cld
rep	movsd
mov	cx, bx
and	cx, 3
rep	movsb
pop4	ds, si, di, bx, cx
retf

full65536:
mov	bx, cx
mov	cx, 65536/4
jmp	ok
CopyMemCC ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; CopyMemCE	INTERNAL FUNCTION
;
; Purpose:
;   Copy from CONV to EMS.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemCE
CopyMemCE PROC
push2	ax, si
mov	WORD PTR MEMusage, cx
mov	WORD PTR MEMusage[2], 0
or	cx, cx
jnz	ok
mov	WORD PTR MEMusage[2], 1

ok:
mov	BYTE PTR MEMusage[4], 0
mov	ax, EMShandle
mov	WORD PTR MEMusage[5], ax
mov	WORD PTR MEMusage[7], si
mov	WORD PTR MEMusage[9], fs
mov	BYTE PTR MEMusage[11], 1
mov	WORD PTR MEMusage[12], ax
mov	WORD PTR MEMusage[14], di
mov	ax, es
shl	ax, 2
mov	WORD PTR MEMusage[16], ax
mov	si, OFFSET MEMusage
mov	ax, 5700h
int	67h
pop2	ax, si
retf
CopyMemCE ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; CopyMemCX	INTERNAL FUNCTION
;
; Purpose:
;   Copy from CONV to XMS.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemCX
CopyMemCX PROC
push2	ax, si
mov	WORD PTR MEMusage, cx
mov	WORD PTR MEMusage[4], 0
or	cx, cx
jnz	ok
mov	WORD PTR MEMusage[4], 1

ok:
mov	WORD PTR MEMusage[6], si
mov	WORD PTR MEMusage[8], fs
mov	ax, XMShandle
mov	WORD PTR MEMusage[10], ax
mov	WORD PTR MEMusage[12], di
mov	WORD PTR MEMusage[14], es
mov	ah, 0Bh
mov	si, OFFSET MEMusage
call	DWORD PTR XMSdriver
pop2	ax, si
retf
CopyMemCX ENDP



; -----------------------------------------------------------------------------------------------------------------------------
;CopyMemCF	INTERNAL FUNCTION
;
; Purpose:
;   Copy from CONV to FILE.
;
; Usage:
;   fs:esi=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemCF
CopyMemCF PROC
push4	ax, bx, cx, si
mov	ax, es
xor	bl, bl
push	ecx
mov	ecx, edi
call	SeekFile
pop	ecx
or	cx, cx
jz	fullcopy
call	WriteFile

over48:
pop4	ax, bx, cx, si
retf

fullcopy:
mov	cx, 32768
call	WriteFile
add	si, 32768
call	WriteFile
jmp	over48
CopyMemCF ENDP



; -----------------------------------------------------------------------------------------------------------------------------
;CopyMemEC	INTERNAL FUNCTION
;
; Purpose:
;   Copy from EMS to CONV.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemEC
CopyMemEC PROC
push2	ax, si
mov	WORD PTR MEMusage, cx
mov	WORD PTR MEMusage[2], 0
or	cx, cx
jnz	ok
mov	WORD PTR MEMusage[2], 1

ok:
mov	BYTE PTR MEMusage[4], 1
mov	ax, EMShandle
mov	WORD PTR MEMusage[5], ax
mov	WORD PTR MEMusage[7], si
mov	ax, fs
shl	ax, 2
mov	WORD PTR MEMusage[9], ax
mov	BYTE PTR MEMusage[11], 0
mov	ax, EMShandle
mov	WORD PTR MEMusage[12], ax
mov	WORD PTR MEMusage[14], di
mov	WORD PTR MEMusage[16], es
mov	si, OFFSET MEMusage
mov	ax, 5700h
int	67h
pop2	ax, si
retf
CopyMemEC ENDP



; -----------------------------------------------------------------------------------------------------------------------------
;CopyMemEE	INTERNAL FUNCTION
;
; Purpose:
;   Copy from EMS to EMS.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemEE
CopyMemEE PROC
push2	ax, si
mov	WORD PTR MEMusage, cx
mov	WORD PTR MEMusage[2], 0
or	cx, cx
jnz	ok
mov	WORD PTR MEMusage[2], 1

ok:
mov	BYTE PTR MEMusage[4], 1
mov	ax, EMShandle
mov	WORD PTR MEMusage[5], ax
mov	WORD PTR MEMusage[7], si
mov	ax, fs
shl	ax, 2
mov	WORD PTR MEMusage[9], ax
mov	BYTE PTR MEMusage[11], 1
mov	ax, EMShandle
mov	WORD PTR MEMusage[12], ax
mov	WORD PTR MEMusage[14], di
mov	ax, es
shl	ax, 2
mov	WORD PTR MEMusage[16], ax
mov	si, OFFSET MEMusage
mov	ax, 5700h
int	67h
pop2	ax, si
retf
CopyMemEE ENDP




; -----------------------------------------------------------------------------------------------------------------------------
;CopyMemEX	INTERNAL FUNCTION
;
; Purpose:
;   Copy from EMS to XMS.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemEX
CopyMemEX PROC
push3	ax, bx, si
mov	ax, EMSpage
push	ax
mov	ax, fs
call	GetMemE
mov	fs, ax
mov	WORD PTR MEMusage, cx
mov	WORD PTR MEMusage[2], 0
or	cx, cx
jnz	ok
mov	WORD PTR MEMusage[2], 1

ok:
mov	WORD PTR MEMusage[4], 0
mov	WORD PTR MEMusage[6], si
mov	WORD PTR MEMusage[8], fs
mov	ax, XMShandle
mov	WORD PTR MEMusage[10], ax
mov	WORD PTR MEMusage[12], di
mov	WORD PTR MEMusage[14], es
mov	ah, 0Bh
mov	si, OFFSET MEMusage
call	DWORD PTR XMSdriver
pop	ax
call	GetMemE
pop3	ax, bx, si
retf
CopyMemEX ENDP



; -----------------------------------------------------------------------------------------------------------------------------
;CopyMemEF	INTERNAL FUNCTION
;
; Purpose:
;   Copy from EMS to FILE.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemEF
CopyMemEF PROC
push2	fs, ax
mov	ax, EMSpage
mov	ax, fs
call	GetMemE
mov	fs, ax
call	CopyMemCF
pop	ax
call	GetMemE
pop2	fs, ax
retf
CopyMemEF ENDP




; -----------------------------------------------------------------------------------------------------------------------------
;CopyMemXC	INTERNAL FUNCTION
;
; Purpose:
;   Copy from XMS to CONV.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemXC
CopyMemXC PROC
push2	ax, si
mov	WORD PTR MEMusage, cx
mov	WORD PTR MEMusage[2], 0
or	cx, cx
jnz	ok
mov	WORD PTR MEMusage[2], 1

ok:
mov	ax, XMShandle
mov	WORD PTR MEMusage[4], ax
mov	WORD PTR MEMusage[6], si
mov	WORD PTR MEMusage[8], fs
mov	WORD PTR MEMusage[10], 0
mov	WORD PTR MEMusage[12], di
mov	WORD PTR MEMusage[14], es
mov	ah, 0Bh
mov	si, OFFSET MEMusage
call	DWORD PTR XMSdriver
pop2	ax, si
retf
CopyMemXC ENDP



; -----------------------------------------------------------------------------------------------------------------------------
;CopyMemXE	INTERNAL FUNCTION
;
; Purpose:
;   Copy from XMS to CONV.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemXE
CopyMemXE PROC
push3	ax, bx, si
mov	ax, EMSpage
push	ax
mov	ax, es
call	GetMemE
mov	es, ax
mov	WORD PTR MEMusage, cx
mov	WORD PTR MEMusage[2], 0
or	cx, cx
jnz	ok
mov	WORD PTR MEMusage[2], 1

ok:
mov	ax, XMShandle
mov	WORD PTR MEMusage[4], ax
mov	WORD PTR MEMusage[6], si
mov	WORD PTR MEMusage[8], fs
mov	WORD PTR MEMusage[10], 0
mov	WORD PTR MEMusage[12], di
mov	WORD PTR MEMusage[14], es
mov	ah, 0Bh
mov	si, OFFSET MEMusage
call	DWORD PTR XMSdriver
pop	ax
call	GetMemE
pop3	ax, bx, si
retf
CopyMemXE ENDP



; -----------------------------------------------------------------------------------------------------------------------------
;CopyMemXX	INTERNAL FUNCTION
;
; Purpose:
;   Copy from XMS to XMS.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemXX
CopyMemXX PROC
push2	ax, si
mov	WORD PTR MEMusage, cx
mov	WORD PTR MEMusage[2], 0
or	cx, cx
jnz	ok
mov	WORD PTR MEMusage[2], 1

ok:
mov	ax, XMShandle
mov	WORD PTR MEMusage[4], ax
mov	WORD PTR MEMusage[6], si
mov	WORD PTR MEMusage[8], fs
mov	WORD PTR MEMusage[10], 0
mov	WORD PTR MEMusage[12], di
mov	WORD PTR MEMusage[14], es
mov	ah, 0Bh
mov	si, OFFSET MEMusage
call	DWORD PTR XMSdriver
pop2	ax, si
retf
CopyMemXX ENDP



; -----------------------------------------------------------------------------------------------------------------------------
;CopyMemXF	INTERNAL FUNCTION
;
; Purpose:
;   Copy from XMS to FILE.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemXF
CopyMemXF PROC
push3	fs, si, ax
mov	ax, EMSpage
push	ax
mov	ax, XMSuseSEG
call	GetMemE
push2	es, di
mov	es, ax
mov	di, 0
call	CopyMemXC
mov	fs, ax
mov	si, di
pop2	es, di
call	CopyMemCF
pop	ax
call	GetMemE
pop3	fs, si, ax
retf
CopyMemXF ENDP


; -----------------------------------------------------------------------------------------------------------------------------
;CopyMemFC	INTERNAL FUNCTION
;
; Purpose:
;   Copy from FILE to CONV.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemFC
CopyMemFC PROC
push4	ax, bx, cx, si
mov	ax, fs
xor	bl, bl
push	ecx
mov	ecx, esi
call	SeekFile
pop	ecx
or	cx, cx
jz	fulltapmar
call	ReadFile

khatam:
pop4	ax, bx, cx, si
retf

fulltapmar:
mov	cx, 32768
call	ReadFile
add	di, 32768
call	ReadFile
jmp	khatam
CopyMemFC ENDP



; -----------------------------------------------------------------------------------------------------------------------------
;CopyMemFE	INTERNAL FUNCTION
;
; Purpose:
;   Copy from FILE to EMS.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemFE
CopyMemFE PROC
push2	es, ax
mov	ax, EMSpage
push	ax
mov	ax, es
call	GetMemE
mov	es, ax
call	CopyMemFC
pop	ax
call	GetMemE
pop2	es, ax
retf
CopyMemFE ENDP



; -----------------------------------------------------------------------------------------------------------------------------
;CopyMemFX	INTERNAL FUNCTION
;
; Purpose:
;   Copy from FILE to XMS.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemFX
CopyMemFX PROC
push3	fs, si, ax
mov	ax, EMSpage
push	ax
mov	ax, XMSuseSEG
call	GetMemE
push2	es, di
mov	es, ax
mov	di, 0
call	CopyMemFC
mov	fs, ax
mov	si, di
pop2	es, di
call	CopyMemCX
pop	ax
call	GetMemE
pop3	fs, si, ax
retf
CopyMemFX ENDP



; -----------------------------------------------------------------------------------------------------------------------------
;CopyMemFF	INTERNAL FUNCTION
;
; Purpose:
;   Copy from FILE to FILE.
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMemFF
CopyMemFF PROC
push3	fs, si, ax
mov	ax, EMSpage
push	ax
mov	ax, RoughSEG
call	GetMemE
push2	es, di
mov	es, ax
mov	di, 0
call	CopyMemFC
mov	fs, ax
mov	si, 0
pop2	es, di
call	CopyMemCF
pop	ax
call	GetMemE
pop3	fs, si, ax
retf
CopyMemFF ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; GetMemX	INTERNAL FUNCTION
;
; Purpose:
;   Get an XMS page.
;
; Usage:
;   ax=XMS page
;
; Returns:
;   ax=CONV page
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetMemX
GetMemX PROC
push5	fs, si, es, di, cx
mov	fs, ax
xor	si, si
mov	es, XMSuseSEG
xor	di, di
xor	cx, cx
call	CopyMemXE
mov	ax, EMSseg
pop5	fs, si, es, di, cx
retf
GetMemX	ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; GetMemF	INTERNAL FUNCTION
;
; Purpose:
;   Get a FILE page.
;
; Usage:
;   ax=FILE handle, ebx=FILE page
;
; Returns:
;   ax=CONV page
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetMemF
GetMemF PROC
push5	fs, esi, es, di, cx
mov	fs, ax
mov	esi, ebx
and	esi, 0FFFF0000h
mov	ax, FILEuseSEG
call	GetMemE
mov	es, ax
mov	di, 0
xor	cx, cx
call	CopyMemFC
pop5	fs, esi, es, di, cx
retf
GetMemF ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; GetMem		INTERNAL FUNCTION
;
; Purpose:
;   Get an ALL page.
;
; Usage:
;   ax=ALL page / ax=FILE handle, bx=FILE page(if file), cl=type
;
; Returns:
;   ax=CONV page
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetMem
GetMem PROC
push2	cx, si
and	cx, 3
mov	si, cx
shl	si, 2
call	DWORD PTR MEMGETmapping[si]
pop2	cx, si

getover:
retf
GetMem	ENDP




; -----------------------------------------------------------------------------------------------------------------------------
;CopyMem		INTERNAL FUNCTION
;
; Purpose:
;   Copy from ALL to ALL.
;
; Usage:
;   fs:si=source, es:di=dest, ah=srctype, al=desttype, cx=bytes
;   0-CONV, 1-EMS, 2-XMS, 3-FILE
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyMem
CopyMem	PROC
push2	ax, bx
shl	ah, 2
and	al, 3
or	al, ah
and	al, 0Fh
xor	bx, bx
mov	bl, al
shl	bx, 2
call	DWORD PTR MEMCOPYmapping[bx]
pop2	ax, bx
retf
CopyMem	ENDP






; -----------------------------------------------------------------------------------------------------------------------------
;CopyDataPack	INTERNAL FUNCTION
;
; Purpose:
;   Copy a data packet from source mem to destination mem
;
; Usage:
;   ah:fs:si=src mem, al:es:di=des mem
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CopyDataPack
CopyDataPack PROC
push3	ax, es, edi
push2	eax, eax
mov	di, ss
mov	es, di
mov	di, sp
mov	al, 0
mov	cx, 8
call	CopyMem
pop	edi
mov	cx, di
add	cx, 8
pop	edi
pop3	ax, es, edi
call	CopyMem
retf
CopyDataPack ENDP









; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------


; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetMemory	FUNCTION
;
; Purpose:
;   Get an CONV/EMS/XMS/FILE page.
;   0-CONV, 1-EMS, 2-XMS, 3-FILE
;
; Declaration:
;   DECLARE FUNCTION HZDgetMemory&(BYVAL type%, BYVAL Seg%, BYVAL Off&)
;
; Returns:
;   CONV address as a long datatype.
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetMemory
HZDgetMemory PROC
UseParam
push	ebx
mov	cl, param4
mov	ax, param3
mov	ebx, param1
mov	GetMemPage, ax
call	GetMem
pop	ebx
EndParam
xor	dx, dx
retf	8
HZDgetMemory ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDcopyMemory	SUB
;
; Purpose:
;   Copy CONV/EMS/XMS/FILE memory to CONV/EMS/XMS/FILE memory.
;   0-CONV, 1-EMS, 2-XMS, 3-FILE
;
; Declaration:
;   DECLARE SUB HZDcopyMemory(BYVAL srctype%, BYVAL srcSeg%, BYVAL srcOff&,
;			      BYVAL desttype%, BYVAL destSeg%, BYVAL destOff&
;			      BYVAL bytes&)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDcopyMemory
HZDcopyMemory PROC
UseParam
push4	fs, esi, es, edi
mov	ah, param10
mov	fs, param9
mov	esi, param7
mov	al, param6
mov	es, param5
mov	edi, param3
mov	cx, param1
call	CopyMem
pop4	fs, esi, es, edi
EndParam
retf	20
HZDcopyMemory ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDcopyDataPack	SUB
;
; Purpose:
;   Copy data packet from source memory to destination memory
;
; Declaration:
;   DECLARE SUB HZDcopyDataPack(BYVAL srctype%, BYVAL srcSeg%, BYVAL srcOff&,
;			      BYVAL desttype%, BYVAL destSeg%, BYVAL destOff&)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDcopyDataPack
HZDcopyDataPack PROC
UseParam
push4	fs, esi, es, edi
mov	ah, param8
mov	fs, param7
mov	esi, param5
mov	al, param4
mov	es, param3
mov	edi, param1
call	CopyDataPack
pop4	fs, esi, es, edi
EndParam
retf	16
HZDcopyDataPack ENDP



END

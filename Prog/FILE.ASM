;--------------------------------------------------------------------------------
;			FILE MACHINE
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
EXTRN	EMSseg:WORD
EXTRN	WindowsActive:BYTE
EXTRN	RoughSEG:WORD
EXTRN	XMSuseSEG:WORD
EXTRN	FreeConv:BYTE
EXTRN	LibReadHandle:WORD
EXTRN	LibSaveHandle:WORD
EXTRN	FileHandlesSEG:WORD





;CONST
halfseg			equ	32768





.DATA
testfile			DB	'a.txt',0





;External SUBS
EXTRN	GetMem:FAR
EXTRN	GetMemE:FAR
EXTRN	CopyMemCC:FAR
EXTRN	CopyString:FAR
EXTRN	PutStringRough:FAR





.CODE

; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------






; -----------------------------------------------------------------------------------------------------------------------------
; GetFileHandle	INTERNAL FUNCTION
;
; Purpose:
;   Get the file handle
;
; Usage:
;   al=filenum
;
; Returns:
;   ax=file handle
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetFileHandle
GetFileHandle PROC
push2	bx, ds
mov	bl, al
xor	bh, bh
shl	bx, 4
add	bx, filehandlesOFF
mov	ax, FileHandlesSeg
call	GetMemE
mov	ds, ax
mov	ax, [bx]
pop2	bx, ds
retf
GetFileHandle ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; GetFileHandleSP	INTERNAL FUNCTION
;
; Purpose:
;   Get the file handle along with other details
;
; Usage:
;   al=filenum
;
; Returns:
;   ax=file handle, es:bx=file handle area
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetFileHandleSP
GetFileHandleSP PROC
mov	bl, al
xor	bh, bh
shl	bx, 4
add	bx, filehandlesOFF
mov	ax, FileHandlesSeg
call	GetMemE
mov	es, ax
mov	ax, es:[bx]
retf
GetFileHandleSP ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; DeleteFile	INTERNAL FUNCTION
;
; Purpose:
;   Delete a file
;
; Usage:
;   fs:si=File name
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC DeleteFile
DeleteFile PROC
push4	ds, ax, cx, dx
mov	ax, fs
mov	ds, ax
mov	dx, si
mov	ah, 41h
xor	cl, cl
int	21h
jc	delfileerr

over49:
pop4	ds, ax, cx, dx
retf

delfileerr:
mov	LastError, errdeletefile
jmp	over49
DeleteFile ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; CreateFile	INTERNAL FUNCTION
;
; Purpose:
;   Create a file
;
; Usage:
;   fs:si=File name, cx=file attriutes
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CreateFile
CreateFile PROC
push3	ds, ax, dx
mov	ax, fs
mov	ds, ax
mov	dx, si
add	dx, 2
mov	ah, 3Ch
int	21h
jc	creafileerr

over50:
pop3	ds, ax, dx
retf

creafileerr:
mov	LastError, errcreatefile
jmp	over50
CreateFile ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; OpenFile	INTERNAL FUNCTION
;
; Purpose:
;   Opens an "existing" file
;   Long filenames may be supported
;
; Usage:
;   fs:si=File Name in CONV, bh=file number, bl=mode
;
; Returns:
;   ax=file handle
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC OpenFile
OpenFile PROC
push4	es, bx, cx, dx
mov	al, bh
call	GetFileHandle
or	ax, ax
jnz	numusederr
mov	ah, 3Dh
mov	al, bl
xor	cx, cx
push	ds
mov	dx, fs
mov	ds, dx
mov	dx, si
add	dx, 2
clc
int	21h
pop	ds
jc	fileopenerr
mov	dx, ax
mov	al, bh
call	GetFileHandleSP
mov	es:[bx], dx
mov	ax, dx

over:
pop4	es, bx, cx, dx
retf

fileopenerr:
mov	LastError, erropenfile
jmp	over

numusederr:
mov	LastError, errfilenumused
jmp	over
OpenFile ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; CloseFile	INTERNAL FUNCTION
;
; Purpose:
;   Closes a file(both special and non-special)
;
; Usage:
;   al=file number
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC CloseFile
CloseFile PROC
push3	ax, bx, es
call	GetFileHandleSP
or	ax, ax
jz	filenotopenerr
mov	DWORD PTR es:[bx], 0
mov	DWORD PTR es:[bx+4], 0
mov	bx, ax
mov	ah, 3Eh
int	21h
jc	filecloseerr

over1:
pop3	ax, bx, es
retf

filenotopenerr:
mov	LastError, errfilenumnotused
jmp	over1


filecloseerr:
mov	LastError, errclosefile
jmp	over1
CloseFile ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; FreeFile	INTERNAL FUNCTION
;
; Purpose:
;   Returns a free file number
;
; Usage:
;   nothing
;
; Returns:
;   al=file number, ax=-1 in case of no free file
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC FreeFile
FreeFile PROC
push2	bx, cx
mov	ax, FileHandlesSEG
call	GetMemE
push	ds
mov	ds, ax
mov	bx, filehandlesOFF
mov	cx, 256

findmore:
cmp	WORD PTR [bx], 0
je	hndlgot
add	bx, 16
dec	cx
jnz	findmore

pop	ds
mov	ax,-1
mov	LastError, errnofreefile
jmp	over2

hndlgot:
pop	ds
sub	bx, filehandlesOFF
shr	bx, 4
mov	al, bl
xor	ah, ah

over2:
pop2	bx, cx
retf
FreeFile ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; SeekFile	INTERNAL FUNCTION
;
; Purpose:
;   Seeks to a particular position in file
;
; Usage:
;   ax=file handle, bl=mode, ecx=file address
;
; Returns:
;   ecx=new address
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC SeekFile
SeekFile PROC
push3	ax, bx, dx
push	bp
sub	sp, 4
mov	bp, sp
mov	stack0, ecx
xchg	bx, ax
mov	ah, 42h
mov	cx, stack2
mov	dx, stack0
int	21h
mov	stack2, dx
mov	stack0, ax
mov	ecx, stack0
jc	fileseekerr

over3:
add	sp, 4
pop	bp
pop3	ax, bx, dx
retf

fileseekerr:
mov	LastError, errseekfile
jmp	over3
SeekFile ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; ReadFile	INTERNAL FUNCTION
;
; Purpose:
;   Reads data from file to CONV
;
; Usage:
;   ax=file handle, es:di=dest, cx=length
;
; Returns:
;   cx=amount actually read
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC ReadFile
ReadFile PROC
push3	ax, bx, dx
mov	bx, ax
mov	ax, es
push	ds
mov	ds, ax
mov	dx, di
mov	ah, 3Fh
int	21h
pop	ds
jc	filereaderr

over4:
pop3	ax, bx, dx
retf

filereaderr:
mov	LastError, errreadfile
jmp	over4
ReadFile ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; WriteFile	INTERNAL FUNCTION
;
; Purpose:
;   Writes data from CONV to file
;
; Usage:
;   ax=file handle, fs:si=src, cx=length
;
; Returns:
;   cx=amount actually written
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC WriteFile
WriteFile PROC
push3	ax, bx, dx
mov	bx, ax
mov	ax, fs
push	ds
mov	ds, ax
mov	dx, si
mov	ah, 40h
int	21h
pop	ds
jc	filewriteerr

over5:
pop3	ax, bx, dx
retf

filewriteerr:
mov	LastError, errwritefile
xor	cx, cx
jmp	over5
WriteFile ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; FileSize	INTERNAL FUNCTION
;
; Purpose:
;   Gets the size of a file
;
; Usage:
;   ax=file handle
;
; Returns:
;   ecx=file size
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC FileSize
FileSize PROC
push	bx
push	bp
sub	sp, 4
mov	bp, sp
mov	bl, 1
xor	ecx, ecx
call	SeekFile
mov	stack0, ecx
mov	bl, 2
xor	ecx, ecx
call	SeekFile
xor	bl, bl
xchg	stack0, ecx
call	SeekFile
mov	ecx, stack0
add	sp, 4
pop	bp
pop	bx
retf
FileSize ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; StartFile	INTERNAL FUNCTION
;
; Purpose:
;   Start File facility.
;
; Usage:
;   fs:si=LibRead file name, es:di=LibSave file name
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StartFile
StartFile PROC
push5	fs, si, ax, bx, cx
mov	bh, libreadnum
mov	bl, 00100000b
call	OpenFile
mov	LibReadHandle, ax
mov	ax, es
mov	fs, ax
mov	si, di
xor	cx, cx
call	CreateFile
mov	bh, libsavenum
mov	bl, 01000010b
call	OpenFile
mov	LibSaveHandle, ax
pop5	fs, si, ax, bx, cx
retf
StartFile ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; StopFile	INTERNAL FUNCTION
;
; Purpose:
;   Stop File facility.
;
; Usage:
;   fs:si=LibSave file name
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StopFile
StopFile PROC
push	ax
mov	al, libreadnum
call	CloseFile
mov	al, libsavenum
call	CloseFile
call	DeleteFile
pop	ax
StopFile ENDP








; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------


; -----------------------------------------------------------------------------------------------------------------------------
; HZDcreateFile	SUB
;
; Purpose:
;   Create a new file
;   Note that it is essential to create a "non-existing" file
;   before opening to write into it
;
; Declaration:
;   DECLARE SUB HZDcreateFile(file$, BYVAL fileattrib%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDcreateFile
HZDcreateFile PROC
UseParam
push2	fs, si
mov	ax, @DATA
mov	fs, ax
mov	bx, param2
mov	cx, [bx]
mov	bx, [bx+2]
mov	si, bx
sub	si, 2
add	bx, cx
mov	ax, [bx]
push2	ax, bx
mov	WORD PTR [bx],0
mov	cx, param1
call	CreateFile
pop2	ax, bx
mov	[bx], ax
pop2	fs, si
EndParam
retf	4
HZDcreateFile ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDopenFile	SUB
;
; Purpose:
;   Opens an "existing" file
;
; Declaration:
;   DECLARE SUB HZDopenFile(BYVAL filenum%, file$, BYVAL filemode%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDopenFile
HZDopenFile PROC
UseParam
push2	fs, si
mov	ax, @DATA
mov	fs, ax
mov	bx, param2
mov	cx, [bx]
mov	bx, [bx+2]
mov	si, bx
sub	si, 2
add	bx, cx
mov	ax, [bx]
push2	ax, bx
mov	WORD PTR [bx],0
mov	bh, param3
mov	bl, param1
call	OpenFile
pop2	ax, bx
mov	[bx], ax
pop2	fs, si
EndParam
retf	6
HZDopenFile ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDcloseFile	SUB
;
; Purpose:
;   Closes a specified file
;
; Declaration:
;   DECLARE SUB HZDcloseFile(BYVAL filenum%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDcloseFile
HZDcloseFile PROC
UseParam
mov	al, param1
call	CloseFile
EndParam
retf	2
HZDcloseFile ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDfreeFile	FUNCTION
;
; Purpose:
;   Returns a free file number
;
; Declaration:
;   DECLARE FUNCTION HZDfreeFile%()
;
; Returns:
;   free file number
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDfreeFile
HZDfreeFile PROC
call	FreeFile
retf
HZDfreeFile ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDseekFile	SUB
;
; Purpose:
;   Seeks to a particular position in file
;
; Declaration:
;   DECLARE SUB HZDseekFile(BYVAL filenum%, BYVAL position&)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDseekFile
HZDseekFile PROC
UseParam
push	ecx
mov	al, param3
call	GetFileHandle
or	ax, ax
jz	filenotopen
xor	bl, bl
mov	ecx, param1
call	SeekFile

over7:
pop	ecx
EndParam
retf	6

filenotopen:
mov	LastError, errfilenotopen
jmp	over7
HZDseekFile ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDreadFile	SUB
;
; Purpose:
;   Reads data from file to CONV
;
; Declaration:
;   DECLARE SUB HZDreadFile(BYVAL filenum%, BYVAL desSEG%, BYVAL desOFF%, 
;			    BYVAL length%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDreadFile
HZDreadFile PROC
UseParam
push	di
mov	al, param4
call	GetFileHandle
or	ax, ax
jz	filenotopen
mov	es, param3
mov	di, param2
mov	cx, param1
call	ReadFile

over8:
pop	di
EndParam
retf	8

filenotopen:
mov	LastError, errfilenotopen
jmp	over8
HZDreadFile ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDwriteFile	SUB
;
; Purpose:
;   Writes data from CONV to file
;
; Declaration:
;   DECLARE SUB HZDwriteFile(BYVAL filenum%, BYVAL srcSEG%, BYVAL srcOFF%, 
;			     BYVAL length%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDwriteFile
HZDwriteFile PROC
UseParam
push2	fs, si
mov	al, param4
call	GetFileHandle
or	ax, ax
jz	filenotopen
mov	fs, param3
mov	si, param2
mov	cx, param1
call	WriteFile

over9:
pop2	fs, si
EndParam
retf	8

filenotopen:
mov	LastError, errfilenotopen
jmp	over9
HZDwriteFile ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDfileSize	FUNCTION
;
; Purpose:
;   Gets the size of the file
;
; Declaration:
;   DECLARE FUNCTION HZDfileSize&(BYVAL filenum%)
;
; Returns:
;   file size
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDfileSize
HZDfileSize PROC
UseParam
mov	al, param1
call	GetFileHandle
or	ax, ax
jz	filenotopen
call	FileSize
sub	sp, 4
mov	bp, sp
mov	stack0, ecx
mov	dx, stack2
mov	ax, stack0
add	sp, 4

over0:
EndParam
retf	2

filenotopen:
mov	LastError, errfilenotopen
jmp	over0
HZDfileSize ENDP




END
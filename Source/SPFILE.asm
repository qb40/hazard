;--------------------------------------------------------------------------------
;			SPECIAL FILE MACHINE
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
EXTRN	RoughSEG:WORD
EXTRN	LibReadHandle:WORD
EXTRN	LibSaveHandle:WORD



;CONST
spfilenameOFF		equ	0
spfilehandledataOFF		equ	24
roughOFF			equ	0




.DATA
SPfileID			DB	'HZD file'
DataPackGet		DB	17 DUP(0)
DataTypeGet		DD	0




;External SUBS
EXTRN	PutStringRough:FAR
EXTRN	StringToQBrough:FAR
EXTRN	GetFileHandleSP:FAR
EXTRN	CloseFile:FAR
EXTRN	OpenFile:FAR
EXTRN	CopyString:FAR
EXTRN	CopyMemFC:FAR
EXTRN	GetMemE:FAR
EXTRN	CompareStringsCC:FAR
EXTRN	GetFileHandle:FAR
EXTRN	CreateFile:FAR
EXTRN	DeleteFile:FAR









;DETAILS

;DataPacketGet ------
;Byte 0:	DWORD	Offset to Name
;Byte 4:	DWORD	Offset to Data Packet Type, Type name
;Byte 8:	DWORD	Offset to Data Packet
;Byte 12:	DWORD	Data Packet size
;Byte 16:	BYTE	File Number






.CODE

; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------


; -----------------------------------------------------------------------------------------------------------------------------
; OpenSPfile	INTERNAL FUNCTION
;
; Purpose:
;   Open a special file
;
; Usage:
;   fs:si=File Name, bh=file number, bl=mode
;
; Returns:
;   ax=file handle
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC OpenSPfile
OpenSPfile PROC
push7	fs, esi, es, di, ds, bx, cx
call	OpenFile
mov	cx, ax
mov	al, bh
call	GetFileHandleSP
mov	fs, cx
mov	esi, spfilenameOFF
mov	di, bx
add	di, 2
mov	cx, 8
call	CopyMemFC
mov	ax, SEG SPfileID
push	ds
mov	ds, ax
mov	si, OFFSET SPfileID
repe	cmpsb
pop	ds
jne	notSPfile
mov	esi, spfilehandledataOFF
mov	cx, 12
call	CopyMemFC

over:
mov	ax, fs
pop7	fs, esi, es, di, ds, bx, cx
retf

notSPfile:
mov	al, bh
call	CloseFile
mov	LastError, errnotspfile
jmp	over
OpenSPfile	ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; GetDataPackNum	INTERNAL FUNCTION
;
; Purpose:
;   Gets the offset particular data packet when its number is given
;
; Usage:
;   al=filenum, cx=data packet number
;
; Returns:
;   ecx=offset to the data packet
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetDataPackNum
GetDataPackNum PROC
push6	ax, bx, fs, esi, es, di
mov	si, ax
call	GetFileHandleSP
mov	fs, ax
cmp	es:[bx+2], cx
jae	nopresentdata
mov	ax, si
mov	BYTE PTR DataPackGet[16], al
mov	ax, SEG DataPackGet
mov	es, ax
mov	di, OFFSET DataPackGet
xor	esi, esi
mov	si, cx
shl	esi, 4
add	esi, 4
mov	cx, 16
call	CopyMemFC
mov	ecx, DWORD PTR DataPackGet[8]

over1:
pop6	ax, bx, fs, esi, es, di
retf

nopresentdata:
mov	LastError, errdatapacknotavailable
xor	ecx, ecx
jmp	over1
GetDataPackNum ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; GetDataPackName	INTERNAL FUNCTION
;
; Purpose:
;   Get the name of the data pack that was got last
;
; Usage:
;   none
;
; Returns:
;   Name String in the RoughSEG[2]
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetDataPackName
GetDataPackName PROC
push5	ax, fs, esi, es, di
mov	al, BYTE PTR DataPackGet[16]
call	GetFileHandle
mov	fs, ax
mov	esi, DWORD PTR DataPackGet
mov	es, RoughSEG[2]
mov	di, roughOFF
mov	ax, 0301h
call	CopyString
pop5	ax, fs, esi, es, di
retf
GetDataPackName ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; GetDataPackType	INTERNAL FUNCTION
;
; Purpose:
;   Get the type number of the data pack that was got last
;
; Usage:
;   none
;
; Returns:
;   eax=type number
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetDataPackType
GetDataPackType PROC
push4	fs, esi, es, di
mov	al, BYTE PTR DataPackGet[16]
call	GetFileHandle
mov	fs, ax
mov	esi, DWORD PTR DataPackGet[4]
sub	sp, 4
mov	ax, ss
mov	es, ax
mov	di, sp
call	CopyMemFC
pop	eax
pop4	fs, esi, es, di
retf
GetDataPackType ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; GetDataPackTypeName	INTERNAL FUNCTION
;
; Purpose:
;   Get the type name of the data pack that was got last
;
; Usage:
;   none
;
; Returns:
;   Type String in the RoughSEG[2]
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetDataPackTypeName
GetDataPackTypeName PROC
push5	ax, fs, esi, es, di
mov	al, BYTE PTR DataPackGet[16]
call	GetFileHandle
mov	fs, ax
mov	esi, DWORD PTR DataPackGet[4]
add	esi, 4
sub	sp, 4
mov	ax, ss
mov	es, ax
mov	di, sp
call	CopyMemFC
pop	esi
mov	es, RoughSEG[2]
mov	di, roughOFF
mov	ax, 0301h
call	CopyString
pop5	ax, fs, esi, es, di
retf
GetDataPackTypeName ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; GetDataPackNumFromName	INTERNAL FUNCTION
;
; Purpose:
;   Gets the data packet number when its name is given
;
; Usage:
;   al=file number, Name in RoughSEG[2]
;
; Returns:
;   cx=data pack number, cx=-1 if not found
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetDataPackNumFromName
GetDataPackNumFromName PROC
push7	ax, bx, dx, fs, esi, es, di
mov	bx, ax
mov	ax, RoughSEG[2]
call	GetMemE
mov	es, ax
mov	di, es:[roughOFF]
add	di, 3
mov	al, bl
call	GetFileHandleSP
mov	fs, ax
mov	cx, es:[bx+2]
mov	dx, cx
mov	esi, es:[bx+4]
add	esi, 6

findagain:
mov	ax, 0300h
call	CopyString
call	CompareStringsCC
or	ax, ax
jz	findingover
add	esi, es:[di]
add	esi, 3
dec	dx
jnz	findagain

mov	cx, -1
mov	LastError, errdatapacknotavailable

over2:
pop7	ax, bx, dx, fs, esi, es, di
retf

findingover:
sub	cx, dx
dec	cx
jmp	over2
GetDataPackNumFromName ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; GetFileInfoCommonForQB	INTERNAL FUNCTION
;
; Purpose:
;   Gets the data packet number when its name is given
;
; Usage:
;   edx=??, undefined
;
; Returns:
;   QB string
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetFileInfoCommonForQB
GetFileInfoCommonForQB PROC
push3	fs, esi, di
mov	al, param1
call	GetFileHandle
mov	fs, ax
mov	esi, 8
mov	ax, RoughSEG[2]
call	GetMemE
mov	es, ax
mov	di, roughOFF
mov	cx, 4
call	CopyMemFC
mov	esi, es:[roughOFF]
add	esi, edx
call	CopyMemFC
mov	esi, es:[roughOFF]
call	CopyString
call	StringToQBrough
pop3	fs, esi, di
GetFileInfoCommonForQB ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; StartSPfile	INTERNAL FUNCTION
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
PUBLIC StartSPfile
StartSPfile PROC
push5	fs, si, ax, bx, cx
mov	bh, libreadnum
mov	bl, 00100000b
call	OpenSPfile
mov	LibReadHandle, ax
mov	ax, es
mov	fs, ax
mov	si, di
xor	cx, cx
call	CreateFile
mov	bh, libsavenum
mov	bl, 01000010b
call	OpenSPfile
mov	LibSaveHandle, ax
pop5	fs, si, ax, bx, cx
retf
StartSPfile ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; StopSPfile	INTERNAL FUNCTION
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
PUBLIC StopSPfile
StopSPfile PROC
push	ax
mov	al, libreadnum
call	CloseFile
mov	al, libsavenum
call	CloseFile
call	DeleteFile
pop	ax
StopSPfile	ENDP


















; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------


; -----------------------------------------------------------------------------------------------------------------------------
; HZDopenSPfile			SUB
;
; Purpose:
;   Opens an "existing" special file
;
; Declaration:
;   DECLARE SUB HZDopenSPfile(BYVAL filenum%, file$, BYVAL filemode%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDopenSPfile
HZDopenSPfile PROC
UseParam
push2	fs, si
mov	ax, param2
call	PutStringRough
mov	fs, EMSseg
mov	si, roughOFF
mov	bh, param3
mov	bl, param1
call	OpenFile
pop2	fs, si
EndParam
retf	6
HZDopenSPfile ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDcloseSPfile		SUB
;
; Purpose:
;   Closes a specified file
;
; Declaration:
;   DECLARE SUB HZDcloseSPfile(BYVAL filenum%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDcloseSPfile
HZDcloseSPfile PROC
UseParam
mov	al, param1
call	CloseFile
EndParam
retf	2
HZDcloseSPfile ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDnumDataPacks		FUNCTION
;
; Purpose:
;   Gives the number of data packets in a special file
;
; Declaration:
;   DECLARE FUNCTION HZDnumDataPacks%(BYVAL filenum%)
;
; Returns:
;   no. of data packs
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDnumDataPacks
HZDnumDataPacks PROC
UseParam
mov	al, param1
call	GetFileHandleSP
mov	ax, es:[bx+2]
EndParam
retf	2
HZDnumDataPacks ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetDataPackOff		FUNCTION
;
; Purpose:
;   Gets the offset to a particular data packet, and other related info
;   when its number is given
;
; Declaration:
;   DECLARE FUNCTION HZDgetDataPackOff&(BYVAL filenum%, BYVAL dataPackno%)
;
; Returns:
;   Offset to the data packet
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetDataPackOff
HZDgetDataPackOff PROC
UseParam
mov	al, param2
mov	cx, param1
call	GetDataPackNum
sub	sp, 4
mov	bx, sp
mov	ss:[bx], ecx
pop	ax
pop	dx
EndParam
retf	4
HZDgetDataPackOff ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetDataPackName		FUNCTION
;
; Purpose:
;   Gives the name of the currently got data pack using
;   HZDgetDataPackOff&()
;
; Declaration:
;   DECLARE FUNCTION HZDgetDataPackName$()
;
; Returns:
;   name of data pack
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetDataPackName
HZDgetDataPackName PROC
call	GetDataPackName
call	StringToQBrough
retf
HZDgetDataPackName ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetDataPackTypeNum		FUNCTION
;
; Purpose:
;   Gives the type number of the currently got data pack using
;   HZDgetDataPackOff&()
;
; Declaration:
;   DECLARE FUNCTION HZDgetDataPackTypeNum&()
;
; Returns:
;   type of data pack
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetDataPackTypeNum
HZDgetDataPackTypeNum PROC
call	GetDataPackType
push	eax
pop	ax
pop	dx
retf
HZDgetDataPackTypeNum ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetDataPackTypeName	FUNCTION
;
; Purpose:
;   Gives the type name of the currently got data pack using
;   HZDgetDataPackOff&()
;
; Declaration:
;   DECLARE FUNCTION HZDgetDataPackTypeNum&()
;
; Returns:
;   type name of data pack
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetDataPackTypeName
HZDgetDataPackTypeName PROC
call	GetDataPackTypeName
call	StringToQBrough
retf
HZDgetDataPackTypeName ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetDataPackNum		FUNCTION
;
; Purpose:
;   Gets the data pack number when name of the data pack is given
;
; Declaration:
;   DECLARE FUNCTION HZDgetDataPackNum%(BYVAL filenum%, String1$)
;
; Returns:
;   data packet number
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetDataPackNum
HZDgetDataPackNum PROC
UseParam
mov	ax, param1
call	PutStringRough
mov	al, param2
call	GetDataPackNumFromName
mov	ax, cx
EndParam
retf	4
HZDgetDataPackNum ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetSPfileName		FUNCTION
;
; Purpose:
;   Gets the name of file from file info
;
; Declaration:
;   DECLARE FUNCTION HZDgetSPfileName$(BYVAL filenum%)
;
; Returns:
;   data packet number
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetSPfileName
HZDgetSPfileName PROC
UseParam
push	edx
xor	edx, edx
call	GetFileInfoCommonForQB
pop	edx
EndParam
retf	2
HZDgetSPfileName ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetSPfileAuthor		FUNCTION
;
; Purpose:
;   Gets the author of file from file info
;
; Declaration:
;   DECLARE FUNCTION HZDgetSPfileAuthor$(BYVAL filenum%)
;
; Returns:
;   data packet number
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetSPfileAuthor
HZDgetSPfileAuthor PROC
UseParam
push	edx
mov	edx, 4
call	GetFileInfoCommonForQB
pop	edx
EndParam
retf	2
HZDgetSPfileAuthor ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetSPfilePackage		FUNCTION
;
; Purpose:
;   Gets the author of file from file info
;
; Declaration:
;   DECLARE FUNCTION HZDgetSPfilePackage$(BYVAL filenum%)
;
; Returns:
;   data packet number
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetSPfilePackage
HZDgetSPfilePackage PROC
UseParam
push	edx
mov	edx, 4
call	GetFileInfoCommonForQB
pop	edx
EndParam
retf	2
HZDgetSPfilePackage ENDP



END

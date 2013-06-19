;--------------------------------------------------------------------------------
;			DISK MACHINE
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
EXTRN	EMSseg:WORD
EXTRN	FindFileSEG:WORD



;CONST




.DATA



;External SUBS
EXTRN	GetMemE:FAR
EXTRN	AscizToLasciz:FAR
EXTRN	StringToQBrough:FAR
EXTRN	PutStringAny:FAR





.CODE












; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------







; -----------------------------------------------------------------------------------------------------------------------------
; ReturnFindFileData	INTERNAL FUNCTION
;
; Purpose:
;   Returns the find file data from memory to QB variable
;
; Usage:
;   bx=offset to QB variable, es=find file data(2OFF)
;
; Returns:
;   find file data
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC ReturnFindFileData
ReturnFindFileData PROC
push2	eax, cx
mov	eax, es:[findfileOFF+2+1Eh]
mov	[bx], eax
mov	eax, es:[findfileOFF+2+1Eh+4]
mov	[bx+4], eax
mov	eax, es:[findfileOFF+2+1Eh+8]
mov	[bx+8], eax
mov	al, [findfileOFF+2+1Eh+12]
mov	[bx+12], eax
mov	al, es:[findfileOFF+2+15h]
xor	ah, ah
mov	[bx+13], ax
mov	eax, es:[findfileOFF+2+1Ah]
mov	[bx+14], eax
mov	ax, es:[findfileOFF+2+16h]
mov	cx, ax
and	cx, 11111b
shl	cx, 1
mov	[bx+18], cx
mov	cx, ax
shr	cx, 5
and	cx, 111111b
mov	[bx+20], cx
shr	ax, 11
mov	[bx+22], ax
mov	ax, es:[findfileOFF+2+18h]
mov	cx, ax
and	cx, 11111b
mov	[bx+24], cx
mov	cx, ax
shr	cx, 5
and	cx, 1111b
mov	[bx+26], cx
shr	ax, 9
add	ax, 1980
mov	[bx+28], ax
mov	al, es:[findfileOFF+2+0]
add	al, 65
mov	ah, ':'
mov	[bx+30], ax
pop2	eax, cx
retf
ReturnFindFileData ENDP







; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------


; -----------------------------------------------------------------------------------------------------------------------------
; HZDnumFixedDrives	FUNCTION
;
; Purpose:
;   Gives the number of fixed drives(C:,D:,etc.)
;
; Declaration:
;   DECLARE FUNCTION HZDnumFixedDrives%()
;
; Returns:
;   number of fixed drives
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDnumFixedDrives
HZDnumFixedDrives PROC
mov	ax, 40h
mov	es, ax
mov	al, es:[75h]
xor	ah, ah
retf
HZDnumFixedDrives ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDcurrentDrive	SUB
;
; Purpose:
;   Gives the name of current drives(C:/D:/E:/,etc.)
;
; Declaration:
;   DECLARE SUB HZDcurrentDrive(driveletter AS HZDdrive)
;
; Returns:
;   driveletter.Letter=the current drive letter
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDcurrentDrive
HZDcurrentDrive PROC
UseParam
mov	ah, 19h
int	21h
add	al, 65
mov	ah, ':'
mov	bx, param1
mov	[bx], ax
EndParam
retf	2
HZDcurrentDrive ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDcurrentDirectory	FUNCTION
;
; Purpose:
;   Gives the current directory(address)
;
; Declaration:
;   DECLARE FUNCTION HZDcurrentDirectory$()
;
; Returns:
;   current drive name
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDcurrentDirectory
HZDcurrentDirectory PROC
push2	fs, si
mov	ax, RoughSEG[2]
call	GetMemE
push	ds
mov	ds, ax
mov	si, roughOFF+2
xor	dl, dl
mov	ah, 47h
int	21h
pop	ds
mov	fs, EMSseg
call	AscizToLasciz
call	StringToQBrough
pop2	fs, si
retf
HZDcurrentDirectory ENDP









; -----------------------------------------------------------------------------------------------------------------------------
; HZDfindFirst	SUB
;
; Purpose:
;   Start a search for files(and directories) in the current directory
;
; Declaration:
;   DECLARE SUB HZDfindFirst(search1 AS HZDfindDirectory, FileName$, BYVAL includes1%)
;
; Returns:
;   search1.ItsName=Name of file/directory
;   search1.Attribute=Attributes of file
;   search1.Size=Size of file
;   search1.TimeSecond=Time of file creation(s)
;   search1.TimeMinute=Time of file creation(m)
;   search1.TimeHour=Time of file creation(h)(24-hour)
;   search1.DateDay=Day of month creation(d)
;   search1.DateMonth=Month of month creation(m)
;   search1.DateYear=Year of month creation(y)
;   search1.Drive=Drive in which file is located
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDfindFirst
HZDfindFirst PROC
UseParam
push	edi
mov	bx, param2
mov	es, FindFileSEG
mov	edi, findfileOFF
mov	al, 1
call	PutStringAny
mov	ax, FindFileSEG
call	GetMemE
push	ds
mov	ds, ax
mov	dx, 2
mov	cx, param1
xor	al, al
mov	ah, 4Eh
int	21h
pop	ds
jc	goterr09
mov	bx, param3
mov	es, EMSseg
call	ReturnFindFileData

over56:
pop	edi
EndParam
retf	6

goterr09:
mov	LastError, errfindfile
jmp	over56
HZDfindFirst ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDfindNext	SUB
;
; Purpose:
;   Search for files[CONTINUE WITH OLD SEARCH](and directories) in the current directory
;
; Declaration:
;   DECLARE SUB HZDfindNext(search1 AS HZDfindDirectory)
;
; Returns:
;   search1.ItsName=Name of file/directory
;   search1.Attribute=Attributes of file
;   search1.Size=Size of file
;   search1.TimeSecond=Time of file creation(s)
;   search1.TimeMinute=Time of file creation(m)
;   search1.TimeHour=Time of file creation(h)(24-hour)
;   search1.DateDay=Day of month creation(d)
;   search1.DateMonth=Month of month creation(m)
;   search1.DateYear=Year of month creation(y)
;   search1.Drive=Drive in which file is located
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDfindNext
HZDfindNext PROC
UseParam
mov	ax, FindFileSEG
call	GetMemE
mov	ah, 4Fh
int	21h
jc	goterr02
mov	bx, param1
mov	es, EMSseg
call	ReturnFindFileData

over45:
EndParam
retf	2

goterr02:
mov	LastError, errfindfile
jmp	over45
HZDfindNext ENDP










END

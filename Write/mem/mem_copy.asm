;--------------------------------------------------------------------------------
;				MEMORY COPY
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







.MODEL Large, BASIC

.386

INCLUDE	Includes.inc




;SHARED




.STACK 200h



;External Variables
EXTRN	zErrorCode:WORD
EXTRN	zEMSsegment:WORD
EXTRN	zEMSpage:WORD
EXTRN	zEMShandle:WORD
EXTRN	zXMSdriver:DWORD
EXTRN	zXMShandle:WORD
EXTRN	zEMS_XMSseg:WORD
EXTRN	zEMS_FILEseg:WORD





;CONST




.DATA

zMEMCOPY_mapping	DW	OFFSET hCopyMemCC, SEG hCopyMemCC, OFFSET hCopyMemCE, SEG hCopyMemCE
			DW	OFFSET hCopyMemCX, SEG hCopyMemCX, OFFSET hCopyMemCF, SEG hCopyMemCF
			DW	OFFSET hCopyMemEC, SEG hCopyMemEC, OFFSET hCopyMemEE, SEG hCopyMemEE
			DW	OFFSET hCopyMemEX, SEG hCopyMemEX, OFFSET hCopyMemEF, SEG hCopyMemEF
			DW	OFFSET hCopyMemXC, SEG hCopyMemXC, OFFSET hCopyMemXE, SEG hCopyMemXE
			DW	OFFSET hCopyMemXX, SEG hCopyMemXX, OFFSET hCopyMemXF, SEG hCopyMemXF
			DW	OFFSET hCopyMemFC, SEG hCopyMemFC, OFFSET hCopyMemFE, SEG hCopyMemFE
			DW	OFFSET hCopyMemFX, SEG hCopyMemFX, OFFSET hCopyMemFF, SEG hCopyMemFF




;External SUBS
EXTRN	hGetMemEMS:FAR
EXTRN	hSeekFile:FAR
EXTRN	hReadFile:FAR
EXTRN	hWriteFile:FAR




;Include File for memory
INCLUDE		mem_incl.inc




.CODE









;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemCCx		INTERNAL FUNCTION
;
; Purpose:
;   Copy from CONV to CONV (using top-bottom approach only)(quick).
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes(=0 for full 64K)
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemCCx
hCopyMemCCx PROC
PUSH4	DS, SI, DI, BX, CX
MOV	BX, FS
MOV	DS, BX
OR	CX, CX
JZ	copymemccxfull
MOV	BX, BX
SHR	CX, 2

copymemccxok:
CLD
REP	MOVSD
MOV	CX, BX
AND	CX, 3
REP	MOVSB
POP4	DS, SI, DI, BX, CX
RETF

copymemccxfull:
MOV	BX, CX
MOV	CX, 65536/4
JMP	copymemccxok
hCopyMemCCx ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>










;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemCC		INTERNAL FUNCTION
;
; Purpose:
;   Copy from CONV to CONV (using EMM)(speed=?).
;
; Usage:
;   fs:si=source, es:di=dest, ecx=bytes
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemCC
hCopyMemCC PROC
PUSH4	AX, DS, SI, BP
SUB	SP, _emscopy_strucsize
MOV	BP, SP
MOVD	emscopy_numbytes, ECX
MOVB	emscopy_srctype, 0
MOV	AX, zEMShandle
MOVW	emscopy_srchandle, AX
MOVW	emscopy_srcoff, SI
MOVW	emscopy_srcseg, FS
MOVB	emscopy_destype, 0
MOVW	emscopy_deshandle, AX
MOVW	emscopy_desoff, DI
MOVW	emscopy_desseg, ES
MOV	SI, BP
MOV	AX, SS
MOV	DS, AX
Zero	AL
EMSfunction	_ems_move_or_exchange_memory_region
POP4	AX, DS, SI, BP
RETF
hCopyMemCC ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>










;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemCE		INTERNAL FUNCTION
;
; Purpose:
;   Copy from CONV to EMS (using EMM)(speed=?).
;
; Usage:
;   fs:si=source, es:di=dest, ecx=bytes
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemCE
hCopyMemCE PROC
PUSH4	AX, DS, SI, BP
SUB	SP, _emscopy_strucsize
MOV	BP, SP
MOVD	emscopy_numbytes, ECX
MOVB	emscopy_srctype, 0
MOV	AX, zEMShandle
MOVW	emscopy_srchandle, AX
MOVW	emscopy_srcoff, SI
MOVW	emscopy_srcseg, FS
MOVB	emscopy_destype, 1
MOVW	emscopy_deshandle, AX
MOVW	emscopy_desoff, DI
MOV	AX, ES
SHL	AX, 2
MOVW	emscopy_desseg, AX
MOV	SI, BP
MOV	AX, SS
MOV	DS, AX
Zero	AL
EMSfunction	_ems_move_or_exchange_memory_region
POP4	AX, DS, SI, BP
RETF
hCopyMemCE ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>










;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemCX		INTERNAL FUNCTION
;
; Purpose:
;   Copy from CONV to XMS (using XMM)(speed=?).
;
; Usage:
;   fs:si=source, es:di=dest, ecx=bytes
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemCX
hCopyMemCX PROC
PUSH4	AX, DS, SI, BP
SUB	SP, _xmscopy_strucsize
MOV	BP, SP
MOVD	xmscopy_numbytes, ECX
MOV	AX, zXMShandle
MOVW	emscopy_srchandle, 0
MOVW	emscopy_srcoff, SI
MOVW	emscopy_srcseg, FS
MOVW	emscopy_deshandle, AX
MOVW	emscopy_desoff, DI
MOVW	emscopy_desseg, ES		;shl ES, ??
MOV	SI, BP
MOV	AX, SS
MOV	DS, AX
MOV	AL, 0
XMSfunction	_xms_copy_memory_region
POP4	AX, DS, SI, BP
RETF
hCopyMemCX ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>











;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemCF		INTERNAL FUNCTION
;
; Purpose:
;   Copy from CONV to FILE.
;
; Usage:
;   fs:si=source, es:edi=dest, ecx=bytes
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemCF
hCopyMemCF PROC
PUSH5	FS, SI, AX, BX, ECX
;LOCAL.........
UseLocal	8
LOCAL_VAR	_1cpmemcfOldFileLoc, DWORD PTR stack0
LOCAL_VAR	_1cpmemcfNumBytes, DWORD PTR stack4
;LOCAL.........
MOV	_1cpmemcfNumBytes, ECX
MOV	AX, ES
Zero	BX
Zero	ECX
CALL	hSeekFile
CMP	ErrorCode, 0
JNZ	copymemcf02
MOV	_1cpmemcfOldFileLoc, ECX
MOV	ECX, EDI
CALL	hSeekFile
CMP	ErrorCode, 0
JNZ	copymemcf01
MOV	CX, SI
SHR	CX, 4
MOV	BX, FS
ADD	BX, CX
MOV	FS, BX
AND	SI, 0Fh
Zero	BX

copymemcf06:
MOV	ECX, 32768
CMP	_1cpmemcfNumBytes, 32768
JA	copymemcf05
MOV	ECX, _1cpmemNumBytes

copymemcf05:
CALL	hWriteFile
CMP	ErrorCode, 0
JNZ	copymemcf01
MOV	BX, FS
ADD	BX, 32768/4
MOV	FS, BX
Zero	BX
SUB	_1cpmemcfNumBytes, ECX
JNZ	copymemcf06

copymemcf01:
MOV	ECX, _1cpmemcfOldFileLoc
CALL	hSeekFile

copymemcf02:
EndLocal	8
POP5	FS, SI, AX, BX, ECX
RETF
hCopyMemCF ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>











;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemEC		INTERNAL FUNCTION
;
; Purpose:
;   Copy from EMS to CONV (using EMM)(speed=?).
;
; Usage:
;   fs:si=source, es:di=dest, ecx=bytes
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemEC
hCopyMemEC PROC
PUSH4	AX, DS, SI, BP
SUB	SP, _emscopy_strucsize
MOV	BP, SP
MOVD	emscopy_numbytes, ECX
MOVB	emscopy_srctype, 1
MOV	AX, zEMShandle
MOVW	emscopy_srchandle, AX
MOVW	emscopy_srcoff, SI
MOV	AX, FS
SHL	AX, 2
MOVW	emscopy_srcseg, AX
MOVB	emscopy_destype, 0
MOV	AX, zEMShandle
MOVW	emscopy_deshandle, AX
MOVW	emscopy_desoff, DI
MOVW	emscopy_desseg, ES
MOV	SI, BP
MOV	AX, SS
MOV	DS, AX
MOV	AL, 0
EMSfunction	_ems_move_or_exchange_memory_region
POP4	AX, DS, SI, BP
RETF
hCopyMemEC ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>











;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemEE		INTERNAL FUNCTION
;
; Purpose:
;   Copy from EMS to EMS (using EMM)(speed=?).
;
; Usage:
;   fs:si=source, es:di=dest, ecx=bytes
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemEE
hCopyMemEE PROC
PUSH4	AX, DS, SI, BP
SUB	SP, _emscopy_strucsize
MOV	BP, SP
MOVD	emscopy_numbytes, ECX
MOVB	emscopy_srctype, 1
MOV	AX, zEMShandle
MOVW	emscopy_srchandle, AX
MOVW	emscopy_srcoff, SI
MOV	AX, FS
SHL	AX, 2
MOVW	emscopy_srcseg, AX
MOVB	emscopy_destype, 1
MOV	AX, zEMShandle
MOVW	emscopy_deshandle, AX
MOVW	emscopy_desoff, DI
MOV	AX, zEMShandle
SHL	AX, 2
MOVW	emscopy_desseg, AX
MOV	SI, BP
MOV	AX, SS
MOV	DS, AX
MOV	AL, 0
EMSfunction	_ems_move_or_exchange_memory_region
POP4	AX, DS, SI, BP
RETF
hCopyMemEE ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>











;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemEX		INTERNAL FUNCTION
;
; Purpose:
;   Copy from EMS to XMS.(using XMM)(speed=?)
;
; Usage:
;   fs:si=source, es:di=dest, ecx=bytes
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemEX
hCopyMemEX PROC
PUSH7	FS, SI, ES, EDI, AX, ECX, EDX
;LOCAL.........
UseLocal	6
LOCAL_VAR	_1cpmemexOldEMSpage, WORD PTR stack0
LOCAL_VAR	_1cpmemexNumBytes, DWORD PTR stack2
;LOCAL.........
MOV	AX, zEMSpage
MOV	_1cpmemexOldEMSpage, AX
MOV	AX, FS
MOV	FS, EMSsegment
MOV	_1cpmemexNumBytes, ECX
CALL	hGetMemEMS
MOV	EDX, 65536
OR	SI, SI
JZ	copymemex01
Zero	EDX
SUB	DX, SI

copymemex01:
CMP	ECX, EDX
JBE	copymemex02
MOV	ECX, EDX

copymemex02:
CALL	hCopyMemCX
MOV	BX, ES
BT	ECX, 16
ADC	BX, 0
ADD	DI, CX
ADC	BX, 0
MOV	ES, BX
SUB	_1cpmemexNumBytes, ECX
JNZ	copymemex03

copymemex06:
MOV	AX, _1cpmemexOldEMSpage
CALL	hGetMemEMS
EndLocal	6
POP7	FS, SI, ES, EDI, AX, ECX, EDX
RETF

copymemex03:
XOR	SI, SI

copymemex05:
INC	AX
CALL	hGetMemEMS
MOV	ECX, 65536
CMP	_1cpmemexNumBytes, 65536
JA	copymemex04
MOV	ECX, _1cpmemexNumBytes

copymemex04:
CALL	CopyMemCX
MOV	BX, ES
BT	ECX, 16
ADC	BX, 0
ADD	DI, CX
ADC	BX, 0
MOV	ES, BX
SUB	_1cpmemexNumBytes, ECX
JNZ	copymemex05
JMP	copymemex06
hCopyMemEX ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>











;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemEF		INTERNAL FUNCTION
;
; Purpose:
;   Copy from EMS to FILE.(using DOS FILE)(speed=low)
;
; Usage:
;   fs:si=source, es:edi=dest, ecx=bytes
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemEF
hCopyMemEF PROC
PUSH6	FS, SI, EDI, AX, ECX, EDX
;LOCAL.........
UseLocal	6
LOCAL_VAR	_1cpmemefOldEMSpage, WORD PTR stack0
LOCAL_VAR	_1cpmemefNumBytes, DWORD PTR stack2
;LOCAL.........
MOV	AX, zEMSpage
MOV	_1cpmemefOldEMSpage, AX
MOV	AX, FS
MOV	FS, EMSsegment
MOV	_1cpmemefNumBytes, ECX
CALL	hGetMemEMS
MOV	EDX, 65536
OR	SI, SI
JZ	copymemef01
Zero	EDX
SUB	DX, SI

copymemef01:
CMP	ECX, EDX
JBE	copymemef02
MOV	ECX, EDX

copymemef02:
CALL	hCopyMemCF
ADD	EDI, ECX
SUB	_1cpmemefNumBytes, ECX
JNZ	copymemef03

copymemef06:
MOV	AX, _1cpmemefOldEMSpage
CALL	hGetMemEMS
EndLocal	6
POP6	FS, SI, EDI, AX, ECX, EDX
RETF

copymemef03:
XOR	SI, SI

copymemef05:
INC	AX
CALL	hGetMemEMS
MOV	ECX, 65536
CMP	_1cpmemefNumBytes, 65536
JA	copymemef04
MOV	ECX, _1cpmemefNumBytes

copymemef04:
CALL	CopyMemCF
ADD	EDI, ECX
SUB	_1cpmemefNumBytes, ECX
JNZ	copymemef05
JMP	copymemef06
hCopyMemEF ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>










;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemXC		INTERNAL FUNCTION
;
; Purpose:
;   Copy from XMS to CONV (using XMM)(speed=?).
;
; Usage:
;   fs:si=source, es:di=dest, cx=bytes(=0 for full 64K)
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemXC
hCopyMemXC PROC
PUSH4	AX, DS, SI, BP
SUB	SP, _xmscopy_strucsize
MOV	BP, SP
MOVD	xmscopy_numbytes, ECX
MOV	AX, zXMShandle
MOVW	emscopy_srchandle, AX
MOVW	emscopy_srcoff, SI
MOVW	emscopy_srcseg, FS
MOVW	emscopy_deshandle, 0
MOVW	emscopy_desoff, DI
MOVW	emscopy_desseg, ES		;shl ES, ??
MOV	SI, BP
MOV	AX, SS
MOV	DS, AX
MOV	AL, 0
XMSfunction	_xms_copy_memory_region
POP4	AX, DS, SI, BP
RETF
hCopyMemXC ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>











;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemXE		INTERNAL FUNCTION
;
; Purpose:
;   Copy from XMS to EMS (using XMM)(speed=?)
;
; Usage:
;   fs:si=source, es:di=dest, ecx=bytes
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemXE
hCopyMemXE PROC
PUSH7	FS, SI, ES, EDI, AX, ECX, EDX
;LOCAL.........
UseLocal	6
LOCAL_VAR	_1cpmemxeOldEMSpage, WORD PTR stack0
LOCAL_VAR	_1cpmemxeNumBytes, DWORD PTR stack2
;LOCAL.........
MOV	AX, zEMSpage
MOV	_1cpmemxeOldEMSpage, AX
MOV	AX, ES
MOV	ES, EMSsegment
MOV	_1cpmemxeNumBytes, ECX
CALL	hGetMemEMS
MOV	EDX, 65536
OR	DI, DI
JZ	copymemxe01
Zero	EDX
SUB	DX, DI

copymemxe01:
CMP	ECX, EDX
JBE	copymemxe02
MOV	ECX, EDX

copymemxe02:
CALL	hCopyMemXC
MOV	BX, FS
BT	ECX, 16
ADC	BX, 0
ADD	SI, CX
ADC	BX, 0
MOV	FS, BX
SUB	_1cpmemxeNumBytes, ECX
JNZ	copymemxe03

copymemxe06:
MOV	AX, _1cpmemxeOldEMSpage
CALL	hGetMemEMS
EndLocal	6
POP7	FS, SI, ES, EDI, AX, ECX, EDX
RETF

copymemxe03:
XOR	DI, DI

copymemxe05:
INC	AX
CALL	hGetMemEMS
MOV	ECX, 65536
CMP	_1cpmemxeNumBytes, 65536
JA	copymemxe04
MOV	ECX, _1cpmemxeNumBytes

copymemxe04:
CALL	CopyMemXC
MOV	BX, FS
BT	ECX, 16
ADC	BX, 0
ADD	SI, CX
ADC	BX, 0
MOV	FS, BX
SUB	_1cpmemxeNumBytes, ECX
JNZ	copymemxe05
JMP	copymemex06
hCopyMemXE ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>











;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemXX		INTERNAL FUNCTION
;
; Purpose:
;   Copy from XMS to XMS (using XMM)(speed=?).
;
; Usage:
;   fs:si=source, es:di=dest, ecx=bytes
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemXX
hCopyMemXX PROC
PUSH4	AX, DS, SI, BP
SUB	SP, _xmscopy_strucsize
MOV	BP, SP
MOVD	xmscopy_numbytes, ECX
MOV	AX, zEMShandle
MOVW	emscopy_srchandle, AX
MOVW	emscopy_srcoff, SI
MOVW	emscopy_srcseg, FS
MOVW	emscopy_deshandle, AX
MOVW	emscopy_desoff, DI
MOVW	emscopy_desseg, ES		;shl ES, ??
MOV	SI, BP
MOV	AX, SS
MOV	DS, AX
MOV	AL, 0
XMSfunction	_xms_copy_memory_region
POP4	AX, DS, SI, BP
RETF
hCopyMemXX ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>












;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemXF		INTERNAL FUNCTION
;
; Purpose:
;   Copy from XMS to FILE.(using XMM and DOS FILE)(speed=slow+?)
;
; Usage:
;   fs:si=source, es:edi=dest, ecx=bytes
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemXF
hCopyMemXF PROC
PUSH5	FS, SI, EDI, EAX, ECX
;LOCAL.........
UseLocal	14
LOCAL_VAR	_1cpmemxfOldEMSpage, WORD PTR stack0
LOCAL_VAR	_1cpmemxfFileHandle, WORD PTR stack2
LOCAL_VAR	_1cpmemxfFileAddress, DWORD PTR stack4
LOCAL_VAR	_1cpmemxfXMSsrcSeg, WORD PTR stack8
LOCAL_VAR	_1cpmemxfNumBytes, DWORD PTR stack10
;LOCAL.........
MOV	AX, zEMSpage
MOV	_1cpmemxfOldEMSpage, AX
MOV	AX, EMS_XMSseg
CALL	hGetMemEMS
MOV	_1cpmemxfFileHandle, ES
MOV	_1cpmemxfFileAddress, EDI
MOV	_1cpmemxfXMSsrcSeg, FS
MOV	_1cpmemxfNumBytes, ECX
MOV	EAX, 65536
OR	SI, SI
JZ	copymemxf01
Zero	EAX
SUB	DX, SI

copymemxf01:
CMP	ECX, EAX
JBE	copymemxf02
MOV	ECX, EAX

copymemxf02:
MOV	ES, EMSsegment
Zero	DI
Call	hCopyMemXC
MOV	FS, EMSsegment
Zero	SI
MOV	ES, _1cpmemxfFileHandle
MOV	EDI, _1cpmemxfFileAddress
CALL	hCopyMemCF
ADD	_1cpmemxfFileAddress, ECX
SUB	_1cpmemxfNumBytes, ECX
JNZ	copymemxf03

copymemxf06:
MOV	AX, _1cpmemxfOldEMSpage
CALL	hGetMemEMS
MOV	ES, _1cpmemxfFileHandle
EndLocal	14
POP5	FS, SI, EDI, EAX, ECX
RETF

copymemxf03:
MOV	ECX, 65536
CMP	_1cpmemxfNumBytes, 65536
JA	copymemxf04
MOV	ECX, _1cpmemxfNumBytes

copymemxf04:
Zero	SI

copymemxf05:
MOV	AX, _1cpmemxfXMSsrcSeg
INC	AX
MOV	_1cpmemxfXMSsrcSeg, AX
MOV	FS, AX
MOV	ES, EMSsegment
Zero	DI
CALL	hCopyMemXC
MOV	FS, EMSsegment
MOV	ES, _1cpmemxfFileHandle
MOV	EDI, _1cpmemxfFileAddress
CALL	hCopyMemCF
ADD	_1cpmemxfFileAddress, ECX
SUB	_1cpmemxfNumBytes, ECX
JNZ	copymemxf05
JMP	copymemxf06
hCopyMemXF ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>












;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemFC		INTERNAL FUNCTION
;
; Purpose:
;   Copy from FILE to CONV.(using DOS FILE)(speed=slow)
;
; Usage:
;   fs:esi=source, es:di=dest, ecx=bytes
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemFC
hCopyMemFC PROC
PUSH5	ES, DI, AX, BX, ECX
;LOCAL.........
UseLocal	8
LOCAL_VAR	_1cpmemfcOldFileLoc, DWORD PTR stack0
LOCAL_VAR	_1cpmemfcNumBytes, DWORD PTR stack4
;LOCAL.........
MOV	_1cpmemfcNumBytes, ECX
MOV	AX, FS
Zero	BX
Zero	ECX
CALL	hSeekFile
CMP	ErrorCode, 0
JNZ	copymemfc02
MOV	_1cpmemfcOldFileLoc, ECX
MOV	ECX, ESI
CALL	hSeekFile
CMP	ErrorCode, 0
JNZ	copymemfc01
MOV	CX, DI
SHR	CX, 4
MOV	BX, ES
ADD	BX, CX
MOV	ES, BX
AND	DI, 0Fh
Zero	BX

copymemfc06:
MOV	ECX, 32768
CMP	_1cpmemfcNumBytes, 32768
JA	copymemfc05
MOV	ECX, _1cpmemfcNumBytes

copymemfc05:
CALL	hReadFile
CMP	ErrorCode, 0
JNZ	copymemfc01
MOV	BX, ES
ADD	BX, 32768/4
MOV	ES, BX
Zero	BX
SUB	_1cpmemfcNumBytes, ECX
JNZ	copymemfc06

copymemfc01:
MOV	ECX, _1cpmemfcOldFileLoc
CALL	hSeekFile

copymemfc02:
EndLocal	8
POP5	ES, DI, AX, BX, ECX
RETF
hCopyMemFC ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>













;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemFE		INTERNAL FUNCTION
;
; Purpose:
;   Copy from FILE to EMS.(using DOS FILE)(speed=slow)
;
; Usage:
;   fs:esi=source, es:di=dest, ecx=bytes
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemFE
hCopyMemFE PROC
PUSH6	ES, DI, ESI, AX, ECX, EDX
;LOCAL.........
UseLocal	6
LOCAL_VAR	_1cpmemfeOldEMSpage, WORD PTR stack0
LOCAL_VAR	_1cpmemfeNumBytes, DWORD PTR stack2
;LOCAL.........
MOV	AX, zEMSpage
MOV	_1cpmemfeOldEMSpage, AX
MOV	AX, ES
MOV	ES, EMSsegment
MOV	_1cpmemfeNumBytes, ECX
CALL	hGetMemEMS
MOV	EDX, 65536
OR	DI, DI
JZ	copymemfe01
Zero	EDX
SUB	DX, DI

copymemfe01:
CMP	ECX, EDX
JBE	copymemfe02
MOV	ECX, EDX

copymemfe02:
CALL	hCopyMemFC
ADD	ESI, ECX
SUB	_1cpmemfeNumBytes, ECX
JNZ	copymemfe03

copymemfe06:
MOV	AX, _1cpmemfeOldEMSpage
CALL	hGetMemEMS
EndLocal	6
POP6	ES, DI, ESI, AX, ECX, EDX
RETF

copymemfe03:
Zero	DI

copymemfe05:
INC	AX
CALL	hGetMemEMS
MOV	ECX, 65536
CMP	_1cpmemfeNumBytes, 65536
JA	copymemfe04
MOV	ECX, _1cpmemfeNumBytes

copymemfe04:
CALL	CopyMemFC
ADD	ESI, ECX
SUB	_1cpmemfeNumBytes, ECX
JNZ	copymemfe05
JMP	copymemfe06
hCopyMemFE ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>













;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemFX		INTERNAL FUNCTION
;
; Purpose:
;   Copy from FILE to XMS.(using DOS FILE and XMM)(speed=slow+?)
;
; Usage:
;   fs:esi=source, es:di=dest, cx=bytes(=0 for full 64K)
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemFX
hCopyMemFX PROC
PUSH3	FS, SI, AX
MOV	AX, zEMSpage
PUSH	AX
MOV	AX, zEMS_XMSseg
CALL	hGetMemEMS
PUSH2	ES, DI
MOV	ES, zEMSsegment
Zero	DI
CALL	CopyMemFC
MOV	FS, zEMSsegment
Zero	SI
POP2	ES, DI
CALL	CopyMemCX
POP	AX
CALL	hGetMemEMS
POP3	FS, SI, AX
RETF
hCopyMemFX ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>













;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMemFF		INTERNAL FUNCTION
;
; Purpose:
;   Copy from FILE to FILE.(using DOS FILE)(speed=quite slow)
;
; Usage:
;   fs:esi=source, es:edi=dest, cx=bytes(=0 for full 64K)
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMemFF
hCopyMemFF PROC
PUSH3	FS, SI, AX
MOV	AX, zEMSpage
PUSH	AX
MOV	AX, zEMS_FILEseg
CALL	hGetMemEMS
PUSH2	ES, DI
MOV	ES, zEMSsegment
Zero	DI
CALL	CopyMemFC
MOV	FS, zEMSsegment
Zero	SI
POP2	ES, DI
CALL	CopyMemCF
POP	AX
CALL	hGetMemEMS
POP3	FS, SI, AX
RETF
hCopyMemFF ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>















;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyMem		INTERNAL FUNCTION
;
; Purpose:
;   Copy from ALL to ALL.
;
; Usage:
;   fs:esi=source, es:edi=dest, ah=srctype, al=desttype, cx=bytes(=0 for full 64K)
;   0-CONV, 1-EMS, 2-XMS, 3-FILE
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyMem
hCopyMem PROC
PUSH	BX
MOV	BH, AH
MOV	BL, AL
SHL	BL, 2
SHL	BH, 4
OR	BL, BH
XOR	BH, BH
CALL	DWORD PTR zMEMCOPY_mapping[BX]
POP	BX
RETF
hCopyMem ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>













;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hCopyDataPack		INTERNAL FUNCTION
;
; Purpose:
;   Copy a data packet from source memory to destination memory
;
; Usage:
;   ah:fs:esi=src mem, al:es:edi=des mem
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hCopyDataPack
hCopyDataPack PROC
PUSH4	AX, CX, ES, EDI
PUSH	EAX
MOV	DI, SS
MOV	ES, DI
MOV	DI, SP
Zero	AL
MOV	CX, 4
CALL	hCopyMem
POP	EDI
OR	EDI, EDI
JZ	copydatapack01
MOV	CX, DI
ADD	CX, 4
POP4	AX, CX, ES, EDI
CALL	hCopyMem
RETF

copydatapack01:
POP4	AX, CX, ES, EDI
RETF
hCopyDataPack ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>











END

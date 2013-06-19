;--------------------------------------------------------------------------------
;				MEMORY CONTROL
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

;General INCLUDE File
INCLUDE	Includes.inc



;SHARED data
PUBLIC	zEMSsegment, zEMSpage, zEMShandle, zXMSdriver, zXMShandle



.STACK 200h



;External Variables
EXTRN	zErrorCode:WORD
EXTRN	zErrorAction:WORD






;CONST
_ems_min_memory_required				equ	16	;KB of EMS required
_xms_min_memory_required				equ	0	;KB of XMS required ??




.DATA
zMemoryStatus					DB	?
zEMMid						DB	'EMMXXXX0'
zEMShandle					DW	?
zEMSpage						DW	?
zEMSsegment					DW	?
zXMSdriver					DD	?
zXMShandle					DW	?
zMEMGET_mapping					DW	OFFSET getmemover,SEG getmemover,OFFSET GetMemE,   SEG GetMemE
						DW	OFFSET GetMemX,   SEG GetMemX,   OFFSET GetMemF,   SEG GetMemF
zMEMPUT_mapping					DW	OFFSET getmemover,SEG getmemover,OFFSET getmemover,SEG getmemover
						DW	OFFSET GetMemX,   SEG GetMemX,   OFFSET GetMemF,   SEG GetMemF



;INCLUDE Files
INCLUDE	mem_incl.inc



;External SUBS
EXTRN	hCopyMemCX:FAR
EXTRN	hCopyMemXC:FAR
EXTRN	hCopyMemCF:FAR
EXTRN	hCopyMemFC:FAR






.CODE



;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hStartMemory	INTERNAL FUNCTION
;
; Purpose:
;   Start Memory facility.
;   Starts EMS and XMS if possible.
;   Recommends to exit program if no or insufficient EMS found.
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hStartMemory
hStartMemory PROC

PUSH7	AX, BX, CX, EDX, ES, SI, DI

;Clean variables
Zerox	zMemoryStatus

;Allocate some CONV memory for DLLs and mem buffering, etc.

;Try to get EMS memory
MOV	AX, _ems_interrupt
CALL	hCheckInterruptExistence
CMP	AX, FALSE
JE	startmem01
CALL	hGetInterrupt
MOV	DI, _ems_emm_id_pointer
MOV	SI, OFFSET zEMMid
MOV	CX, _ems_emm_id_length
CLD
REPE	CMPSB
JNE	startmem02
XOR	BX, BX
EMSfunction	_ems_get_number_of_pages
SHL	BX, 4
CMP	BX, _ems_min_memory_required
JA	morememfound
MOV	BX, _ems_min_memory_required
ADD	BX, 1111b

morememfound:
SHR	BX, 4
EMSfunction	_ems_get_handle_and_allocate_memory
OR	AH, AH
JNZ	startmem03
MOV	zEMShandle, DX
EMSfunction	_ems_get_page_frame_segment
OR	AH, AH
JNZ	startmem03
MOV	zEMSsegment, BX
BTS	zMemoryStatus, _memory_emsready

;Try to get XMS memory
XMSinterrupt	_xms_installation_check
CMP	AL, 80h
JNE	startmem04
XMSinterrupt	_xms_get_driver_address
MOV	WORD PTR zXMSdriver, BX
MOV	WORD PTR zXMSdriver[2], ES
XMSfunction	_xms_amount_of_xms_available
						;??I doubt howto check memory
CMP	EDX, _xms_min_memory_required
JA	morexmsfound
MOV	EDX, _xms_min_memory_required
ADD	EDX, ?

morexmsfound:
SHR	EDX, ?
XMSfunction	_xms_allocate_memory
OR	AX, AX
JNZ	startmem05
MOV	zXMShandle, DX
BTS	zMemoryStatus, _memory_xmsready

startmemend:
POP7	AX, BX, CX, EDX, ES, SI, DI
RETF

;Errors
startmem01:
MOV	AH, _error_ems
MOV	AL, 01h						;01h=EMS interrupt does not exist 
MOV	zErrorCode, AX
MOV	zErrorAction, _error_exitprogram		;exitprogram error recommendation
JMP	startmemend

startmem02:
MOV	AH, _error_ems
MOV	AL, 02h						;02h=EMS interrupt does not exist but some other program exists in its place
MOV	zErrorCode, AX
MOV	zErrorAction, _error_exitprogram		;exitprogram error recommendation
JMP	startmemend

startmem03:
MOV	AH, _error_ems
MOV	zErrorCode, AX					;EMM error code
MOV	zErrorAction, _error_exitprogram		;exitprogram error recommendation
JMP	startmemend

startmem04:
MOV	AH, _error_xms
MOV	AL, 01h						;01h=No XMS found
MOV	zErrorCode, AX
MOV	zErrorAction, _error_maystay
JMP	startmemend

startmem05:
MOV	AH, _error_xms
MOV	AL, 02h						;02h=Cannot allocate required XMS memory
MOV	zErrorCode, AX
MOV	zErrorAction, _error_maystay
JMP	startmemend
hStartMemory ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>










;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hStopMemory	INTERNAL FUNCTION
;
; Purpose:
;   Stop Memory facility.
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hStopMemory
hStopMemory PROC

PUSH2	AX, DX

;Deallocate EMS memory
TEST	zMemoryStatus, _memory_emsready
JZ	stopmem01
MOV	DX, zEMShandle
EMSfunction	_ems_release_handle_and_memory

;Deallocate XMS memory
stopmem01:
TEST	zMemoryStatus, _memory_xmsready
JZ	stopmem02
MOV	DX, zXMShandle
XMSfunction	_xms_deallocate_memory

stopmem02:
POP2	AX, DX
RETF

hStopMemory ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>










;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hGetMemEMS12	INTERNAL FUNCTION
;
; Purpose:
;   Get an EMS page (32K) on the first or second half.
;
; Usage:
;   ax=EMS page (x2 or 32K page number), bx=1 or 2, indicating 1st half or 2nd half
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hGetMemEMS12
hGetMemEMS12 PROC

PUSH3	AX, BX, DX

;Check if EMS available
TEST	zMemoryStatus, _memory_emsready
JZ	getmemems01

;Map 2 16K EMS pages to the first half of zEMSsegment
XCHG	BX, AX
CMP	AX, 2
Zerox	AL
JNE	getmemems00
INC	AL
INC	AL

getmemems00:
SHL	BX, 1
MOV	DX, zEMShandle
EMSfunction	_ems_map_memory
INC	BX
INC	AL
EMSfunction	_ems_map_memory

getmememsxx:
POP3	AX, BX, DX
RETF

;Errors
getmemems01:
MOV	AH, _error_ems
MOV	AL, 03h			;03h=No EMS has been allocated
MOV	zErrorCode, AX
MOV	zErrorAction, _error_exitprogram
JMP	getmememsxx

hGetMemEMS12 ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>










;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hGetMemEMS	INTERNAL FUNCTION
;
; Purpose:
;   Get an EMS page (64K).
;
; Usage:
;   ax=EMS page (64K page number)
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hGetMemEMS
hGetMemEMS PROC

PUSH3	AX, BX, DX

;Check if EMS available
TEST	zMemoryStatus, _memory_emsready
JZ	getmemems02

;Map 4 16K EMS pages to the zEMSsegment
MOV	zEMSpage, AX
MOV	BX, AX
Zerox	AL
SHL	BX, 2
MOV	DX, zEMShandle
EMSfunction	_ems_map_memory
INC	BX
INC	AL
EMSfunction	_ems_map_memory
INC	BX
INC	AL
EMSfunction	_ems_map_memory
INC	BX
INC	AL
EMSfunction	_ems_map_memory
OR	AH, AH
JNZ	getmemems03

getmememsyy:
POP3	AX, BX, DX
RETF

;Errors
getmemems02:
MOV	AH, _error_ems
MOV	AL, 03h			;03h=No EMS has been allocated
MOV	zErrorCode, AX
MOV	zErrorAction, _error_exitprogram
JMP	getmememsyy

getmemems03:
MOV	AH, _error_ems
MOV	zErrorCode, AX
MOV	zErrorAction, _error_exitprogram
JMP	getmememsyy

hGetMemEMS ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>










;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hGetMemXMS	INTERNAL FUNCTION
;
; Purpose:
;   Get an XMS page (64K).
;
; Usage:
;   ax=XMS page (64K page number)
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hGetMemXMS
hGetMemXMS PROC

PUSH6	AX, CX, FS, SI, ES, DI

;Check if XMS available
TEST	zMemoryStatus, _memory_xmsready
JZ	getmemxms01

;Map 4 16K XMS pages to the EMS_XMSseg
MOV	FS, AX
MOV	ES, zEMSsegment
MOV	AX, EMS_XMSseg
CALL	hGetMemEMS
Zero	SI
Zero	DI
Zero	CX
CALL	hCopyMemXC

getmemxmsxx:
POP6	AX, CX, FS, SI, ES, DI
RETF

;Errors
getmemems01:
MOV	AH, _error_xms
MOV	AL, 03h			;03h=No XMS has been allocated
MOV	zErrorCode, AX
MOV	zErrorAction, _error_maystay
JMP	getmemxmsxx

hGetMemXMS ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>










;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hPutMemXMS	INTERNAL FUNCTION
;
; Purpose:
;   Put an XMS page (64K).
;
; Usage:
;   ax=XMS page (64K page number)
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hPutMemXMS
hPutMemXMS PROC

PUSH6	AX, CX, FS, SI, ES, DI

;Check if XMS available
TEST	zMemoryStatus, _memory_xmsready
JZ	getmemxms02

;Map 4 16K XMS pages to the EMS_XMSseg
MOV	ES, AX
MOV	FS, zEMSsegment
MOV	AX, EMS_XMSseg
CALL	hGetMemEMS
Zero	SI
Zero	DI
Zero	CX
CALL	hCopyMemCX

getmemxmsyy:
POP6	AX, CX, FS, SI, ES, DI
RETF

;Errors
getmemems02:
MOV	AH, _error_xms
MOV	AL, 03h			;03h=No XMS has been allocated
MOV	zErrorCode, AX
MOV	zErrorAction, _error_maystay
JMP	getmemxmsyy

hPutMemXMS ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>









;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hGetMemFILE	INTERNAL FUNCTION
;
; Purpose:
;   Get a FILE page.
;
; Usage:
;   ax=FILE handle, ebx=FILE page
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hGetMemFILE
hGetMemFILE PROC
PUSH5	CX, FS, ESI, ES, DI
MOV	FS, AX
MOV	ES, zEMSsegment
MOV	ESI, EBX
Zero	SI
MOV	AX, EMS_FILEseg
CALL	hGetMemEMS
Zero	DI
Zero	CX
CALL	CopyMemFC
POP5	CX, FS, ESI, ES, DI
RETF
hGetMemFILE ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>









;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hPutMemFILE	INTERNAL FUNCTION
;
; Purpose:
;   Put a FILE page.
;
; Usage:
;   ax=FILE handle, ebx=FILE page
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hPutMemFILE
hPutMemFILE PROC
PUSH5	CX, FS, SI, ES, EDI
MOV	FS, zEMSsegment
MOV	ES, AX
MOV	EDI, EBX
Zero	DI
MOV	AX, EMS_FILEseg
CALL	hGetMemEMS
Zero	SI
Zero	CX
CALL	CopyMemCF
POP5	CX, FS, SI, ES, EDI
RETF
hPutMemFILE ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>










;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hGetMem		INTERNAL FUNCTION
;
; Purpose:
;   Get an ANY page.
;
; Usage:
;   ax=ANY page / ax=FILE handle, ebx=FILE page(if file), cl=type
;
; Returns:
;   ax=CONV page
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hGetMem
hGetMem PROC
PUSH2	CX, SI
AND	CX, 3
MOV	SI, CX
SHL	SI, 2
CALL	DWORD PTR zMEMGET_mapping[si]
OR	CX, CX
JZ	getmemover
MOV	AX, zEMSsegment

getmemover:
POP2	CX, SI
RETF
hGetMem ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>










;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; hPutMem		INTERNAL FUNCTION
;
; Purpose:
;   Put an ANY page.
;
; Usage:
;   ax=ANY page / ax=FILE handle, ebx=FILE page(if file), cl=type
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC hPutMem
hPutMem PROC
PUSH2	CX, SI
AND	CX, 3
MOV	SI, CX
SHL	SI, 2
CALL	DWORD PTR zMEMPUT_mapping[si]
OR	CX, CX
JZ	getmemover

putmemover:
POP2	CX, SI
RETF
hPutMem ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>








END

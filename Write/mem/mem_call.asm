;--------------------------------------------------------------------------------
;				MEMORY CALLABLE ROUTINES
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



.STACK 200h



;External Variables
EXTRN	zEMSsegment:WORD
EXTRN	zErrorCode:WORD





;CONST




.DATA



;INCLUDE Files
INCLUDE	mem_incl.inc



;External SUBS
EXTRN	hGetMem:FAR
EXTRN	hPutMem:FAR
EXTRN	hCopyMem:FAR
EXTRN	hCopyDataPack:FAR
EXTRN	hReportError:FAR





.CODE




;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; HZDgetMemory	FUNCTION
;
; Purpose:
;   Get an CONV/EMS/XMS/FILE page.
;   Map any memory to desired location and give its segment address.
;   0-CONV, 1-EMS, 2-XMS, 3-FILE
;
; Declaration:
;   DECLARE FUNCTION HZDgetMemory&(BYVAL type%, BYVAL Seg%, BYVAL Off&)
;
; Returns:
;   CONV address as a long datatype.
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC HZDgetMemory
HZDgetMemory PROC
UseParam
PUSH	EBX
MOV	CL, param4
AND	CL, 3
MOV	AX, param3
MOV	EBX, param1
CALL	hGetMem
POP	EBX
OR	CL, CL
JZ	hzdgetmem01
MOV	AX, zEMSsegment

hzdgetmem01:
XOR	DX, DX
CMP	zErrorCode, 0
JNZ	hzdgetmem0err

hzdgetmem1err:
EndParam
RETF	8

hzdgetmem0err:
CALL	hReportError
JMP	hzdgetmem1err
HZDgetMemory ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>












;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; HZDputMemory	SUB
;
; Purpose:
;   Put an CONV/EMS/XMS/FILE page.
;   Save memory at desired location to any memory.
;   0-CONV, 1-EMS, 2-XMS, 3-FILE
;
; Declaration:
;   DECLARE SUB HZDputMemory(BYVAL type%, BYVAL Seg%, BYVAL Off&)
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC HZDputMemory
HZDputMemory PROC
UseParam
PUSH	EBX
MOV	CL, param4
AND	CL, 3
MOV	AX, param3
MOV	EBX, param1
CALL	hPutMem
POP	EBX
CMP	zErrorCode, 0
JNZ	hzdputmem0err

hzdputmem1err:
EndParam
RETF	8

hzdputmem0err:
CALL	hReportError
JMP	hzdputmem1err
HZDputMemory ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>











;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; HZDcopyMemory	SUB
;
; Purpose:
;   Copy CONV/EMS/XMS/FILE memory to CONV/EMS/XMS/FILE memory.
;   Copy memory from source to destination.(max=64K=65536, min=0)
;   0-CONV, 1-EMS, 2-XMS, 3-FILE
;
; Declaration:
;   DECLARE SUB HZDcopyMemory(BYVAL srctype%, BYVAL srcSeg%, BYVAL srcOff&,
;			      BYVAL desttype%, BYVAL destSeg%, BYVAL destOff&
;			      BYVAL bytes&)
;
; Returns:
;   nothing
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC HZDcopyMemory
HZDcopyMemory PROC
UseParam
PUSH4	FS, ESI, ES, EDI
MOV	AH, param10
MOV	FS, param9
MOV	ESI, param7
MOV	AL, param6
MOV	ES, param5
MOV	EDI, param3
AND	AH, 3
AND	AL, 3
CMP	DWORD PTR param1, 0
JZ	hzdcopymem01
MOV	CX, param1
CALL	hCopyMem

hzdcopymem01:
POP4	FS, ESI, ES, EDI
CMP	zErrorCode, 0
JNZ	hzdcopymem0err

hzdcopymem1err:
EndParam
RETF	20

hzdcopymem0err:
CALL	hReportError
JMP	hzdcopymem1err
HZDcopyMemory ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>













;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
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
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
EVEN
PUBLIC HZDcopyDataPack
HZDcopyDataPack PROC
UseParam
PUSH4	FS, ESI, ES, EDI
MOV	AH, param8
MOV	FS, param7
MOV	ESI, param5
MOV	AL, param4
MOV	ES, param3
MOV	EDI, param1
CALL	hCopyDataPack
POP4	FS, ESI, ES, EDI
CMP	zErrorCode, 0
JNZ	hzdcopydatapack0err

hzdcopydatapack1err:
EndParam
RETF	16

hzdcopydatapack0err:
CALL	hReportError
JMP	hzdcopydatapack1err
HZDcopyDataPack ENDP
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>








END

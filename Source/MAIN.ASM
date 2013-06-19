;--------------------------------------------------------------------------------
;		MAIN MACHINE
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

.STACK 100h




; *** Data ***
.DATA




;*****************
; Global variables
;*****************
PUBLIC	LibReadHandle, LibSaveHandle
PUBLIC	XMSuseSEG, FileUseSEG, RoughSEG, FindFileSEG, PaletteSEG, MouseImgSEG, 
PUBLIC	PCspeakerSEG, FileHandlesSEG, SoundTablesSEG, FontSEG
PUBLIC	SoundSEG, GeneralSoundsSEG, GeneralPicsSEG, VideoSEG










;****************
; Main data
;****************
LibActive			DB	0
LibReadHandle		DW	0
LibSaveHandle		DW	0
XMSuseSEG		DW	0
FILEuseSEG		DW	1
RoughSEG			DW	2, 3, 4
FindFileSEG		DW	5
PaletteSEG		DW	6
MouseImgSEG		DW	6
PCspeakerSEG		DW	6
FileHandlesSEG		DW	6
SoundTablesSEG		DW	6
FontSEG			DW	7, 8
SoundSEG		DW	9, 10
GeneralSoundsSEG		DW	11
GeneralPicsSEG		DW	12
VideoSEG			DW	13, 14, 15, 16




;****************
; Includes
;****************
INCLUDE Includes.inc













;****************
; External SUBS
;****************
EXTRN	StartMem:FAR
EXTRN	StopMem:FAR
EXTRN	StartGraphics:FAR
EXTRN	StopGraphics:FAR
EXTRN	StartTime:FAR
EXTRN	StopTime:FAR
EXTRN	StopPCsound:FAR
EXTRN	StartKeyboard:FAR
EXTRN	StopKeyboard:FAR














.CODE












; ***************************************************************************
; Internal library procedures
; ***************************************************************************

















; ***************************************************************************
; Public library procedures
; ***************************************************************************


;************************************************************************************************************************
; HZDstart SUB
;
; Purpose:
;
;
; Declaration:
;   DECLARE SUB HZDstart()
;
;************************************************************************************************************************
EVEN
PUBLIC HZDstart
HZDstart PROC
test	LibActive, 1
jnz	startDone
mov	LibActive, 1
call	StartMem
call	StartGraphics
call	StartTime
call	StartKeyboard

startDone:
retf
HZDstart ENDP


;************************************************************************************************************************
; HZDstop SUB
;
; Purpose:
;
;
; Declaration:
;   DECLARE SUB HZDstop()
;
;************************************************************************************************************************
EVEN
PUBLIC HZDstop
HZDstop PROC
test	LibActive, 1
jz	stopDone
mov	LibActive, 0
call	StopMem
call	StopGraphics
call	StopTime
call	StopPCsound
call	StopKeyboard

stopDone:
retf
HZDstop ENDP






END


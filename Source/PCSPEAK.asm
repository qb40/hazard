;--------------------------------------------------------------------------------
;			PC SPEAKER MACHINE
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
PUBLIC	PCspeakerActive




.STACK 200h

EXTRN	LastError:WORD
EXTRN	PCspeakerSEG:WORD
EXTRN	EMSpage:WORD




;CONST
silentfrequency			equ	2
timer2div				equ	42h
kybdctrlb				equ	61h
timermodereg			equ	43h
pcspeakerSIZE			equ	512
onehertznumber			equ	1192755


.DATA
PCspeakerActive			DW	0
LeftPlayLength			DD	0
PlayPosition			DW	0
PlayDataSource			DB	0
PlayDataSeg			DW	0
PlayDataOffset			DD	0






;External SUBS
EXTRN	CopyMem:FAR
EXTRN	GetMemE:FAR




.CODE









; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------






; -----------------------------------------------------------------------------------------------------------------------------
; StopPCsound		INTERNAL FUNCTION
;
; Purpose:
;   Stops the PC sound being played
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StopPCsound
StopPCsound PROC
push	ax
mov	PCspeakerActive, 0
in	al, kybdctrlb
and	al, 0FEh
out	kybdctrlb, al
mov	LeftPlayLength, 0
pop	ax
retf
StopPCsound ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; PlayPCsoundISR	INTERNAL FUNCTION
;
; Purpose:
;   This is PC speaker service routine
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC PlayPCsoundISR
PlayPCsoundISR PROC
push6	ax, bx, cx, dx, fs, esi
cmp	LeftPlayLength, 0
je	stoppcspeaker
mov	ax, EMSpage
push	ax
mov	ax, PCspeakerSEG
call	GetMemE
mov	es, ax
mov	bx, pcspeakerOFF
add	bx, PlayPosition
mov	dx, es:[bx]
pop	ax
call	GetMemE
sub	bx, pcspeakerOFF
cmp	bx, pcspeakerSIZE-1
jbe	sizeok
xor	bx, bx
mov	ah, PlayDataSource
mov	fs, PlayDataSeg
mov	esi, PlayDataOffset
add	esi, pcspeakerSIZE
mov	PlayDataOffset, esi
mov	cx, pcspeakerSIZE
call	CopyMem

sizeok:
inc	bx
inc	bx
mov	PlayPosition, bx
;mov	al, 10110110b
;out	timermodereg, al
mov	al, dl
out	timer2div, al
mov	al, dh
out	timer2div, al
sub	LeftPlayLength, 2

over10:
push6	ax, bx, cx, dx, fs, esi
retf

stoppcspeaker:
call	StopPCsound
jmp	over10
PlayPCsoundISR ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; PlayPCsound		INTERNAL FUNCTION
;
; Purpose:
;   Play a PC sound
;
; Usage:
;   ah:fs:si=src mem
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC PlayPCsound
PlayPCsound PROC
push4	es, di, ax, ecx
sub	sp, 8
mov	di, ss
mov	es, di
mov	di, sp
mov	al, 0
mov	ecx, 8
call	CopyMem
pop	ecx
cmp	ecx, datatypepcspeaker
jne	notcorrect
pop	ecx
mov	PlayDataSource, ah
mov	PlayDataSeg, fs
add	esi, 8
mov	PlayDataOffset, esi
mov	LeftPlayLength, ecx
mov	PlayPosition, 0
mov	al, 1
mov	es, PCspeakerSEG
mov	di, pcspeakerOFF
mov	cx, pcspeakerSIZE
call	CopyMem
sub	esi, 8
mov	ax, silentfrequency
out	timer2div, al
xchg	ah, al
out	timer2div, al
in	al, kybdctrlb
or	al, 1
out	kybdctrlb, al
mov	PCspeakerActive, 1

over01:
push4	es, di, ax, ecx
retf

notcorrect:
mov	LastError, errdatatypewrong
jmp	over01
PlayPCsound ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; PausePCsound		INTERNAL FUNCTION
;
; Purpose:
;   Pauses the PC sound being played
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC PausePCsound
PausePCsound PROC
push	ax
mov	PCspeakerActive, 0
in	al, kybdctrlb
and	al, 0FEh
out	kybdctrlb, al
pop	ax
PausePCsound ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; ResumePCsound		INTERNAL FUNCTION
;
; Purpose:
;   Resumes the PC sound being played
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC ResumePCsound
ResumePCsound PROC
push	ax
in	al, kybdctrlb
or	al, 1
out	kybdctrlb, al
mov	PCspeakerActive, 1
pop	ax
ResumePCsound ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; PlayFrequency		INTERNAL FUNCTION
;
; Purpose:
;   Play a particular frequency
;
; Usage:
;   ax=frequency
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC PlayFrequency
PlayFrequency PROC
push3	eax, ebx, edx
xor	ebx, ebx
xor	edx, edx
mov	bx, ax
mov	eax, onehertznumber
div	ebx
mov	bx, ax
mov	al, 10000110b
out	timermodereg, al
mov	al, 10110110b
out	timermodereg, al
mov	ax, bx
out	timer2div, al
mov	al, ah
out	timer2div, al
in	al, kybdctrlb
or	al, 1
out	kybdctrlb, al
pop3	eax, ebx, edx
retf
PlayFrequency ENDP





























; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------





; -----------------------------------------------------------------------------------------------------------------------------
; HZDplayPCsound		SUB
;
; Purpose:
;   Play a PC sound from a source mem/file
;
; Declaration:
;   DECLARE SUB HZDplayPCsound(BYVAL srctype%, BYVAL srcSEG%, BYVAL srcOFF&)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDplayPCsound
HZDplayPCsound PROC
UseParam
push2	fs, esi
mov	ah, param4
mov	fs, param3
mov	esi, param1
call	PlayPCsound
pop2	fs, esi
EndParam
retf	8
HZDplayPCsound ENDP






; -----------------------------------------------------------------------------------------------------------------------------
; HZDstopPCsound		SUB
;
; Purpose:
;   Stop the PC sound being played
;
; Declaration:
;   DECLARE SUB HZDstopPCsound()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDstopPCsound
HZDstopPCsound PROC
call	StopPCsound
retf
HZDstopPCsound ENDP






; -----------------------------------------------------------------------------------------------------------------------------
; HZDpausePCsound		SUB
;
; Purpose:
;   Pause the PC sound being played
;
; Declaration:
;   DECLARE SUB HZDpausePCsound()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDpausePCsound
HZDpausePCsound PROC
call	PausePCsound
retf
HZDpausePCsound ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDresumePCsound		SUB
;
; Purpose:
;   Resume the PC sound that was paused
;
; Declaration:
;   DECLARE SUB HZDresumePCsound()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDresumePCsound
HZDresumePCsound PROC
call	ResumePCsound
retf
HZDresumePCsound ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDplayFrequency		SUB
;
; Purpose:
;   Play a particular frequency from the PC speaker
;   (Only 37Hz-32767Hz)
;
; Declaration:
;   DECLARE SUB HZDplayFrequency(BYVAL freq%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDplayFrequency
HZDplayFrequency PROC
UseParam
mov	ax, param1
cmp	ax, 37
jae	sndok0
mov	ax, 37

sndok0:
cmp	ax, 32767
jbe	sndok1
mov	ax, 32767

sndok1:
call	PlayFrequency
EndParam
retf	2
HZDplayFrequency ENDP













END

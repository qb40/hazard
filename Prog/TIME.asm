;--------------------------------------------------------------------------------
;			TIME MACHINE
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
EXTRN	PCspeakerActive:BYTE




;CONST
irq0				equ	8h*4
timermodereg			equ	43h
timer0reg				equ	40h
timeticksarea			equ	6Ch
midnightflag			equ	70h
midnightoverflow			equ	1572480
hourtick				equ	65520
minutetick				equ	1092
secondtick				equ	18
onesecondtime			equ	1192755
onecentitime			equ	11927



.DATA
OldTimerSEG			DW	0
OldTimerOFF			DW	0
StopWatchActive			DB	0
StopWatchAccuracy			DB	0
StopWatchTime			DD	0




;External SUBS
EXTRN	PlayPCsoundISR:FAR



.CODE







; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------



; -----------------------------------------------------------------------------------------------------------------------------
; StartTime	INTERNAL FUNCTION
;
; Purpose:
;   Starts the time machine
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StartTime
StartTime PROC
push2	es, ax
xor	ax, ax
mov	es, ax
mov	ax, es:[irq0+2]
mov	OldTimerSEG, ax
mov	ax, es:[irq0]
mov	OldTimerOFF, ax
cli
mov	ax, SEG TimerISR
mov	es:[irq0+2], ax
mov	ax, OFFSET TimerISR
mov	es:[irq0], ax
sti
pop2	es, ax
retf

TimerISR:
sti
push2	ds, eax
mov	ax, 40h
mov	ds, ax
mov	eax, ds:[timeticksarea]
inc	eax
cmp	eax, midnightoverflow
jae	midnightcarry

timenormal:
mov	ds:[timeticksarea], eax
mov	ax, @DATA
mov	ds, ax
cmp	StopWatchActive, 1
jne	over00
inc	StopWatchTime

over00:
cmp	PCspeakerActive, 1
jne	overxx
call	PlayPCsoundISR

overxx:
mov	al, 20h
out	20h, al
pop2	ds, eax
iret

midnightcarry:
xor	eax, eax
inc	BYTE PTR ds:[midnightflag]
jmp	timenormal
StartTime ENDP


; -----------------------------------------------------------------------------------------------------------------------------
; StopTime	INTERNAL FUNCTION
;
; Purpose:
;   Stops the time machine
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StopTime
StopTime PROC
push2	es, ax
xor	ax, ax
mov	es, ax
cli
mov	ax, OldTimerSEG
mov	es:[irq0+2], ax
mov	ax, OldTimerOFF
mov	es:[irq0], ax
sti
mov	StopWatchActive, 0
mov	StopWatchAccuracy, 0
mov	StopWatchTime, 0
pop2	es, ax
retf
StopTime ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; GetMicroTime	INTERNAL FUNCTION
;
; Purpose:
;   Gets the micro time
;
; Usage:
;   none
;
; Returns:
;   ax=microtime
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC GetMicroTime
GetMicroTime PROC
cli
mov	al, 00000110b
out	timermodereg, al
mov	al, 11110110b
out	timermodereg, al
in	al, timer0reg
mov	ah, al
in	al, timer0reg
xchg	ah, al
sti
retf
GetMicroTime ENDP





















; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------





; -----------------------------------------------------------------------------------------------------------------------------
; HZDwatchAccuracy	SUB
;
; Purpose:
;   Set the accuracy of the stopwatch(0=LOW/1=HIGH)
;
; Declaration:
;   DECLARE SUB HZDwatchAccuracy(BYVAL accuracy%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDwatchAccuracy
HZDwatchAccuracy PROC
UseParam
mov	al, param1
and	al, 1
mov	StopWatchAccuracy, al
EndParam
retf	2
HZDwatchAccuracy ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDstartWatch	SUB
;
; Purpose:
;   Starts the stopwatch
;
; Declaration:
;   DECLARE SUB HZDstartWatch()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDstartWatch
HZDstartWatch PROC
mov	StopWatchActive, 1
retf
HZDstartWatch ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDstopWatch	SUB
;
; Purpose:
;   Stops the stopwatch
;
; Declaration:
;   DECLARE SUB HZDstopWatch()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDstopWatch
HZDstopWatch PROC
mov	StopWatchActive, 0
mov	StopWatchTime, 0
retf
HZDstopWatch ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDpauseWatch	SUB
;
; Purpose:
;   Pauses the stopwatch
;
; Declaration:
;   DECLARE SUB HZDpauseWatch()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDpauseWatch
HZDpauseWatch PROC
mov	StopWatchActive, 0
retf
HZDpauseWatch ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDresumeWatch	SUB
;
; Purpose:
;   Resumes the stopwatch
;
; Declaration:
;   DECLARE SUB HZDresumeWatch()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDresumeWatch
HZDresumeWatch PROC
mov	StopWatchActive, 1
retf
HZDresumeWatch ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDrawWatchTime		FUNCTION
;
; Purpose:
;   Gives the raw time on the stopwatch
;
; Declaration:
;   DECLARE FUNCTION HZDrawWatchTime&()
;
; Returns:
;   raw stopwatch time
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDrawWatchTime
HZDrawWatchTime PROC
push	edi
mov	edi, StopWatchTime
push	edi
pop	ax
pop	dx
pop	edi
retf
HZDrawWatchTime ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetWatchTime		SUB
;
; Purpose:
;   Loads the proper watch time in hrs:min:sec:cen
;
; Declaration:
;   DECLARE SUB HZDgetWatchTime(time1 AS HZDwatchTime)
;
; Returns:
;   Watch time
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetWatchTime
HZDgetWatchTime PROC
UseParam
push2	eax, si
mov	si, param1
mov	eax, StopWatchTime
push	eax
pop	ax
pop	dx
mov	bx, hourtick
div	bx
mov	[si], ax		;Hour
mov	ax, dx
xor	dx, dx
mov	bx, minutetick
div	bx
mov	[si+2], ax	;Minute
mov	ax, dx
cmp	StopWatchAccuracy, 1
je	findaccurate
mov	bx, secondtick
xor	dx, dx
div	bx
mov	[si+4], ax	;Second
mov	WORD PTR [si+6], 0		;Centi
jmp	over78

findaccurate:
push2	ebx, edx
xor	edx, edx
shl	eax, 16
call	GetMicroTime
mov	ebx, onesecondtime
div	ebx
mov	[si+4], ax	;Second
mov	eax, edx
xor	edx, edx
mov	ebx, onecentitime
div	ebx
mov	[si+6], ax	;Centi
pop2	ebx, edx

over78:
pop2	eax, si
retf	2
HZDgetWatchTime ENDP













END

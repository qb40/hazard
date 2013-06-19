;--------------------------------------------------------------------------------
;			SOUND MACHINE
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


;CONST
sndmidpoint		equ	128
dspbase			equ	220h
dspreset			equ	dspbase+6h
dspread			equ	dspbase+0Ah
dspreadstatus		equ	dspbase+0Eh
dspwrite			equ	dspbase+0Ch
dspwritestatus		equ	dspbase+0Ch
dspresetcheck		equ	200
mixeraddress		equ	dspabse+4h
mixerdata			equ	dspbase+5h
midibase			equ	330h
midistatus			equ	midibase+1h
midicommand		equ	midibase+1h
mididata			equ	midibase
dmamask			equ	0Ah
dmamode			equ	0Bh
dmaclear			equ	0Ch
dmapage			equ	83h
dmaaddress		equ	2h
dmalength			equ	3h
dmamaskusestart		equ	101b
dmamaskusestop		equ	001b
dmamodeuseblock		equ	10001001b
dmamodeusecascade		equ	11001001b
cmdspeakeron		equ	0D1h
cmdspeakeroff		equ	0D3h
sndfullsum			equ	[bp+48]
sndnumpacks		equ	[bp+52]
sndsizepacks		equ	[bp+54]
sndsarsalcalc		equ	[bp+16]
sndvoiceOFF		equ	17


.DATA
DMAmodeUse		DB	dmamodeuseblock
DSPmodes			DB	2 DUP(0)





;External SUBS
EXTRN	GetMem:FAR





.CODE



; -----------------------------------------------------------------------------------------------------------------------------
;		IMPORTANT MACROS
; -----------------------------------------------------------------------------------------------------------------------------
DoSarSalNow		MACRO
sub	cl, 8
ja	dosal
neg	cl
sar	eax, cl
jmp	sarsalover

doshl:
sal	eax, cl

sarsalover:
ENDM









; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------






; -----------------------------------------------------------------------------------------------------------------------------
; ResetDSP	INTERNAL FUNCTION
;
; Purpose:
;   Resets the DSP
;
; Usage:
;   none
;
; Returns:
;   ax=0 if successful, -1 if not
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC ResetDSP
ResetDSP PROC
push2	cx, dx
mov	dx, dspreset
mov	al, 1
out	dx, al
xor	al, al
out	dx, al
mov	cx, dspresetcheck
mov	dx, dspreadstatus

resettry:
in	al, dx
or	al, al
js	resetgot
dec	cx
jnz	resettry

resetfailed:
mov	ax, -1
jmp	over

resetgot:
mov	dx, dspread
in	al, dx
cmp	al, 0AAh
jne	resetfailed
xor	ax, ax

over:
pop2	cx, dx
retf
ResetDSP ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; ReadFromDSP	INTERNAL FUNCTION
;
; Purpose:
;   Reads data from DSP
;
; Usage:
;   none
;
; Returns:
;   al=data read
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC ReadFromDSP
ReadFromDSP PROC
push	dx
mov	dx, dspreadstatus

readtry:
in	al, dx
or	al, al
jns	readtry
mov	dx, dspread
in	al, dx
pop	dx
retf
ReadFromDSP ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; WriteToDSP	INTERNAL FUNCTION
;
; Purpose:
;   Writes data to DSP
;
; Usage:
;   al=write data
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC WriteToDSP
WriteToDSP PROC
push2	dx, ax
mov	dx, dspwritestatus

writetry:
in	al, dx
or	al, al
js	writetry
pop	ax
out	al, dx
pop	dx
retf
WriteToDSP ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; ReadMixerReg	INTERNAL FUNCTION
;
; Purpose:
;   Reads data from a mixer register
;
; Usage:
;   bl=register number
;
; Returns:
;   al=data read
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC ReadMixerReg
ReadMixerReg PROC
push	dx
mov	dx, mixeraddress
mov	al, bl
out	dx, al
inc	dx
in	al, dx
pop	dx
retf
ReadMixerReg ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; WriteMixerReg	INTERNAL FUNCTION
;
; Purpose:
;   Writes data to a mixer register
;
; Usage:
;   al=data to write, bl=register number
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC WriteMixerReg
WriteMixerReg PROC
push	dx
mov	dx, mixeraddress
xchg	al, bl
out	dx, al
inc	dx
xchg	al, bl
out	dx, al
pop	dx
retf
WriteMixerReg ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; PlayBlock	INTERNAL FUNCTION
;
; Purpose:
;   Plays the block of EMS that has been mapped
;
; Usage:
;   EMSpage mapped is used, cx=bytes-1
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC PlayBlock
PlayBlock PROC
push3	ax, bx, dx
mov	dx, dmamask
mov	al, dmamaskusestart
out	dx, al
mov	dx, dmaclear
xor	al, al
out	dx, al
mov	dx, dmamode
mov	al, DMAmodeUse
out	dx, al
mov	bx, EMSseg
shl	bx, 4
mov	dx, dmaaddress
mov	al, bl
out	dx, al
mov	al, bh
out	dx, al
mov	dx, dmapage
mov	bx, EMSseg
shr	bh, 4
mov	al, bh
out	dx, al
mov	dx, dmalength
mov	al, cl
out	dx, al
mov	al, ch
out	dx, al
mov	dx, dmamask
mov	al, dmamaskusestop
out	dx, al
mov	al, cmdtimeconstant
call	WriteToDSP
mov	al, TimeConstant
call	WriteToDSP
mov	al, cmdtransfersize
call	WriteToDSP
mov	al, cl
call	WriteToDSP
mov	al, ch
call	WriteToDSP
mov	al, DSPcommand
call	WriteToDSP
mov	al, DSPcommand[1]
mov	DSPcommand, al
pop3	ax, bx, dx
retf
PlayBlock ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; MixAllVoices	INTERNAL FUNCTION
;
; Purpose:
;   Mixes all voices(REAL if same freq, VIRT if diff)
;
; Usage:
;   EMSpage mapped is used, cx=bytes-1
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC MixAllVoices
MixAllVoices PROC

;SARSAL BEFORE ADDITION DOING PART -
; THIS PART SIMPLY CALCULATES SARSAL TO BE DONE BEFORE ADDITION
; TOTAL VOICES ALLOWED IS 16
; SARSAL BEFOR ADDITION AND SARSAL AFTER ADDITION MUST BE GIVEN
; OFFSETS TO EACH VOICE MUST BE GIVEN
; NUM DATA PACKS, SIZE OF EACH MUST ALSO BE GIVEN
; STACK0-STACK15=SARSAL BEFORE ADDITION
; STACK16=SARSAL AFTER ADDITION
; STACK17-STACK47=OFFSET TO VOICES
; STACK48=FULL SUM
; STACK52=NUM DATA PACKS
; STACK54=SIZE OF EACH
; ASSUMPTIONS
; VOICETABLESSEG HAS BEEN MAPPED
; ES POINTS TO EMSSEG






































;MIXING DOING PART -
; THIS PART SIMPLY MIXES THE DATA TO FIRST VOICE
; TOTAL VOICES ALLOWED IS 16
; SARSAL BEFOR ADDITION AND SARSAL AFTER ADDITION MUST BE GIVEN
; OFFSETS TO EACH VOICE MUST BE GIVEN
; NUM DATA PACKS, SIZE OF EACH MUST ALSO BE GIVEN
; STACK0-STACK15=SARSAL BEFORE ADDITION
; STACK16=SARSAL AFTER ADDITION
; STACK17-STACK47=OFFSET TO VOICES
; STACK48=FULL SUM
; STACK52=NUM DATA PACKS
; STACK54=SIZE OF EACH
; ASSUMPTIONS
; ROUGHSEG4 HAS BEEN MAPPED
; ES POINTS TO EMSSEG
xor	di, di

loopforbytes:
mov	sndfullsum, 0
xor	si, si

loopforvoice:
shl	si, 1
mov	bx, [bp+si+sndvoiceOFF]
xor	eax, eax
mov	al, es:[bx+di]
sub	eax, sndmidpoint
shr	si, 1
mov	cl, [bp+si]
DoSarSalNow
add	sndfullsum, eax
inc	si
dec	sndnumpacks
jnz	loopforvoice

mov	cl, sndsarsalcalc
mov	eax, sndfullsum
DoSarSalNow
add	al, sndmidpoint
mov	bx, [bp+sndvoiceOFF]
mov	es:[bx+di], al
inc	di
dec	sndsizepacks
jnz	loopforbytes








; -----------------------------------------------------------------------------------------------------------------------------
; DQBinstallSB FUNCTION
; purpose:
;   Initialized the SB and starts the realtime mixing. Returns 0 on successful
;   otherwise an error code.
; declaration:
;   DECLARE FUNCTION DQBinstallSB(BYVAL VolActive,BYVAL Channels,BYVAL Freq,
;                                 BYVAL BaseAddr,BYVAL IRQ,BYVAL DMA)
; -----------------------------------------------------------------------------------------------------------------------------


; -----------------------------------------------------------------------------------------------------------------------------
; DQBloadSound FUNCTION
; purpose:
;   Loads a sound sample into a specified sound slot. Sounds must be 8 bit
;   mono and their sampling rate must not be greater than 22000 Hz.
; declaration:
;   DECLARE FUNCTION xDQBloadSound(BYVAL Slot,BYVAL FileSeg,BYVAL FileOff)
;   DECLARE FUNCTION DQBloadSound(Slot AS INTEGER,FileName AS STRING)
; -----------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------
; DQBloadRawSound FUNCTION
; purpose:
;   Loads a sound sample into a specified sound slot. Sounds must be 8 bit
;   mono and their sampling rate must not be greater than 22000 Hz, although
;   this function does not check for the format to be supported.
;   DQBloadRawSound also requires the offset where the sound data begins into
;   the specified file, plus the sound length in bytes; in this way you can
;   store several sounds into the same file, and load them all using this
;   function.
; declaration:
;   DECLARE FUNCTION xDQBloadRawSound(BYVAL Slot,BYVAL FileSeg,BYVAL FileOff,
;                                     BYVAL Offset AS LONG,BYVAL Length)
;   DECLARE FUNCTION DQBloadRawSound(Slot AS INTEGER,FileName AS STRING,
;                                     Offset AS LONG,Length AS LONG)
; -----------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------
; DQBplaySound SUB
; purpose:
;   Plays a sound previously loaded in memory
; declaration:
;   DECLARE SUB DQBplaySound(BYVAL SoundNum,BYVAL Voice,BYVAL Freq,
;                            BYVAL LoopFlag)
; -----------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------
; DQBinUse FUNCTION
; purpose:
;   Returns true if a sound is currently being played on specified voice,
;   otherwise false.
; declaration:
;   DECLARE FUNCTION DQBinUse(BYVAL Voice)
; -----------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------
; DQBpauseSound SUB
; purpose:
;   Pauses the samples sound output
; declaration:
;   DECLARE SUB DQBpauseSound()
; -----------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------
; DQBresumeSound SUB
; purpose:
;   Resumes the samples sound output
; declaration:
;   DECLARE SUB DQBresumeSound()
; -----------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------
; DQBstopVoice SUB
; purpose:
;   Stops sound playing on specified voice
; declaration:
;   DECLARE SUB DQBstopVoice(BYVAL Voice)
; -----------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------
; DQBsetVoiceVol SUB
; purpose:
;   Sets the sound output volume of a voice
; declaration:
;   DECLARE SUB DQBsetVoiceVol(BYVAL Voice,BYVAL NewVol)
; -----------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------
; DQBremoveSB SUB
; purpose:
;   Turns off SB output
; declaration:
;   DECLARE SUB DQBremoveSB()
; -----------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------
; DQBsetFreq SUB
; purpose:
;   Alters the sampling rate of the specified channel.
;   You may change it from 4000 to 32766 for sampling rate.
; declaration:
;   DECLARE SUB DQBsetFreq(BYVAL Voice, BYVAL SampleRate)
; -----------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------
; DQBsetVolume SUB
; purpose:
;   Sets the master volume for sound output, in the range 0-15
; declaration:
;   DECLARE SUB DQBsetVolume(BYVAL Volume)
; -----------------------------------------------------------------------------------------------------------------------------

END

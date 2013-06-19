;--------------------------------------------------------------------------------
;		KEYBOARD MACHINE
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



.STACK 100h

EXTRN	LastError:WORD
EXTRN	LibReadHandle:WORD



;CONST
irq1					equ	9h*4
irqport					equ	20h
keyport					equ	60h
keytellport				equ	61h
extendedkey				equ	0E0h
keycurrentsize				equ	8
maxbuffersize				equ	256
keyfree1					equ	04
keyfree2					equ	06
keynumlocked				equ	2Ah
keyctrl					equ	1Dh
keyalt					equ	38h








.DATA
KeyActive					DB	0
OldKybdSEG				DW	0
OldKybdOFF				DW	0
KeyLastPress				DB	0
BreakKeySave				DB	1
KeyWasExtended				DB	0
KeyBuffer					DB	maxbuffersize DUP (0)
KeyCurrent				DB	keycurrentsize DUP (0)
KeyCurrentFlag				DB	16 DUP(0)
KeyBuuSize				DW	0
KeyBuuFront				DW	maxbuffersize-1
KeyBuuRear				DW	maxbuffersize-1
KeySimplify	DB	000h, 001h, 00Fh, 010h, 011h, 012h, 013h, 014h		;0
		DB	015h, 016h, 017h, 018h, 019h, 01Ah, 01Bh, 01Ch		;8
		DB	01Dh, 01Eh, 01Fh, 020h, 021h, 022h, 023h, 024h		;10
		DB	025h, 026h, 027h, 028h, 036h, 043h, 02Bh, 02Ch		;18
		DB	02Dh, 02Eh, 02Fh, 030h, 031h, 032h, 033h, 034h		;20
		DB	035h, 00Eh, 037h, 029h, 038h, 039h, 03Ah, 03Bh		;28
		DB	03Ch, 03Dh, 03Eh, 03Fh, 040h, 041h, 042h, 054h		;30
		DB	044h, 045h, 02Ah, 002h, 003h, 004h, 005h, 006h		;38
		DB	007h, 008h, 009h, 00Ah, 00Bh, 052h, 000h, 056h		;40
		DB	057h, 058h, 055h, 059h, 05Ah, 05Bh, 05Ch, 05Dh		;48
		DB	05Eh, 05Fh, 060h, 061h, 000h, 000h, 000h, 00Ch		;50
		DB	00Dh, 000h, 000h, 000h, 000h, 000h, 000h, 000h		;58
;		DB	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h		;60
;		DB	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h		;68
;		DB	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h		;70
;		DB	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h		;78
							;Simplification table

KeySpecials	DB	050h, 04Dh, 048h, 04Bh, 047h, 053h, 046h, 049h		;0
		DB	04Eh, 04Ah, 000h, 04Fh, 062h, 051h, 000h, 000h		;8
							;Special key simplification table


KeyControls	DB	000h, 001h, 002h, 003h, 004h, 005h, 006h, 007h		;0
		DB	008h, 009h, 00Ah, 00Bh, 00Ch, 00Dh, 00Eh, 00Fh		;8
		DB	010h, 011h, 012h, 013h, 014h, 015h, 016h, 017h		;10
		DB	018h, 019h, 01Ah, 01Bh, 01Ch, 01Dh, 01Eh, 01Fh		;18
		DB	020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h		;20
		DB	028h, 029h, 02Ah, 02Bh, 02Ch, 02Dh, 02Eh, 02Fh		;28
		DB	030h, 031h, 032h, 033h, 034h, 035h, 036h, 037h		;30
		DB	038h, 039h, 03Ah, 03Bh, 03Ch, 03Dh, 03Eh, 03Fh		;38
		DB	040h, 041h, 042h, 043h, 044h, 045h, 046h, 047h		;40
		DB	048h, 049h, 04Ah, 04Bh, 04Ch, 04Dh, 04Eh, 04Fh		;48
		DB	050h, 051h, 052h, 053h, 054h, 055h, 056h, 057h		;50
		DB	058h, 059h, 05Ah, 05Bh, 05Ch, 05Dh, 05Eh, 05Fh		;58
		DB	060h, 061h, 062h, 000h, 000h, 000h, 000h, 000h		;60
;		DB	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h		;68
;		DB	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h		;70
;		DB	000h, 000h, 000h, 000h, 000h, 000h, 000h, 000h		;78
							;Controls







;External SUBs
EXTRN	CopyMem:FAR
EXTRN	CopyMemFC:FAR



.CODE










; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------


; -----------------------------------------------------------------------------------------------------------------------------
; PushToKeyBuffer			INTERNAL FUNCTION
; Purpose:
;   Pushes data to the keyboard buffer
;
; Usage:
;   cl=data to push
;
; Returns:
;   bx=destroyed
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC PushToKeyBuffer
PushToKeyBuffer PROC
cmp	KeyBuuSize, maxbuffersize
jae	keybufferfull
inc	KeyBuuSize
dec	KeyBuuRear

keybufferfull:
inc	KeyBuuRear
cmp	KeyBuuRear, maxbuffersize
jb	queuerearok
sub	KeyBuuRear, maxbuffersize

queuerearok:
inc	KeyBuuFront
cmp	KeyBuuFront, maxbuffersize
jb	queuefrontok
sub	KeyBuuFront, maxbuffersize

queuefrontok:
mov	bx, KeyBuuFront
mov	KeyBuffer[bx], cl
retf
PushToKeyBuffer ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; StartKeyboard			INTERNAL FUNCTION
; Purpose:
;   Starts the keyboard
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StartKeyboard
StartKeyboard PROC
push2	es, ax
xor	ax, ax
mov	es, ax
mov	ax, es:[irq1+2]
mov	OldKybdSEG, ax
mov	ax, es:[irq1]
mov	OldKybdOFF, ax
mov	ax, SEG KeyboardISR
cli
mov	es:[irq1+2], ax
mov	ax, OFFSET KeyboardISR
mov	es:[irq1], ax
mov	KeyActive, 1
sti
pop2	es, ax
retf

KeyboardISR:
sti
push4	ds, ax, bx, cx
mov	ax, @DATA
mov	ds, ax
in	al, keyport
cmp	KeyWasExtended, 1
je	keyisextended
cmp	al, extendedkey
jne	keynotextended
mov	KeyWasExtended, 1
jmp	keyhandleover

keynotextended:
xor	bh, bh
mov	bl, al
and	bl, 7Fh
mov	bl, KeySimplify[bx]

keyextendedreach:
mov	cl, bl
or	al, al
js	keypressover
cmp	bl, KeyLastPress
jne	newkeypressed

pushtobuffer:
call	PushToKeyBuffer

keyhandleover:
in	al, keytellport
or	al, 80h
out	keytellport, al
mov	al, 20h
out	irqport, al
pop4	ds, ax, bx, cx
iret

keyisextended:
mov	KeyWasExtended, 0
mov	bl, al
and	bl, 7Fh
cmp	bl, keynumlocked
je	keyhandleover
cmp	bl, keyctrl
jne	keynotctrl
mov	bl, keyfree1

keynotctrl:
cmp	bl, keyalt
jne	keynotalt
mov	bl, keyfree2

keynotalt:
xor	bh, bh
and	bl, 0Fh
mov	bl, KeySpecials[bx]
jmp	keyextendedreach

keypressover:
mov	KeyLastPress, 0
or	cl,  80h
mov	ch, bl
mov	bx, keycurrentsize-1

findkey0:
cmp	KeyCurrent[bx], ch
je	gotkey0
dec	bx
jns	findkey0
jmp	keybreakdo

gotkey0:
mov	KeyCurrent[bx], 0

keybreakdo:
cmp	BreakKeySave, 1
je	pushtobuffer
jmp	keyhandleover

newkeypressed:
mov	KeyLastPress, bl
mov	ch, bl
mov	bx, keycurrentsize-1

findkey1:
cmp	KeyCurrent[bx], ch
je	pushtobuffer
dec	bx
jns	findkey1
mov	bx, keycurrentsize-1

findkey2:
cmp	KeyCurrent[bx], 0
je	gotkey1
dec	bx
jns	findkey2
jmp	pushtobuffer

gotkey1:
mov	KeyCurrent[bx], ch
jmp	pushtobuffer
StartKeyboard ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; StopKeyboard			INTERNAL FUNCTION
; Purpose:
;   Stops the keyboard
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StopKeyboard
StopKeyboard PROC
push2	es, ax
xor	ax, ax
mov	es, ax
cli
mov	ax, OldKybdSEG
mov	es:[irq1+2], ax
mov	ax, OldKybdOFF
mov	es:[irq1], ax
mov	KeyActive,0
sti
mov	KeyBuuSize, 0
mov	KeyBuuFront, maxbuffersize-1
mov	KeyBuuRear, maxbuffersize-1
pop2	es, ax
retf
StopKeyboard ENDP










; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------





; -----------------------------------------------------------------------------------------------------------------------------
; HZDstartKeyboard	SUB
;
; Purpose:
;   Starts the keyboard machine
;
; Declaration:
;   DECLARE SUB HZDstartKeyboard()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDstartKeyboard
HZDstartKeyboard PROC
cmp	KeyActive, 1
je	alreadyactive
call	StartKeyboard

alreadyactive:
retf
HZDstartKeyboard ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDstopKeyboard	SUB
;
; Purpose:
;   Stops the keyboard machine
;
; Declaration:
;   DECLARE SUB HZDstopKeyboard()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDstopKeyboard
HZDstopKeyboard PROC
cmp	KeyActive, 0
je	alreadyinactive
call	StopKeyboard

alreadyinactive:
retf
HZDstopKeyboard ENDP







; -----------------------------------------------------------------------------------------------------------------------------
; HZDkeyClear	SUB
;
; Purpose:
;   Clear the keyboard buffer
;
; Declaration:
;   DECLARE SUB HZDkeyClear()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDkeyClear
HZDkeyClear PROC
cli
mov	KeyBuuSize, 0
mov	KeyBuuFront, maxbuffersize-1
mov	KeyBuuRear, maxbuffersize-1
sti
retf
HZDkeyClear ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDrawKeyPressed	FUNCTION
;
; Purpose:
;   Gives the oldest key that was pressed(in RAW form)
;
; Declaration:
;   DECLARE FUNCTION HZDrawKeyPressed%()
;
; Returns:
;   last key pressed
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDrawKeyPressed
HZDrawKeyPressed PROC
xor	ax, ax
cmp	KeyBuuSize, 0
jz	keypressover
cli
dec	KeyBuuSize
inc	KeyBuuRear
cmp	KeyBuuRear, maxbuffersize
jb	pressqrearok
sub	KeyBuuRear, maxbuffersize

pressqrearok:
mov	bx, KeyBuuRear
mov	al, KeyBuffer[bx]
sti
xor	ah, ah

keypressover:
retf
HZDrawKeyPressed ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDkeyPressed	FUNCTION
;
; Purpose:
;   Gives the oldest key that was pressed
;
; Declaration:
;   DECLARE FUNCTION HZDkeyPressed%()
;
; Returns:
;   last key pressed
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDkeyPressed
HZDkeyPressed PROC
call	HZDrawKeyPressed
or	ax, ax
jz	keyrawover0
mov	bx, ax
and	al, 80h
and	bl, 7Fh
mov	bl, KeyControls[bx]
or	al, bl
xor	ah, ah

keyrawover0:
retf
HZDkeyPressed ENDP






; -----------------------------------------------------------------------------------------------------------------------------
; HZDkeyNowPressed	SUB
;
; Purpose:
;   Saves the keys that are now pressed. Can be got later by using
;   HZDkeyPressed() function to get keys one by one.
;
; Declaration:
;   DECLARE SUB HZDkeyNowPressed()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDkeyNowPressed
HZDkeyNowPressed PROC
push	si
mov	si, keycurrentsize-1

traverseloop:
mov	al, KeyCurrent[si]
or	al, al
jz	nokey0
mov	cl, al
call	PushToKeyBuffer

nokey0:
dec	si
jns	traverseloop
pop	si
retf
HZDkeyNowPressed ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDwaitRawKey SUB
;
; Purpose:
;   Wait for the user to press(after the requsted time) a specified key
;   (in raw form). Any key=-1
;   
; Declaration:
;   DECLARE SUB HZDwaitRawKey(BYVal rawKey%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDwaitRawKey
HZDwaitRawKey PROC
UseParam
mov	bx, param1
cmp	bx, -1
je	keywaitany

keywait1:
call	HZDkeyPressed
or	ax, ax
jz	keywait1
cmp	ax, bx
jne	keywait1
jmp	keywaitover

keywaitany:
call	HZDkeyPressed
or	ax, ax
jz	keywait1

keywaitover:
EndParam
retf	2
HZDwaitRawKey ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDwaitKey SUB
;
; Purpose:
;   Wait for the user to press(after the requsted time) a specified key.
;   Any key=-1
;   
; Declaration:
;   DECLARE SUB HZDwaitKey(BYVal aKey%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDwaitKey
HZDwaitKey PROC
UseParam
mov	bx, param1
cmp	bx, -1
je	keywaitany1
mov	bl, KeyControls[bx]

keywait11:
call	HZDkeyPressed
or	ax, ax
jz	keywait11
cmp	ax, bx
jne	keywait11
jmp	keywaitover1

keywaitany1:
call	HZDkeyPressed
or	ax, ax
jz	keywait11

keywaitover1:
EndParam
retf	2
HZDwaitKey ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDloadDefControls SUB
;
; Purpose:
;   Load the default key controls
;   
; Declaration:
;   DECLARE SUB HZDloadDefControls()
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDloadDefControls
HZDloadDefControls PROC
push4	fs, esi, es, di
mov	fs, LibReadHandle
mov	esi, keydefcontrolsADRS
mov	ax, @DATA
mov	es, ax
mov	di, OFFSET KeyControls
mov	cx, keydefcontrolsSIZE
call	CopyMemFC
pop4	fs, esi, es, di
retf
HZDloadDefControls ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDloadControls SUB
;
; Purpose:
;   Load key controls
;   
; Declaration:
;   DECLARE SUB HZDloadControls(BYVAL cntTYPE%, BYVAL cntSEG%, BYVAL cntOFF&)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDloadControls
HZDloadControls PROC
UseParam
push4	fs, esi, es, di
mov	ah, param4
mov	fs, param3
mov	esi, param1
push2	esi, esi
mov	di, ss
mov	es, di
mov	di, sp
mov	cx, 8
mov	al, 0
call	CopyMem
pop	esi
cmp	esi, datatypekeycontrols
pop	esi
jne	errkeycnt
add	esi, 8
mov	di, @DATA
mov	es, di
mov	di, OFFSET KeyControls
mov	cx, keydefcontrolsSIZE
call	CopyMem
sub	esi, 8

over99:
pop4	fs, esi, es, di
EndParam
retf	8

errkeycnt:
mov	LastError, errdatatypewrong
jmp	over99
HZDloadControls ENDP















END
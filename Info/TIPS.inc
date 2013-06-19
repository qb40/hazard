;--------------------------------------------------------------------------------
;			TIPS
;--------------------------------------------------------------------------------
; Part of HAZARD Library
; (a game/software programming library for QuickBasic 4.5 or similar)
; 
; Version: first
; by WolfRAM
;********************************************************************************
;
;
RETRIEVE DEF SEG SEGMENT
First trick is how to retrieve the DEF SEG'ed segment. A version can be found in the excellent ABC packets, that i submitted ages ago.

Note: I have found this to work in quick libraries!

First, declare the global (DGROUP) segment that QB uses. This is common to use in all functions to use that retrieves this info. Without it the linker wouldnt know what you are talking about.

CODE  SEGMENT WORD PUBLIC USE16 'CODE'
CODE  ENDS

_BSS  SEGMENT WORD PUBLIC USE16 'DATA'
_BSS  ENDS

_DATA SEGMENT WORD PUBLIC USE16 'DATA'
_DATA ENDS


DGROUP  GROUP _BSS

EXTRN   b$seg:WORD	; Tell linker we want to use this variable.
PUBLIC	MyRoutine	; Tell linker here is our routine

CODE SEGMENT
MyRoutine:
	mov ax, b$seg
	retf
CODE ENDS
END

Now declare in a basic file

DECLARE FUNCTION MyRoutine AS INTEGER

DEF SEG = &HA000
a% = MyRoutine
PRINT HEX$(a%)

a% should now be &HA000. It worked for me!
RETRIEVE VARIOUS SCREEN INFO
Second trick, how to retrieve the current screen mode information. This one is basically like the above, except a different variable.

* Warning * This does not work in a Quick library!

[ same as above ]

EXTRN b$ScreenMode:BYTE			; Current screen mode  (0,..,13)
EXTRN b$HorzRes:WORD			; Horizontal resolution (320,..,640)
EXTRN b$VertRes:WORD			; Vertical resolution (200,..,480)
EXTRN b$CharColor:BYTE			; Character color
EXTRN b$BFColors:WORD			; Character colors e.x:
					; AH = Background, AL = Foreground
EXTRN b$ForeColor:BYTE			; Character foreground color
EXTRN b$BackColor:BYTE			; Character background color

b$CharColor is a "special" case compared to the others above. The highnibble is the background color, the lownibble is foreground. The funny thing is, b$BackColor has the background color too, but no extra twiddling is necessary, and b$ForeColor has the foreground color. The use of b$CharColor is primarily assembly usage, as it requires shifting etc. To convert Foreground, Background colors to b$CharColor do this:

(Background*2^4)+ForeGround

Or in assembly terms:

mov al, Background
shl al, 4
xor al, Foreground

;--------------------------------------------------------------------------------
;			USEFUL MACROS
;--------------------------------------------------------------------------------
; Part of HAZARD Library
; (a game/software programming library for QuickBasic 4.5 or similar)
; 
; Version: first
; by WolfRAM
;********************************************************************************




Null			MACRO	var
xor	var, var
ENDM

Nullx			MACRO	var
mov	var, 0
ENDM

UseParam		MACRO
push	bp
mov	bp, sp
ENDM

EndParam		MACRO
pop	bp
ENDM

movx			MACRO	dest, src, dummy
mov	dummy, src
mov	dest, dummy
ENDM

cmpx			MACRO	dest, src, dummy
mov	dummy, src
cmp	dest, dummy
ENDM

addx			MACRO	dest, src, dummy
mov	dummy, src
add	dest, dummy
ENDM

xchgx			MACRO	dest, src, dummy
mov	dummy, src
xchg	dest, dummy
mov	src, dummy
ENDM

pushx			MACRO	src, dummy
mov	dummy, src
push	dummy
ENDM


LookToData		MACRO
mov	ax, @DATA
mov	ds, ax
ENDM


GetInterrupt		MACRO	Interrupt, IntSeg, IntOff
push	ds
push	bx
push	ax
mov	bx, Interrupt
shl	bx, 2
movx	ds:[bx], IntSeg, ax
movx	ds:[bx+2], IntOff, ax
pop	ax
pop	bx
pop	ds
ENDM

SetInterrupt		MACRO	Interrupt, IntSeg, IntOff
push	ds
push	bx
push	ax
mov	bx, Interrupt
shl	bx, 2
movx	IntSeg, ds:[bx], ax
movx	IntOff, ds:[bx+2], ax
pop	ax
pop	bx
pop	ds
ENDM


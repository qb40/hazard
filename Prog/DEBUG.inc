;--------------------------------------------------------------------------------
;		DEBUGGING MACHINE
;--------------------------------------------------------------------------------
; Part of HAZARD Library
; (a game/software programming library for QuickBasic 4.5 or similar)
; 
; Version: first
; by WolfRAM
;********************************************************************************




.MODEL Large, Basic

.386


.STACK 100h

.DATA

.CODE

;************************************************************************************************************************
; HZDdebugNum SUB
; purpose:
; Displays the number at the given index in the screen
; uses:
; ax=number bx=address
;************************************************************************************************************************
EVEN
PUBLIC HZDdebugNum
HZDdebugNum PROC
push	ax
push	bx
push	cx
push	es
and	bx, 0FFFEh
mov	cx, 0B800h
mov	es, cx
mov	cl, ah
shr	cl, 4
cmp	cl, 10
jb	debugOk1
add	cl, 'A'-'0'-10

debugOk1:
add	cl, '0'
mov	es:[bx], cl
mov	BYTE PTR es:[bx+1], 7
mov	cl, ah
and	cl, 0Fh
cmp	cl, 10
jb	debugOk2
add	cl, 'A'-'0'-10

debugOk2:
add	cl, '0'
mov	es:[bx+2], cl
mov	BYTE PTR es:[bx+3], 7
mov	cl, al
shr	cl, 4
cmp	cl, 10
jb	debugOk3
add	cl, 'A'-'0'-10

debugOk3:
add	cl, '0'
mov	es:[bx+4], cl
mov	BYTE PTR es:[bx+5], 7
mov	cl, al
and	cl, 0Fh
cmp	cl, 10
jb	debugOk4
add	cl, 'A'-'0'-10

debugOk4:
add	cl, '0'
mov	es:[bx+6], cl
mov	BYTE PTR es:[bx+7], 7
pop	es
pop	cx
pop	bx
pop	ax
ret

HZDdebugNum ENDP


END
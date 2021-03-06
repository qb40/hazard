;--------------------------------------------------------------------------------
;			USEFUL PUSHES AND POPS
;--------------------------------------------------------------------------------
; Part of HAZARD Library
; (a game/software programming library for QuickBasic 4.5 or similar)
; 
; Version: first
; by WolfRAM
;********************************************************************************



push2				MACRO	a, b
push	a
push	b
ENDM


push3				MACRO	a, b, c
push	a
push	b
push	c
ENDM


push4				MACRO	a, b, c, d
push	a
push	b
push	c
push	d
ENDM


push5				MACRO	a, b, c, d, e
push	a
push	b
push	c
push	d
push	e
ENDM


push6				MACRO	a, b, c, d, e, f
push	a
push	b
push	c
push	d
push	e
push	f
ENDM


push7				MACRO	a, b, c, d, e, f, g
push	a
push	b
push	c
push	d
push	e
push	f
push	g
ENDM


push8				MACRO	a, b, c, d, e, f, g, h
push	a
push	b
push	c
push	d
push	e
push	f
push	g
push	h
ENDM


push9				MACRO	a, b, c, d, e, f, g, h, i
push	a
push	b
push	c
push	d
push	e
push	f
push	g
push	h
push	i
ENDM



push10				MACRO	a, b, c, d, e, f, g, h, i, j
push	a
push	b
push	c
push	d
push	e
push	f
push	g
push	h
push	i
push	j
ENDM


pop2				MACRO	a, b
pop	b
pop	a
ENDM


pop3				MACRO	a, b, c
pop	c
pop	b
pop	a
ENDM


pop4				MACRO	a, b, c, d
pop	d
pop	c
pop	b
pop	a
ENDM


pop5				MACRO	a, b, c, d, e
pop	e
pop	d
pop	c
pop	b
pop	a
ENDM


pop6				MACRO	a, b, c, d, e, f
pop	f
pop	e
pop	d
pop	c
pop	b
pop	a
ENDM


pop7				MACRO	a, b, c, d, e, f, g
pop	g
pop	f
pop	e
pop	d
pop	c
pop	b
pop	a
ENDM



pop8				MACRO	a, b, c, d, e, f, g, h
pop	h
pop	g
pop	f
pop	e
pop	d
pop	c
pop	b
pop	a
ENDM



pop9				MACRO	a, b, c, d, e, f, g, h, i
pop	i
pop	h
pop	g
pop	f
pop	e
pop	d
pop	c
pop	b
pop	a
ENDM




pop10				MACRO	a, b, c, d, e, f, g, h, i, j
pop	j
pop	i
pop	h
pop	g
pop	f
pop	e
pop	d
pop	c
pop	b
pop	a
ENDM



;--------------------------------------------------------------------------------
;				MEMORY DATA
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










;======================EMS copy data structure======================
_emscopy_strucsize					equ	18
_emscopy_numbytes					equ	0
_emscopy_srctype					equ	4
_emscopy_srchandle					equ	5
_emscopy_srcoff						equ	7
_emscopy_srcseg						equ	9
_emscopy_destype					equ	11
_emscopy_deshandle					equ	12
_emscopy_desoff						equ	14
_emscopy_desseg						equ	16
;======================EMS copy data structure======================




;======================XMS copy data structure======================
_xmscopy_strucsize					equ	16
_xmscopy_numbytes					equ	0
_xmscopy_srchandle					equ	4
_xmscopy_srcoff						equ	6
_xmscopy_srcseg						equ	8
_xmscopy_deshandle					equ	10
_xmscopy_desoff						equ	12
_xmscopy_desseg						equ	14
;======================XMS copy data structure======================







;======================EMS copy data usage======================
emscopy_numbytes					equ	[bp+_emscopy_numbytes]
emscopy_numbyteslo					equ	[bp+_emscopy_numbytes]
emscopy_numbyteshi					equ	[bp+_emscopy_numbytes+2]
emscopy_srctype						equ	[bp+_emscopy_srctype]
emscopy_srchandle					equ	[bp+_emscopy_srchandle]
emscopy_srcoff						equ	[bp+_emscopy_srcoff]
emscopy_srcseg						equ	[bp+_emscopy_srcseg]
emscopy_destype						equ	[bp+_emscopy_destype]
emscopy_deshandle					equ	[bp+_emscopy_deshandle]
emscopy_desoff						equ	[bp+_emscopy_desoff]
emscopy_desseg						equ	[bp+_emscopy_desseg]
;======================EMS copy data usage======================








;======================XMS copy data usage======================
xmscopy_numbytes					equ	[bp+_xmscopy_numbytes]
xmscopy_numbyteslo					equ	[bp+_xmscopy_numbytes]
xmscopy_numbyteshi					equ	[bp+_xmscopy_numbytes+2]
xmscopy_srchandle					equ	[bp+_xmscopy_srchandle]
xmscopy_srcoff						equ	[bp+_xmscopy_srcoff]
xmscopy_srcseg						equ	[bp+_xmscopy_srcseg]
xmscopy_deshandle					equ	[bp+_xmscopy_deshandle]
xmscopy_desoff						equ	[bp+_xmscopy_desoff]
xmscopy_desseg						equ	[bp+_xmscopy_desseg]
;======================XMS copy data usage======================




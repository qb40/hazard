;--------------------------------------------------------------------------------
;			FONT USE DETAILS
;--------------------------------------------------------------------------------
; Part of HAZARD Library
; (a game/software programming library for QuickBasic 4.5 or similar)
; 
; Version: first
; by WolfRAM
;********************************************************************************
;
;
;
;FONT DATA FORMAT
;........................
; [Font type]dw
; [Data size]dw
; [Offset to preferred palette(in file)][Reserved(in memory)]dw
; [Character range(byte0-byte1)]w
; [Font resolution(x*y)]dw
; START of font data
;.......................
;
;
; FONT 0
;	EMS page		-	7
;	EMS offset	-	0
;
; FONT 1
;	EMS page		-	8
;	EMS offset	-	0
;
; Max. permitted size for each font character	-	256 bytes
;
;
; Larger fonts be be used by direct from file method.
; Font storage will be bytewise, not bitwise.
;
;
;
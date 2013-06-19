;--------------------------------------------------------------------------------
;			STRING DETAILS
;--------------------------------------------------------------------------------
; Part of HAZARD Library
; (a game/software programming library for QuickBasic 4.5 or similar)
; 
; Version: first
; by WolfRAM
;********************************************************************************
;
;
How to use string from Qbasic
In place of the string a near offset to the string pointer is pushed.
String pointer is in data segment.
String Pointer is somewhat like this
0	WORD	Length
2	WORD	NEAR Offset to actual string


How to return string to Qbasic
Let ax=near offset to String Pointer.
String pointer is in data segment.
String Pointer is somewhat like this
0	WORD	Length
2	WORD	NEAR Offset to actual string


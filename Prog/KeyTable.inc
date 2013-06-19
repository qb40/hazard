;--------------------------------------------------------------------------------
;		KEYBOARD TABLES
;--------------------------------------------------------------------------------
; Part of HAZARD Library
; (a game/software programming library for QuickBasic 4.5 or similar)
; 
; Version: first
; by WolfRAM
;********************************************************************************




KeyActive		DB	0			;Is Hazard Key machine active?
KeyOldSeg		DW	0			;Old Key machine
KeyOldOff		DW	0			;Old Key machine
KeyLastPress		DB	0			;Last pressed key
KeyBuffer		DB 128 DUP(0)			;The keyboard buffer(circular queue)
KeyBuuSize		equ	128			;Buffer Size
KeyBuuNum		DW	0			;Buffer Used
KeyBuuFirst		equ	0			;Buffer Start(0)
KeyBuuLast		equ	128			;Buffer End(Start+Size)
KeyBuuFront		DW	0			;Front end(push)
KeyBuuRear		DW	128			;Rear end(pop)
KeyCurrent		DW 8 DUP(0)			;Currently pressed keys

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


KeyControl	DB	000h, 001h, 002h, 003h, 004h, 005h, 006h, 007h		;0
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

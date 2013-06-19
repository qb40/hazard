;--------------------------------------------------------------------------------
;			FILE HANDLE DETAILS
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
;
;
; OFFSET 00	-	WORD
;	DOS handle of the file.
;
; OFFSET 02	-	WORD
;	Number of data packs(for special file only).
;
; OFFSET 04	-	DWORD
;	Offset to data pack name table(for special file only).
;
; OFFSET 08	-	DWORD
;	Offset to data pack type table(for special file only).
;
; OFFSET 12	-	DWORD
;	Offset to data pack address table(for special file only).
;
;
; Total size of one File Handle		-	16 bytes
; Total number of File Handles		-	256
; Total Size of File Handle Table	-	4096 bytes
;						[4K]
;
; EMS page used for the purpose	-	4
; EMS offset used		-	61440
;					[0F000h]
;
;
;
;
;
;
;

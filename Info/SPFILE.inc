;--------------------------------------------------------------------------------
;			SPECIAL FILE DETAILS
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
The Special File format is as follows

FILE BEGIN
Byte 0:			8BYTES	“HZD File”
Byte 8:			DWORD	Offset to File info
Byte 12:		DWORD	Length of full file
Byte 16:		DWORD	Reserved(File Checksum)


FILE TABLE
Byte 20:		DWORD	File Table size
Byte 24:		WORD	Number of Data Packets
Byte 26:		DWORD	Offset to name list
Byte 30:		DWORD	Offset to type list
Byte 34:		DWORD	Offset to number list


FILE NAME LIST			(relative offsets)
Byte 0:			DWORD	Name list size
Byte 4:			WORD	Minimum name check bytes
Byte 6:			LASCIZ Name0, LASCIZ Name1, etc.
Byte last:		WORD	Zero(0000h)


FILE TYPE LIST			(relative offsets)
Byte 0:			DWORD	Type list size
Byte 4:			LASCIZ Typex, LASCIZ Typey, etc.
Byte last:		WORD	Zero(0000h)


FILE DATA PACKET NUMBER LIST	(relative offsets)
Byte 0:			DWORD	Datapacket number list size
Byte 4:			NumList0, NumList0, etc.
Byte last:		WORD	Zero(0000h)


NUMLIST				(relative offsets)
Byte 0:			DWORD	Offset to Name
Byte 4:			DWORD	Offset to Data Packet Type, Type name
Byte 8:			DWORD	Offset to Data Packet
Byte 12:		DWORD	Data Packet size


DATA PACKET			(relative offsets)
Byte 0:			DWORD	Data Packet Type
Byte 4:			DWORD	Data Packet size
Byte 8:			Data(that is needed)


FILE INFO
Byte 0:			DWORD	Offset to file name
Byte 4:			DWORD	Offset to author name
Byte 8:			DWORD	Offset to package name
Byte 12:		DWORD	Offset to etc.

Byte x:			LASCIZ File Name
Byte y:			LASCIZ Author Name
Byte z:			LASCIZ Package Name
Byte ?: etc.



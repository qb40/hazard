;--------------------------------------------------------------------------------
;			VOICE TABLE DETAILS
;--------------------------------------------------------------------------------
; Part of HAZARD Library
; (a game/software programming library for QuickBasic 4.5 or similar)
; 
; Version: first
; by WolfRAM
;********************************************************************************
;
;
VoiceTablesSEG		-	5


OFFSET

001	BYTE	Voice0 active?(0-no,1-yes)
002	BYTE	Voice1 active?(0-no,1-yes)
...

017	BYTE	Voice0 priority/volume(max=15)
018	BYTE	Voice1 priotity/volume
...

033	BYTE	Voice0 temp priority/volume(max=15)
034	BYTE	Voice1 temp priority/volume
...

033	BYTE	Voice0 source type(CONV/EMS/XMS/FILE)
034	BYTE	Voice1 source type(CONV/EMS/XMS/FILE)
...

033	WORD	Voice0 source seg
034	WORD	Voice1 source seg
...

033	DWORD	Voice0 source off
034	DWORD	Voice1 source off
...

033	BYTE	Voice0 type(PCM/ADPCM/etc)
034	BYTE	Voice1 type(PCM/ADPCM/etc)
...

033	DWORD	Voice0 size left
034	DWORD	Voice1 size left
...

033	BYTE	Voice0 time constant
034	BYTE	Voice1 time constant
...

033	DWORD	Voice0 size pass per unit time
034	DWORD	Voice1 size pass per unit time
...

033	BYTE	Voice0 mode req(lo/hi)
034	BYTE	Voice1 mode req(lo/hi)
...

000	BYTE	Number of Voices active(max=16)
000	BYTE	Master Volume(virtual)(max=3)
000	BYTE	Master Volume(real)(max=7)
000	BYTE	Current mode(lo/hi)
000	BYTE	Current style(single/auto)
000	BYTE	Current time constant
000	BYTE	Current way of working(RealMix/VirtMix)
000	BYTE	Current way of working(RealMix/VirtMix)







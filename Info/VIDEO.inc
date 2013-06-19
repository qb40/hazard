;--------------------------------------------------------------------------------
;			VIDEO USE DETAILS
;--------------------------------------------------------------------------------
; Part of HAZARD Library
; (a game/software programming library for QuickBasic 4.5 or similar)
; 
; Version: first
; by Subhajit Sahu
;********************************************************************************
;
;
;
;VIDEO DATA FORMAT
;........................
; [Video type(1/2/3)]dw
; [Data size]dw
; [Offset to preferred palette(in file)][Reserved(in memory)]dw
; [Number of slides]dw
; [Font resolution(x*y)]dw
; START of video data
;.......................
;
;
; Video can be of 4 different formats
; 1. DIRECT PIXEL FORMAT
;    This one is just like RAW image set which however includes an extra of waitnumber facility
; 2. DELTA PIXEL FORMAT
;    This one first giver RAW image and the colour is given by 4-bit delta. Also includes
;    waitnumber facility.
; 3. DIRECT PIXEL REPEAT BYTE control FORMAT
;    Extra feature of compressed repeat bytes
; 4. DELTA PIXEL REPEAT NIBBLE control FORMAT
;    Extra feature of compressed repeat nibbles(also bytes in slide0)
;
;
1. DIRECT PIXEL FORMAT
[SLIDE0]? [WAIT TIMES]b [SLIDE1]? [WAIT TIMES]b ...

2. DELTA PIXEL FORMAT
[8-BIT SLIDE0]? [WAIT TIMES]b [4-BIT/8-BIT MASK]b [4-BIT/8-BIT SLIDE1]? [WAIT TIMES]b ...

3. DIRECT PIXEL REPEAT BYTE control FORMAT
[SLIDE0]? [WAIT TIMES]b [SLIDE1]? [WAIT TIMES]b ...
{SLIDE DETAILS} [NUM BYTES OF ABSOLUTE DATA]w [ABSOLUTE DATA]? [NUM BYTES OF COPY DATA]w [COPY DATA]b...

4. DELTA PIXEL REPEAT NIBBLE control FORMAT
[RESERVED(0b)]b [8-BIT SLIDE0]? [WAIT TIMES]b [4-BIT/8-BIT MASK]b [4-BIT/8-BIT SLIDE1]? [WAIT TIMES]b ...
{4-BIT SLIDE DETAILS} [NUM NIBBLES OF ABSOLUTE DATA]w [ABSOLUTE DATA]? [NUM NIBBLES OF COPY DATA]w [COPY DATA]b...
{8-BIT SLIDE DETAILS} [NUM NIBBLES OF ABSOLUTE DATA]w [ABSOLUTE DATA]? [NUM NIBBLES OF COPY DATA]w [COPY DATA]b...

Note: Each slide starts with relative offset to next slide in all cases


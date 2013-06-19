DECLARE FUNCTION BoxInput$ (n$, y%, pass%)
DECLARE SUB SetPalette ()
DECLARE SUB Help ()
DECLARE SUB FileName (a$)
DECLARE SUB Character (a%)
DECLARE SUB Message (a$)
DECLARE SUB MessageDestroy ()
DECLARE SUB SuperSeek (file1%, pos1&)
DECLARE SUB FontPset (x%, y%, clr%)
DECLARE SUB LoadChar (ch%)
DECLARE SUB SaveChar (ch%)
DECLARE SUB Create ()
DECLARE SUB NewFile ()
DECLARE SUB OldFile ()

CONST FONTDATABEGIN = 21, LASTLINE = 19
CONST FONTBUFFERSIZE = 2500 - 1
CONST CHARACTERX = 27, CHARACTERY = 11
CONST FILENAMEX = 27, FILENAMEY = 3, FILENAMESIZE = 20
CONST MESSAGEX = 27, MESSAGEY = 13, MESSAGESIZE = 12, MESSAGEHOLDTIME = 5



'Declaring Keys
CONST kbackspc = 8, kenter = 13, ktab = 9, kesc = 27
CONST kleft = 75, kright = 77, kup = 72, kdown = 80
CONST kuplt = 71, kuprt = 73, kdnlt = 79, kdnrt = 81
CONST kinsert = 82, khome = 73, kpageup = 71
CONST kdel = 83, kend = 81, kpagedn = 79
CONST kf1 = 59, kf2 = 60, kf3 = 61, kf4 = 62, kf5 = 63, kf6 = 64
CONST kf7 = 65, kf8 = 66, kf9 = 67, kf10 = 68, kf11 = 133, kf12 = 134
'Keys declared



'Global Variables
DIM SHARED FontBuffer(100, 100) AS INTEGER
DIM SHARED FontType&, DataSize&, PaletteOff&
DIM SHARED FontStart%, FontStop%, FontCharacter%
DIM SHARED FontXdisp%, FontYdisp%, BorderColour%
DIM SHARED FontXres%, FontYres%, FontSize&
DIM SHARED MessageStart!, FontFile$



DO
CLS
SCREEN 13
SetPalette
COLOR 48
LOCATE 1, 20
PRINT "HAZARD Font Designer"
FontFile$ = BoxInput$("Font name", 4, 0)

recreate:
OPEN "B", #1, FontFile$
IF (LOF(1) = 0) THEN NewFile
OldFile
Create
Message "Press a key.Press F12 toreload file.Press Esc toexit."
CLOSE #1
k$ = ""
WHILE k$ = ""
k$ = INKEY$
WEND
IF (k$ = CHR$(0) + CHR$(kf12)) THEN GOTO recreate
LOOP UNTIL k$ = CHR$(kesc)
SYSTEM

FUNCTION BoxInput$ (n$, y%, pass%)

'Save Background
DEF SEG = &HA000
BSAVE "FONTMAKE.TMP", 0, 64000
SHELL "ATTRIB FONTMAKE.TMP +H"

COLOR 196
LOCATE y%, 1, 0
PRINT "Õ"; STRING$(35, "Í"); "¸";
LOCATE y% + 1, 1, 0
PRINT "³ "; n$; STRING$(34 - LEN(n$), " "); "³";
LOCATE y% + 2, 1, 0
PRINT "Ã"; STRING$(35, "Ä"); "´";
LOCATE y% + 3, 1, 0
PRINT "³"; STRING$(35, " "); "³";
LOCATE y% + 4, 1, 0
PRINT "À"; STRING$(35, "Í"); "Ù";
COLOR 48
y1% = y% + 3
LOCATE y1%, 3, 0
PRINT STRING$(33, " ");
LOCATE y1%, 3, 1
a$ = ""
DO
k% = ASC(INPUT$(1))
IF (k% = kbackspc) THEN
IF (LEN(a$) <> 0) THEN
x% = 2 + LEN(a$)
LOCATE y1%, x%, 0
PRINT " ";
a$ = LEFT$(a$, LEN(a$) - 1)
x% = x%
LOCATE y1%, x%, 1
END IF
ELSEIF (k% = kesc) THEN
a$ = ""
LOCATE y1%, 3, 0
PRINT STRING$(33, " ");
LOCATE y1%, 3, 1
ELSEIF (k% = kenter) THEN
EXIT DO
ELSEIF (k% >= 32 AND k% <= 126) THEN
IF (LEN(a$) < 30) THEN
B$ = CHR$(k%)
x% = 3 + LEN(a$)
LOCATE y1%, x%, 0
IF (pass%) THEN PRINT "è";  ELSE PRINT B$;
a$ = a$ + B$
x% = x% + 1
LOCATE y1%, x%, 1
END IF
END IF
LOOP

'Load Background
SHELL "ATTRIB FONTMAKE.TMP -H"
BLOAD "FONTMAKE.TMP", 0
KILL "FONTMAKE.TMP"
DEF SEG
BoxInput$ = a$
END FUNCTION

SUB Character (a%)

COLOR 48
LOCATE CHARACTERY, CHARACTERX
PRINT "Character:"; CHR$(a%);
END SUB

SUB Create

DEF SEG = &HA000
BSAVE "FONTMAK2.TMP", 0, 64000
SHELL "ATTRIB FONTMAK2.TMP +H"
DEF SEG

'Draw the Control Area
LINE (210, 120)-(211 + FontXres%, 121 + FontYres%), 15, B
LoadChar FontCharacter%
BorderColour% = 255
FOR i% = 0 TO FontXres% - 1
FOR j% = 0 TO FontYres% - 1
FontPset i%, j%, FontBuffer(i%, j%)
NEXT
NEXT

'Varible Start
CursorX% = 0
CursorY% = 0
CursorClr% = 1
ChangesMade% = 0
BorderColour% = CursorClr%
FontPset CursorX%, CursorY%, FontBuffer(CursorX%, CursorY%)
Character FontCharacter%





'Main Loop
DO
k$ = ""
WHILE k$ = ""
k$ = INKEY$
WEND
MessageDestroy
k$ = UCASE$(k$)

optionselect:
SELECT CASE k$

CASE CHR$(0) + CHR$(kup)
BorderColour% = 255
FontPset CursorX%, CursorY%, FontBuffer(CursorX%, CursorY%)
IF (CursorY% > 0) THEN CursorY% = CursorY% - 1
BorderColour% = CursorClr%
FontPset CursorX%, CursorY%, FontBuffer(CursorX%, CursorY%)

CASE CHR$(0) + CHR$(kdown)
BorderColour% = 255
FontPset CursorX%, CursorY%, FontBuffer(CursorX%, CursorY%)
IF (CursorY% < FontYres% - 1) THEN CursorY% = CursorY% + 1
BorderColour% = CursorClr%
FontPset CursorX%, CursorY%, FontBuffer(CursorX%, CursorY%)

CASE CHR$(0) + CHR$(kleft)
BorderColour% = 255
FontPset CursorX%, CursorY%, FontBuffer(CursorX%, CursorY%)
IF (CursorX% > 0) THEN CursorX% = CursorX% - 1
BorderColour% = CursorClr%
FontPset CursorX%, CursorY%, FontBuffer(CursorX%, CursorY%)

CASE CHR$(0) + CHR$(kright)
BorderColour% = 255
FontPset CursorX%, CursorY%, FontBuffer(CursorX%, CursorY%)
IF (CursorX% < FontXres% - 1) THEN CursorX% = CursorX% + 1
BorderColour% = CursorClr%
FontPset CursorX%, CursorY%, FontBuffer(CursorX%, CursorY%)

CASE CHR$(kenter)
k$ = BoxInput$("Enter Task", 4, 0)
k$ = "TASK:" + UCASE$(k$)
GOTO optionselect

CASE "4"
CursorClr% = (256 + CursorClr% - 1) MOD 256
BorderColour% = CursorClr%
FontPset CursorX%, CursorY%, FontBuffer(CursorX%, CursorY%)
Message "Colour " + STR$(CursorClr%) + "   "

CASE "6"
CursorClr% = (256 + CursorClr% + 1) MOD 256
BorderColour% = CursorClr%
FontPset CursorX%, CursorY%, FontBuffer(CursorX%, CursorY%)
Message "Colour " + STR$(CursorClr%) + "   "

CASE "5"
FontBuffer(CursorX%, CursorY%) = CursorClr%
FontPset CursorX%, CursorY%, CursorClr%
Message "Draw.              "
ChangesMade% = 1

CASE CHR$(0) + CHR$(kf1)
Help

CASE CHR$(0) + CHR$(kf5)
BorderColour% = 255
FOR i% = 0 TO FontXres% - 1
FOR j% = 0 TO FontYres% - 1
FontPset i%, j%, FontBuffer(i%, j%)
NEXT
NEXT
BorderColour% = CursorClr%
FontPset CursorX%, CursorY%, FontBuffer(CursorX%, CursorY%)
Message "Refresh.          "

CASE CHR$(0) + CHR$(kf9)
SaveChar FontCharacter%
Message "Character " + CHR$(FontCharacter%) + " Saved."
ChangesMade% = 0

CASE CHR$(0) + CHR$(kf12)
IF (ChangesMade%) THEN
k$ = BoxInput$("Save Character?", 4, 0)
k$ = LCASE$(LEFT$(k$, 1))
IF (k$ = "y") THEN
SaveChar FontCharacter%
Message "Character " + CHR$(FontCharacter%) + " Saved."
ChangesMade% = 0
END IF
END IF
k$ = BoxInput$("Enter Character or ASCII", 4, 0)
IF (VAL(k$) <> 0) THEN
a% = VAL(k$)
ELSEIF (LEN(k$) = 3 AND LEFT$(k$, 1) = CHR$(34)) THEN
a% = ASC(MID$(k$, 2, 1))
ELSE
a% = ASC(k$)
END IF
LoadChar FontCharacter%
Character FontCharacter%
k$ = CHR$(0) + CHR$(kf5)
GOTO optionselect

CASE "A"
IF (ChangesMade%) THEN
k$ = BoxInput$("Save Character?", 4, 0)
k$ = LCASE$(LEFT$(k$, 1))
IF (k$ = "y") THEN
SaveChar FontCharacter%
Message "Character " + CHR$(FontCharacter%) + " Saved."
ChangesMade% = 0
END IF
END IF
FontCharacter% = FontCharacter% - 1
IF (FontCharacter% < FontStart%) THEN FontCharacter% = FontStop%
LoadChar FontCharacter%
Character FontCharacter%
k$ = CHR$(0) + CHR$(kf5)
GOTO optionselect

CASE "D"
IF (ChangesMade%) THEN
k$ = BoxInput$("Save Character?", 4, 0)
k$ = LCASE$(LEFT$(k$, 1))
IF (k$ = "y") THEN
SaveChar FontCharacter%
Message "Character " + CHR$(FontCharacter%) + " Saved."
ChangesMade% = 0
END IF
END IF
FontCharacter% = FontCharacter% + 1
IF (FontCharacter% > FontStop%) THEN FontCharacter% = FontStart%
LoadChar FontCharacter%
Character FontCharacter%
k$ = CHR$(0) + CHR$(kf5)
GOTO optionselect

CASE CHR$(kesc)
IF (ChangesMade%) THEN
k$ = BoxInput$("Save Character?", 4, 0)
k$ = LCASE$(LEFT$(k$, 1))
IF (k$ = "y") THEN
SaveChar FontCharacter%
Message "Character " + CHR$(FontCharacter%) + " Saved."
END IF
END IF
EXIT DO

CASE "TASK:HELP"
k$ = CHR$(0) + CHR$(kf1)
GOTO optionselect

CASE "TASK:COLOUR"
k$ = BoxInput$("Enter Colour Number", 4, 0)
a% = VAL(k$)
CursorClr% = a% MOD 256
BorderColour% = CursorClr%
FontPset CursorX%, CursorY%, FontBuffer(CursorX%, CursorY%)

CASE "TASK:SAVE"
k$ = CHR$(0) + CHR$(kf9)
GOTO optionselect

CASE "TASK:EXIT"
k$ = CHR$(kesc)
GOTO optionselect

CASE "TASK:QUIT"
k$ = CHR$(kesc)
GOTO optionselect

CASE "TASK:LOAD"
k$ = CHR$(0) + CHR$(kf12)
GOTO optionselect

CASE "TASK:SAVE AS"
k$ = BoxInput$("Enter Character or ASCII", 4, 0)
IF (VAL(k$) <> 0) THEN
a% = VAL(k$)
ELSEIF (LEN(k$) = 3 AND LEFT$(k$, 1) = CHR$(34)) THEN
a% = ASC(MID$(k$, 2, 1))
ELSE
a% = ASC(k$)
END IF
SWAP FontCharacter%, a%
SaveChar FontCharacter%
Character FontCharacter%
Message "Character " + CHR$(a%) + " Saved As " + CHR$(FontCharacter%) + "."
ChangesMade% = 0
a% = FontCharacter%
LoadChar a%
Character a%
k$ = CHR$(0) + CHR$(kf5)
GOTO optionselect

CASE ELSE
IF (LEN(k$) > 5) THEN
IF (LEFT$(k$, 5) = "TASK:") THEN
k$ = MID$(k$, 6, LEN(k$) - 5)
DEF SEG = &HA000
BSAVE "FONTMAK4.TMP", 0, 64000
SHELL "ATTRIB FONTMAK4.TMP +H"
DEF SEG
SHELL k$
DEF SEG = &HA000
SHELL "ATTRIB FONTMAK4.TMP -H"
BLOAD "FONTMAK4.TMP", 0
KILL "FONTMAK4.TMP"
DEF SEG
END IF
END IF

END SELECT

LOOP

DEF SEG = &HA000
SHELL "ATTRIB FONTMAK2.TMP -H"
BLOAD "FONTMAK2.TMP", 0
KILL "FONTMAK2.TMP"
DEF SEG
END SUB

SUB FileName (a$)

COLOR 196
LOCATE FILENAMEY, FILENAMEX
PRINT a$;
END SUB

SUB FontPset (x%, y%, clr%)

pos1x% = x% * FontXdisp%
pos1y% = y% * FontYdisp%
pos2x% = pos1x% + FontXdisp% - 1
pos2y% = pos1y% + FontYdisp% - 1
LINE (pos1x%, pos1y%)-(pos2x%, pos2y%), clr%, BF
LINE (pos1x%, pos1y%)-(pos2x%, pos2y%), BorderColour%, B
PSET (211 + x%, 121 + y%), clr%
END SUB

SUB Help
'Save Background
DEF SEG = &HA000
BSAVE "FONTMAK3.TMP", 0, 64000
SHELL "ATTRIB FONTMAK3.TMP +H"

CLS
COLOR 64
PRINT "HAZARD FontMake HELP"
COLOR 13
PRINT "--------------------"
PRINT
PRINT
COLOR 12
PRINT "Arrow keys    -       Move cursor"
PRINT "4, 6          -       Change Colour"
PRINT "5             -       Draw pixel"
PRINT "A, D          -       Prev/Next character"
PRINT "F1            -       Help"
PRINT "F5            -       Refresh screen"
PRINT "F9            -       Save current character"
PRINT "F12           -       Load Character"
PRINT "Enter         -       Command window"
PRINT "Internal Commands"
PRINT "SAVE, LOAD, SAVE AS, COLOUR, EXIT, QUIT, COMMAND"
PRINT "Other shell commands can also be executed from here"
k$ = INPUT$(1)

'Load Background
SHELL "ATTRIB FONTMAK3.TMP -H"
BLOAD "FONTMAK3.TMP", 0
KILL "FONTMAK3.TMP"
DEF SEG
END SUB

SUB LoadChar (ch%)

IF NOT (ch% >= FontStart% AND ch% <= FontStop%) THEN GOTO edispch
num% = ch% - FontStart%
pos1& = (num% * FontSize&) + FONTDATABEGIN
SuperSeek 1, pos1& + FontSize& - 1
DataSize& = LOF(1)
k$ = MKL$(DataSize&)
PUT #1, 5, k$
SEEK #1, pos1&
TempBuffer$ = INPUT$(FontSize&, #1)
DEF SEG = VARSEG(TempBuffer$)
pos1& = SADD(TempBuffer$)
FOR j% = 0 TO FontYres% - 1
FOR i% = 0 TO FontXres% - 1
FontBuffer(i%, j%) = PEEK(pos1&)
pos1& = pos1& + 1
NEXT
NEXT
DEF SEG

edispch:
END SUB

SUB Message (a$)

COLOR 128
re1% = LEN(a$)
i% = 1
WHILE re1% > 0
IF (re1% < MESSAGESIZE) THEN dd% = re1% ELSE dd% = MESSAGESIZE
LOCATE MESSAGEY + i% \ 10, MESSAGEX
PRINT MID$(a$, i%, dd%);
re1% = re1% - dd%
i% = i% + dd%
WEND
MessageStart! = TIMER
END SUB

SUB MessageDestroy

IF (TIMER - MessageStart! > MESSAGEHOLDTIME) THEN
LOCATE MESSAGEY, MESSAGEX
PRINT SPACE$(MESSAGESIZE);
END IF
END SUB

SUB NewFile

FontType& = VAL(BoxInput$("Font Data Type", 4, 0))
DataSize& = LOF(1)
PaletteOff& = VAL(BoxInput$("Palette Offset", 4, 0))
FontStart% = VAL(BoxInput$("Character Start ASCII", 4, 0))
FontStop% = VAL(BoxInput$("Character Stop ASCII", 4, 0))
FontXres% = VAL(BoxInput$("Font Xres", 4, 0))
FontYres% = VAL(BoxInput$("Font Yres", 4, 0))
k$ = MKL$(FontType&) + MKL$(DataSize&) + MKL$(PaletteOff&)
k$ = k$ + MKI$(FontStart%) + MKI$(FontStop%) + MKI$(FontXres%) + MKI$(FontYres%)
PUT #1, 1, k$
END SUB

SUB OldFile

COLOR 64
'Get from file
SEEK #1, 1
k$ = INPUT$(20, #1)
FontType& = CVL(LEFT$(k$, 4))
DataSize& = CVL(MID$(k$, 5, 4))
PaletteOff& = CVL(MID$(k$, 9, 4))
FontStart% = CVI(MID$(k$, 13, 2))
FontStop% = CVI(MID$(k$, 15, 2))
FontXres% = CVI(MID$(k$, 17, 2))
FontYres% = CVI(RIGHT$(k$, 2))

'Calculate
FontSize& = CLNG(FontXres%) * FontYres%
FontXdisp% = 200 \ FontXres%
FontYdisp% = 200 \ FontYres%
IF (FontXdisp% > FontYdisp%) THEN FontXdisp% = FontYdisp% ELSE FontYdisp% = FontXdisp%
FontCharacter% = FontStart%

'Display
FileName FontFile$
LOCATE 4, 27
PRINT "Type:"; FontType&;
LOCATE 5, 27
PRINT "Size:"; DataSize&; "B";
LOCATE 6, 27
PRINT "Pal Off:"; PaletteOff&;
LOCATE 7, 27
PRINT "Start:"; FontStart%;
LOCATE 8, 27
PRINT "Stop:"; FontStop%;
LOCATE 9, 27
PRINT "Xres:"; FontXres%;
LOCATE 10, 27
PRINT "Yres:"; FontYres%;

END SUB

SUB SaveChar (ch%)

IF NOT (ch% >= FontStart% AND ch% <= FontStop%) THEN GOTO esvch
num% = ch% - FontStart%
TempBuffer$ = SPACE$(FontSize&)
DEF SEG = VARSEG(TempBuffer$)
pos1& = SADD(TempBuffer$)
FOR j% = 0 TO FontYres% - 1
FOR i% = 0 TO FontXres% - 1
POKE pos1&, FontBuffer(i%, j%)
pos1& = pos1& + 1
NEXT
NEXT
DEF SEG
pos1& = (num% * FontSize&) + FONTDATABEGIN
PUT #1, pos1&, TempBuffer$
DataSize& = LOF(1)
k$ = MKL$(DataSize&)
PUT #1, 5, k$


esvch:
END SUB

SUB SetPalette
FOR i% = 0 TO 255
OUT &H3C8, i%
r% = (i% AND 3) / 3 * 63
g% = ((i% \ 4) AND 7) / 7 * 63
B% = ((i% \ 32) AND 7) / 7 * 63
OUT &H3C9, r%
OUT &H3C9, g%
OUT &H3C9, B%
NEXT
'OUT &H3C8, 0
'OUT &H3C9, 0
'OUT &H3C9, 0
'OUT &H3C9, 0
END SUB

SUB SuperSeek (file1%, pos1&)

IF (LOF(file1%) < pos1&) THEN
a$ = CHR$(0)
PUT #file1%, pos1&, a$
END IF
SEEK #file1%, pos1&
END SUB


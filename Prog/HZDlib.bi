'--------------------------------------------------------------------------------
'               INCLUDE FILE
'--------------------------------------------------------------------------------
' Part of HAZARD Library
' (a game/software programming library for QuickBasic 4.5 or similar)
'
' Version: first
' by WolfRAM
'********************************************************************************

' To include this file in QuickBasic us the metacommand given below
' '$INCLUDE: 'HZDlib.bi'


'::::::::::::::::::::::::::::::::
' DATATYPES
'::::::::::::::::::::::::::::::::
TYPE HZDwatchTime
Hour AS INTEGER
Minute AS INTEGER
Second AS INTEGER
Centi AS INTEGER
END TYPE

TYPE HZDmouseStatus
X AS INTEGER
Y AS INTEGER
LeftButton1 AS INTEGER
RightButton1 AS INTEGER
LeftButton2 AS INTEGER
RightButton2 AS INTEGER
END TYPE

TYPE HZDdrive
Letter AS STRING*2
END TYPE

TYPE HZDfindDirectory
ItsName AS STRING*13
Attribute AS INTEGER
Size AS LONG
TimeSecond AS INTEGER
TimeMinute AS INTEGER
TimeHour AS INTEGER
DateDay AS INTEGER
DateMonth AS INTEGER
DateYear AS INTEGER
Drive AS STRING*2
END TYPE




'::::::::::::::::::::::::::::::::
' MAIN functions
'::::::::::::::::::::::::::::::::
DECLARE SUB HZDstart ()
DECLARE SUB HZDstop ()
DECLARE FUNCTION HZDlastError% ()


'::::::::::::::::::::::::::::::::
' MEMORY MACHINE functions
'::::::::::::::::::::::::::::::::
DECLARE FUNCTION HZDgetMemory& (BYVAL typ%, BYVAL Segm%, BYVAL Offs&)
DECLARE SUB HZDcopyMemory (BYVAL srctype%, BYVAL srcSEG%, BYVAL srcOFF&, BYVAL desttype%, BYVAL destSeg%, BYVAL destOff&, BYVAL bytes&)
DECLARE SUB HZDcopyDataPack (BYVAL srctype%, BYVAL srcSEG%, BYVAL srcOFF&, BYVAL desttype%, BYVAL destSeg%, BYVAL destOff&)


'::::::::::::::::::::::::::::::::
' STRING MACHINE functions
'::::::::::::::::::::::::::::::::
DECLARE FUNCTION HZDcompareStrings%(BYVAL srcSEG%, BYVAL srcOFF%, BYVAL desSEG%, BYVAL desOFF%)
DECLARE SUB HZDcopyString (BYVAL srctype%, BYVAL srcSEG%, BYVAL srcOFF&, BYVAL desttype%, BYVAL destSeg%, BYVAL destOff&)
DECLARE FUNCTION HZDgetString$ (BYVAL srctype%, BYVAL srcSEG%, BYVAL srcOFF&)
DECLARE SUB HZDputString (astring$, BYVAL destype%, BYVAL desSEG%, BYVAL desOFF&)


'::::::::::::::::::::::::::::::::
' PALETTE MACHINE functions
'::::::::::::::::::::::::::::::::
DECLARE SUB HZDloadDefPalette (BYVAL location%)
DECLARE SUB HZDloadPalette (BYVAL loaction%, BYVAL srctype%, BYVAL srcSEG%, BYVAL srcOFF&)
DECLARE SUB HZDselectPalette (BYVAL loaction%)
DECLARE SUB HZDapplyPalette ()
DECLARE SUB HZDsetBrightness (BYVAL brightness%)
DECLARE SUB HZDsetContrast (BYVAL contrast%)


'::::::::::::::::::::::::::::::::
' FILE MACHINE functions
'::::::::::::::::::::::::::::::::
DECLARE SUB HZDcreateFile (file$, BYVAL fileattrib%)
DECLARE SUB HZDopenFile (BYVAL filenum%, file$, BYVAL filemode%)
DECLARE SUB HZDcloseFile (BYVAL filenum%)
DECLARE FUNCTION HZDfreeFile% ()
DECLARE SUB HZDseekFile (BYVAL filenum%, BYVAL position&)
DECLARE SUB HZDreadFile (BYVAL filenum%, BYVAL desSEG%, BYVAL desOFF%, BYVAL length%)
DECLARE SUB HZDwriteFile (BYVAL filenum%, BYVAL srcSEG%, BYVAL srcOFF%, BYVAL length%)
DECLARE FUNCTION HZDfileSize& (BYVAL filenum%)


'::::::::::::::::::::::::::::::::
' GRAPHICS MACHINE functions
'::::::::::::::::::::::::::::::::
DECLARE SUB HZDselectGraphicsPage (BYVAL page%)
DECLARE SUB HZDcopyGraphicsPage(BYVAL srcpage%, BYVAL despage%)
DECLARE SUB HZDcopyGraphicsPageTrans(BYVAL srcpage%, BYVAL despage%)
DECLARE SUB HZDsetRefreshRate (BYVAL rate%)
DECLARE SUB HZDsetGraphicsRange (BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%)
DECLARE SUB HZDpset (BYVAL x%, BYVAL y%, BYVAL colour%)
DECLARE FUNCTION HZDpoint% (BYVAL x%, BYVAL y%)
DECLARE SUB HZDdisplayGraphics ()
DECLARE SUB HZDclearPage ()
DECLARE SUB HZDtakeScreenshot (BYVAL destype%, BYVAL desSEG%, BYVAL desOFF&, BYVAL xpixsize%, BYVAL ypixsize%)
DECLARE SUB HZDsavePage (BYVAL destype%, BYVAL desSEG%, BYVAL desOFF&)
DECLARE SUB HZDloadPage (BYVAL srctype%, BYVAL srcSEG%, BYVAL srcOFF&)
DECLARE SUB HZDgetPart (BYVAL destype%, BYVAL desSEG%, BYVAL desOFF&, BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%)
DECLARE SUB HZDputPart (BYVAL srctype%, BYVAL srcSEG%, BYVAL srcOFF&, BYVAL x%, BYVAL y%)


'::::::::::::::::::::::::::::::::
' TIME MACHINE functions
'::::::::::::::::::::::::::::::::
DECLARE SUB HZDwatchAccuracy (BYVAL accuracy%)
DECLARE SUB HZDstartWatch ()
DECLARE SUB HZDstopWatch ()
DECLARE SUB HZDpauseWatch ()
DECLARE SUB HZDresumeWatch ()
DECLARE FUNCTION HZDrawWatchTime& ()
DECLARE SUB HZDgetWatchTime (time1 AS HZDwatchTime)


'::::::::::::::::::::::::::::::::
' PC SPEAKER MACHINE functions
'::::::::::::::::::::::::::::::::
DECLARE SUB HZDplayPCsound (BYVAL srctype%, BYVAL srcSEG%, BYVAL srcOFF&)
DECLARE SUB HZDstopPCsound ()
DECLARE SUB HZDpausePCsound ()
DECLARE SUB HZDresumePCsound ()
DECLARE SUB HZDplayFrequency (BYVAL freq%)


'::::::::::::::::::::::::::::::::
' SP FILE MACHINE functions
'::::::::::::::::::::::::::::::::
DECLARE SUB HZDopenSPfile (BYVAL filenum%, file$, BYVAL filemode%)
DECLARE SUB HZDcloseSPfile (BYVAL filenum%)
DECLARE FUNCTION HZDnumDataPacks% (BYVAL filenum%)
DECLARE FUNCTION HZDgetDataPackOff& (BYVAL filenum%, BYVAL dataPackno%)
DECLARE FUNCTION HZDgetDataPackName$ ()
DECLARE FUNCTION HZDgetDataPackTypeNum& ()
DECLARE FUNCTION HZDgetDataPackNum% (BYVAL filenum%, String1$)
DECLARE FUNCTION HZDgetSPfileName$ (BYVAL filenum%)
DECLARE FUNCTION HZDgetSPfileAuthor$ (BYVAL filenum%)
DECLARE FUNCTION HZDgetSPfilePackage$ (BYVAL filenum%)




'::::::::::::::::::::::::::::::::
' KEYBOARD MACHINE functions
'::::::::::::::::::::::::::::::::
DECLARE SUB HZDstartKeyboard()
DECLARE SUB HZDstopKeyboard()
DECLARE SUB HZDkeyClear()
DECLARE FUNCTION HZDrawKeyPressed%()
DECLARE FUNCTION HZDkeyPressed%()
DECLARE SUB HZDkeyNowPressed()
DECLARE SUB HZDwaitRawKey(BYVal rawKey%)
DECLARE SUB HZDwaitKey(BYVal aKey%)
DECLARE SUB HZDloadDefControls()
DECLARE SUB HZDloadControls(BYVAL cntTYPE%, BYVAL cntSEG%, BYVAL cntOFF&)


'::::::::::::::::::::::::::::::::
' DISK MACHINE functions
'::::::::::::::::::::::::::::::::
DECLARE FUNCTION HZDnumFixedDrives%()
DECLARE SUB HZDcurrentDrive(driveletter AS HZDdrive)
DECLARE FUNCTION HZDcurrentDirectory$()
DECLARE SUB HZDfindFirst(search1 AS HZDfindDirectory, FileName$, BYVAL includes1%)
DECLARE SUB HZDfindNext(search1 AS HZDfindDirectory)


'::::::::::::::::::::::::::::::::
' DRAWING MACHINE functions
'::::::::::::::::::::::::::::::::
DECLARE SUB HZDdrawBoxFill(BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL clr%)
DECLARE SUB HZDdrawBox(BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL clr%)
DECLARE SUB HZDdrawLine(BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%, BYVAL clr%)






'++++++++++++++++++++++++++++++++
' HAZARD LIBRARY Constants
'++++++++++++++++++++++++++++++++
'--------------------------------
'TIME MACHINE
'--------------------------------
CONST hLOW = 0, hHIGH = 1

'--------------------------------
'FILE MACHINE
'--------------------------------
CONST hFILER = 0, hFILEW = 1, hFILERW = 2
CONST hCOMPATIBLEMODE = 0 * 16, hLOCKRW = 1 * 16, hLOCKW = 2 * 16, hLOCKR = 3 * 16, hNOLOCK = 4 * 16
CONST hREADONLY = 1, hHIDDEN = 2, hSYSTEM = 4, hARCHIVE = 32

'--------------------------------
'MEMORY MACHINE
'--------------------------------
CONST hCONV = 0, hEMS = 1, hXMS = 2, hFILE = 3

'--------------------------------
'DISK MACHINE
'--------------------------------
CONST hDIRECTORY=16

'--------------------------------
'KEYBOARD MACHINE
'--------------------------------
CONST hkeyESC=1, hkeyF1=2, hkeyF2=3, hkeyF3=4, hkeyF4=5, hkeyF5=6, hkeyF6=7
CONST hkeyF7=8, hkeyF8=9, hkeyF9=10, hkeyF10=11, hkeyF11=12, hkeyF12=13
CONST kkeyGRAVE=14, hkey1=15, hkey2=16, hkey3=17, hkey4=18, hkey5=19, hkey6=20
CONST hkey7=21,hkey8=22,hkey9=23,hkey0=24, hkeyMINUS=25, hkeyEQUAL=26
CONST hkeyBACKSPACE=27, hkeyTAB=28, hkeyQ=29, hkeyW=30, hkeyE=31, hkeyR=32
CONST hkeyT=33, hkeyY=34, hkeyU=35, hkeyI=36, hkeyO=37, hkeyP=38
CONST hkeyBRACKETOPEN=39, hkeyBRACKETCLOSE=40, hkeySLASH=41
CONST hkeyCAPSLOCK=42, hkeyA=43, hkeyS=44, hkeyD=45, hkeyF=46, hkeyG=47
CONST hkeyH=48, hkeyJ=49, hkeyK=50, hkeyL=51, hkeySEMICOLON=52
CONST hkeyINVERTEDCOMMA=53, hkeyENTER=53, hkeyLEFTSHIFT=54
CONST hkeyZ=55, hkeyX=56, hkeyC=57, hkeyV=58, hkeyB=59, hkeyN=60
CONST hkeyM=61, hkeyCOMMA=62, hkeyFULLSTOP=63, hkeyDIVIDE=64
CONST hkeyRIGHTSHIFT=65, hkeyLEFTCTRL=66, hkeyLEFTALT=67
CONST hkeySPACE=68, hkeyRIGHTALT=69, hkeyRIGHTCTRL=70
CONST hkeyINSERT=71, hkeyHOME=72, hkeyPAGEUP=73, hkeyDELETE=74
CONST hkeyEND=75, hkeyPAGEDOWN=76, hkeyUPARROW=77, hkeyLEFTARROW=78
CONST hkeyDOWNARROW=79, hkeyRIGHTARROW=80, hkeyNUMLOCK=81
CONST hkeyNUMDIVIDE=82, hkeyNUMINTO=83, hkeyNUMMINUS=84
CONST hkeyNUM7=85, hkeyNUM8=86, hkeyNUM9=87, hkeyNUM4=88
CONST hkeyNUM5=89, hkeyNUM6=90, hkeyNUMPLUS=91, hkeyNUM1=92
CONST hkeyNUM2=93, hkeyNUM3=94, hkeyNUM0=95, hkeyNUMFULLSTOP=96
CONST hkeyNUMENTER=97










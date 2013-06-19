;--------------------------------------------------------------------------------
;		MOUSE MACHINE
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





.MODEL Large, Basic

.386

INCLUDE	Includes.inc


;SHARED



.STACK 100h

EXTRN	LastError:WORD



;CONST





;
;======================MOUSE IMAGE FORMAT======================
;
;[Size of image]			DWORD
;[X resolution]				WORD
;[Y resolution]				WORD
;[Palette int/ext]			BYTE
;[Offset to palette/palette number]	DWORD
;[Offset to image]			DWORD
;[Hotspot X]				WORD
;[Hotspot Y]				WORD
;[Raw Image data]			BYTE x Size
;
;======================MOUSE IMAGE FORMAT======================
;




;======================MOUSE FUNCTIONS======================
_mouse_reset						equ	0000h
_mouse_show_cursor					equ	0001h
_mouse_hide_cursor					equ	0002h
_mouse_get_position_and_button_status			equ	0003h
_mouse_set_cursor_position_				equ	0004h
_mouse_get_button_press_data				equ	0005h
_mouse_get_button_release_data				equ	0006h
_mouse_set_horizontal_cursor_range			equ	0007h
_mouse_set_vertical_cursor_range			equ	0008h
_mouse_set_graphics_cursor				equ	0009h
_mouse_set_text_cursor					equ	000Ah
_mouse_get_motion_counters				equ	000Bh
_mouse_set_interrupt_subroutine_parameters		equ	000Ch
_mouse_light_pen_emulation_on				equ	000Dh
_mouse_light_pen_emulation_off				equ	000Eh
_mouse_set_mickey_pixel_ratio				equ	000Fh
_mouse_set_screen_region_for_updating			equ	0010h
_mouse_set_large_graphics_cursor_block			equ	0012h
_mouse_set_double_speed_threshold			equ	0013h
_mouse_exchange_subroutine_parameters			equ	0014h
_mouse_get_driver_storage_requirements			equ	0015h
_mouse_save_driver_state				equ	0016h
_mouse_restore_driver_state				equ	0017h
_mouse_set_alternate_mouse_user_handler			equ	0018h
_mouse_get_user_alternate_interrupt_vector		equ	0019h
_mouse_set_mouse_sensitivity				equ	001Ah
_mouse_get_mouse_sensitivity				equ	001Bh
_mouse_set_interrupt_rate				equ	001Ch
_mouse_set_display_page_number				equ	001Dh
_mouse_get_display_page_number				equ	001Eh
_mouse_disable_mouse_driver				equ	001Fh
_mouse_enable_mouse_driver				equ	0020h
_mouse_software_reset					equ	0021h
_mouse_set_language_for_messages			equ	0022h
_mouse_get_language_for_messages			equ	0023h
_mouse_get_version_mouse_type_irq			equ	0024h
_mouse_get_general_driver_informtion			equ	0025h
_mouse_get_maximum_virtual_coordinates			equ	0026h
_mouse_get_screen_cursor_masks_and_mickey_counts	equ	0027h
_mouse_set_video_mode					equ	0028h
_mouse_enumerate_video_modes				equ	0029h
_mouse_get_cursor_hot_spot				equ	002Ah
_mouse_load_acceleration_profiles			equ	002Bh
_mouse_get_acceleration_profiles			equ	002Ch
_mouse_select_acceleration_profile			equ	002Dh
_mouse_set_acceleration_profile_names			equ	002Eh
_mouse_mouse_hardware_reset				equ	002Fh
_mouse_get_set_ballpoint_information			equ	0030h
_mouse_get_minimum_maximum_virtual_coordinates		equ	0031h
_mouse_get_active_advanced_functions			equ	0032h
_mouse_get_switch_settings_and_accelation_profile_data	equ	0033h
_mouse_get_initialization_file				equ	0034h
_mouse_lcd_large_pointer_support			equ	0035h
_mouse_return_pointer_to_copyright_string		equ	004Dh
_mouse_get_version_string				equ	006Dh
;======================MOUSE FUNCTIONS======================










;======================MOUSE MACROS======================
RunMouseFunction		MACRO
int	33h
ENDM


MouseFunction			MACRO	fn
mov	ax, fn
RunMouseFunction
ENDM


IsBoundaryWithin		MACRO	x, y, notwithin
mov	ax, x
cmp	ax, BoundaryX1
jb	notwithin
cmp	ax, BoundaryX2
ja	notwithin
mov	ax, y
cmp	ax, BoundaryY1
jb	notwithin
cmp	ax, BoundaryY2
ja	notwithin
ENDM




RearrangeXY			MACRO	x1, y1, x2, y2
mov	ax, x1
cmp	ax, x2
jbe	x1lex2
xchg	ax, x2
mov	x1, ax

x1lex2:
mov	ax, y1
cmp	ax, y2
jbe	y1ley2
xchg	ax, y2
mov	y1, ax

y1ley2:
ENDM



BringWithinDefaultValue		MACRO	x, lowrange, highrange, xok1, xok2
cmp	WORD PTR x, lowrange
jge	xok1
mov	WORD PTR x, lowrange

xok1:
cmp	WORD PTR x, highrange
jle	xok2
mov	WORD PTR x, highrange

xok2:
ENDM



BringWithinDefault		MACRO	x1, y1, x2, y2
BringWithinDefaultValue	x1, 0, 319, a1, b1
BringWithinDefaultValue	x2, 0, 319, a2, b2
BringWithinDefaultValue	y1, 0, 199, a3, b3
BringWithinDefaultValue	y2, 0, 199, a4, b4
ENDM



GetPixelAddress			MACRO	x, y
xor	ax, ax
xor	bx, bx
mov	ah, y
mov	bh, ah
shr	ax, 2
add	bx, ax
add	bx, x
ENDM





BringWithinBoundaryX		MACRO	x, xok1, xok2
mov	ax, x
cmp	ax, MsBoundaryX1
jae	xok1
mov	ax, MsBoundaryX1

xok1:
cmp	ax, MsBoundaryX2
jbe	xok2
mov	ax, MsBoundaryX2

xok2:
mov	x, ax
ENDM




BringWithinBoundaryY		MACRO	y, yok1, yok2
mov	ax, y
cmp	ax, MsBoundaryY1
jae	yok1
mov	ax, MsBoundaryY1

yok1:
cmp	ax, MsBoundaryY2
jbe	yok2
mov	ax, MsBoundaryY2

yok2:
mov	y, ax
ENDM




BringWithinBoundary		MACRO	x1, y1, x2, y2
BringWithinBoundaryX	x1
BringWithinBoundaryY	y1
BringWithinBoundaryX	x2
BringWithinBoundaryY	y2
ENDM



GetPixelAddress			MACRO	x, y
push	ax
xor	ax, ax
xor	bx, bx
mov	ah, y
mov	bh, ah
shr	ax, 2
add	bx, ax
add	bx, x
pop	ax
ENDM
;======================MOUSE MACROS======================









;======================MOUSE DATATYPES======================
;TYPE HZDmouseSensitivity
;SenseX		AS INTEGER
;SenseY		AS INTEGER
;DoubleSpeedTh	AS INTEGER
;END TYPE
;
;
;TYPE HZDmouseStatus
;X		AS INTEGER
;Y		AS INTEGER
;Button1	AS INTEGER
;Button2	AS INTEGER
;END TYPE
;



STRUC	MemorySlot
MemType		DB	0
MemSEG		DW	0
MemOFF		DD	0
ENDS




.DATA
MouseImageSlot			MemorySlot	8 DUP(0)






;External SUBs
LoadImage
DisplayImage
GetFreeSlot



.CODE


















; -----------------------------------------------------------------------------------------------------------------------------
;		INTERNAL FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------



; -----------------------------------------------------------------------------------------------------------------------------
; StartMouse			INTERNAL FUNCTION
; Purpose:
;   Starts the mouse machine
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StartMouse
StartMouse PROC
push3	ax, cx, dx
MouseFunction	_mouse_reset
or	ax, ax
jns	mouseerr
mov	cx, defboundaryx1
mov	dx, defboundaryx2
MouseFunction	_mouse_set_horizontal_cursor_range
mov	cx, defboundaryy1
mov	dx, defboundaryy2
MouseFunction	_mouse_set_vertical_cursor_range
pop3	ax, cx, dx
retf
StartMouse ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; StopMouse			INTERNAL FUNCTION
; Purpose:
;   Stops the mouse machine
;
; Usage:
;   none
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC StopMouse
StopMouse PROC
push	ax
MouseFunction	_mouse_reset
pop	ax
retf
StopMouse ENDP










; -----------------------------------------------------------------------------------------------------------------------------
;		PUBLIC FUNCTIONS
; -----------------------------------------------------------------------------------------------------------------------------





; -----------------------------------------------------------------------------------------------------------------------------
; HZDmouseDisplay		SUB
;
; Purpose:
;   Turn mouse display on or off
;
; Declaration:
;   DECLARE SUB HZDmouseDisplay(BYVAL drw%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDmouseDisplay
HZDmouseDisplay PROC
UseParam
cmp	VideoActive, 1
je	graphicsmodeactive
mov	ax, param1
not	ax
and	ax, 1
inc	ax
RunMouseFunction

over98:
EndParam
retf	2

graphicsmodeactive:
mov	al, param1
and	al, 1
mov	MouseDisplay, al
jmp	over98
HZDmouseDisplay ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDsetMouseRange	SUB
;
; Purpose:
;   Set the range in which mouse can move
;
; Declaration:
;   DECLARE SUB HZDsetMouseRange(BYVAL x1%, BYVAL y1%, BYVAL x2%, BYVAL y2%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDsetMouseRange
HZDsetMouseRange PROC
UseParam
RearrangeXY	param4, param3, param2, param1
BringWithinDefault	param4, param3, param2, param1
mov	cx, param4
mov	MsBoundaryX1, cx
mov	dx, param2
mov	MsBoundaryX2, dx
MouseFunction _mouse_set_horizontal_cursor_range
mov	cx, param3
mov	MsBoundaryY1, cx
mov	dx, param1
mov	MsBoundaryY2, dx
MouseFunction _mouse_set_vertical_cursor_range
EndParam
retf	8
HZDsetMouseRange ENDP







; -----------------------------------------------------------------------------------------------------------------------------
; HZDsetMousePosition	SUB
;
; Purpose:
;   Set the position of the mouse
;
; Declaration:
;   DECLARE SUB HZDsetMousePosition(BYVAL x%, BYVAL y%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDsetMousePosition
HZDsetMousePosition PROC
UseParam
BringWithinBoundaryX	param2, bla01, bla02
BringWithinBoundaryY	param1, bla03, bla04
mov	cx, param2
mov	dx, param1
MouseFunction	_mouse_set_cursor_position
EndParam
retf	4
HZDsetMousePosition ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDsetMousePixelRatio	SUB
;
; Purpose:
;   Set the pixel ratio of the mouse
;   Default values are 16,16.
;
; Declaration:
;   DECLARE SUB HZDsetMousePixelRatio(BYVAL ratiox%, BYVAL ratioy%)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDsetMousePixelRatio
HZDsetMousePixelRatio PROC
UseParam
mov	cx, param2
mov	dx, param1
shr	cx, 1
MouseFunction	_mouse_set_mickey_pixel_ratio
EndParam
retf	4
HZDsetMousePixelRatio ENDP




; -----------------------------------------------------------------------------------------------------------------------------
; HZDsetMouseSensitivity	SUB
;
; Purpose:
;   Set the sensitivity of mouse and double speed threshold
;   sense.SenseX = X sensitivity
;   sense.SenseY = Y sensitivity
;   sense.DoubleSpeedTh = Double speed threshold
;
; Declaration:
;   DECLARE SUB HZDsetMouseSensitivity(sense AS HZDmouseSensitivity)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDsetMouseSensitivity
HZDsetMouseSensitivity PROC
UseParam
mov	bx, param1
mov	cx, [bx+2]
mov	dx, [bx+4]
mov	bx, [bx]
MouseFunction	_mouse_set_mouse_sensitivity
EndParam
retf	2
HZDsetMouseSensitivity ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetMouseSensitivity	FUNCTION
;
; Purpose:
;   Gives the sensitivity of mouse and double speed threshold(in sense)
;   sense.SenseX = X sensitivity
;   sense.SenseY = Y sensitivity
;   sense.DoubleSpeedTh = Double speed threshold
;
; Declaration:
;   DECLARE SUB HZDgetMouseSensitivity(sense AS HZDmouseSensitivity)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetMouseSensitivity
HZDgetMouseSensitivity PROC
UseParam
MouseFunction	_mouse_get_mouse_sensitivity
mov	ax, bx
mov	bx, param1
mov	[bx], ax
mov	[bx+2], cx
mov	[bx+4], dx
EndParam
retf	2
HZDgetMouseSensitivity ENDP







; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetMouseStatus	SUB
;
; Purpose:
;   Gives the current mouse status(position of mouse and state of buttons)
;
; Declaration:
;   DECLARE SUB HZDgetMouseStatus(status1 AS HZDmouseStatus)
;
; Returns:
;   status1.X=current column of mouse on the screen
;   status1.Y=current row of mouse on the screen
;   status1.Button1=1 if left mouse button is pressed, else 0
;   status1.Button2=1 if right mouse button is pressed, else 0
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetMouseStatus
HZDgetMouseStatus PROC
UseParam
push	si
mov	si, param1
MouseFunction	_mouse_get_position_and_button_status
mov	[si], cx
mov	[si+2], dx
mov	cx, bx
and	cx, 1
mov	[si+4], cx
mov	cx, bx
shr	cx, 1
mov	[si+6], cx
pop	si
EndParam
retf	2
HZDgetMouseStatus ENDP



; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetDeltaMouseStatus SUB
;
; Purpose:
;   Gives the change in mouse status(change in position of mouse and state of buttons)
;   
; Declaration:
;   DECLARE SUB HZDgetDeltaMouseStatus(status1 AS HZDmouseStatus)
;
; Returns:
;   status1.X=change in column of mouse since last call(no border)
;   status1.Y=change in row of mouse since last call(no border)
;   status1.Button1=number of changes in left mouse button state
;   status1.Button2=number of changes in right mouse button state
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetDeltaMouseStatus
HZDgetDeltaMouseStatus PROC
UseParam
push	si
mov	si, param1
MouseFunction	_mouse_get_motion_counters
mov	[si], cx
mov	[si+2], dx
mov	cx, LeftButtonDelta
mov	[si+4], cx
mov	cx, RightButtonDelta
mov	[si+6], cx
pop	si
EndParam
retf	2
HZDgetDeltaMouseStatus ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDgetMouseButtonUseStatus SUB
;
; Purpose:
;   Gives the information related to button press
;   button = 0 (left)
;   button = 1 (right)
;   buttonuse = 0 (released)
;   buttonuse = 1 (pressed)
;   
; Declaration:
;   DECLARE SUB HZDgetMouseButtonUseStatus(status1 AS HZDmouseStatus, BYVAL button%, BYVAL buttonuse%)
;
; Returns:
;   status1.X=column of mouse where the specified button was pressed/released
;   status1.Y=row of mouse where the specified button was pressed/released
;   status1.Button1=number of times the specified button was pressed/released
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDgetMouseButtonUseStatus
HZDgetMouseButtonUseStatus PROC
UseParam
push	si
mov	si, param3
mov	bx, param2
mov	cx, param1
and	bx, 1
and	cx, 1
mov	ax, 6
sub	ax, cx
RunMouseFunction
mov	[si], cx
mov	[si+2], dx
mov	[si+4], bx
pop	si
EndParam
retf	6
HZDgetMouseButtonUseStatus ENDP





; -----------------------------------------------------------------------------------------------------------------------------
; HZDloadMouseImage SUB
;
; Purpose:
;   Load mouse image from memory
;   
; Declaration:
;   DECLARE SUB HZDloadMouseImage(BYVAL Slot%, BYVAL srcTYPE%, BYVAL srcSEG%, BYVAL srcOFF&)
;
; Returns:
;   nothing
; -----------------------------------------------------------------------------------------------------------------------------
EVEN
PUBLIC HZDloadMouseImage
HZDloadMouseImage PROC
UseParam
mov	ax, param5
and	ax, 7
mov	bx, ax
shl	bx, 3
sub	bx, ax
cmp	MouseImageSlot[bx], 

EndParam
HZDloadMouseImage ENDP



;Make Button
;Get Button Status














END
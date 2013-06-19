;--------------------------------------------------------------------------------
;		MOUSE VALUES
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
_mouse_interrupt					equ	33h
_mouse_reset						equ	00h
_mouse_show_cursor					equ	01h
_mouse_hide_cursor					equ	02h
_mouse_get_position_and_button_status			equ	03h
_mouse_set_cursor_position_				equ	04h
_mouse_get_button_press_data				equ	05h
_mouse_get_button_release_data				equ	06h
_mouse_set_horizontal_cursor_range			equ	07h
_mouse_set_vertical_cursor_range			equ	08h
_mouse_set_graphics_cursor				equ	09h
_mouse_set_text_cursor					equ	0Ah
_mouse_get_motion_counters				equ	0Bh
_mouse_set_interrupt_subroutine_parameters		equ	0Ch
_mouse_light_pen_emulation_on				equ	0Dh
_mouse_light_pen_emulation_off				equ	0Eh
_mouse_set_mickey_pixel_ratio				equ	0Fh
_mouse_set_screen_region_for_updating			equ	10h
_mouse_set_large_graphics_cursor_block			equ	12h
_mouse_set_double_speed_threshold			equ	13h
_mouse_exchange_subroutine_parameters			equ	14h
_mouse_get_driver_storage_requirements			equ	15h
_mouse_save_driver_state				equ	16h
_mouse_restore_driver_state				equ	17h
_mouse_set_alternate_mouse_user_handler			equ	18h
_mouse_get_user_alternate_interrupt_vector		equ	19h
_mouse_set_mouse_sensitivity				equ	1Ah
_mouse_get_mouse_sensitivity				equ	1Bh
_mouse_set_interrupt_rate				equ	1Ch
_mouse_set_display_page_number				equ	1Dh
_mouse_get_display_page_number				equ	1Eh
_mouse_disable_mouse_driver				equ	1Fh
_mouse_enable_mouse_driver				equ	20h
_mouse_software_reset					equ	21h
_mouse_set_language_for_messages			equ	22h
_mouse_get_language_for_messages			equ	23h
_mouse_get_version_mouse_type_irq			equ	24h
_mouse_get_general_driver_informtion			equ	25h
_mouse_get_maximum_virtual_coordinates			equ	26h
_mouse_get_screen_cursor_masks_and_mickey_counts	equ	27h
_mouse_set_video_mode					equ	28h
_mouse_enumerate_video_modes				equ	29h
_mouse_get_cursor_hot_spot				equ	2Ah
_mouse_load_acceleration_profiles			equ	2Bh
_mouse_get_acceleration_profiles			equ	2Ch
_mouse_select_acceleration_profile			equ	2Dh
_mouse_set_acceleration_profile_names			equ	2Eh
_mouse_mouse_hardware_reset				equ	2Fh
_mouse_get_set_ballpoint_information			equ	30h
_mouse_get_minimum_maximum_virtual_coordinates		equ	31h
_mouse_get_active_advanced_functions			equ	32h
_mouse_get_switch_settings_and_accelation_profile_data	equ	33h
_mouse_get_initialization_file				equ	34h
_mouse_lcd_large_pointer_support			equ	35h
_mouse_return_pointer_to_copyright_string		equ	4Dh
_mouse_get_version_string				equ	6Dh
;======================MOUSE FUNCTIONS======================




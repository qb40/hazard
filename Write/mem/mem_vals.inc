;--------------------------------------------------------------------------------
;				MEMORY VALUES
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








;======================MEMORY STATUS FLAGS======================
_memory_emsready					equ	0
_memory_xmsready					equ	1




;======================MEMORY STATUS FLAGS======================





;======================MEMORY ALLOCATION======================

;======================MEMORY ALLOCATION======================







;======================EMS FUNCTIONS======================
_ems_interrupt						equ	67h
_ems_emm_id_pointer					equ	0Ah
_ems_emm_id_length					equ	08h
_ems_get_manager_status					equ	40h
_ems_get_page_frame_segment				equ	41h
_ems_get_number_of_pages				equ	42h
_ems_get_handle_and_allocate_memory			equ	43h
_ems_map_memory						equ	44h
_ems_release_handle_and_memory				equ	45h
_ems_get_emm_version					equ	46h
_ems_save_mapping_context				equ	47h
_ems_restore_mapping_context				equ	48h
_ems_get_io_port_address				equ	49h
_ems_get_translation_array				equ	4Ah
_ems_get_number_of_emm_handles				equ	4Bh
_ems_get_pages_owned_by_handle				equ	4Ch
_ems_get_pages_for_all_handles				equ	4Dh
_ems_get_or_set_page_map				equ	4Eh
_ems_get_or_set_partial_page_map			equ	4Fh
_ems_map_or_unmap_multiple_handle_pages			equ	50h
_ems_reallocate_pages					equ	51h
_ems_get_or_set_handle_attributes			equ	52h
_ems_get_or_set_handle_name				equ	53h
_ems_get_handle_directory				equ	54h
_ems_alter_page_map_and_jump				equ	55h
_ems_alter_page_map_and_call				equ	56h
_ems_move_or_exchange_memory_region			equ	57h
_ems_get_mappable_physical_address_array		equ	58h
_ems_get_expanded_memory_hardware_information		equ	59h
_ems_allocate_standard_or_raw_pages			equ	5Ah
_ems_alternate_map_register_set_dma_registers		equ	5Bh
_ems_prepare_expanded_memory_hardware_for_warm_boot	equ	5Ch
_ems_enable_or_disable_os_function_set_functions	equ	5Dh
;======================EMS FUNCTIONS======================



;======================XMS FUNCTIONS======================
_xms_interrupt						equ	2Fh
_xms_installation_check					equ	4300h
_xms_get_driver_address					equ	4310h
_xms_amount_of_xms_available				equ	08h
_xms_allocate_memory					equ	09h
_xms_deallocate_memory					equ	0Ah
_xms_copy_memory_region					equ	0Bh
;======================XMS FUNCTIONS======================






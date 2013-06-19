;--------------------------------------------------------------------------------
;				DOS VALUES
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











;======================DOS Functions======================
_dos_interrupt						equ	21h
_dos_read_chracter_from_standard_input_with_echo	equ	0100h
_dos_write_character_to_standard_output			equ	0200h
_dos_read_character_from_stdaux				equ	0300h
_dos_write_character_to_stdaux				equ	0400h
_dos_write_character_to_printer				equ	0500h
_dos_direct_console_input_or_output			equ	0600h
_dos_direct_character_input_without_echo		equ	0700h
_dos_character_input_without_echo			equ	0800h
_dos_write_string_to_standard_output			equ	0900h
_dos_buffered_input					equ	0A00h
_dos_get_stdin_status					equ	0B00h
_dos_flush_buffer_and_read_standard_input		equ	0C00h
_dos_disk_reset						equ	0D00h
_dos_select_default_drive				equ	0E00h
_dos_open_file_using_fcb				equ	0F00h
_dos_close_file_using_fcb				equ	1000h
_dos_find_first_matching_file_using_fcb			equ	1100h
_dos_find_next_matching_file_using_fcb			equ	1200h
_dos_delete_file_using_fcb				equ	1300h
_dos_sequential_read_from_fcb_file			equ	1400h
_dos_sequential_write_to_fcb_file			equ	1500h
_dos_create_or_truncate_file_using_fcb			equ	1600h
_dos_rename_file_using_fcb				equ	1700h
_dos_get_current_default_drive				equ	1900h
_dos_set_disk_transfer_area_address			equ	1A00h
_dos_get_allocation_information_for_default_drive	equ	1B00h
_dos_get_allocation_information_for_specific_drive	equ	1C00h
_dos_get_drive_parameter_block_for_default_drive	equ	1F00h
_dos_read_random_record_from_fcb_file			equ	2100h
_dos_write_random_record_to_fcb_file			equ	2200h
_dos_get_file_size_for_fcb				equ	2300h
_dos_set_random_record_number_for_fcb			equ	2400h
_dos_set_interrupt_vector				equ	2500h
_dos_create_new_program_segment_prefix			equ	2600h
_dos_random_block_read_from_fcb_file			equ	2700h
_dos_random_block_write_to_fcb_file			equ	2800h
_dos_get_system_date					equ	2A00h
_dos_set_system_date					equ	2B00h
_dos_get_system_time					equ	2C00h
_dos_set_system_time					equ	2D00h
_dos_set_verify_flag					equ	2E00h
_dos_get_disk_transfer_area_address			equ	2F00h
_dos_get_dos_version					equ	3000h
_dos_terminate_and_stay_resident			equ	3100h
_dos_get_current_extended_break_state			equ	3300h
_dos_set_extended_break_state				equ	3301h
_dos_get_boot_drive					equ	3305h
_dos_get_true_version_number				equ	3306h
_dos_get_interrupt_vector				equ	3500h
_dos_get_free_disk_space				equ	3600h
_dos_create_subdirectory				equ	3900h
_dos_remove_subdirectory				equ	3A00h
_dos_set_current_directory				equ	3B00h
_dos_create_or_truncate_file				equ	3C00h
_dos_open_existing_file					equ	3D00h
_dos_close_file						equ	3E00h
_dos_read_from_file_or_device				equ	3F00h
_dos_write_to_file_or_device				equ	4000h
_dos_delete_file					equ	4100h
_dos_set_current_file_position				equ	4200h
_dos_get_file_attributes				equ	4300h
_dos_set_file_attributes				equ	4301h
_dos_duplicate_file_handle				equ	4500h
_dos_force_duplicate_file_handle			equ	4600h
_dos_get_current_directory				equ	4700h
_dos_allocate_memory					equ	4800h
_dos_free_memory					equ	4900h
_dos_resize_memory_block				equ	4A00h
_dos_load_and_or_execute_program			equ	4B00h
_dos_terminate_with_return_code				equ	4C00h
_dos_get_return_code_errorlevel				equ	4D00h
_dos_find_first_matching_file				equ	4E00h
_dos_find_next_matching_file				equ	4F00h
_dos_get_verify_flag					equ	5400h
_dos_rename_file					equ	5600h
_dos_get_file_last_written_date_and_time		equ	5700h
_dos_set_file_last_written_date_and_time		equ	5701h
_dos_get_memory_allocation_strategy			equ	5800h
_dos_set_memory_allocation_strategy			equ	5801h
_dos_get_umb_link_state					equ	5802h
_dos_set_umb_link_state					equ	5803h
_dos_get_extended_error_information			equ	5900h
_dos_create_temporary_file				equ	5A00h
_dos_create_new_file					equ	5B00h
_dos_flock_lock_file_region				equ	5C00h
_dos_flock_unlock_file_region				equ	5C01h
_dos_enable_drive					equ	5F07h
_dos_disable_drive					equ	5F08h
;======================DOS Functions======================








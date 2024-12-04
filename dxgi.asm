format PE64 GUI 5.0 DLL NX at 123400000h
include 'win64a.inc'

; safety checks:
; * we're going to read/write from fixed addresses, ImageSize of the executable should cover them
expected_image_size = 0x6110000

; there are two versions of IsSolved, let's call them IsSolved and IsSolvedBy;
; the second one additionally takes a player identifier.
; The first one is crucial, patch both just in case.
is_solved_offset = 0x1431665
is_solved_by_offset = 0x143182C

save_game_offset = 0x12C66FE
expected_save_game_original_value1 = 0x30508D4840488B48
expected_save_game_original_value2 = 0x48C03345

fstring_add_offset = 0x8822F0 ; FString operator+(const FString&, const wchar_t*)
fmemory_free_offset = 0x162AD30 ; FMemory::Free(void*)
getsavegamepath_offset = 0x335D270 ; FString FGenericSaveGameSystem::GetSaveGamePath(const wchar_t*)
projectsaveddir_offset = 0x16FF280

ChargeJumpRechargeDelay_setter_offset = 0x13262E4
ChargeJumpRechargeDelay_setter_expected = 0x0000000AC086C749

mirrormaze_size_check_offset = 0x1448695
mirrormaze_size_check_expected = 0x000005788F100FF3

; UQuestSystemComponent::Tick calls UGISProgression::AddRewards twice
; so sparks (and mirabilis from monolith fragments) are counted twice
; but these are only virtual and will be deducted back after restart
call_addrewards_offset1 = 0x1372E52
call_addrewards_offset2 = 0x1365D10

; ...and if you have got negative sparks as a result,
; you won't be able to take quests with UnlockCost = 0, which is all of them
exec_getunlockcost_offset = 0x15DBD55
exec_getunlockcost_expected = 0x0130818B

; make UQuestSystemComponent believe that APuzzleBase::canAwardAutoQuest = false
autoquestcheck_offset = 0x1377D62
autoquestcheck_expected = 0x840F000003C9B538 ; 6 last bytes of previous instruction + 2 bytes of jz

; make AViewfinderCamera believe that ASophiaCharacter::doHighQualityViewfinderCapture = true
sightseer_capture_offset = 0x14D9FE9
sightseer_capture_expected = 0x740000000739BB80

; insert extra marker for the nearest puzzle
collectmarkers_exit_offset = 0x14FA45B
collectmarkers_exit_expected = 0xD88D8B483024448B
tarray216_resize_grow_offset = 0x0A4D4E0
tarray216_resize_grow_expected = 0xB8E1F74897B425ED
FLocationMarkerData_constructor_offset = 0x1205A70
FLocationMarkerData_constructor_expected = 0x01010C41C7084189

section '.text' code readable executable

CreateDXGIFactory:
virtual at 0
	rb	20h	; shadow space for callees
.saved_rcx	dq	?
.saved_rdx	dq	?
.saved_r8	dq	?
.saved_r9	dq	?
.func	dd	?
.tmp2	dd	?
.patch_failed	db	?
	align 2
.tmp	dd	?	; used by make_writable/restore_protection
.orig_dll_name:
	rw	104h + 14h
	align 16
.stack_size = $
end virtual
	mov	al, 0
	jmp	@f
..CreateDXGIFactory1:
	mov	al, 1
	jmp	@f
..CreateDXGIFactory2:
	mov	al, 2
@@:
	push	rbx
.prolog_offs1 = $ - CreateDXGIFactory
	push	rdi
.prolog_offs2 = $ - CreateDXGIFactory
	sub	rsp, .stack_size + 8  ; 8 to align the stack
.prolog_offs3 = $ - CreateDXGIFactory
.prolog_size = $ - CreateDXGIFactory
	lea	rbx, [rsp+.orig_dll_name]
	movzx	eax, al
	cmp	qword [original], 0
	jnz	.justdoit
	mov	[rbx + .func - .orig_dll_name], eax
	mov	[rbx + .saved_rcx - .orig_dll_name], rcx
	mov	[rbx + .saved_rdx - .orig_dll_name], rdx
	mov	[rbx + .saved_r8 - .orig_dll_name], r8
	mov	[rbx + .saved_r9 - .orig_dll_name], r9
; get the path to the ini file
	xor	ecx, ecx
	mov	rdx, rbx
	mov	r8d, 104h
	call	[GetModuleFileNameW]
	lea	rdi, [rbx + rax*2]
@@:
	cmp	rdi, rbx
	jz	@f
	cmp	word [rdi-2], '/'
	jz	@f
	cmp	word [rdi-2], '\'
	jz	@f
	sub	rdi, 2
	jmp	@b
@@:
	mov	rax, 0x0069006700780064 ; dxgi
	stosq
	mov	rax, 0x0069006E0069002E	; .ini
	stosq
	and	word [rdi], 0
; patch function that saves player's location/rotation
	xor	ecx, ecx
	mov	[rbx + .patch_failed - .orig_dll_name], cl
	call	[GetModuleHandleW]
	mov	ecx, [rax+3Ch]
	cmp	dword [rax+rcx+50h], expected_image_size
	jnz	.nag
	lea	rcx, [rax+fstring_add_offset]
	mov	rdx, 0x8B840F0038834166
	cmp	[rcx+25h], rdx
	jz	@f
	xor	ecx, ecx
	mov	[rbx + .patch_failed - .orig_dll_name], 1
@@:
	mov	[fstring_add], rcx
	lea	rcx, [rax+fmemory_free_offset]
	mov	rdx, 0x8348532E74C98548
	cmp	[rcx], rdx
	jz	@f
	xor	ecx, ecx
	mov	[rbx + .patch_failed - .orig_dll_name], 1
@@:
	mov	[fmemory_free], rcx
	lea	rcx, [rax+getsavegamepath_offset]
	mov	edx, [rcx+2Dh]
	cmp	edx, expected_image_size - (getsavegamepath_offset + 31h) - 8
	ja	@f
	mov	r8, 0x0061005300730025 ; %sSa... (...veGames/%s.sav)
	cmp	[rdx+rcx+31h], r8
@@:
	jz	@f
	xor	ecx, ecx
	mov	[rbx + .patch_failed - .orig_dll_name], 1
@@:
	mov	[getsavegamepath], rcx
	lea	rdi, [rax+is_solved_offset]
; patch IsSolved/IsSolvedBy so that solved puzzles stay solved
	lea	rcx, [strGameplay]
	lea	rdx, [strSolvedStaySolved]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	test	eax, eax
	jz	.skip_solved_patch
	mov	edx, is_solved_by_offset - is_solved_offset + 1
	call	make_writable.large
; safety check: expect 7E to patch with EB
	mov	cl, 1
	cmp	byte [rdi], 0x7E
	jnz	@f
	mov	cl, 0
	mov	byte [rdi], 0xEB
@@:
	or	[rbx + .patch_failed - .orig_dll_name], cl
	mov	cl, 1
	lea	rax, [rdi + is_solved_by_offset - is_solved_offset]
	cmp	byte [rax], 0x7E
	jnz	@f
	mov	cl, 0
	mov	byte [rax], 0xEB
@@:
	or	[rbx + .patch_failed - .orig_dll_name], cl
	mov	edx, is_solved_by_offset - is_solved_offset + 1
	call	restore_protection.large
.skip_solved_patch:
; patch the caller of UGameplayStatics::SaveGameToSlot for save-to-temporary/move-temporary-to-main
; this assumes the availability of fstring_add, fmemory_free, getsavegamepath
	add	rdi, save_game_offset - is_solved_offset
	cmp	[rbx + .patch_failed - .orig_dll_name], 0
	jnz	.skip_savegame_patch
	lea	rcx, [strSaves]
	lea	rdx, [strViaTemporaryFile]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	mov	[use_temporary_file], al
	lea	rcx, [strSaves]
	lea	rdx, [strMaxBackups]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	mov	[max_backups], eax
	test	eax, eax
	jg	@f
	inc	[backup_made]
	cmp	[use_temporary_file], 0
	jz	.skip_savegame_patch
@@:
	lea	rax, [rdi - save_game_offset + projectsaveddir_offset]
	mov	rdx, 0x000109B880F88B48
	cmp	[rax+0Bh], rdx
	jnz	@f
	call	rax
	mov	[projectsaveddir], rax
@@:
	call	make_writable
	mov	rax, expected_save_game_original_value1
	mov	cl, 1
	cmp	[rdi], rax
	jnz	@f
	cmp	dword [rdi+8], expected_save_game_original_value2
	jnz	@f
	mov	eax, [rdi+10h]
	lea	rax, [rdi+14h+rax]
	mov	[savegametoslot], rax
	mov	word [rdi], 0xB948  ; mov rcx,imm64
	lea	rax, [save_game_patched]
	mov	[rdi+2], rax
	mov	word [rdi+10], 0xE1FF  ; jmp rcx
	mov	cl, 0
@@:
	or	[rbx + .patch_failed - .orig_dll_name], cl
	call	restore_protection
.skip_savegame_patch:
; patch ChargeJumpRechargeDelay
	add	rdi, ChargeJumpRechargeDelay_setter_offset - save_game_offset
	lea	rcx, [strGameplay]
	lea	rdx, [strChargeJumpRechargeDelay]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	test	eax, eax
	jz	.skip_recharge_patch
	mov	[rbx + .tmp2 - .orig_dll_name], eax
	mov	cl, 1
	mov	rdx, ChargeJumpRechargeDelay_setter_expected
	cmp	qword [rdi], rdx
	jnz	.done_recharge_patch
	call	make_writable
	movss	xmm0, [rbx + .tmp2 - .orig_dll_name]
	cvtdq2ps xmm0, xmm0
	movss	[rdi+7], xmm0
	call	restore_protection
	mov	cl, 0
.done_recharge_patch:
	or	[rbx + .patch_failed - .orig_dll_name], cl
.skip_recharge_patch:
; patch away size check in AMirrorMazePuzzle
	add	rdi, mirrormaze_size_check_offset - ChargeJumpRechargeDelay_setter_offset
	mov	rax, mirrormaze_size_check_expected
	mov	cl, 1
	cmp	qword [rdi], rax
	jnz	@f
	call	make_writable
	mov	word [rdi], 0x4AEB
	call	restore_protection
	mov	cl, 0
@@:
	or	[rbx + .patch_failed - .orig_dll_name], cl
	add	rdi, call_addrewards_offset1 - mirrormaze_size_check_offset
	lea	rcx, [strGameplay]
	lea	rdx, [strFixQuestRewards]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	test	eax, eax
	jz	.skip_fixrewards_patch
	mov	cl, 1
	cmp	byte [rdi], 0xE8
	jnz	.done_fixrewards_patch
	lea	rax, [rdi + call_addrewards_offset2 - call_addrewards_offset1]
	cmp	byte [rax], 0xE8
	jnz	.done_fixrewards_patch
	add	eax, [rax + 1]
	mov	edx, [rdi + 1]
	add	edx, edi
	cmp	eax, edx
	jnz	.done_fixrewards_patch
	call	make_writable
	mov	byte [rdi], 0x90
	mov	dword [rdi+1], 0x90909090
	call	restore_protection
	mov	cl, 0
.done_fixrewards_patch:
	or	[rbx + .patch_failed - .orig_dll_name], cl
.skip_fixrewards_patch:
	mov	cl, 1
	add	rdi, exec_getunlockcost_offset - call_addrewards_offset1
	cmp	dword [rdi], exec_getunlockcost_expected
	jnz	@f
	call	make_writable
	mov	word [rdi], 0xB890
	mov	dword [rdi+2], -1000000000
	call	restore_protection
	mov	cl, 0
@@:
	or	[rbx + .patch_failed - .orig_dll_name], cl
	add	rdi, autoquestcheck_offset - exec_getunlockcost_offset
	lea	rcx, [strGameplay]
	lea	rdx, [strDisableWandererQuests]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	test	eax, eax
	jz	.skip_autoquestcheck_patch
	mov	cl, 1
	mov	rax, autoquestcheck_expected
	cmp	qword [rdi-6], rax
	jnz	.done_autoquestcheck_patch
	call	make_writable
	mov	word [rdi], 0xE990
	call	restore_protection
	mov	cl, 0
.done_autoquestcheck_patch:
	or	[rbx + .patch_failed - .orig_dll_name], cl
.skip_autoquestcheck_patch:
	add	rdi, sightseer_capture_offset - autoquestcheck_offset
	lea	rcx, [strGameplay]
	lea	rdx, [strHighQualitySightSeerCapture]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	test	eax, eax
	jz	.skip_sightseer_capture_patch
	mov	cl, 1
	mov	rax, sightseer_capture_expected
	cmp	qword [rdi-7], rax
	jnz	.done_sightseer_capture_patch
	call	make_writable
	mov	byte [rdi+1], 0
	call	restore_protection
	mov	cl, 0
.done_sightseer_capture_patch:
	or	[rbx + .patch_failed - .orig_dll_name], cl
.skip_sightseer_capture_patch:
	add	rdi, collectmarkers_exit_offset - sightseer_capture_offset
	lea	rcx, [strGameplay]
	lea	rdx, [strShowNearestUnsolved]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	test	eax, eax
	jz	.skip_shownearest_patch
	lea	rcx, [strGameplay]
	lea	rdx, [strHiddenPuzzlesMarkerMaxDistance]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	cvtsi2ss xmm0, eax
	unpcklps xmm0, xmm0
	unpcklps xmm0, xmm0
	mulps	xmm0, xword [hide_radius_multiplier]
	movaps	xword [hide_radius], xmm0
	mov	rax, collectmarkers_exit_expected
	mov	cl, 1
	cmp	qword [rdi+1], rax
	jnz	.done_shownearest_patch
	lea	rax, [rdi+15]
	mov	[additionalmarkers_continue], rax
	add	rax, tarray216_resize_grow_offset - (collectmarkers_exit_offset + 15)
	mov	rdx, tarray216_resize_grow_expected
	cmp	[rax+4Eh], rdx
	jnz	.done_shownearest_patch
	mov	[tarray216_resize_grow], rax
	add	rax, FLocationMarkerData_constructor_offset - tarray216_resize_grow_offset
	mov	rdx, FLocationMarkerData_constructor_expected
	cmp	[rax+24h], rdx
	jnz	.done_shownearest_patch
	mov	[FLocationMarkerData_constructor], rax
	call	make_writable
	mov	word [rdi], 0xB848
	lea	rax, [additional_markers]
	mov	[rdi+2], rax
	mov	word [rdi+10], 0xE0FF
	call	restore_protection
	mov	cl, 0
.done_shownearest_patch:
	or	[rbx + .patch_failed - .orig_dll_name], cl
.skip_shownearest_patch:
	cmp	[rbx + .patch_failed - .orig_dll_name], 0
	jz	.done
.nag:
	xor	ecx, ecx
	lea	rdx, [patch_failed_text]
	lea	r8, [patch_failed_caption]
	lea	r9, [rcx+MB_OK+MB_ICONSTOP]
	call	[MessageBoxA]
.done:
	mov	rcx, rbx
	mov	edx, 104h
	call	[GetSystemDirectoryW]
	lea	rdi, [rbx + rax*2]
	mov	rax, 0x006700780064005C ; \dxg
	stosq
	mov	rax, 0x006C0064002E0069	; i.dl
	stosq
	mov	eax, 0x0000006C	; l
	stosd
	mov	rcx, rbx
	call	[LoadLibraryW]
	mov	rbx, rax
	lea	rdi, [original]
	mov	rcx, rax
	lea	rdx, [export_name1_rva + ($ - rva $)]
	call	[GetProcAddress]
	stosq
	mov	rcx, rbx
	lea	rdx, [export_name2_rva + ($ - rva $)]
	call	[GetProcAddress]
	stosq
	mov	rcx, rbx
	lea	rdx, [export_name3_rva + ($ - rva $)]
	call	[GetProcAddress]
	stosq
	mov	rbx, rsp
	mov	eax, [rbx + .func]
	mov	rcx, [rbx + .saved_rcx]
	mov	rdx, [rbx + .saved_rdx]
	mov	r8, [rbx + .saved_r8]
	mov	r9, [rbx + .saved_r9]
.justdoit:
	lea	r10, [original]
	add	rsp, .stack_size + 8
	pop	rdi
	pop	rbx
@@:
	jmp	qword [r10 + rax*8]
; https://stackoverflow.com/questions/36788685/meaning-of-rex-w-prefix-before-amd64-jmp-ff25
load a byte from @b
assert a = 0x41
store byte a+8 at @b
.end:

make_writable:
	mov	edx, 12
.large:
	sub	rsp, 28h
.prolog_size = $ - make_writable
	mov	rcx, rdi
	mov	r8d, PAGE_READWRITE
	lea	r9, [rbx - 4]
	call	[VirtualProtect]
	add	rsp, 28h
	ret
.end:

restore_protection:
	mov	edx, 12
.large:
	sub	rsp, 28h
.prolog_size = $ - restore_protection
	mov	rcx, rdi
	lea	r9, [rbx - 4]
	mov	r8d, [r9]
	call	[VirtualProtect]
	add	rsp, 28h
	ret
.end:

save_game_patched:
	mov	[rsp+20h], rax ; save useful data
	cmp	[backup_made], 0
	jnz	@f
	inc	[backup_made]
	mov	rdx, [projectsaveddir]
	test	rdx, rdx
	jz	@f
	call	make_backup
@@:
	lea	rcx, [rsp+30h]
	mov	rax, [rcx-10h]
	cmp	[use_temporary_file], 0
	jnz	@f
	mov	rcx, [rax+40h]
	lea	rdx, [rax+30h]
	xor	r8d, r8d
	add	rsp, 28h
	jmp	[savegametoslot]
@@:
; "OfflineSavegame" -> "OfflineSavegame.tmp"
	lea	rdx, [rax+30h]
	lea	r8, [str_tmp]
	call	[fstring_add]
; save the game into OfflineSavegame.tmp; on error, stop further processing
	lea	rdx, [rsp+30h]
	mov	rax, [rdx-10h]
	mov	rcx, [rax+40h]
	xor	r8d, r8d
	call	[savegametoslot]
	test	al, al
	jz	.done
; "OfflineSavegame.tmp" -> ".../SaveGames/OfflineSavegame.tmp.sav"
	xor	ecx, ecx
	lea	rdx, [rsp+40h]
	mov	r8, [rdx-10h]
	call	[getsavegamepath]
; we don't need "OfflineSavegame.tmp" anymore, free the memory now
	mov	rcx, [rsp+30h]
	call	[fmemory_free]
; "OfflineSavegame" -> ".../SaveGames/OfflineSavegame.sav"
	xor	ecx, ecx
	lea	rdx, [rsp+30h]
	mov	rax, [rdx-10h]
	mov	r8, [rax+30h]
	call	[getsavegamepath]
; delete the old file, ignore errors (for the first launch, there will be no old save)
	mov	rcx, [rsp+30h]
	call	[DeleteFileW]
; move the new file to the final name
	mov	rcx, [rsp+40h]
	mov	rdx, [rsp+30h]
	call	[MoveFileW]
; the game does not care about the returned value
; maybe we could do something ourselves to handle a possible failure,
; but it is unclear what exactly
	mov	rcx, [rsp+40h]
	call	[fmemory_free]
.done:
	mov	rcx, [rsp+30h]
	call	[fmemory_free]
	mov	al, 1
	add	rsp, 28h
	ret
.end:

make_backup:
virtual at 0
	rb	48h	; shadow space for callees + arguments for Sprintf
virtual at $-4
.old_backups_left	dd	?
end virtual
.frame_offset:
.savebackups_dir	rq	2
.tmp_filename		rq	2
.new_backup_filename	rq	2
assert ($ mod 16) = 8
.stack_size = $
	dq	?	; saved rdi
	dq	?	; saved rbx
	dq	?	; return address
; use shadow space of the caller
.old_backups	dq	?
.old_backups_end	dq	?
.enum_dir_handle	dq	?
end virtual
	push	rbx
.prolog_offs1 = $ - make_backup
	push	rdi
.prolog_offs2 = $ - make_backup
	add	rsp, -.stack_size
.prolog_offs3 = $ - make_backup
.prolog_size = $ - make_backup
	lea	rbx, [rsp + .frame_offset]
	lea	rcx, [rbx - .frame_offset + .savebackups_dir]
	lea	r8, [savebackups_path]
	call	[fstring_add]
	mov	rcx, [rbx - .frame_offset + .savebackups_dir]
	mov	eax, dword [rbx - .frame_offset + .savebackups_dir + 8]
	mov	byte [rcx + rax*2 - 4], 0 ; '/' -> 0
	xor	edx, edx
	call	[CreateDirectoryW]
	lea	rcx, [rbx - .frame_offset + .new_backup_filename]
	call	[GetLocalTime]
	movzx	eax, word [rbx - .frame_offset + .new_backup_filename + SYSTEMTIME.wMonth]
	mov	qword [rbx - .frame_offset + 20h], rax
	movzx	eax, word [rbx - .frame_offset + .new_backup_filename + SYSTEMTIME.wDay]
	mov	qword [rbx - .frame_offset + 28h], rax
	movzx	eax, word [rbx - .frame_offset + .new_backup_filename + SYSTEMTIME.wHour]
	mov	qword [rbx - .frame_offset + 30h], rax
	movzx	eax, word [rbx - .frame_offset + .new_backup_filename + SYSTEMTIME.wMinute]
	mov	qword [rbx - .frame_offset + 38h], rax
	movzx	eax, word [rbx - .frame_offset + .new_backup_filename + SYSTEMTIME.wSecond]
	mov	qword [rbx - .frame_offset + 40h], rax
	mov	r8, [rbx - .frame_offset + .savebackups_dir]
	mov	eax, dword [rbx - .frame_offset + .savebackups_dir + 8]
	mov	byte [r8 + rax*2 - 4], '/'
	mov	rax, [getsavegamepath]
	movsxd	rcx, dword [rax+35h]
	lea	rax, [rax+39h+rcx]
	lea	rcx, [rbx - .frame_offset + .new_backup_filename]
	lea	rdx, [backup_filename_formatstring]
	movzx	r9d, word [rbx - .frame_offset + .new_backup_filename + SYSTEMTIME.wYear]
	call	rax
	lea	rcx, [rbx - .frame_offset + .tmp_filename]
	lea	rdx, [rbx - .frame_offset + .savebackups_dir]
	lea	r8, [savebackups_mask]
	call	[fstring_add]
	call	[GetProcessHeap]
	mov	rcx, rax
	xor	edx, edx
	mov	eax, [max_backups]
	mov	[rbx - .frame_offset + .old_backups_left], eax
	imul	r8d, eax, sizeof.WIN32_FIND_DATAW
	mov	[rbx - .frame_offset + .old_backups_end], r8
	call	[HeapAlloc]
	test	rax, rax
	jz	.cleanup_failed
	mov	rdi, rax
	mov	[rbx - .frame_offset + .old_backups], rax
	add	[rbx - .frame_offset + .old_backups_end], rax
	mov	rcx, [rbx - .frame_offset + .tmp_filename]
	mov	rdx, rax
	call	[FindFirstFileW]
	cmp	rax, -1
	jz	.no_backups_to_remove
	mov	[rbx - .frame_offset + .enum_dir_handle], rax
.file_loop:
	test	byte [rdi+WIN32_FIND_DATAW.dwFileAttributes], FILE_ATTRIBUTE_DIRECTORY
	jnz	.next_file
	add	rdi, sizeof.WIN32_FIND_DATAW
	dec	[rbx - .frame_offset + .old_backups_left]
	jg	.next_file
; we got max_backups files, remove the oldest one to make the space for the new one
	mov	rax, [rbx - .frame_offset + .old_backups]
	mov	rdi, rax
	mov	rcx, qword [rax + WIN32_FIND_DATAW.ftLastWriteTime]
.find_oldest_file:
	add	rax, sizeof.WIN32_FIND_DATAW
	cmp	rax, [rbx - .frame_offset + .old_backups_end]
	jz	.found_oldest_file
	cmp	qword [rax + WIN32_FIND_DATAW.ftLastWriteTime], rcx
	jae	.find_oldest_file
	mov	rdi, rax
	mov	rcx, qword [rax + WIN32_FIND_DATAW.ftLastWriteTime]
	jmp	.find_oldest_file
.found_oldest_file:
	mov	rcx, [rbx - .frame_offset + .tmp_filename]
	call	[fmemory_free]
	lea	rcx, [rbx - .frame_offset + .tmp_filename]
	lea	rdx, [rbx - .frame_offset + .savebackups_dir]
	lea	r8, [rdi + WIN32_FIND_DATAW.cFileName]
	call	[fstring_add]
	mov	rcx, [rbx - .frame_offset + .tmp_filename]
	call	[DeleteFileW]
.next_file:
	mov	rcx, [rbx - .frame_offset + .enum_dir_handle]
	mov	rdx, rdi
	call	[FindNextFileW]
	test	eax, eax
	jnz	.file_loop
	mov	rcx, [rbx - .frame_offset + .enum_dir_handle]
	call	[FindClose]
.no_backups_to_remove:
	mov	rcx, [rbx - .frame_offset + .tmp_filename]
	call	[fmemory_free]
	call	[GetProcessHeap]
	mov	rcx, rax
	xor	edx, edx
	mov	r8, [rbx - .frame_offset + .old_backups]
	call	[HeapFree]
.cleanup_failed:
; cleanup completed, now actually make a backup
	xor	ecx, ecx
	lea	rdx, [rbx - .frame_offset + .old_backups] ; reuse the stack var
	lea	r8, [str_OfflineSavegame]
	call	[getsavegamepath]
	mov	rcx, [rbx - .frame_offset + .old_backups]
	mov	rdx, [rbx - .frame_offset + .new_backup_filename]
	xor	r8d, r8d
	call	[CopyFileW]
	mov	rcx, [rbx - .frame_offset + .old_backups]
	call	[fmemory_free]
	mov	rcx, [rbx - .frame_offset + .new_backup_filename]
	call	[fmemory_free]
	mov	rcx, [rbx - .frame_offset + .savebackups_dir]
	call	[fmemory_free]
	add	rsp, .stack_size
	pop	rdi
	pop	rbx
	ret
.end:

additional_markers:
; we'll use xmm6 as the best distance, xmm7 as the current distance,
; xmm8 as player position, xmm9 as best coordinates, xmm10 as current coordinates
; xmm6 is already saved/restored by the original code
	movaps	[rbp], xmm7
.prolog_offs1 = $ - additional_markers
	movaps	[rbp+10h], xmm8
.prolog_offs2 = $ - additional_markers
	movaps	[rbp+20h], xmm9
.prolog_offs3 = $ - additional_markers
	movaps	[rbp+30h], xmm10
.prolog_offs4 = $ - additional_markers
.prolog_size = $ - additional_markers
; called twice per frame, for the screen and for the map. Don't do the same work twice
	cmp	byte [rbp+1E0h], 0
	jz	.done
; r12 = UMarkerComponent*, rsi = AGameState*
	mov	rax, [r12+0A0h] ; UActorComponent::OwnerPrivate
	mov	rax, [rax+220h]	; AHUD::PlayerOwner
	mov	rax, [rax+250h]	; AController::Pawn
	mov	r14, [rax+878h]	; ASophiaCharacter::CurDungeon
	mov	rax, [rax+130h]	; AActor::RootComponent
	movups	xmm8, [rax+1D0h]	; get player position
	mov	eax, 7F800000h	; fp32 infinity
	movd	xmm6, eax
	xor	r15, r15
	mov	edi, [rsi+390h]
	mov	rsi, [rsi+388h]
.findnearest:
	dec	edi
	js	.oknearest
	mov	rcx, [rsi+rdi*8]
	xor	ebx, ebx
.retry_if_matchbox:
; find the relevant point
	movzx	eax, byte [rcx+254h]
	cmp	al, -1	; something technical including instances of AMonument for wall slots (but not puzzles themselves)
	jz	.findnearest
; outside of dungeons: ignore dungeon puzzles, ignore gyroRing and rosary
; inside of a dungeon: ignore other dungeon puzzles, include mainland puzzles, include gyroRing and rosary from the same dungeon
	mov	rdx, [rcx+4E8h]
	cmp	rdx, r14
	jz	.samedungeon
	test	r14, r14
	jz	.findnearest
	test	rdx, rdx
	jnz	.findnearest
.samedungeon:
	test	rdx, rdx
	jnz	@f
	cmp	al, 9	; just ignore gyroRing
	jz	.findnearest
	cmp	al, 26	; just ignore rosary
	jz	.findnearest
@@:
; viewfinder's reference point is the solving place, we need ViewfinderImage->planeMesh instead
	cmp	al, 31
	jnz	.not_viewfinder
	mov	rdx, [rcx+5E8h]
	test	rdx, rdx
	jz	.findnearest
	mov	rdx, [rdx+258h]
	jmp	.position_from_component
.not_viewfinder:
; for seek5, racingrings and followtheshiny the reference point is usually correct,
; but sometimes a few meters off; get a point aligned with the visuals
	cmp	al, 28
	jnz	.not_seek5
	mov	rdx, [rcx+518h]	; CentralPillar
	jmp	.position_from_component
.not_seek5:
	cmp	al, 24
	jnz	.not_racingrings
	mov	rdx, [rcx+568h]	; StartingPlatform
	jmp	.position_from_component
.not_racingrings:
	cmp	al, 4
	jnz	.not_followtheshiny
	mov	rdx, [rcx+548h]	; ShinyMesh
	jmp	.position_from_component
.not_followtheshiny:
; for racingballs, there are several relevant points,
; but the reference point is not one of them;
; get the middle point in the array because why not
	cmp	al, 23
	jnz	.not_racingballs
	mov	eax, [rcx+5E8h]
	test	eax, eax
	jz	.not_racingballs
	shr	eax, 1
	mov	rdx, [rcx+5E0h]
	mov	rdx, [rdx+rax*8]
	jmp	.position_from_component
.not_racingballs:
; for matchbox, repeat the loop twice for both components
	cmp	al, 18
	jnz	.not_matchbox
	mov	rdx, [rcx+508h+rbx*8]
	jmp	.position_from_component
.not_matchbox:
.position_from_actor:
; by default, just take the reference point from the root component
	mov	rdx, [rcx+130h]
.position_from_component:
	movups	xmm7, [rdx+1D0h]
; for hidden archways, cubes, rings, light patterns and matchboxes add a random offset
; hiddenArchway=10, hiddenCube=11, hiddenRing=12, lightPattern=14, matchbox=18
	cmp	eax, 32
	jae	.no_random_offset
	mov	edx, (1 shl 10) or (1 shl 11) or (1 shl 12) or (1 shl 14) or (1 shl 18)
	bt	edx, eax
	jnc	.no_random_offset
	mov	eax, [rcx+420h]	; KrakenId
	add	eax, ebx
@@:
	imul	eax, 196314165
	add	eax, 907633515
	cvtsi2ss xmm0, eax
	unpcklps xmm1, xmm0 ; xmm1 = ? rnd1 ? ?
	mulss	xmm0, xmm0
	imul	eax, 196314165
	add	eax, 907633515
	cvtsi2ss xmm2, eax
	unpcklps xmm1, xmm2 ; xmm1 = ? rnd2 rnd1 ?
	mulss	xmm2, xmm2
	addss	xmm0, xmm2
	imul	eax, 196314165
	add	eax, 907633515
	cvtsi2ss xmm2, eax
	movss	xmm1, xmm2 ; xmm1 = rnd3 rnd2 rnd1 ?
	mulss	xmm2, xmm2
	addss	xmm0, xmm2
	comiss	xmm0, [_2pow62]
	jae	@b
	mulps	xmm1, xword [hide_radius]
	addps	xmm7, xmm1
.no_random_offset:
; compare the distance to the player with current best
	movaps	xmm10, xmm7
	subps	xmm7, xmm8
	mulps	xmm7, xmm7
	movaps	xmm0, xmm7
	movaps	xmm1, xmm7
	shufps	xmm0, xmm0, 55h
	shufps	xmm1, xmm1, 0AAh
	addss	xmm7, xmm0
	addss	xmm7, xmm1
	comiss	xmm6, xmm7
	jbe	.skip
; check whether this is solved
	mov	rax, [rcx]
	call	qword [rax+730h]
	mov	rcx, [rsi+rdi*8]
	test	al, al
	jnz	.skip
; seems good, update our best candidate
	mov	r15, rcx
	movss	xmm6, xmm7
	movaps	xmm9, xmm10
.skip:
	inc	ebx
	cmp	byte [rcx+254h], 18
	jnz	.findnearest
	cmp	ebx, 2
	jb	.retry_if_matchbox
	jmp	.findnearest
.oknearest:
	test	r15, r15
	jz	.done
; we have got our puzzle, now fill the marker
	lea	rcx, [rsp+30h]
	mov	ebx, [rcx+8]
	lea	eax, [rbx+1]
	mov	[rcx+8], eax
	cmp	eax, [rcx+0Ch]
	jbe	@f
	mov	edx, ebx
	call	[tarray216_resize_grow]
@@:
	imul	edi, ebx, 0xD8
	add	rdi, [rsp+30h]
	mov	rcx, rdi
	call	[FLocationMarkerData_constructor]
	movups	[rdi], xmm9
	mov	dword [rdi+0Ch], 1 ; VisibleOnScreen = true, VisibleOnMap = showEverywhere = ShowOverFog = false
	mov	rax, [r15+2C0h]
	mov	[rdi+20h], rax ; worldTex
	mov	rax, [r15+2C8h]
	mov	[rdi+28h], rax ; mapTex
.done:
	movaps	xmm7, [rbp]
	movaps	xmm8, [rbp+10h]
	movaps	xmm9, [rbp+20h]
	movaps	xmm10, [rbp+30h]
	mov	rax, [rsp+30h]
	mov	rcx, [rbp+1D8h]
	mov	[rcx], rax
	jmp	[additionalmarkers_continue]
.end:

section '.rdata' data readable
; 100.0 to convert meters -> UE units, 2**-31 to deal with our random method
hide_radius_multiplier	dd	0x33480000, 0x33480000, 0x33480000, 0

data import
library kernel32, 'KERNEL32.DLL', user32, 'USER32.DLL'
include 'api/kernel32.inc'
include 'api/user32.inc'
end data

align 4
export_data:
data export
export 'dxgi.dll', \
	CreateDXGIFactory, 'CreateDXGIFactory', \
	..CreateDXGIFactory1, 'CreateDXGIFactory1', \
	..CreateDXGIFactory2, 'CreateDXGIFactory2'
end data
load export_name_table_rva dword from export_data+20h ; IMAGE_EXPORT_DIRECTORY.AddressOfNames
load export_name1_rva dword from (export_data - rva export_data + export_name_table_rva)
load export_name2_rva dword from (export_data - rva export_data + export_name_table_rva + 4)
load export_name3_rva dword from (export_data - rva export_data + export_name_table_rva + 8)

align 4
data 3  ; IMAGE_DIRECTORY_ENTRY_EXCEPTION
	dd	rva CreateDXGIFactory, rva CreateDXGIFactory.end, rva CreateDXGIFactory_unwind
	dd	rva save_game_patched, rva save_game_patched.end, rva save_game_patched_unwind
	dd	rva make_backup, rva make_backup.end, rva make_backup_unwind
	dd	rva make_writable, rva make_writable.end, rva make_writable_unwind
	dd	rva restore_protection, rva restore_protection.end, rva make_writable_unwind ; the prologues are identical
	dd	rva additional_markers, rva additional_markers.end, rva additional_markers_unwind
end data

CreateDXGIFactory_unwind:
	db	1, CreateDXGIFactory.prolog_size, CreateDXGIFactory_unwind.size / 2, 0
.start:
	db	CreateDXGIFactory.prolog_offs3, 1	; UWOP_ALLOC_LARGE
	dw	(CreateDXGIFactory.stack_size + 8) / 8	; arg for UWOP_ALLOC_LARGE
	db	CreateDXGIFactory.prolog_offs2, 70h ; UWOP_PUSH_NONVOL=0, rdi->7
	db	CreateDXGIFactory.prolog_offs1, 30h ; UWOP_PUSH_NONVOL=0, rbx->3
.size = $ - .start
if .size mod 4
	dw	0
end if
save_game_patched_unwind:
	db	1, 0, save_game_patched_unwind.size / 2, 0
.start:
	db	0, 2 + ((28h - 8) / 8) * 10h ; UWOP_ALLOC_SMALL for 28h bytes
.size = $ - .start
if .size mod 4
	dw	0
end if
make_backup_unwind:
	db	1, make_backup.prolog_size, make_backup_unwind.size / 2, 0
.start:
	db	make_backup.prolog_offs3, 2 + ((make_backup.stack_size - 8) / 8) * 10h
	db	make_backup.prolog_offs2, 70h ; UWOP_PUSH_NONVOL=0, rdi->7
	db	make_backup.prolog_offs1, 30h ; UWOP_PUSH_NONVOL=0, rbx->3
.size = $ - .start
if .size mod 4
	dw	0
end if
make_writable_unwind: ; also used for restore_protection
	db	1, make_writable.prolog_size, make_writable_unwind.size / 2, 0
.start:
	db	make_writable.prolog_size, 2 + ((28h - 8) / 8) * 10h
.size = $ - .start
if .size mod 4
	dw	0
end if
additional_markers_unwind:
	db	1, additional_markers.prolog_size, additional_markers_unwind.size / 2, 0
.start:
	db	additional_markers.prolog_offs4, 8 + 10 * 10h	; UWOP_SAVE_XMM128 for xmm10
	dw	0x13	; saved to [rsp+130h]
	db	additional_markers.prolog_offs3, 8 + 9 * 10h	; UWOP_SAVE_XMM128 for xmm9
	dw	0x12	; saved to [rsp+120h]
	db	additional_markers.prolog_offs2, 8 + 8 * 10h	; UWOP_SAVE_XMM128 for xmm8
	dw	0x11	; saved to [rsp+110h]
	db	additional_markers.prolog_offs1, 8 + 7 * 10h	; UWOP_SAVE_XMM128 for xmm7
	dw	0x10	; saved to [rsp+100h]
; we inherit these from the main code
	db	0, 8 + 6 * 10h	; UWOP_SAVE_XMM128 for xmm6
	dw	27h	; saved to [rsp+270h]
	db	0, 1	; UWOP_ALLOC_LARGE
	dw	51h
	db	0, 0F0h	; UWOP_PUSH_NONVOL r15
	db	0, 0E0h	; UWOP_PUSH_NONVOL r14
	db	0, 0D0h	; UWOP_PUSH_NONVOL r13
	db	0, 0C0h	; UWOP_PUSH_NONVOL r12
	db	0, 70h	; UWOP_PUSH_NONVOL rdi
	db	0, 60h	; UWOP_PUSH_NONVOL rsi
	db	0, 30h	; UWOP_PUSH_NONVOL rbx
	db	0, 50h	; UWOP_PUSH_NONVOL rbp
.size = $ - .start
if .size mod 4
	dw	0
end if

align 4
fixups_start = $
data fixups
if $ = fixups_start
	dd	0, 8	; fake entry
end if
end data

_2pow62	dd	0x5E800000

patch_failed_text:
	db	'Some patches have not been applied. Probably the executable has been updated and you need to get a new version of the patch.', 0
patch_failed_caption:
	db	'Patch error',0

align 2
str_tmp	du	'.tmp',0
str_OfflineSavegame	du	'OfflineSavegame',0
backup_filename_formatstring	du	'%sOfflineSavegame_%04d-%02d-%02d_%02d%02d%02d.sav',0
savebackups_path	du	'SaveBackups/',0
savebackups_mask	du	'*.sav',0

; ini file sections and keys
strSaves	du	'Saves', 0
strViaTemporaryFile	du	'ViaTemporaryFile', 0
strMaxBackups	du	'MaxBackups', 0
strGameplay	du	'Gameplay', 0
strSolvedStaySolved	du	'SolvedStaySolved', 0
strChargeJumpRechargeDelay	du	'ChargeJumpRechargeDelay', 0
strFixQuestRewards	du	'FixQuestRewards', 0
strDisableWandererQuests	du	'DisableWandererQuests', 0
strHighQualitySightSeerCapture	du	'HighQualitySightSeerCapture', 0
strShowNearestUnsolved	du	'ShowNearestUnsolved', 0
strHiddenPuzzlesMarkerMaxDistance	du	'HiddenPuzzlesMarkerMaxDistance', 0

section '.data' data readable writable
hide_radius	rq	4
original	rq	3
savegametoslot	dq	?
fstring_add	dq	?
fmemory_free	dq	?
getsavegamepath	dq	?
projectsaveddir	dq	?
additionalmarkers_continue	dq	?
tarray216_resize_grow	dq	?
FLocationMarkerData_constructor	dq	?
max_backups	dd	?
backup_made	db	?
use_temporary_file db	?

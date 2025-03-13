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

; hook ASophiaCharacter::PutMarker to point to the nearest puzzle
putmarker_offset = 0x1358FE0
putmarker_expected1 = 0x24548820245C8948
putmarker_expected2 = 0x565508244C894810

; hook reading of ASophia/BuildId/version.txt at Esc screen to add mod version
sophiagameinstance_loadversion_offset = 0x12B119F
sophiagameinstance_loadversion_expected = 0xE8000006C08F8D48

; SHA1 calculator
sha1_hashbuffer_offset = 0x16F56F0
sha1_hashbuffer_expected = 0x2444C7C033C28B4C

; make initialization of UPuzzleDatabase robust to repeated calls
puzzledatabase_init_offset = 0x14CFCD2
puzzledatabase_init_expected = 0x244489B04589C78B

; ignore subsequent presses of "Offline mode" button that cause several calls of UGISKraken::Init
giskraken_init_offset = 0x124AEF0
giskraken_init_expected = 0x74894808245C8948

; UMatchboxRadarComponent::TickComponent has several checks that filter puzzles,
; we need to patch two of them: the first one excludes hidden objects,
; the second one directly checks against AMatchbox
radar_hiddenobj_check_offset = 0x12D563F
radar_hiddenobj_check_expected = 0x840FC08400000658
radar_matchbox_check_offset = 0x12D56FD
radar_matchbox_check_expected = 0xE83077D92F0FD858

puzzlegrid_check_modifier_offset = 0x138EA71
puzzlegrid_check_modifier_expected = 0x850F06F883410101

chargridcomponent_hint_offset = 0x131D8D8
chargridcomponent_hint_expected1 = 0x35100FF3
chargridcomponent_hint_expected2 = 0x0561B880

spawnnotify_patch1_offset = 0x14DE211
spawnnotify_patch1_expected = 0x02CCB53B413B8B48
spawnnotify_patch2_offset = 0x14DE2D9
spawnnotify_patch2_expected = 0x7489C6FF0C7501A8
spawnnotify_addmsg_offset = 0x14DF2D5
spawnnotify_addmsg_expected = 0x40247C80
spawnnotify_stringmapinsertcall_offset = 0x14DF212
spawnnotify_stringmapinsertcall_expected = 0xE8000003208D8D48

; the first place to patch is in APuzzleBase::SetSolvedOnServer,
; just before the call to UGISKraken::SolvePuzzle that writes to savefile
bestsolvetime1_offset = 0x144B907
bestsolvetime1_expected = 0x8BC08B4CB84D8D4C
; the second place to patch is in APuzzleBase::AddSolvedPuzzle,
; just before the call that updates in-memory FPlayerProgressionData
bestsolvetime2_offset = 0x1442D91
bestsolvetime2_expected = 0x100F41F3A0458948
getpuzzlesolvestatus_offset = 0x12462F0
getpuzzlesolvestatus_expected = 0xD08B49F98B41F28B

gridsolve_offset = 0x13C5606
gridsolve_expected = 0x840F000478800000

ASandboxGameMode_vmt_Tick_offset = 0x468C3B8
ASandboxGameMode_Tick_expected = 0xA486FF41
ASandboxGameMode_vmt_InitGameMode_offset = 0x468C8A0
ASandboxGameMode_InitGameMode_expected = 0xC748F98B4830EC83
execGetLevel_offset = 0x1595CFE
execGetLevel_expected = 0xC35B20C483480389
findmarkerclass_offset = 0x151C11D
findmarkerclass_expected = 0xE8CE8B48000000E0
ARacingBalls_AppendLocationMarkers_offset = 0x142CDEE
ARacingBalls_AppendLocationMarkers_expected = 0x8C0F000005E8BF3B
FFileHelper_LoadFileToArray_offset = 0x16F8F10
GetSophiaCharacterFromWorld_offset = 0x1344A90
GetAllPuzzleDataInZone_offset = 0x14AEE20
GetAllSolvedPuzzleDataInZone_offset = 0x14AFDA0
FActorSpawnParameters_ctr_offset = 0x35723C0
FSoftObjectPtr_LoadSynchronous_offset = 0x097F4D0
UWorld_SpawnActor_offset = 0x31C4330
UItemData_StaticClass_offset = 0x1568960
FStaticConstructObjectParameters_ctr_offset = 0x19329E0
StaticConstructObject_Internal_offset = 0x194DDB0
UDefaultItems_GetDefaultItem_offset = 0x12A7920
USceneComponent_SetRelativeScale3D_offset = 0x3002860
AActor_Destroy_offset = 0x2E3D710
first_zone = 2
num_zones = 5

patch_liars_modifier = 0
add_chests = 1
debug_chests = 1

section '.text' code readable executable

CreateDXGIFactory:
virtual at 0
	rb	20h	; shadow space for callees
.very_temporary	rq	3	; stack args for callees
.full_pak_name	rq	2
.directory_end	dq	?
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
	rw	104h + 18h
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
	mov	[rbx + .directory_end - .orig_dll_name], rdi
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
	lea	rcx, [save_critsect]
	call	[InitializeCriticalSection]
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
	cmp	[use_temporary_file], 0
	jz	.skip_savegame_patch
@@:
	lea	rcx, [strSaves]
	lea	rdx, [strBackupPeriod]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	imul	eax, 1000
	mov	[backup_period], eax
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
	mov	[show_nearest_unsolved], al
	lea	rcx, [strGameplay]
	lea	rdx, [strShowNearestLogicGrid]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	mov	[show_nearest_logicgrid], al
	lea	rcx, [strGameplay]
	lea	rdx, [strMinLogicGridDifficulty]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	cmp	al, 1
	jbe	@f
	mov	[min_logicgrid_difficulty], al
@@:
	lea	rcx, [strGameplay]
	lea	rdx, [strEmoteMarksNearestUnsolved]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	mov	byte [rbx + .tmp2 - .orig_dll_name], al
if debug_chests
	lea	rcx, [strGameplay]
	lea	rdx, [strAddChestsMarker]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	mov	[add_chests_marker], al
	or	al, byte [rbx + .tmp2 - .orig_dll_name]
end if
	or	al, [show_nearest_unsolved]
	or	al, [show_nearest_logicgrid]
	jz	.skip_shownearest_patch
	lea	rcx, [strGameplay]
	lea	rdx, [strHiddenPuzzlesMarkerMaxDistance]
	mov	r8d, 50
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
	cmp	byte [rbx + .tmp2 - .orig_dll_name], 0
	jz	@f
	add	rax, putmarker_offset - FLocationMarkerData_constructor_offset
	mov	rdx, putmarker_expected1
	cmp	qword [rax], rdx
	jnz	.done_shownearest_patch
	mov	rdx, putmarker_expected2
	cmp	qword [rax+8], rdx
	jnz	.done_shownearest_patch
	mov	rdi, rax
	add	rax, 14
	mov	[putmarker_continue], rax
	call	make_writable
	mov	word [rdi], 0xB848
	lea	rax, [hook_putmarker]
	mov	[rdi+2], rax
	mov	word [rdi+10], 0xE0FF
	call	restore_protection
	add	rdi, collectmarkers_exit_offset - putmarker_offset
@@:
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
	add	rdi, chargridcomponent_hint_offset - collectmarkers_exit_offset
	lea	rcx, [strGameplay]
	lea	rdx, [strCheaperMusicForesight]
	mov	r8d, 1
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	test	eax, eax
	jz	.skip_musichint_patch
	mov	cl, 1
	cmp	dword [rdi], chargridcomponent_hint_expected1
	jnz	.done_musichint_patch
	cmp	dword [rdi+8], chargridcomponent_hint_expected2
	jnz	.done_musichint_patch
	lea	rax, [rdi+15]
	mov	[hook_hint_continue], rax
	call	make_writable
	mov	word [rdi], 0xB948
	lea	rax, [hook_hint]
	mov	[rdi+2], rax
	mov	word [rdi+10], 0xE1FF
	call	restore_protection
	mov	cl, 0
.done_musichint_patch:
	or	[rbx + .patch_failed - .orig_dll_name], cl
.skip_musichint_patch:
	add	rdi, sophiagameinstance_loadversion_offset - chargridcomponent_hint_offset
	lea	rcx, [strMod]
	lea	rdx, [strVersion]
	xor	r8d, r8d
	lea	r9, [modVersion]
	mov	dword [rsp+20h], 256-1
	mov	[rsp+28h], rbx
	call	[GetPrivateProfileStringW]
	lea	rcx, [modVersion]
	mov	dword [rcx+rax*2], 0x0A
	lea	rcx, [strMod]
	lea	rdx, [strPakFileHash]
	xor	r8d, r8d
	lea	r9, [pakFileHash]
	mov	dword [rsp+20h], 41
	mov	[rsp+28h], rbx
	call	[GetPrivateProfileStringW]
	test	eax, eax
	jnz	@f
	cmp	word [modVersion+2], 0
	jz	.skip_mod_section
@@:
	mov	cl, 1
	mov	rax, sophiagameinstance_loadversion_expected
	cmp	qword [rdi], rax
	jnz	.done_mod_section
	mov	eax, [rdi-44h]
	add	eax, sophiagameinstance_loadversion_offset - 40h + 28h
	cmp	eax, expected_image_size
	jae	.done_mod_section
	mov	rdx, 0x0073007200650076	; 'vers'
	cmp	qword [rdi-sophiagameinstance_loadversion_offset+rax-8], rdx
	jnz	.done_mod_section
	movsxd	rax, dword [rdi+8]
	lea	rax, [rax+rdi+12]
	mov	[loadfiletostring], rax
	movsxd	rax, dword [rdi-30h]
	lea	rax, [rax+rdi-2Ch]
	mov	[FPaths_ProjectContentDir], rax
	cmp	word [modVersion+6], 0
	jz	.skip_version_patch
	call	make_writable
	mov	word [rdi], 0xB848
	lea	rax, [hook_loadversion]
	mov	[rdi+2], rax
	mov	word [rdi+10], 0xD0FF ; call rax
	call	restore_protection
.skip_version_patch:
	cmp	word [pakFileHash], 0
	jz	.skip_mod_section
	cmp	[rbx + .patch_failed - .orig_dll_name], 0
	jnz	.skip_mod_section
	lea	rcx, [rbx + .very_temporary - .orig_dll_name]
	call	[FPaths_ProjectContentDir]
	lea	rcx, [rbx + .full_pak_name - .orig_dll_name]
	lea	rdx, [rbx + .very_temporary - .orig_dll_name]
	lea	r8, [pak_file_name]
	call	[fstring_add]
	mov	rcx, [rbx + .very_temporary - .orig_dll_name]
	call	[fmemory_free]
	mov	rcx, [rbx + .full_pak_name - .orig_dll_name]
	mov	edx, GENERIC_READ
	xor	r9d, r9d
	lea	r8d, [r9+FILE_SHARE_READ+FILE_SHARE_WRITE+FILE_SHARE_DELETE]
	mov	dword [rbx + .very_temporary - .orig_dll_name], OPEN_EXISTING
	mov	dword [rbx + .very_temporary + 8 - .orig_dll_name], r9d
	mov	qword [rbx + .very_temporary + 10h - .orig_dll_name], r9
	call	[CreateFileW]
	mov	qword [rbx + .very_temporary + 10h - .orig_dll_name], rax
	mov	rcx, [rbx + .full_pak_name - .orig_dll_name]
	call	[fmemory_free]
	lea	rdx, [no_pak_file_text]
	mov	rcx, [rbx + .very_temporary + 10h - .orig_dll_name]
	cmp	rcx, INVALID_HANDLE_VALUE
	jz	.bad_pak_messagebox
	xor	edx, edx
	call	[GetFileSize]
	mov	dword [rbx + .full_pak_name - .orig_dll_name], eax
	mov	rcx, [rbx + .very_temporary + 10h - .orig_dll_name]
	xor	edx, edx
	lea	r8d, [rdx + PAGE_READONLY]
	xor	r9d, r9d
	mov	dword [rbx + .very_temporary - .orig_dll_name], eax
	mov	qword [rbx + .very_temporary + 8 - .orig_dll_name], rdx
	call	[CreateFileMappingW]
	mov	rcx, qword [rbx + .very_temporary + 10h - .orig_dll_name]
	mov	qword [rbx + .very_temporary + 10h - .orig_dll_name], rax
	call	[CloseHandle]
	lea	rdx, [error_pak_file_text]
	mov	rcx, qword [rbx + .very_temporary + 10h - .orig_dll_name]
	test	rcx, rcx
	jz	.bad_pak_messagebox
	xor	r8d, r8d
	xor	r9d, r9d
	lea	rdx, [r8 + FILE_MAP_READ]
	mov	eax, dword [rbx + .full_pak_name - .orig_dll_name]
	mov	qword [rbx + .very_temporary - .orig_dll_name], rax
	call	[MapViewOfFile]
	mov	rcx, qword [rbx + .very_temporary + 10h - .orig_dll_name]
	mov	qword [rbx + .full_pak_name + 8 - .orig_dll_name], rax
	call	[CloseHandle]
	lea	edx, [error_pak_file_text]
	mov	rcx, qword [rbx + .full_pak_name + 8 - .orig_dll_name]
	test	rcx, rcx
	jz	.bad_pak_messagebox
	lea	rax, [rdi + sha1_hashbuffer_offset - sophiagameinstance_loadversion_offset]
	mov	rdx, sha1_hashbuffer_expected
	cmp	[rax+28h], rdx
	jz	@f
	mov	[rbx + .patch_failed - .orig_dll_name], 1
	mov	byte [rbx + .tmp2 - .orig_dll_name], 0
	jmp	.pak_checked
@@:
	mov	edx, dword [rbx + .full_pak_name - .orig_dll_name]
	lea	r8, [rbx + .very_temporary - .orig_dll_name]
	call	rax
	lea	rdx, [pakFileHash]
	xor	ecx, ecx
.hashloop:
	mov	al, [rdx + 4*rcx]
	or	al, 20h
	sub	al, '0'
	cmp	al, 9
	jbe	@f
	sub	al, 'a' - '0' - 10
@@:
	mov	ah, [rdx + 4*rcx + 2]
	or	ah, 20h
	sub	ah, '0'
	cmp	ah, 9
	jbe	@f
	sub	ah, 'a' - '0' - 10
@@:
	shl	al, 4
	or	al, ah
	cmp	byte [rbx + .very_temporary - .orig_dll_name + rcx], al
	jnz	.badhash
	inc	ecx
	cmp	ecx, 20
	jnz	.hashloop
.badhash:
	setnz	byte [rbx + .tmp2 - .orig_dll_name]
.pak_checked:
	mov	rcx, qword [rbx + .full_pak_name + 8 - .orig_dll_name]
	call	[UnmapViewOfFile]
	cmp	byte [rbx + .tmp2 - .orig_dll_name], 0
	jz	.pak_ok
	lea	rdx, [mismatch_pak_file_text]
.bad_pak_messagebox:
	xor	ecx, ecx
	lea	r8, [bad_pak_caption]
	lea	r9, [rcx+MB_OK+MB_ICONSTOP]
	call	[MessageBoxA]
.pak_ok:
	mov	cl, 0
.done_mod_section:
	or	[rbx + .patch_failed - .orig_dll_name], cl
.skip_mod_section:
	add	rdi, puzzledatabase_init_offset - sophiagameinstance_loadversion_offset
	mov	rax, puzzledatabase_init_expected
	mov	cl, 1
	cmp	[rdi], rax
	jnz	.done_puzzledatabase_patch
	lea	rax, [rdi+10h]
	mov	[puzzledatabase_init_continue], rax
	call	make_writable
	mov	word [rdi], 0xB848
	lea	rax, [hook_puzzledatabase_init]
	mov	qword [rdi+2], rax
	mov	word [rdi+10], 0xE0FF
	call	restore_protection
	mov	cl, 0
.done_puzzledatabase_patch:
	or	[rbx + .patch_failed - .orig_dll_name], cl
	add	rdi, radar_hiddenobj_check_offset - puzzledatabase_init_offset
	lea	rcx, [strGameplay]
	lea	rdx, [strHackMatchboxRadar]
	mov	r8d, 1
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	test	eax, eax
	jz	.skip_chests_patch
	mov	cl, 1
	mov	rax, radar_hiddenobj_check_expected
	cmp	[rdi-8], rax
	jnz	.done_chests_patch
	mov	rax, radar_matchbox_check_expected
	cmp	[rdi+radar_matchbox_check_offset-7-radar_hiddenobj_check_offset], rax
	jnz	.done_chests_patch
	mov	rdx, radar_matchbox_check_offset+14-radar_hiddenobj_check_offset
	call	make_writable.large
	mov	byte [rdi], 0
	lea	rdx, [rdi+radar_matchbox_check_offset-radar_hiddenobj_check_offset]
	mov	word [rdx], 0xB848
	lea	rax, [radar_check]
	mov	[rdx+2], rax
	mov	dword [rdx+10], 0x13EBD0FF ; call rax, jmp $+15h
	mov	rdx, radar_matchbox_check_offset+14-radar_hiddenobj_check_offset
	call	restore_protection.large
	mov	cl, 0
.done_chests_patch:
	or	[rbx + .patch_failed - .orig_dll_name], cl
.skip_chests_patch:
	add	rdi, spawnnotify_patch1_offset - radar_hiddenobj_check_offset
	lea	rcx, [strGameplay]
	lea	rdx, [strNotifyPuzzleSpawns]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	test	eax, eax
	jz	.skip_spawnnotify_patch
	mov	cl, 1
	mov	rax, spawnnotify_patch1_expected
	cmp	[rdi], rax
	jnz	.done_spawnnotify_patch
	mov	rax, spawnnotify_patch2_expected
	cmp	[rdi+spawnnotify_patch2_offset-spawnnotify_patch1_offset], rax
	jnz	.done_spawnnotify_patch
	lea	rax, [rdi+15h]
	mov	[spawnnotify_continue1], rax
	add	rax, spawnnotify_addmsg_offset-spawnnotify_patch1_offset-15h
	cmp	dword [rax], spawnnotify_addmsg_expected
	jnz	.done_spawnnotify_patch
	mov	[spawnnotify_continue3], rax
	add	rax, spawnnotify_stringmapinsertcall_offset+5-spawnnotify_addmsg_offset
	mov	rdx, spawnnotify_stringmapinsertcall_expected
	cmp	[rax-12], rdx
	jnz	.done_spawnnotify_patch
	movsxd	rdx, dword [rax-4]
	add	rax, rdx
	mov	[stringmap_insert], rax
	mov	rdx, spawnnotify_patch2_offset + 12 - spawnnotify_patch1_offset
	lea	rax, [rdi+rdx]
	mov	[spawnnotify_continue2], rax
	call	make_writable.large
	mov	word [rdi], 0xB848
	lea	rax, [spawnnotify_hook1]
	mov	[rdi+2], rax
	mov	word [rdi+10], 0xE0FF
	mov	rdx, spawnnotify_patch2_offset + 12 - spawnnotify_patch1_offset
	mov	word [rdi+rdx-12], 0xB948
	add	rax, spawnnotify_hook2 - spawnnotify_hook1
	mov	[rdi+rdx-10], rax
	mov	word [rdi+rdx-2], 0xE1FF
	call	restore_protection.large
	mov	cl, 0
.done_spawnnotify_patch:
	or	[rbx + .patch_failed - .orig_dll_name], cl
.skip_spawnnotify_patch:
; should be the last code that works with .ini
if add_chests
	lea	rcx, [strGameplay]
	lea	rdx, [strAddChests]
	xor	r8d, r8d
	mov	r9, rbx
	call	[GetPrivateProfileIntW]
	test	eax, eax
	jz	.skip_chests_patch2
	mov	cl, 1
	mov	rdx, [rdi+ASandboxGameMode_vmt_InitGameMode_offset-spawnnotify_patch1_offset]
	mov	[original_initgamemode], rdx
	lea	rax, [rdx+spawnnotify_patch1_offset]
	sub	rax, rdi
	cmp	rax, expected_image_size
	jae	.done_chests_patch2
	mov	rax, ASandboxGameMode_InitGameMode_expected
	cmp	[rdx+0Ch], rax
	jnz	.done_chests_patch2
	mov	rdx, [rdi+ASandboxGameMode_vmt_Tick_offset-spawnnotify_patch1_offset]
	lea	rax, [rdx+spawnnotify_patch1_offset]
	sub	rax, rdi
	cmp	rax, expected_image_size
	jae	.done_chests_patch2
	cmp	dword [rdx+25h], ASandboxGameMode_Tick_expected
	jnz	.done_chests_patch2
	mov	[original_gamemode_tick], rdx
	mov	rdx, [rbx + .directory_end - .orig_dll_name]
virtual at 0
	du	'chests.bin', 0, 0
assert $ = 18h
load chests_bin_qword0 qword from 0
load chests_bin_qword8 qword from 8
load chests_bin_qword10 qword from 10h
end virtual
	mov	rax, chests_bin_qword0
	mov	[rdx], rax
	mov	rax, chests_bin_qword8
	mov	[rdx+8], rax
	mov	rax, chests_bin_qword10
	mov	[rdx+10h], rax
	lea	rax, [rdi+FFileHelper_LoadFileToArray_offset-spawnnotify_patch1_offset]
	lea	rcx, [chests_bin_data]
	mov	rdx, rbx
	xor	r8d, r8d
	call	rax
	test	al, al
	jz	.chests_bin_failed
	lea	rax, [chests_by_zone]
	mov	r8, qword [rax+chests_bin_data-chests_by_zone]
	xor	ecx, ecx
	cmp	dword [rax+chests_bin_data+8-chests_by_zone], ecx
	jz	.chests_bin_failed
	mov	r9d, first_zone
.chests_bin_loop:
	mov	edx, [r8+rcx]
	cmp	edx, r9d
	jb	.chests_bin_failed
	jz	@f
	cmp	edx, first_zone + num_zones
	jae	.chests_bin_failed
	mov	[rax+(rdx-first_zone)*8], ecx
	mov	r9d, edx
@@:
	inc	dword [rax+(rdx-first_zone)*8+4]
	add	ecx, 20h
	cmp	ecx, dword [rax+chests_bin_data+8-chests_by_zone]
	jb	.chests_bin_loop
	jz	.chests_bin_ok
.chests_bin_failed:
	xor	ecx, ecx
	lea	rdx, [bad_chests_text]
	lea	r8, [bad_chests_caption]
	lea	r9, [rcx+MB_OK+MB_ICONSTOP]
	call	[MessageBoxA]
	jmp	.skip_chests_patch2
.chests_bin_ok:
	lea	rax, [rdi+GetSophiaCharacterFromWorld_offset-spawnnotify_patch1_offset]
	mov	[GetSophiaCharacterFromWorld], rax
	add	rax, GetAllPuzzleDataInZone_offset-GetSophiaCharacterFromWorld_offset
	mov	[GetAllPuzzleDataInZone], rax
	add	rax, GetAllSolvedPuzzleDataInZone_offset-GetAllPuzzleDataInZone_offset
	mov	[GetAllSolvedPuzzleDataInZone], rax
	add	rax, FActorSpawnParameters_ctr_offset-GetAllSolvedPuzzleDataInZone_offset
	mov	[FActorSpawnParameters_ctr], rax
	add	rax, FSoftObjectPtr_LoadSynchronous_offset-FActorSpawnParameters_ctr_offset
	mov	[FSoftObjectPtr_LoadSynchronous], rax
	add	rax, UWorld_SpawnActor_offset-FSoftObjectPtr_LoadSynchronous_offset
	mov	[UWorld_SpawnActor], rax
	add	rax, UItemData_StaticClass_offset-UWorld_SpawnActor_offset
	mov	[UItemData_StaticClass], rax
	add	rax, FStaticConstructObjectParameters_ctr_offset-UItemData_StaticClass_offset
	mov	[FStaticConstructObjectParameters_ctr], rax
	add	rax, StaticConstructObject_Internal_offset-FStaticConstructObjectParameters_ctr_offset
	mov	[StaticConstructObject_Internal], rax
	add	rax, UDefaultItems_GetDefaultItem_offset-StaticConstructObject_Internal_offset
	mov	[UDefaultItems_GetDefaultItem], rax
	add	rax, USceneComponent_SetRelativeScale3D_offset-UDefaultItems_GetDefaultItem_offset
	mov	[USceneComponent_SetRelativeScale3D], rax
	add	rax, AActor_Destroy_offset-USceneComponent_SetRelativeScale3D_offset
	mov	[AActor_Destroy], rax
	add	rdi, ASandboxGameMode_vmt_Tick_offset-spawnnotify_patch1_offset
	mov	edx, ASandboxGameMode_vmt_InitGameMode_offset-ASandboxGameMode_vmt_Tick_offset+8
	call	make_writable.large
	lea	rax, [hook_gamemode_tick]
	mov	[rdi], rax
	lea	rax, [hook_initgamemode]
	mov	[rdi+ASandboxGameMode_vmt_InitGameMode_offset-ASandboxGameMode_vmt_Tick_offset], rax
	mov	edx, ASandboxGameMode_vmt_InitGameMode_offset-ASandboxGameMode_vmt_Tick_offset+8
	call	restore_protection.large
; noncritical patches for better radar visuals, ignore fails
	add	rdi, execGetLevel_offset-ASandboxGameMode_vmt_Tick_offset
	cmp	byte [rdi], 0xE8
	jnz	@f
	mov	rax, execGetLevel_expected
	cmp	[rdi+5], rax
	jnz	@f
	call	make_writable
	mov	word [rdi], 0xB848
	lea	rax, [hook_execGetLevel]
	mov	[rdi+2], rax
	mov	word [rdi+10], 0xE0FF
	call	restore_protection
@@:
	add	rdi, findmarkerclass_offset-execGetLevel_offset
	mov	rax, findmarkerclass_expected
	cmp	[rdi+3], rax
	jnz	@f
	movsxd	rax, dword [rdi+11]
	lea	rax, [rax+rdi+15]
	mov	[original_findmarkerclass], rax
	mov	rdx, 14
	call	make_writable.large
	mov	word [rdi], 0xB848
	lea	rax, [hook_findmarkerclass]
	mov	[rdi+2], rax
	mov	dword [rdi+10], 0xB190D0FF
	mov	rdx, 14
	call	restore_protection.large
@@:
	add	rdi, ARacingBalls_AppendLocationMarkers_offset-findmarkerclass_offset
	mov	rax, ARacingBalls_AppendLocationMarkers_expected
	cmp	[rdi-8], rax
	jnz	@f
	call	make_writable
	and	dword [rdi], 0
	call	restore_protection
@@:
	add	rdi, spawnnotify_patch1_offset-ARacingBalls_AppendLocationMarkers_offset
	mov	cl, 0
.done_chests_patch2:
	or	[rbx + .patch_failed - .orig_dll_name], cl
.skip_chests_patch2:
end if
	add	rdi, giskraken_init_offset - spawnnotify_patch1_offset
	mov	rax, giskraken_init_expected
	mov	cl, 1
	cmp	[rdi], rax
	jnz	.done_giskraken_patch
	mov	eax, [rdi+15h]
	add	eax, giskraken_init_offset + 19h + 8
	cmp	eax, expected_image_size
	jae	.done_giskraken_patch
	mov	rdx, 0x004400410045004C ; "LEAD" ...ERBOARD_PAGE_SIZE
	cmp	[rdi+rax-giskraken_init_offset-8], rdx
	jnz	.done_giskraken_patch
	lea	rax, [rdi+0Fh]
	mov	[giskraken_init_continue], rax
	call	make_writable
	mov	word [rdi], 0xB848
	lea	rax, [hook_giskraken_init]
	mov	[rdi+2], rax
	mov	word [rdi+10], 0xE0FF
	call	restore_protection
	mov	cl, 0
.done_giskraken_patch:
	or	[rbx + .patch_failed - .orig_dll_name], cl
	add	rdi, bestsolvetime1_offset - giskraken_init_offset
	mov	cl, 1
	cmp	[fmemory_free], 0
	jz	.done_bestsolvetime_patch
	mov	rax, bestsolvetime1_expected
	cmp	[rdi], rax
	jnz	.done_bestsolvetime_patch
	mov	rax, bestsolvetime2_expected
	cmp	[rdi - bestsolvetime1_offset + bestsolvetime2_offset], rax
	jnz	.done_bestsolvetime_patch
	lea	rdx, [rdi - bestsolvetime1_offset + getpuzzlesolvestatus_offset]
	mov	rax, getpuzzlesolvestatus_expected
	cmp	[rdx+10h], rax
	jnz	.done_bestsolvetime_patch
	mov	[getpuzzlesolvestatus], rdx
	lea	rax, [rdi+13]
	mov	[savesolvedtime1_continue], rax
	call	make_writable
	mov	word [rdi], 0xB948
	lea	rax, [hook_savesolvedtime1]
	mov	[rdi+2], rax
	mov	word [rdi+10], 0xE1FF
	call	restore_protection
	sub	rdi, bestsolvetime1_offset - bestsolvetime2_offset
	lea	rax, [rdi+14]
	mov	[savesolvedtime2_continue], rax
	call	make_writable
	mov	word [rdi], 0xB948
	lea	rax, [hook_savesolvedtime2]
	mov	[rdi+2], rax
	mov	word [rdi+10], 0xE1FF
	call	restore_protection
	add	rdi, bestsolvetime1_offset - bestsolvetime2_offset
	mov	cl, 0
.done_bestsolvetime_patch:
	or	[rbx + .patch_failed - .orig_dll_name], cl
	add	rdi, gridsolve_offset - bestsolvetime1_offset
	mov	cl, 1
	mov	rax, gridsolve_expected
	cmp	[rdi+5], rax
	jnz	.done_gridsolve_patch
	lea	rax, [rdi+11h]
	mov	[gridsolve_continue1], rax
	movsxd	rdx, [rax-4]
	add	rax, rdx
	mov	[gridsolve_continue2], rax
	call	make_writable
	mov	word [rdi], 0xB848
	lea	rax, [hook_gridsolve_check]
	mov	[rdi+2], rax
	mov	word [rdi+10], 0xE0FF
	call	restore_protection
	mov	cl, 0
.done_gridsolve_patch:
	or	[rbx + .patch_failed - .orig_dll_name], cl
if patch_liars_modifier
	add	rdi, puzzlegrid_check_modifier_offset - gridsolve_offset
	mov	rax, puzzlegrid_check_modifier_expected
	mov	cl, 1
	cmp	[rdi-2], rax
	jnz	.done_puzzlegrid_modifier11_patch
	lea	rax, [rdi+14]
	mov	[continue_after_puzzlegrid_check_modifier1], rax
	mov	eax, [rdi+6]
	lea	rax, [rax+rdi+10]
	mov	[continue_after_puzzlegrid_check_modifier2], rax
	call	make_writable
	mov	word [rdi], 0xB848
	lea	rax, [hook_puzzlegrid_check_modifier]
	mov	[rdi+2], rax
	mov	word [rdi+10], 0xE0FF
	call	restore_protection
	mov	cl, 0
.done_puzzlegrid_modifier11_patch:
	or	[rbx + .patch_failed - .orig_dll_name], cl
end if
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
.prolog_size = $ - make_writable.large
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
.prolog_size = $ - restore_protection.large
	mov	rcx, rdi
	lea	r9, [rbx - 4]
	mov	r8d, [r9]
	call	[VirtualProtect]
	add	rsp, 28h
	ret
.end:

save_game_patched:
	mov	[rsp+20h], rax ; save useful data
	lea	rcx, [save_critsect]
	call	[EnterCriticalSection]
	cmp	[max_backups], 0
	jle	.no_backup
	call	[GetTickCount]
	mov	edx, eax
	cmp	[backup_made], 0
	jnz	@f
	inc	[backup_made]
	jmp	.do_backup
@@:
	mov	ecx, [backup_period]
	sub	eax, [last_backup_time]
	cmp	eax, ecx
	jb	.no_backup
	jecxz	.no_backup
.do_backup:
	mov	[last_backup_time], edx
	mov	rdx, [projectsaveddir]
	test	rdx, rdx
	jz	@f
	call	make_backup
.no_backup:
	lea	rcx, [rsp+30h]
	mov	rax, [rcx-10h]
	cmp	[use_temporary_file], 0
	jnz	@f
	mov	rcx, [rax+40h]
	lea	rdx, [rax+30h]
	xor	r8d, r8d
	call	[savegametoslot]
	jmp	.done2
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
.done2:
	lea	rcx, [save_critsect]
	call	[LeaveCriticalSection]
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

; rcx = ASophiaCharacter*, rax = mask of puzzles to find
; returns rax = pointer to puzzle, xmm0 = marker coordinates
find_nearest_unsolved:
; we'll use xmm6 as the best distance, xmm7 as the current distance,
; xmm8 as player position, xmm9 as best coordinates, xmm10 as current coordinates
	push	rbx
.prolog_offs1 = $ - find_nearest_unsolved
	push	rsi
.prolog_offs2 = $ - find_nearest_unsolved
	push	rdi
.prolog_offs3 = $ - find_nearest_unsolved
	push	rbp
.prolog_offs4 = $ - find_nearest_unsolved
	push	r14
.prolog_offs5 = $ - find_nearest_unsolved
	push	r15
.prolog_offs6 = $ - find_nearest_unsolved
	sub	rsp, 78h
.prolog_offs7 = $ - find_nearest_unsolved
	mov	ebp, eax
	mov	rax, rsp
	movaps	[rax+20h], xmm6
.prolog_offs8 = $ - find_nearest_unsolved
	movaps	[rax+30h], xmm7
.prolog_offs9 = $ - find_nearest_unsolved
	movaps	[rax+40h], xmm8
.prolog_offs10 = $ - find_nearest_unsolved
	movaps	[rax+50h], xmm9
.prolog_offs11 = $ - find_nearest_unsolved
	movaps	[rax+60h], xmm10
.prolog_offs12 = $ - find_nearest_unsolved
.prolog_size = $ - find_nearest_unsolved
	mov	r14, [rcx+878h]	; ASophiaCharacter::CurDungeon
	mov	rax, [rcx+130h]	; AActor::RootComponent
	movups	xmm8, [rax+1D0h]	; get player position
	mov	eax, 7F800000h	; fp32 infinity
	movd	xmm6, eax
	mov	rax, [rcx]
	call	qword [rax+160h]	; get UWorld*
	mov	rcx, [rax+120h]	; get ASophiaPlayerState*
	xor	r15, r15
	mov	edi, [rcx+390h]
	mov	rsi, [rcx+388h]
.findnearest:
	dec	edi
	js	.oknearest
	mov	rcx, [rsi+rdi*8]
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
; puzzle boxes all have the same type in SerializedPuzzleName;
; for the emote markers we need to distinguish actual logic grids and other types of grids
	test	al, al
	jnz	@f
	cmp	byte [rcx+7D8h], 0	; bIsDoppel
	jnz	.findnearest
	mov	rdx, [rcx+6A0h]
	mov	bl, [rdx+6B8h]	; difficulty
	cmp	bl, [min_logicgrid_difficulty]
	jb	.findnearest
	mov	rbx, [rdx+688h]
	mov	edx, [rdx+690h]
	cmp	edx, 2 ; EModifierType__CompleteThePattern
	jbe	@f
	cmp	byte [rbx+2], 0
	jnz	.not_logic_grid
	cmp	edx, 4 ; EModifierType__MatchTheAudio
	jbe	@f
	cmp	byte [rbx+4], 0
	jnz	.not_logic_grid
	cmp	edx, 12 ; EModifierType__Memory
	jbe	@f
	cmp	byte [rbx+12], 0
	jz	@f
.not_logic_grid:
	mov	al, 3 ; this is actually completeThePattern, but our current masks don't care about the exact type
@@:
	mov	ebx, eax
	cmp	al, 31
	jbe	@f
	mov	bl, 31
@@:
	bt	ebp, ebx
	jnc	.findnearest
; viewfinder's reference point is the solving place, we need ViewfinderImage->planeMesh instead
	xor	ebx, ebx
.retry_if_matchbox:
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
; get the first point in the array for consistency with the radar patch
; (and the radar patch gets the first point because it is the easiest way there)
	cmp	al, 23
	jnz	.not_racingballs
	cmp	dword [rcx+5E8h], 0
	jz	.not_racingballs
	mov	rdx, [rcx+5E0h]
	mov	rdx, [rdx]
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
	jae	.no_random_offset_big
	mov	edx, (1 shl 10) or (1 shl 11) or (1 shl 12) or (1 shl 14) or (1 shl 18)
	bt	edx, eax
	jnc	.no_random_offset
	mov	eax, [rcx+420h]	; KrakenId
	add	eax, ebx
@@:
	imul	eax, 196314165
	add	eax, 907633515
	mov	edx, eax
	sar	edx, 1	; make Z shift be from [-0.5, 0.5]
	cvtsi2ss xmm0, edx
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
	jmp	.no_random_offset_big
.no_random_offset:
	mov	edx, (1 shl 0) or (1 shl 3) or (1 shl 19) or (1 shl 21)
	bt	edx, eax
	jnc	@f
; some puzzles from Reflections enclave are flipped via Scale3D, and some are rotated
	mov	rdx, [rcx+130h]
; apply the quaternion to get GetComponentToWorld().GetRotation().GetAxisZ()
; result = 2*[X*Z + Y*W, Y*Z - X*W, -X*X - Y*Y] + [0,0,1]
	movups	xmm3, [rdx+1C0h]	; xmm3 = [X Y Z W]
	movaps	xmm0, xmm3
	movaps	xmm1, xmm3
	shufps	xmm0, xmm3, 0x44	; xmm0 = [X Y X ?]
	shufps	xmm1, xmm3, 0x0A	; xmm1 = [Z Z X ?]
	mulps	xmm0, xmm1	; xmm0 = [X*Z Y*Z X*X ?]
	xorps	xmm0, xword [zw_sign]
	movaps	xmm1, xmm3
	shufps	xmm1, xmm3, 0x11	; xmm1 = [Y X Y ?]
	shufps	xmm3, xmm3, 0x5F	; xmm3 = [W W Y ?]
	mulps	xmm1, xmm3	; xmm1 = [Y*W X*W Y*Y ?]
	xorps	xmm1, xword [yz_sign]
	addps	xmm0, xmm1
	addps	xmm0, xmm0
	addps	xmm0, xword [z_one]
	movss	xmm1, [logic_grid_and_like_offset]
	mulss	xmm1, [rdx+1E8h]	; Scale3D.Z
	shufps	xmm1, xmm1, 0x00
	mulps	xmm0, xmm1
	addps	xmm7, xmm0
@@:
.no_random_offset_big:
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
	movzx	eax, byte [rcx+254h]
	inc	ebx
	cmp	al, 18
	jnz	.findnearest
	cmp	ebx, 2
	jb	.retry_if_matchbox
	jmp	.findnearest
.oknearest:
.done:
	mov	rcx, rsp
	mov	rax, r15
	movaps	xmm0, xmm9
	movaps	xmm6, [rcx+20h]
	movaps	xmm7, [rcx+30h]
	movaps	xmm8, [rcx+40h]
	movaps	xmm9, [rcx+50h]
	movaps	xmm10, [rcx+60h]
	add	rsp, 78h
	pop	r15
	pop	r14
	pop	rbp
	pop	rdi
	pop	rsi
	pop	rbx
	ret
.end:

additional_markers:
; called twice per frame, for the screen and for the map. Don't do the same work twice
	cmp	byte [rbp+1E0h], 0
	jz	.done
; r12 = UMarkerComponent*, rsi = AGameState*
	mov	rbx, [r12+0A0h]	; UActorComponent::OwnerPrivate
	mov	rbx, [rbx+220h]	; AHUD::PlayerOwner
	mov	rbx, [rbx+250h]	; AController::Pawn
	mov	rax, [current_marker_puzzle]
	test	rax, rax
	jz	.no_current
	mov	ecx, [rsi+390h]
	mov	rdi, [rsi+388h]
	repnz scasq
	jnz	.reset_current
	mov	rcx, rax
	mov	rax, [rax]
	call	qword [rax+730h]
	movaps	xmm0, xword [current_marker_pos]
	test	al, al
	mov	rax, [current_marker_puzzle]
	jz	.add_marker
.reset_current:
; current_marker_puzzle either despawned or has been solved
	and	[current_marker_puzzle], 0
.no_current:
	or	eax, -1
	cmp	[show_nearest_unsolved], 0
	jnz	@f
	add	eax, 2
	cmp	[show_nearest_logicgrid], 0
	jz	.done
@@:
	mov	rcx, rbx
	call	find_nearest_unsolved
	test	rax, rax
	jz	.done
.add_marker:
	mov	r15, rax
	movaps	xmm6, xmm0
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
	movups	[rdi], xmm6
	mov	dword [rdi+0Ch], 1 ; VisibleOnScreen = true, VisibleOnMap = showEverywhere = ShowOverFog = false
	mov	rax, [r15+2C0h]
	mov	[rdi+20h], rax ; worldTex
	mov	rax, [r15+2C8h]
	mov	[rdi+28h], rax ; mapTex
.done:
if debug_chests
	cmp	[add_chests_marker], 0
	jz	.no_chests_marker
	lea	rdx, [spawned_chests]
	mov	ecx, [rdx+total_spawned_chests-spawned_chests]
	test	ecx, ecx
	jz	.no_chests_marker
	mov	rax, [r12+0A0h]	; UActorComponent::OwnerPrivate
	mov	rax, [rax+220h]	; AHUD::PlayerOwner
	mov	rax, [rax+250h]	; AController::Pawn
	mov	rax, [rax+130h]	; AActor::RootComponent
	movups	xmm0, [rax+1D0h]	; get player position
	mov	eax, 7F800000h	; fp32 infinity
	movd	xmm1, eax
.find_nearest_chest:
	mov	rax, [rdx+spawned_chest_struct.chest]
	test	rax, rax
	jz	@f
	mov	rax, [rax+130h]
	movups	xmm2, [rax+1D0h]
	subps	xmm2, xmm0
	mulps	xmm2, xmm2
	movaps	xmm3, xmm2
	movaps	xmm4, xmm2
	shufps	xmm2, xmm2, 55h
	shufps	xmm3, xmm3, 0AAh
	addss	xmm2, xmm4
	addss	xmm2, xmm3
	comiss	xmm1, xmm2
	jbe	@f
	movss	xmm1, xmm2
	movups	xmm6, [rax+1D0h]
@@:
	add	rdx, spawned_chest_struct.sizeof
	dec	ecx
	jnz	.find_nearest_chest
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
	movups	[rdi], xmm6
	mov	dword [rdi+0Ch], 1 ; VisibleOnScreen = true, VisibleOnMap = showEverywhere = ShowOverFog = false
	mov	rax, [r12+0C0h]
	mov	rax, [rax+168h] ; defaultTex
	mov	[rdi+20h], rax ; worldTex
.no_chests_marker:
end if
	mov	rax, [rsp+30h]
	mov	rcx, [rbp+1D8h]
	mov	[rcx], rax
	jmp	[additionalmarkers_continue]
.end:

hook_putmarker:
; rcx = ASophiaCharacter*, dl = emote id
; Numpad1 -> dl=1, Numpad2 -> dl=3, Numpad3 -> dl=2, Numpad4 -> dl=4, Numpad5 -> dl=5
	mov	eax, 1 shl 0 ; action 2: logic grids
	cmp	dl, 3
	jz	.action
	mov	eax, (1 shl 10) or (1 shl 11) or (1 shl 12) ; action 3: hidden archways, cubes and rings
	cmp	dl, 2
	jz	.action
	mov	eax, not ((1 shl 0) or (1 shl 10) or (1 shl 11) or (1 shl 12)) ; action 5: everything else
	cmp	dl, 5
	jz	.action
	mov	[rsp+20h], rbx
	mov	[rsp+10h], dl
	mov	[rsp+8], rcx
	jmp	[putmarker_continue]
.action:
	cmp	[current_active_marker_type], dl
	jnz	.findnew
	cmp	[current_marker_puzzle], 0
	jz	.findnew
	and	[current_marker_puzzle], 0
	ret
.findnew:
	mov	[current_active_marker_type], dl
; the code above can be considered as a leaf function,
; where the default "just pop the return address" works for unwinding,
; but we need the actual unwind info here
.start_stack_use:
	sub	rsp, 28h
.prolog_offs1 = $ - .start_stack_use
.prolog_size = $ - .start_stack_use
	call	find_nearest_unsolved
	mov	[current_marker_puzzle], rax
	movaps	xword [current_marker_pos], xmm0
	add	rsp, 28h
	ret
.end:

hook_loadversion:
	sub	rsp, 28h
	lea	rcx, [rsp+30h]
	call	[loadfiletostring]
	lea	rcx, [rsp+40h]
	mov	rdx, rcx
	and	qword [rcx], 0
	and	qword [rcx+8], 0
	lea	r8, [modVersion]
	call	[fstring_add]
	lea	rcx, [rdi+6C0h]
	lea	rdx, [rsp+40h]
	mov	r8, [rdx-10h]
	call	[fstring_add]
	mov	rcx, [rsp+30h]
	call	[fmemory_free]
	mov	rcx, [rsp+40h]
	call	[fmemory_free]
	add	rsp, 28h
	ret
.end:

hook_puzzledatabase_init:
; reset all entries of TMap<EMainMapZoneName, TMap<FString, int>> this+468h with zeroes
	add	rcx, 468h
	xor	eax, eax
.map1_loop:
	cmp	eax, [rcx+28h]
	jae	.map1_done
	mov	rdx, [rcx+20h]
	test	rdx, rdx
	jnz	@f
	lea	rdx, [rcx+10h]
@@:
	bt	[rdx], eax
	jnc	.map1_continue
	imul	ebx, eax, 60h
	add	rbx, [rcx]
	xor	esi, esi
.map2_loop:
	cmp	esi, [rbx+8+28h]
	jae	.map1_continue
	mov	rdx, [rbx+8+20h]
	test	rdx, rdx
	jnz	@f
	lea	rdx, [rbx+8+10h]
@@:
	bt	[rdx], esi
	jnc	.map2_continue
	mov	edx, esi
	shl	edx, 5
	add	rdx, [rbx+8]
	mov	[rdx+10h], edi
.map2_continue:
	inc	esi
	jmp	.map2_loop
.map1_continue:
	inc	eax
	jmp	.map1_loop
.map1_done:
	mov	[rbp-50h], edi
	mov	[rsp+70h], edi
	add	rcx, 320h - 468h
	jmp	[puzzledatabase_init_continue]
.end:

if add_chests
virtual at 0
spawned_chest_struct:
.chest	dq	?
.original_scale	rd	3	; +134h
.opentime	dd	?
.zone		dd	?
.data_offset	dd	?
.sizeof:
end virtual
hook_initgamemode:
	sub	rsp, 28h
	mov	[rsp+20h], rcx
	call	spawn_chests_if_needed
	mov	rcx, [rsp+20h]
	add	rsp, 28h
	db	48h
	jmp	[original_initgamemode]
.end:

hook_gamemode_tick:
	push	rbx
.prolog_offs1 = $ - hook_gamemode_tick
	push	rsi
.prolog_offs2 = $ - hook_gamemode_tick
	sub	rsp, 28h
.prolog_offs3 = $ - hook_gamemode_tick
.prolog_size = $ - hook_gamemode_tick
	mov	[rsp+20h], rcx
	movss	[rsp+40h], xmm1
	lea	rsi, [spawned_chests]
	mov	ebx, dword [rsi-spawned_chests+total_spawned_chests]
	test	ebx, ebx
	jz	.done
.loop:
	mov	rcx, [rsi+spawned_chest_struct.chest]
	test	rcx, rcx
	jz	.nextchest
	cmp	byte [rcx+248h], 0	; bIsOpen
	jz	.nextchest
	movss	xmm0, [rsi+spawned_chest_struct.opentime]
	addss	xmm0, xmm1
	movss	[rsi+spawned_chest_struct.opentime], xmm0
	subss	xmm0, [opened_chest_lifetime]
	comiss	xmm0, dword [z_one+0] ; constant zero
	jae	.destroy
	mulss	xmm0, [opened_chest_shrink_speed]
	comiss	xmm0, dword [z_one+8] ; constant one
	jae	.nextchest
	shufps	xmm0, xmm0, 0
	movups	xmm1, xword [rsi+spawned_chest_struct.original_scale]
	mulps	xmm0, xmm1
	lea	rdx, [rsp+50h]
	movaps	[rdx], xmm0
	mov	rcx, [rcx+130h]
	call	[USceneComponent_SetRelativeScale3D]
	jmp	.restoreregs
.destroy:
	xor	edx, edx
	mov	r8b, 1
	call	[AActor_Destroy]
	and	qword [rsi+spawned_chest_struct.chest], 0
	mov	eax, [rsi+spawned_chest_struct.zone]
	lea	rdx, [num_spawned_chests_by_zone-2*4]
	dec	dword [rdx+rax*4]
	mov	rcx, [rsp+20h]
	call	spawn_chests_if_needed
.restoreregs:
	movss	xmm1, [rsp+40h]
.nextchest:
	add	rsi, spawned_chest_struct.sizeof
	dec	ebx
	jnz	.loop
.done:
	mov	rcx, [rsp+20h]
	add	rsp, 28h
	pop	rsi
	pop	rbx
	db	48h
	jmp	[original_gamemode_tick]
.end:

spawn_chests_if_needed:
	push	rbp
.prolog_offs1 = $ - spawn_chests_if_needed
	push	rbx
.prolog_offs2 = $ - spawn_chests_if_needed
	push	rsi
.prolog_offs3 = $ - spawn_chests_if_needed
	push	rdi
.prolog_offs4 = $ - spawn_chests_if_needed
	sub	rsp, 78h
.prolog_offs5 = $ - spawn_chests_if_needed
.prolog_size = $ - spawn_chests_if_needed
	lea	rbp, [rsp+30h]
	mov	rax, [rcx]
	call	qword [rax+160h]
	mov	rdi, rax	; rdi -> UWorld
	mov	rcx, rax
	lea	rdx, [rbp-8]	; [rbp-8] = [rsp+28h] -> ASophiaCharacter
	call	[GetSophiaCharacterFromWorld]
	test	al, al
	jz	.fail
	mov	ebx, 2
.zoneloop:
	lea	rsi, [chests_by_zone]
	mov	eax, dword [rsi-chests_by_zone+num_spawned_chests_by_zone+(rbx-2)*4]
	test	eax, eax
	jnz	.nextzone
	cmp	[rsi+(rbx-2)*8+4], eax
	jbe	.nextzone
	mov	rcx, [rdi+180h]	; OwningGameInstance
	mov	rcx, [rcx+218h]	; PuzzleDatabase
	mov	rdx, rbp
	mov	r8, [rbp-8]
	lea	r9, [rbp+10h]
	mov	[r9], bl
	call	[GetAllSolvedPuzzleDataInZone]
	mov	rcx, [rax]
	call	[fmemory_free]
	mov	esi, [rbp+8]
	add	esi, esi
	lea	esi, [rsi*5]
	mov	rcx, [rdi+180h]
	mov	rcx, [rcx+218h]
	mov	rdx, rbp
	lea	r8, [rbp+10h]
	call	[GetAllPuzzleDataInZone]
	mov	rcx, [rax]
	call	[fmemory_free]
	cmp	dword [rbp+8], 0
	jz	.nextzone
	mov	eax, esi
	xor	edx, edx
	div	dword [rbp+8]
	cmp	eax, 3
	jb	.nextzone
	lea	rsi, [chests_by_zone]
.findplace:
	call	[rand]
	mul	dword [rsi+(rbx-2)*8+4]
	shrd	eax, edx, 15
	shl	eax, 5
	add	eax, [rsi+(rbx-2)*8]
	lea	r8, [rsi+spawned_chests-chests_by_zone]
	mov	ecx, dword [rsi+total_spawned_chests-chests_by_zone]
	test	ecx, ecx
	jz	.placeok
.checkplace:
	cmp	[r8+spawned_chest_struct.data_offset], eax
	jnz	@f
	cmp	[r8+spawned_chest_struct.chest], 0
	jnz	.findplace
	mov	edx, dword [rsi-chests_by_zone+num_spawned_chests_by_zone+(rbx-2)*4]
	inc	edx
	cmp	[rsi+(rbx-2)*8+4], edx
	ja	.findplace
@@:
	add	r8, spawned_chest_struct.sizeof
	dec	ecx
	jnz	.checkplace
.placeok:
	mov	esi, eax
	mov	rcx, rbp
	mov	[rbp-10h], rcx
	call	[FActorSpawnParameters_ctr]
	mov	rcx, [rdi+118h] ; AuthorityGameMode
	add	rcx, 470h ; ItemPickupClass
	call	[FSoftObjectPtr_LoadSynchronous]
	mov	rdx, rax
	lea	r8, [rsi+8]
	add	r8, [chests_bin_data]
	lea	r9, [r8+0Ch]
	mov	rcx, rdi
	call	[UWorld_SpawnActor]
	lea	rdx, [spawned_chests]
	inc	[rdx-spawned_chests+num_spawned_chests_by_zone+(rbx-2)*4]
	mov	ecx, [rdx+total_spawned_chests-spawned_chests]
	test	ecx, ecx
	jz	.newchestinfo
.findfreechestinfo:
	cmp	[rdx+spawned_chest_struct.chest], 0
	jnz	@f
	cmp	[rdx+spawned_chest_struct.zone], ebx
	jz	.storechestinfo
@@:
	add	rdx, spawned_chest_struct.sizeof
	dec	ecx
	jnz	.findfreechestinfo
.newchestinfo:
	inc	[total_spawned_chests]
.storechestinfo:
	mov	[rdx+spawned_chest_struct.chest], rax
	mov	rcx, [rax+130h]
	movups	xmm0, [rcx+134h]
	movups	xword [rdx+spawned_chest_struct.original_scale], xmm0
	and	[rdx+spawned_chest_struct.opentime], 0
	mov	[rdx+spawned_chest_struct.zone], ebx
	mov	[rdx+spawned_chest_struct.data_offset], esi
	mov	rsi, rax
	call	[UItemData_StaticClass]
	mov	rcx, rbp
	mov	rdx, rax
	call	[FStaticConstructObjectParameters_ctr]
	mov	rcx, rbp
	call	[StaticConstructObject_Internal]
	mov	[rsi+240h], rax
	mov	rsi, rax
	mov	rcx, [rbp-8]
	mov	rcx, [rcx+920h]	; CharItemComponent
	mov	rcx, [rcx+0C0h]	; itemsDataAsset
	mov	dl, 11
	call	[UDefaultItems_GetDefaultItem]
	mov	[rsi+28h], rax
.nextzone:
	inc	ebx
	cmp	bl, first_zone + num_zones
	jb	.zoneloop
.fail:
	add	rsp, 78h
	pop	rdi
	pop	rsi
	pop	rbx
	pop	rbp
	ret
.end:

hook_execGetLevel:
	mov	eax, [rcx+6B8h]	; UPuzzleGrid.levelOverride
	sub	eax, 5
	jae	@f
	xor	eax, eax
@@:
	mov	[rbx], eax
	add	rsp, 20h
	pop	rbx
	ret
.end:

hook_findmarkerclass:
	sub	rsp, 28h
	lea	rdx, [rbp+0E0h]
	mov	rcx, rsi
	call	[original_findmarkerclass]
	cmp	dword [rax], -1
	jz	@f
	mov	rcx, [rbp-38h]
	mov	rcx, [rcx+6A0h]	; PuzzleGrid
	cmp	byte [rcx+6B8h], 5
	ja	@f
	or	dword [rax], -1
@@:
	add	rsp, 28h
	ret
.end:
end if

hook_giskraken_init:
	bts	dword [giskraken_init_called], 0
	jnc	@f
	ret
@@:
	mov	[rsp+8], rbx
	mov	[rsp+20h], rsi
.start_stack_use:
	push	rdi
.prolog_offs1 = $ - .start_stack_use
	sub	rsp, 60h
.prolog_offs2 = $ - .start_stack_use
.prolog_size = $ - .start_stack_use
	jmp	[giskraken_init_continue]
.end:

radar_check:
; in dungeons, show everything except technical -1s
; outside of dungeons, ignore gyroRing and rosary
	mov	al, [rbx+254h]
	cmp	al, -1
	jz	.nope
	cmp	qword [rbx+4E8h], 0
	jnz	.ok
	cmp	al, 9
	jz	.nope
	cmp	al, 26
	jz	.nope
.ok:
	cmp	al, al
	ret
.nope:
	cmp	al, -2
	ret

if patch_liars_modifier
hook_puzzlegrid_check_modifier:
	cmp	r8d, 11
	jnz	.notliar
	mov	ecx, [rsp+40h]
@@:
	cmp	ecx, [r13+8]
	jae	@f
	inc	ecx
	cmp	byte [r10+rcx-1], 0
	jl	@b
@@:
	mov	[rsp+40h], ecx
.notliar:
	cmp	r8d, 6
	jz	@f
	jmp	[continue_after_puzzlegrid_check_modifier2]
@@:
	mov	rax, [rbp-78h]
	jmp	[continue_after_puzzlegrid_check_modifier1]
.end:
end if

hook_hint:
; rax -> ASophiaRune
	movss	xmm6, [normal_hint_cost]
	mov	rdx, [rax+6A0h]
	cmp	dword [rdx+690h], 4 ; EModifierType__MatchTheAudio
	jbe	.not_music_grid
	mov	rdx, [rdx+688h]
	cmp	byte [rdx+4], 0
	jz	.not_music_grid
	movss	xmm6, [music_hint_cost]
.not_music_grid:
	cmp	byte [rax+561h], 0
	jmp	[hook_hint_continue]
.end:

spawnnotify_hook1:
	cmp	rbx, [r13+2D0h]
	jnz	.notfirst
	lea	rcx, [rbp+320h]
	xor	eax, eax
	mov	[rcx], rax
	mov	[rcx+8], rax
	mov	[rcx+20h], rax
	mov	[rcx+28h], rax
	mov	dword [rcx+2Ch], 80h
	mov	[rcx+34h], rax
	mov	[rcx+40h], rax
	mov	[rcx+48h], rax
	dec	eax
	mov	[rcx+30h], eax
	add	r14, 8
.notfirst:
	lea	rax, [rbx+8]
	cmp	rax, r14
	jz	.done
	mov	rdi, [rbx]
	cmp	esi, [r13+2CCh]
	jl	@f
	test	r15b, r15b
	jz	.done
@@:
	jmp	[spawnnotify_continue1]
.done:
	jmp	[spawnnotify_continue3]

spawnnotify_hook2:
	test	al, 1
	jnz	@f
	inc	esi
	xor	r9d, r9d
	lea	r8, [rdi+40h]
	lea	rdx, [rsp+20h]
	lea	rcx, [rbp+320h]
	mov	[rdx+24h], esi
	call	[stringmap_insert]
@@:
	jmp	[spawnnotify_continue2]
.end:

hook_savesolvedtime1:
	mov	cl, [rdi+254h]
	cmp	cl, 23 ; racingBallCourse
	jz	@f
	cmp	cl, 24 ; racingRingCourse
	jz	.racingring
	cmp	dword [rdi+420h], 25248	; KrakenId of skydrops speed challenge
	jnz	.passthrough
@@:
; xmm6 = current solve time, [rbp+0D8h] = historical best or -1
	cmp	dword [rbp+0D8h], 0	; integer comparison with zero is fine for floats
	jle	.passthrough
	comiss	xmm6, [rbp+0D8h]
	jb	.passthrough
.skipupdate:
	mov	rcx, [rax]
	call	[fmemory_free]
	mov	rcx, [rbp-48h]
	call	[fmemory_free]
	mov	rax, [savesolvedtime1_continue]
	add	rax, 5
	jmp	rax
.racingring:
	comiss	xmm6, [rbp+0D8h]
	jb	.skipupdate
.passthrough:
	lea	r9, [rbp-48h]
	mov	r8, rax
	mov	edx, [rbp-78h]
	mov	rcx, r15
	jmp	[savesolvedtime1_continue]
.end:

hook_savesolvedtime2:
	mov	r9d, [rdi+420h]
	mov	cl, [rdi+254h]
	cmp	cl, 23 ; racingBallCourse
	jz	@f
	cmp	cl, 24 ; racingRingCourse
	jz	@f
	cmp	r9d, 25248
	jnz	.done
@@:
; [rdx]FPuzzleSolveData [rcx]UGISProgression::GetPuzzleSolveStatus(
; [r8]const ASophiaCharacter* Player, [r9]int32 KrakenId, [rsp+20h]const FString& LocalID, [rsp+28h]const FString& hackId)
	mov	rcx, rbx
	mov	rdx, rax
	mov	r8, r14
	lea	rax, [rdi+488h]
	mov	[rsp+20h], rax
	lea	rax, [emptystring]
	mov	[rsp+28h], rax
	call	[getpuzzlesolvestatus]
	mov	rcx, [rax+8]
	call	[fmemory_free]
	lea	rax, [rbp-50h]
	movss	xmm0, dword [r15+20h]
	cmp	dword [rax+18h], 0
	jle	.done
	cmp	byte [rdi+254h], 24
	jz	.takemax
	minss	xmm0, dword [rax+18h]
	jmp	.done
.takemax:
	maxss	xmm0, dword [rax+18h]
.done:
	mov	[rbp-30h], r12
	jmp	[savesolvedtime2_continue]
.end:

hook_gridsolve_check:
	mov	rax, [rbx+688h]
	cmp	ecx, 11
	jbe	@f
	cmp	byte [rax+11], 0
	jz	@f
.checkanswer:
	jmp	[gridsolve_continue1]
@@:
	cmp	byte [rax+4], 0
	jnz	.checkanswer
	jmp	[gridsolve_continue2]
.end:

section '.rdata' data readable
; 100.0 to convert meters -> UE units, 2**-31 to deal with our random method
hide_radius_multiplier	dd	0x33480000, 0x33480000, 0x33480000, 0
zw_sign	dd	0, 0, 0x80000000, 0x80000000
yz_sign	dd	0, 0x80000000, 0x80000000, 0
z_one	dd	0, 0, 1.0, 0
emptystring	dq	0, 0
logic_grid_and_like_offset	dd	240.0
if add_chests
opened_chest_lifetime	dd	10.0
opened_chest_shrink_speed	dd	-0.2
end if

data import
library kernel32, 'KERNEL32.DLL', user32, 'USER32.DLL', utility, 'api-ms-win-crt-utility-l1-1-0.dll'
include 'api/kernel32.inc'
include 'api/user32.inc'
import utility, rand, 'rand'
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
	dd	rva make_writable.large, rva make_writable.end, rva make_writable_unwind
	dd	rva restore_protection.large, rva restore_protection.end, rva make_writable_unwind
	dd	rva find_nearest_unsolved, rva find_nearest_unsolved.end, rva find_nearest_unsolved_unwind
	dd	rva additional_markers, rva additional_markers.end, rva additional_markers_unwind
	dd	rva hook_putmarker.start_stack_use, rva hook_putmarker.end, rva make_writable_unwind
	dd	rva hook_loadversion, rva hook_loadversion.end, rva make_writable_unwind
	dd	rva hook_puzzledatabase_init, rva hook_puzzledatabase_init.end, rva hook_puzzledatabase_init_unwind
if add_chests
	dd	rva hook_initgamemode, rva hook_initgamemode.end, rva make_writable_unwind
	dd	rva hook_gamemode_tick, rva hook_gamemode_tick.end, rva hook_gamemode_tick_unwind
	dd	rva spawn_chests_if_needed, rva spawn_chests_if_needed.end, rva spawn_chests_if_needed_unwind
	dd	rva hook_execGetLevel, rva hook_execGetLevel.end, rva hook_execGetLevel_unwind
	dd	rva hook_findmarkerclass, rva hook_findmarkerclass.end, rva make_writable_unwind
end if
	dd	rva hook_giskraken_init.start_stack_use, rva hook_giskraken_init.end, rva hook_giskraken_init_unwind
if patch_liars_modifier
	dd	rva hook_puzzlegrid_check_modifier, rva hook_puzzlegrid_check_modifier.end, rva hook_puzzlegrid_check_modifier_unwind
end if
	dd	rva hook_hint, rva hook_hint.end, rva hook_hint_unwind
	dd	rva spawnnotify_hook1, rva spawnnotify_hook2.end, rva spawnnotify_hook_unwind
	dd	rva hook_savesolvedtime1, rva hook_savesolvedtime1.end, rva hook_savesolvedtime1_unwind
	dd	rva hook_savesolvedtime2, rva hook_savesolvedtime2.end, rva hook_savesolvedtime2_unwind
	dd	rva hook_gridsolve_check, rva hook_gridsolve_check.end, rva hook_gridsolve_check_unwind
end data

macro start_unwind_data {
.start:
}
macro end_unwind_data {
.size = $ - .start
if .size mod 4
	dw	0
end if
}

CreateDXGIFactory_unwind:
	db	1, CreateDXGIFactory.prolog_size, CreateDXGIFactory_unwind.size / 2, 0
start_unwind_data
	db	CreateDXGIFactory.prolog_offs3, 1	; UWOP_ALLOC_LARGE
	dw	(CreateDXGIFactory.stack_size + 8) / 8	; arg for UWOP_ALLOC_LARGE
	db	CreateDXGIFactory.prolog_offs2, 70h ; UWOP_PUSH_NONVOL=0, rdi->7
	db	CreateDXGIFactory.prolog_offs1, 30h ; UWOP_PUSH_NONVOL=0, rbx->3
end_unwind_data
save_game_patched_unwind:
	db	1, 0, save_game_patched_unwind.size / 2, 0
start_unwind_data
	db	0, 2 + ((28h - 8) / 8) * 10h ; UWOP_ALLOC_SMALL for 28h bytes
end_unwind_data
make_backup_unwind:
	db	1, make_backup.prolog_size, make_backup_unwind.size / 2, 0
start_unwind_data
	db	make_backup.prolog_offs3, 2 + ((make_backup.stack_size - 8) / 8) * 10h
	db	make_backup.prolog_offs2, 70h ; UWOP_PUSH_NONVOL=0, rdi->7
	db	make_backup.prolog_offs1, 30h ; UWOP_PUSH_NONVOL=0, rbx->3
end_unwind_data
make_writable_unwind: ; also used for everything with simple prolog/epilog
	db	1, make_writable.prolog_size, make_writable_unwind.size / 2, 0
start_unwind_data
	db	make_writable.prolog_size, 2 + ((28h - 8) / 8) * 10h
end_unwind_data
find_nearest_unsolved_unwind:
	db	1, find_nearest_unsolved.prolog_size, find_nearest_unsolved_unwind.size / 2, 0
start_unwind_data
	db	find_nearest_unsolved.prolog_offs12, 8 + 10 * 10h ; UWOP_SAVE_XMM128 for xmm10
	dw	6	; saved to [rsp+60h]
	db	find_nearest_unsolved.prolog_offs11, 8 + 9 * 10h ; UWOP_SAVE_XMM128 for xmm9
	dw	5	; saved to [rsp+50h]
	db	find_nearest_unsolved.prolog_offs10, 8 + 8 * 10h ; UWOP_SAVE_XMM128 for xmm8
	dw	4	; saved to [rsp+40h]
	db	find_nearest_unsolved.prolog_offs9, 8 + 7 * 10h ; UWOP_SAVE_XMM128 for xmm7
	dw	3	; saved to [rsp+30h]
	db	find_nearest_unsolved.prolog_offs8, 8 + 6 * 10h ; UWOP_SAVE_XMM128 for xmm6
	dw	2	; saved to [rsp+20h]
	db	find_nearest_unsolved.prolog_offs7, 2 + ((78h - 8) / 8) * 10h ; UWOP_ALLOC_SMALL for 78h bytes
	db	find_nearest_unsolved.prolog_offs6, 0F0h	; UWOP_PUSH_NONVOL r15
	db	find_nearest_unsolved.prolog_offs5, 0E0h	; UWOP_PUSH_NONVOL r14
	db	find_nearest_unsolved.prolog_offs4, 50h	; UWOP_PUSH_NONVOL rbp
	db	find_nearest_unsolved.prolog_offs3, 70h	; UWOP_PUSH_NONVOL rdi
	db	find_nearest_unsolved.prolog_offs2, 60h	; UWOP_PUSH_NONVOL rsi
	db	find_nearest_unsolved.prolog_offs1, 30h	; UWOP_PUSH_NONVOL rbx
end_unwind_data
additional_markers_unwind:
	db	1, 0, additional_markers_unwind.size / 2, 0
start_unwind_data
; we don't manipulate the stack ourselves, but inherit these from the main code
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
end_unwind_data
hook_puzzledatabase_init_unwind:
	db	1, 0, hook_puzzledatabase_init_unwind.size / 2, 0
start_unwind_data
; we don't manipulate the stack ourselves, but inherit these from the main code
	db	0, 4 + 7*10h	; UWOP_SAVE_NONVOL rdi
	dw	53h
	db	0, 4 + 6*10h	; UWOP_SAVE_NONVOL rsi
	dw	52h
	db	0, 4 + 3*10h	; UWOP_SAVE_NONVOL rbx
	dw	51h
	db	0, 1	; UWOP_ALLOC_LARGE
	dw	4Ah
	db	0, 0F0h	; UWOP_PUSH_NONVOL r15
	db	0, 0E0h	; UWOP_PUSH_NONVOL r14
	db	0, 0D0h	; UWOP_PUSH_NONVOL r13
	db	0, 0C0h	; UWOP_PUSH_NONVOL r12
	db	0, 50h	; UWOP_PUSH_NONVOL rbp
end_unwind_data
hook_gamemode_tick_unwind:
	db	1, hook_gamemode_tick.prolog_size, .size / 2, 0
start_unwind_data
	db	hook_gamemode_tick.prolog_offs3, 2 + ((28h - 8) / 8) * 10h	; UWOP_ALLOC_SMALL for 28h bytes
	db	hook_gamemode_tick.prolog_offs2, 60h	; UWOP_PUSH_NONVOL rsi
	db	hook_gamemode_tick.prolog_offs1, 30h	; UWOP_PUSH_NONVOL rbx
end_unwind_data
spawn_chests_if_needed_unwind:
	db	1, spawn_chests_if_needed.prolog_size, .size / 2, 0
start_unwind_data
	db	spawn_chests_if_needed.prolog_offs5, 2 + ((78h - 8) / 8) * 10h	; UWOP_ALLOC_SMALL for 78h bytes
	db	spawn_chests_if_needed.prolog_offs4, 70h	; UWOP_PUSH_NONVOL rdi
	db	spawn_chests_if_needed.prolog_offs3, 60h	; UWOP_PUSH_NONVOL rsi
	db	spawn_chests_if_needed.prolog_offs2, 30h	; UWOP_PUSH_NONVOL rbx
	db	spawn_chests_if_needed.prolog_offs1, 50h	; UWOP_PUSH_NONVOL rbp
end_unwind_data
hook_execGetLevel_unwind:
	db	1, 0, .size / 2, 0
start_unwind_data
	db	0, 2 + ((20h - 8) / 8) * 10h	; UWOP_ALLOC_SMALL
	db	0, 30h	; UWOP_PUSH_NONVOL rbx
end_unwind_data
hook_giskraken_init_unwind:
	db	1, hook_giskraken_init.prolog_size, hook_giskraken_init_unwind.size / 2, 0
start_unwind_data
	db	hook_giskraken_init.prolog_offs2, 2 + ((60h - 8) / 8) * 10h	; UWOP_ALLOC_SMALL for 60h bytes
	db	hook_giskraken_init.prolog_offs1, 70h	; UWOP_PUSH_NONVOL rdi
end_unwind_data
if patch_liars_modifier
hook_puzzlegrid_check_modifier_unwind:
	db	1, 0, hook_puzzlegrid_check_modifier_unwind.size / 2, 0
start_unwind_data
	db	0, 8 + 6*10h	; UWOP_SAVE_XMM128 xmm6
	dw	54h
	db	0, 4 + 7*10h	; UWOP_SAVE_NONVOL rdi
	dw	0B3h
	db	0, 4 + 6*10h	; UWOP_SAVE_NONVOL rsi
	dw	0B2h
	db	0, 4 + 3*10h	; UWOP_SAVE_NONVOL rbx
	dw	0B1h
	db	0, 1	; UWOP_ALLOC_LARGE
	dw	0AAh
	db	0, 0F0h	; UWOP_PUSH_NONVOL r15
	db	0, 0E0h	; UWOP_PUSH_NONVOL r14
	db	0, 0D0h	; UWOP_PUSH_NONVOL r13
	db	0, 0C0h	; UWOP_PUSH_NONVOL r12
	db	0, 50h	; UWOP_PUSH_NONVOL rbp
end_unwind_data
end if
hook_hint_unwind:
	db	1, 0, hook_hint_unwind.size / 2, 0
start_unwind_data
	db	0, 8 + 6*10h	; UWOP_SAVE_XMM128 xmm6
	dw	0Bh
	db	0, 4 + 6*10h	; UWOP_SAVE_NONVOL rsi
	dw	1Dh
	db	0, 4 + 5*10h	; UWOP_SAVE_NONVOL rbp
	dw	1Ch
	db	0, 4 + 3*10h	; UWOP_SAVE_NONVOL rbx
	dw	1Bh
	db	0, 1	; UWOP_ALLOC_LARGE
	dw	18h
	db	0, 70h	; UWOP_PUSH_NONVOL rdi
end_unwind_data
spawnnotify_hook_unwind:
	db	1, 0, hook_hint_unwind.size / 2, 0
start_unwind_data
	db	0, 8 + 7*10h	; UWOP_SAVE_XMM128 xmm7
	dw	51h
	db	0, 8 + 6*10h	; UWOP_SAVE_XMM128 xmm6
	dw	52h
	db	0, 4 + 7*10h	; UWOP_SAVE_NONVOL rdi
	dw	0AFh
	db	0, 4 + 6*10h	; UWOP_SAVE_NONVOL rsi
	dw	0AEh
	db	0, 4 + 3*10h	; UWOP_SAVE_NONVOL rbx
	dw	0ADh
	db	0, 1	; UWOP_ALLOC_LARGE
	dw	0A6h
	db	0, 0F0h	; UWOP_PUSH_NONVOL r15
	db	0, 0E0h	; UWOP_PUSH_NONVOL r14
	db	0, 0D0h	; UWOP_PUSH_NONVOL r13
	db	0, 0C0h ; UWOP_PUSH_NONVOL r12
	db	0, 50h	; UWOP_PUSH_NONVOL rbp
end_unwind_data
hook_savesolvedtime1_unwind:
	db	1, 0, hook_savesolvedtime1_unwind.size / 2, 0
start_unwind_data
	db	0, 8 + 7*10h	; UWOP_SAVE_XMM128 xmm7
	dw	2Fh
	db	0, 8 + 6*10h	; UWOP_SAVE_XMM128 xmm6
	dw	30h
	db	0, 1	; UWOP_ALLOC_LARGE
	dw	63h
	db	0, 0F0h	; UWOP_PUSH_NONVOL r15
	db	0, 0E0h	; UWOP_PUSH_NONVOL r14
	db	0, 0D0h	; UWOP_PUSH_NONVOL r13
	db	0, 0C0h	; UWOP_PUSH_NONVOL r12
	db	0, 70h	; UWOP_PUSH_NONVOL rdi
	db	0, 60h	; UWOP_PUSH_NONVOL rsi
	db	0, 30h	; UWOP_PUSH_NONVOL rbx
	db	0, 50h	; UWOP_PUSH_NONVOL rbp
end_unwind_data
hook_savesolvedtime2_unwind:
	db	1, 0, hook_savesolvedtime2_unwind.size / 2, 0
start_unwind_data
	db	0, 8 + 6*10h	; UWOP_SAVE_XMM128 xmm6
	dw	17h
	db	0, 4 + 0Ch*10h	; UWOP_SAVE_NONVOL r12
	dw	37h
	db	0, 4 + 7*10h	; UWOP_SAVE_NONVOL rdi
	dw	36h
	db	0, 4 + 6*10h	; UWOP_SAVE_NONVOL rsi
	dw	35h
	db	0, 4 + 3*10h	; UWOP_SAVE_NONVOL rbx
	dw	34h
	db	0, 1	; UWOP_ALLOC_LARGE
	dw	30h
	db	0, 0F0h	; UWOP_PUSH_NONVOL r15
	db	0, 0E0h	; UWOP_PUSH_NONVOL r14
	db	0, 50h	; UWOP_PUSH_NONVOL rbp
end_unwind_data
hook_gridsolve_check_unwind:
	db	1, 0, hook_gridsolve_check_unwind.size / 2, 0
start_unwind_data
	db	0, 4 + 7*10h	; UWOP_SAVE_NONVOL rdi
	dw	0A1h
	db	0, 4 + 6*10h	; UWOP_SAVE_NONVOL rsi
	dw	0A0h
	db	0, 4 + 3*10h	; UWOP_SAVE_NONVOL rbx
	dw	9Fh
	db	0, 1	; UWOP_ALLOC_LARGE
	dw	98h
	db	0, 0F0h	; UWOP_PUSH_NONVOL r15
	db	0, 0E0h	; UWOP_PUSH_NONVOL r14
	db	0, 0D0h	; UWOP_PUSH_NONVOL r13
	db	0, 0C0h	; UWOP_PUSH_NONVOL r12
	db	0, 50h	; UWOP_PUSH_NONVOL rbp
end_unwind_data

align 4
fixups_start = $
data fixups
if $ = fixups_start
	dd	0, 8	; fake entry
end if
end data

_2pow62	dd	0x5E800000
normal_hint_cost	dd	1.0
music_hint_cost		dd	0.5

patch_failed_text:
	db	'Some patches have not been applied. Probably the executable has been updated and you need to get a new version of the patch.', 0
patch_failed_caption:
	db	'Patch error',0

bad_pak_caption:
	db	'Offline Restored Mod: bad .pak file',0
no_pak_file_text:
	db	"The .dll part of the mod is installed correctly, but the .pak part is missing. You'll miss many important fixes",0
error_pak_file_text:
	db	"Something went wrong while validating .pak part of the mod", 0
mismatch_pak_file_text:
	db	"Please re-download and re-install the latest version of Offline Restored Mod", 0

bad_chests_caption:
	db	'Offline Restored Mod: bad chests.bin file', 0
bad_chests_text:
	db	'AddChests is on, but chests.bin is missing or broken. Reinstall the mod or disable AddChests', 0

align 2
str_tmp	du	'.tmp',0
str_OfflineSavegame	du	'OfflineSavegame',0
backup_filename_formatstring	du	'%sOfflineSavegame_%04d-%02d-%02d_%02d%02d%02d.sav',0
savebackups_path	du	'SaveBackups/',0
savebackups_mask	du	'*.sav',0
pak_file_name	du	'Paks/RRMOD_PuzzleFix.pak',0

; ini file sections and keys
strSaves	du	'Saves', 0
strViaTemporaryFile	du	'ViaTemporaryFile', 0
strMaxBackups	du	'MaxBackups', 0
strBackupPeriod	du	'BackupPeriod', 0
strGameplay	du	'Gameplay', 0
strSolvedStaySolved	du	'SolvedStaySolved', 0
strChargeJumpRechargeDelay	du	'ChargeJumpRechargeDelay', 0
strFixQuestRewards	du	'FixQuestRewards', 0
strDisableWandererQuests	du	'DisableWandererQuests', 0
strHighQualitySightSeerCapture	du	'HighQualitySightSeerCapture', 0
strShowNearestUnsolved	du	'ShowNearestUnsolved', 0
strEmoteMarksNearestUnsolved	du	'EmoteMarksNearestUnsolved', 0
strHiddenPuzzlesMarkerMaxDistance	du	'HiddenPuzzlesMarkerMaxDistance', 0
strShowNearestLogicGrid	du	'ShowNearestLogicGrid', 0
strMinLogicGridDifficulty	du	'MinLogicGridDifficulty', 0
strHackMatchboxRadar	du	'HackMatchboxRadar', 0
if add_chests
strAddChests	du	'AddChests', 0
end if
if debug_chests
strAddChestsMarker	du	'AddChestsMarker', 0
end if
strCheaperMusicForesight	du	'CheaperMusicForesight', 0
strNotifyPuzzleSpawns	du	'NotifyPuzzleSpawns', 0
strMod		du	'Mod', 0
strVersion	du	'Version', 0
strPakFileHash	du	'PakFileHash', 0

section '.data' data readable writable
hide_radius	rd	4
current_marker_pos	rd	4
original	rq	3
save_critsect	rq	5
savegametoslot	dq	?
fstring_add	dq	?
fmemory_free	dq	?
getsavegamepath	dq	?
projectsaveddir	dq	?
additionalmarkers_continue	dq	?
tarray216_resize_grow	dq	?
FLocationMarkerData_constructor	dq	?
putmarker_continue	dq	?
current_marker_puzzle	dq	?
loadfiletostring	dq	?
FPaths_ProjectContentDir	dq	?
puzzledatabase_init_continue	dq	?
giskraken_init_continue	dq	?
if patch_liars_modifier
continue_after_puzzlegrid_check_modifier1	dq	?
continue_after_puzzlegrid_check_modifier2	dq	?
end if
hook_hint_continue	dq	?
spawnnotify_continue1	dq	?
spawnnotify_continue2	dq	?
spawnnotify_continue3	dq	?
stringmap_insert	dq	?
getpuzzlesolvestatus	dq	?
savesolvedtime1_continue	dq	?
savesolvedtime2_continue	dq	?
gridsolve_continue1	dq	?
gridsolve_continue2	dq	?

if add_chests
original_initgamemode	dq	?
original_gamemode_tick	dq	?
original_findmarkerclass	dq	?
GetSophiaCharacterFromWorld	dq	?
GetAllPuzzleDataInZone	dq	?
GetAllSolvedPuzzleDataInZone	dq	?
FActorSpawnParameters_ctr	dq	?
FSoftObjectPtr_LoadSynchronous	dq	?
UWorld_SpawnActor	dq	?
UItemData_StaticClass	dq	?
FStaticConstructObjectParameters_ctr	dq	?
StaticConstructObject_Internal	dq	?
UDefaultItems_GetDefaultItem	dq	?
USceneComponent_SetRelativeScale3D	dq	?
AActor_Destroy	dq	?

chests_bin_data	rq	2
chests_by_zone	rd	num_zones*2
total_spawned_chests	dd	?
num_spawned_chests_by_zone	rd	num_zones
spawned_chests:	rb	num_zones * spawned_chest_struct.sizeof
end if

max_backups	dd	?
backup_period	dd	?
last_backup_time	dd	?
backup_made	db	?
use_temporary_file db	?
show_nearest_unsolved	db	?
show_nearest_logicgrid	db	?
min_logicgrid_difficulty	db	?
current_active_marker_type	db	?
giskraken_init_called	db	?
if debug_chests
add_chests_marker	db	?
end if
align 2
modVersion	rw	256
pakFileHash	rw	41

format PE64 GUI 5.0 DLL NX at 123400000h
include 'win64a.inc'

; safety checks:
; * we're going to read/write from fixed addresses, ImageSize of the executable should cover them
expected_image_size = 0x6110000
; * we're going to patch a concrete function, verify the bytes we'll rewrite
patched_function = 0x135F5F0
expected_original_value1 = 0x4154415756535540
expected_original_value2 = 0x48574156
; * expected_original_value is a not-so-unique function prolog;
;   to make sure we're not going to patch a random function,
;   check that it references the string "PlayerLoc" at the concrete location
safety_check_PlayerLoc_addr = 0x135F7A0

; there are two versions of IsSolved, let's call them IsSolved and IsSolvedBy;
; the second one additionally takes a player identifier.
; The first one is crucial, patch both just in case.
is_solved_offset = 0x1431965
is_solved_by_offset = 0x1431B2C

save_game_offset = 0x12C678E
expected_save_game_original_value1 = 0x30508D4840488B48
expected_save_game_original_value2 = 0x48C03345

fstring_add_offset = 0x8822F0 ; FString operator+(const FString&, const wchar_t*)
fmemory_free_offset = 0x162B070 ; FMemory::Free(void*)
getsavegamepath_offset = 0x335D6D0 ; FString FGenericSaveGameSystem::GetSaveGamePath(const wchar_t*)

; allowed time between saves of the position, in milliseconds
allow_interval = 60 * 1000  ; 1 minute

section '.text' code readable executable

CreateDXGIFactory:
virtual at 0
	rb	20h	; shadow space for callees
.saved_rcx	dq	?
.saved_rdx	dq	?
.saved_r8	dq	?
.saved_r9	dq	?
.func	dd	?
.patch_failed	db	?
.orig_dll_name	rb	104h + 14h
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
	mov	dword [rbx + .func - .orig_dll_name], eax
	mov	qword [rbx + .saved_rcx - .orig_dll_name], rcx
	mov	qword [rbx + .saved_rdx - .orig_dll_name], rdx
	mov	qword [rbx + .saved_r8 - .orig_dll_name], r8
	mov	qword [rbx + .saved_r9 - .orig_dll_name], r9
; patch function that saves player's location/rotation
	xor	ecx, ecx
	mov	byte [rbx + .patch_failed - .orig_dll_name], cl
	call	[GetModuleHandleW]
	mov	ecx, [rax+3Ch]
	cmp	dword [rax+rcx+50h], expected_image_size
	jnz	.nag
	lea	rcx, [rax+fstring_add_offset]
	mov	rdx, 0x8B840F0038834166
	cmp	[rcx+25h], rdx
	jz	@f
	xor	ecx, ecx
	mov	byte [rbx + .patch_failed - .orig_dll_name], 1
@@:
	mov	[fstring_add], rcx
	lea	rcx, [rax+fmemory_free_offset]
	mov	rdx, 0x8348532E74C98548
	cmp	[rcx], rdx
	jz	@f
	xor	ecx, ecx
	mov	byte [rbx + .patch_failed - .orig_dll_name], 1
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
	mov	byte [rbx + .patch_failed - .orig_dll_name], 1
@@:
	mov	[getsavegamepath], rcx
	lea	rdi, [rax+patched_function]
	mov	rcx, expected_original_value1
	cmp	qword [rdi], rcx
	jnz	.nag
	cmp	dword [rdi+8], expected_original_value2
	jnz	.nag
	mov	ecx, [rdi+safety_check_PlayerLoc_addr-patched_function]
	add	ecx, safety_check_PlayerLoc_addr + 4
	cmp	ecx, expected_image_size - 8
	jae	.nag
	mov	rdx, 'PlayerLo'
	cmp	[rax+rcx], rdx
	jnz	.nag
	lea	rax, [rdi+14]
	mov	[continue_after_patch], rax
	mov	rcx, rdi
	mov	edx, 12
	lea	r8d, [rdx-12+PAGE_READWRITE]
	mov	r9, rbx
	call	[VirtualProtect]
	mov	word [rdi], 0xB848  ; mov rax,imm64
	lea	rax, [patched]
	mov	[rdi+2], rax
	mov	word [rdi+10], 0xE0FF  ; jmp rax
	mov	rcx, rdi
	mov	edx, 12
	mov	r9, rbx
	mov	r8d, [rbx]
	call	[VirtualProtect]
; patch IsSolved/IsSolvedBy so that solved puzzles stay solved
	add	rdi, is_solved_offset - patched_function
	mov	rcx, rdi
	mov	edx, is_solved_by_offset - is_solved_offset + 1
	mov	r8d, PAGE_READWRITE
	mov	r9, rbx
	call	[VirtualProtect]
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
	mov	rcx, rdi
	mov	edx, is_solved_by_offset - is_solved_offset + 1
	mov	r8d, [rbx]
	mov	r9, rbx
	call	[VirtualProtect]
; patch the caller of UGameplayStatics::SaveGameToSlot for save-to-temporary/move-temporary-to-main
; this assumes the availability of fstring_add, fmemory_free, getsavegamepath
	add	rdi, save_game_offset - is_solved_offset
	cmp	[rbx + .patch_failed - .orig_dll_name], 0
	jnz	.skip_savegame_patch
	mov	rcx, rdi
	mov	edx, 12
	lea	r8d, [rdx-12+PAGE_READWRITE]
	mov	r9, rbx
	call	[VirtualProtect]
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
	mov	rcx, rdi
	mov	edx, 12
	mov	r8d, [rbx]
	mov	r9, rbx
	call	[VirtualProtect]
.skip_savegame_patch:
	cmp	[rbx + .patch_failed - .orig_dll_name], 0
	jz	@f
	xor	ecx, ecx
	lea	rdx, [patch_failed_text]
	lea	r8, [patch_failed_caption]
	lea	r9, [rcx+MB_OK+MB_ICONSTOP]
	call	[MessageBoxA]
@@:
	jmp	.done
.nag:
	xor	ecx, ecx
	lea	rdx, [nag_text]
	lea	r8, [nag_caption]
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
	mov	eax, dword [rbx + .func]
	mov	rcx, qword [rbx + .saved_rcx]
	mov	rdx, qword [rbx + .saved_rdx]
	mov	r8, qword [rbx + .saved_r8]
	mov	r9, qword [rbx + .saved_r9]
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

; this one totally ignores requirements for unwinding
; because MS frowns about patching anyway
; stack overflow won't be handled gracefully, not a big deal
patched:
	push	rcx	; stack alignment & save/restore the only function argument
	sub	rsp, 20h
	call	[GetTickCount]
	add	rsp, 20h
	pop	rcx
	sub	eax, [last_tick_count]
	cmp	eax, allow_interval
	jae	.allow
	ret
.allow:
	add	[last_tick_count], eax
	push	rbp
	push	rbx
	push	rsi
	push	rdi
	push	r12
	push	r14
	push	r15
	mov	rbp, rsp
	jmp	[continue_after_patch]

save_game_patched:
	mov	[rsp+20h], rax ; save useful data
; "OfflineSavegame" -> "OfflineSavegame.tmp"
	lea	rcx, [rsp+30h]
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

str_tmp	du	'.tmp',0

section '.rdata' data readable
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

align 4
fixups_start = $
data fixups
if $ = fixups_start
	dd	0, 8	; fake entry
end if
end data

nag_caption	db	'Failed to prevent unnecessary saves', 0
nag_text	db	'dxgi.dll cannot apply the patch because the executable has changed.', 13, 10
		db	'Maybe the developers have finally fixed the issue and you can just delete dxgi.dll from the game folder.', 13, 10
		db	'Maybe not and you need an updated version or another way to deal with the issue.', 0

patch_failed_text:
	db	'Some patches have not been applied. Probably the executable has been updated and you need to get a new version of the patch.', 0
patch_failed_caption:
	db	'Patch error',0


section '.data' data readable writable
original	rq	3
continue_after_patch	dq	?
savegametoslot	dq	?
fstring_add	dq	?
fmemory_free	dq	?
getsavegamepath	dq	?
last_tick_count	dd	?

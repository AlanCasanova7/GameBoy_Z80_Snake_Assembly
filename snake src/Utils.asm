ClearVram:              
    ld hl, _SCRNMAX         ; load the end of the screen into hl
    xor a                   ; set accomulator to 0
ClearTiles:
    ld [hl-], a         ; set to 0 whatever is in hl and then i decrease hl by 1
    bit 7, h            ; check if we checked all the sprites
    jp nz, ClearTiles   ; if we haven't checked all the sprites we keep looping
    ret

ClearOam:
	ld hl, _OAMRAM
clear_oam_loop:
	XOR A
	LD [HL+], A
	LD A, $A0
	CP A, L
	JP NZ, clear_oam_loop
	RET

ClearRam:
    ld hl, $C100
    ld bc, $A0
clear_ram_loop:
    ld a, $0
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, clear_ram_loop
    ret

SetMap:
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec de
    ld a, d
    or e
    jp nz, SetMap
    ret



SetTile:
	LD D, 0             ; load 0 into D (will be our counter)
set_tile_loop:
	LD A, [BC]          ; load BC into A (BC has our sprite data)
	LD [HL+], A         ; load A into HL, then increase HL
	INC BC              ; increase BC 
	INC D               ; increase D
	LD A, D             ; load my counter into accomulator
	CP e                ; compare our accomulator (counter) with e that will be 16
	JP NZ, set_tile_loop ; remain in the loop ultill we have done all the 16 piece of data
	ret


Wait_hBlank:
	LD A, [rSTAT]
	AND $03
	JP NZ, Wait_hBlank
	RET
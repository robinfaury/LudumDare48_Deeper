GamerChoice EQU FreeRAM
CurrentLineShown EQU GamerChoice+1
CurrentLine EQU CurrentLineShown+1
CurrentFrame EQU CurrentLine+1
CurrentSpeed EQU CurrentFrame+1
CurrentPosture EQU CurrentSpeed+1
AnimationDeltaT EQU CurrentPosture+1
AnimationDeltaTIdle EQU AnimationDeltaT+1
AnimationIdle EQU AnimationDeltaTIdle+1
Animation EQU AnimationIdle+1
AnimationType EQU Animation+1
MoveDirection EQU AnimationType+1
MapCurrentRow EQU MoveDirection+1
MapCurrentRowPtr EQU MapCurrentRow+1
PaletteCurrentRow EQU MapCurrentRowPtr+2
PaletteCurrentRowPtr EQU PaletteCurrentRow+1
Register1 EQU PaletteCurrentRowPtr+2
Register2 EQU Register1+1
CanGoLeft EQU Register2+1
CanGoRight EQU CanGoLeft+1
BlockUnder EQU CanGoRight+1
CanDigDirt EQU BlockUnder+1
CanDigStone EQU CanDigDirt+1
CanDigMetal EQU CanDigStone+1
CanDigAlien EQU CanDigMetal+1
CannotDig EQU CanDigAlien+1
DigPattern EQU CannotDig+1

POSTURE_NORMAL EQU 0
POSTURE_RIGHT EQU 1
POSTURE_LEFT EQU 3
POSTURE_UPSIDEDOWN EQU 2
ANIMATION_SPEED EQU 4
ANIMATION_NB_FRAME EQU 8
ANIMATION_NB_FRAME_FALL EQU 16
ANIMATION_TYPE_MOVE EQU 1
ANIMATION_TYPE_FALL EQU 2
ANIMATION_TYPE_DIG EQU 3

SECTION "game", ROMX[$4000], BANK[3]
SetupLvl_Bank3:
	call LCD_Stop

	ld a, $01
	ld [rVRAM_BANK], a
	ld hl, palette_Bank3
	ld de, _SCRN0
	ld bc, 32*32
	call mem_Copy

	ld a, $00
	ld [rVRAM_BANK], a
	ld hl, map_Bank3
	ld de, _SCRN0
	ld bc, 32*32
	call mem_Copy

	ld hl, game_tiles_Bank3
	ld de, _VRAM
	ld bc, game_tiles_end_Bank3-game_tiles_Bank3
	call mem_Copy

	ld a, $00
	ld [CurrentLine], a
	ld a, $00
	ld [CurrentFrame], a
	ld a, $00
	ld [CurrentSpeed], a
	ld a, POSTURE_NORMAL
	ld [CurrentPosture], a
	ld a, $00
	ld [AnimationDeltaT], a
	ld a, $00
	ld [AnimationDeltaTIdle], a
	ld a, 18
	ld [CurrentLineShown], a
	ld a, 30
	ld [MapCurrentRow], a
	ld hl, map_Bank3+$20*$02
	ld a, h
	ld [MapCurrentRowPtr+0], a
	ld a, l
	ld [MapCurrentRowPtr+1], a
	ld a, 30
	ld [PaletteCurrentRow], a
	ld hl, palette_Bank3+$20*$02
	ld a, h
	ld [PaletteCurrentRowPtr+0], a
	ld a, l
	ld [PaletteCurrentRowPtr+1], a
	ld a, $00
	call ResetSkill

	ld a, $01
	ld [DigPattern+0], a
	ld a, $00
	ld [DigPattern+1], a
	ld a, $01
	ld [DigPattern+2], a
	ld a, $00
	ld [DigPattern+3], a
	ld a, $FF
	ld [DigPattern+4], a
	ld a, $00
	ld [DigPattern+5], a
	ld a, $01
	ld [DigPattern+6], a
	ld a, $00
	ld [DigPattern+7], a
	ld a, $FF
	ld [DigPattern+8], a
	ld a, $00
	ld [DigPattern+9], a
	ld a, $FF
	ld [DigPattern+10], a
	ld a, $00
	ld [DigPattern+11], a
	ld a, $FF
	ld [DigPattern+12], a
	ld a, $00
	ld [DigPattern+13], a
	ld a, $01
	ld [DigPattern+14], a
	ld a, $00
	ld [DigPattern+15], a
	ld a, $FF
	ld [DigPattern+16], a
	ld a, $00
	ld [DigPattern+17], a
	ld a, $FF
	ld [DigPattern+18], a
	ld a, $00
	ld [DigPattern+19], a
	ld a, $00
	ld [DigPattern+20], a
	ld a, $00
	ld [DigPattern+21], a
	ld a, $01
	ld [DigPattern+22], a
	ld a, $00
	ld [DigPattern+23], a
	ld a, $01
	ld [DigPattern+24], a
	ld a, $00
	ld [DigPattern+25], a
	ld a, $01
	ld [DigPattern+26], a
	ld a, $00
	ld [DigPattern+27], a
	ld a, $FF
	ld [DigPattern+28], a
	ld a, $00
	ld [DigPattern+29], a
	ld a, $00
	ld [DigPattern+30], a
	ld a, $00
	ld [DigPattern+31], a

	call LCD_Start

	ld b, $00
	call ResetSprite

	ld a, $10
	ld [Sprite01], a
	ld a, $18
	ld [Sprite01+1], a
	ld a, %00000000
	ld [Sprite01+3], a

	ld a, $10
	ld [Sprite02], a
	ld a, $20
	ld [Sprite02+1], a
	ld a, %00000000
	ld [Sprite02+3], a

	ld a, $18
	ld [Sprite03], a
	ld a, $18
	ld [Sprite03+1], a
	ld a, %00000000
	ld [Sprite03+3], a

	ld a, $18
	ld [Sprite04], a
	ld a, $20
	ld [Sprite04+1], a
	ld a, %00000000
	ld [Sprite04+3], a

	ld a, $01
	ld [GamerChoice], a

	ld a, $00
	ld [Animation], a
	ld a, $00
	ld [AnimationIdle], a
	ret

ChangeOrientation:
	ld a, [MoveDirection]
	ld b, a
	ld a, [CurrentPosture]
	add a, b
	cp $04
	jr z, .reset_pos
	cp $FF
	jr z, .reset_neg
	ld [CurrentPosture], a
	ret
.reset_neg
	ld a, $03
	ld [CurrentPosture], a
	ret
.reset_pos
	ld a, $00
	ld [CurrentPosture], a
	ret

Move_Bank3:
	ld a, [MoveDirection]
	add a, a
	ld b, a
	ld a, [Sprite01+1]
	add a, b
	ld [Sprite01+1], a
	ld a, [Sprite02+1]
	add a, b
	ld [Sprite02+1], a
	ld a, [Sprite03+1]
	add a, b
	ld [Sprite03+1], a
	ld a, [Sprite04+1]
	add a, b
	ld [Sprite04+1], a
	ret

Animate_Bank3:
	ld a, [AnimationType]
	cp ANIMATION_TYPE_FALL
	jr z, .animation_fall
	cp ANIMATION_TYPE_DIG
	jr z, .animation_dig
.animation_move
	ld a, [AnimationDeltaT]
	inc a
	ld [AnimationDeltaT], a
	cp ANIMATION_SPEED
	jp z, .animation_speed
	ret
.animation_fall
	ld a, [Animation]
	inc a
	ld [Animation], a
	cp ANIMATION_NB_FRAME_FALL+2
	jr z, .end_scroll
	ld a, [rSCY]
	add a, 1
	ld [rSCY], a
	ret
.animation_dig
	ld a, [Animation]
	inc a
	ld [Animation], a
	cp ANIMATION_NB_FRAME_FALL+2
	jr nz, .end_check_dig
	ld a, [CannotDig]
	cp $01
	jr nz, .end_scroll
	ld a, $00
	ld [Animation], a
	ret
.end_check_dig
	ld hl, DigPattern
	ld a, [Animation]
	sub a, 2
	ld d, $00
	ld e, a
	add hl, de
	ld a, [hl]
	ld b, a
	ld a, [Sprite01+0]
	add a, b
	ld [Sprite01+0], a
	ld a, [Sprite02+0]
	add a, b
	ld [Sprite02+0], a
	ld a, [Sprite03+0]
	add a, b
	ld [Sprite03+0], a
	ld a, [Sprite04+0]
	add a, b
	ld [Sprite04+0], a
	ld a, [CannotDig]
	cp $01
	jr z, .cannot_dig
	ld a, [rSCY]
	add a, 1
	ld [rSCY], a
.cannot_dig
	ret
.end_scroll
	ld a, $00
	ld [Animation], a
	ld a, [MapCurrentRow]
	add a, 2
	cp 32
	jr nz, .end_reset
	ld a, $00
.end_reset
	ld [MapCurrentRow], a
	ld [PaletteCurrentRow], a
	ld a, [MapCurrentRow]
	ld h, 0
	ld l, a
	call MultiplyBy32
	ld de, _SCRN0
	add hl, de
	ld a, h
	ld [Register1], a
	ld a, l
	ld [Register2], a
	ld b, h
	ld c, l
	ld a, [MapCurrentRowPtr+0]
	ld h, a
	ld a, [MapCurrentRowPtr+1]
	ld l, a
	ld de, 28*32
	add hl, de
	ld d, b
	ld e, c
	ld bc, 32*2
	call mem_CopyVRAM
	ld a, $01
	ld [rVRAM_BANK], a
	ld a, [PaletteCurrentRowPtr+0]
	ld h, a
	ld a, [PaletteCurrentRowPtr+1]
	ld l, a
	ld de, 28*32
	add hl, de
	ld a, [Register1]
	ld d, a
	ld a, [Register2]
	ld e, a
	ld bc, 32*2
	call mem_CopyVRAM
	ld a, $00
	ld [rVRAM_BANK], a
	ret
.animation_speed
	ld a, $00
	ld [AnimationDeltaT], a
	ld a, [Animation]
	inc a
	ld [Animation], a
	cp ANIMATION_NB_FRAME+1
	jr nz, .move
	ld a, $00
	ld [Animation], a
	call ChangeOrientation
	call ResetPostureRight
	ret
.move
	call Move_Bank3
	ld a, [Sprite01+2]
	add a, b
	ld [Sprite01+2], a
	ld a, [Sprite02+2]
	add a, b
	ld [Sprite02+2], a
	ld a, [Sprite03+2]
	add a, b
	ld [Sprite03+2], a
	ld a, [Sprite04+2]
	add a, b
	ld [Sprite04+2], a
	ret

GoRight_Bank3:
	ld a, $01
	ld [Animation], a
	ld a, $01
	ld [MoveDirection], a
	ld a, ANIMATION_TYPE_MOVE
	ld [AnimationType], a
	call ResetPostureRight
	call Move_Bank3
	ret

GoLeft_Bank3:
	ld a, $01
	ld [Animation], a
	ld a, $FF
	ld [MoveDirection], a
	ld a, ANIMATION_TYPE_MOVE
	ld [AnimationType], a
	call ResetPostureLeft
	call Move_Bank3
	ret

Idle_Bank3:
	ld a, [AnimationDeltaTIdle]
	inc a
	ld [AnimationDeltaTIdle], a
	cp ANIMATION_SPEED*4
	jr z, .animation_speed
	ret
.animation_speed
	ld a, $00
	ld [AnimationDeltaTIdle], a
	ld a, [AnimationIdle]
	cp $00
	jr z, .set_idle_2
.set_idle_1
	ld a, $00
	ld [AnimationIdle], a
	call ResetPostureRight
	ret
.set_idle_2
	ld a, $01
	ld [AnimationIdle], a
	call ResetPostureLeft
	ret

; \Param a: the value
ResetSkill:
	ld [CanDigDirt], a
	ld [CanDigStone], a
	ld [CanDigMetal], a
	ld [CanDigAlien], a
	ret

RunGame_Bank3: ; buttons saved in b
	; Animation cannot be stopped
	ld a, [Animation]
	cp $00
	jr z, .end_animate
	call Animate_Bank3
	jp .end_run_game
.end_animate
.go_fall
	ld a, [Sprite01+1]
	srl a
	srl a
	srl a
	srl a
	add a, a
	ld c, a
	ld a, [MapCurrentRowPtr+0]
	ld h, a
	ld a, [MapCurrentRowPtr+1]
	ld l, a
	ld d, $00
	ld e, c
	add hl, de
	ld a, [hl]
	ld [BlockUnder], a
; Collisions
	cp $8C
	jp z, .fall
	cp $88
	jp z, .fall
	cp $8A
	jp z, .fall
	cp $8E
	jp z, .fall
	cp $A0
	jp z, .fall
	cp $A2
	jp z, .fall
	cp $A4
	jp z, .fall
	cp $A6
	jp z, .fall

	ld de, $0000-$003E
	add hl, de
	ld a, [hl]
	cp $8C
	jr z, .can_go_right
	cp $88
	jr z, .can_go_right
	cp $8A
	jr z, .can_go_right
	cp $8E
	jr z, .can_go_right
	cp $A0
	jr z, .can_go_right
	cp $A2
	jr z, .can_go_right
	cp $A4
	jr z, .can_go_right
	cp $A6
	jr z, .can_go_right
	ld a, $00
	ld [CanGoRight], a
.check_left
	ld de, $0000-$0004
	add hl, de
	ld a, [hl]
	cp $8C
	jr z, .can_go_left
	cp $88
	jr z, .can_go_left
	cp $8A
	jr z, .can_go_left
	cp $8E
	jr z, .can_go_left
	cp $A0
	jr z, .can_go_left
	cp $A2
	jr z, .can_go_left
	cp $A4
	jr z, .can_go_left
	cp $A6
	jr z, .can_go_left
	ld a, $00
	ld [CanGoLeft], a
.check_potion
	ld de, $0000+$0002
	add hl, de
	ld a, [hl]
	cp $A0
	jr z, .switch_dig_dirt
	cp $A2
	jr z, .switch_dig_stone
	cp $A4
	jr z, .switch_dig_metal
	cp $A6
	jr z, .switch_dig_alien
	jr .end_fall
.can_go_right
	ld a, $01
	ld [CanGoRight], a
	jr .check_left
.can_go_left
	ld a, $01
	ld [CanGoLeft], a
	jr .check_potion
.switch_dig_dirt
	ld a, $84
	call ResetSkill
	ld a, %00000011
	ld [Sprite01+3], a
	ld [Sprite02+3], a
	ld [Sprite03+3], a
	ld [Sprite04+3], a
	jr .go_inputs
.switch_dig_stone
	ld a, $80
	call ResetSkill
	ld a, %00000010
	ld [Sprite01+3], a
	ld [Sprite02+3], a
	ld [Sprite03+3], a
	ld [Sprite04+3], a
	jr .go_inputs
.switch_dig_metal
	ld a, $86
	call ResetSkill
	ld a, %00000100
	ld [Sprite01+3], a
	ld [Sprite02+3], a
	ld [Sprite03+3], a
	ld [Sprite04+3], a
	ld a, POSTURE_UPSIDEDOWN
	ld [CurrentPosture], a
	ld e, b
	call ResetPostureRight
	ld b, e
	jr .go_inputs
.switch_dig_alien
	ld a, $82
	call ResetSkill
	ld a, %00000001
	ld [Sprite01+3], a
	ld [Sprite02+3], a
	ld [Sprite03+3], a
	ld [Sprite04+3], a
	jr .go_inputs
.fall
	call UpdatePtr
	ld a, $01
	ld [Animation], a
	ld a, ANIMATION_TYPE_FALL
	ld [AnimationType], a
	jp .end_run_game
.end_fall
.go_inputs
	; Input user
	ld a, b
	and PADF_RIGHT
	jr nz, .go_right
	ld a, b
	and PADF_LEFT
	jr nz, .go_left
	ld a, b
	and PADF_A
	jr nz, .go_a
	jr .go_idle
.go_right
	ld a, [CanGoRight]
	cp $01
	jr nz, .end_run_game
	call GoRight_Bank3
	jr .end_run_game
.go_left
	ld a, [CanGoLeft]
	cp $01
	jr nz, .end_run_game
	call GoLeft_Bank3
	jr .end_run_game
.go_a
	ld a, $01
	ld [Animation], a
	ld a, ANIMATION_TYPE_DIG
	ld [AnimationType], a
	ld a, $01
	ld [CannotDig], a
	ld a, [CurrentPosture]
	cp POSTURE_NORMAL
	jr nz, .end_run_game
	ld a, [BlockUnder]
	ld b, a
	ld a, [CanDigDirt]
	sub a, b
	cp $00
	jr z, .go_dig
	ld a, [CanDigStone]
	sub a, b
	cp $00
	jr z, .go_dig
	ld a, [CanDigMetal]
	sub a, b
	cp $00
	jr z, .go_dig
	ld a, [CanDigAlien]
	sub a, b
	cp $00
	jr z, .go_dig
	jr .end_run_game
.go_dig
	ld a, $01
	ld [Animation], a
	ld a, ANIMATION_TYPE_DIG
	ld [AnimationType], a
	ld a, $00
	ld [CannotDig], a
	call UpdatePtr
	jr .end_run_game
.go_idle
	ld a, [MapCurrentRowPtr]
	cp $58
	jr z, .victory
	call Idle_Bank3
.end_run_game
	ret
.victory
	ld a, [CurrentLevel]
	inc a
	ld [CurrentLevel], a
	ret

UpdatePtr:
	ld a, [MapCurrentRowPtr+0]
	ld h, a
	ld a, [MapCurrentRowPtr+1]
	ld l, a
	ld de, $20*$02
	add hl, de
	ld a, h
	ld [MapCurrentRowPtr+0], a
	ld a, l
	ld [MapCurrentRowPtr+1], a
	ld a, [PaletteCurrentRowPtr+0]
	ld h, a
	ld a, [PaletteCurrentRowPtr+1]
	ld l, a
	ld de, $20*$02
	add hl, de
	ld a, h
	ld [PaletteCurrentRowPtr+0], a
	ld a, l
	ld [PaletteCurrentRowPtr+1], a
	ret

; \Param b: the offset
ResetSprite:
	ld a, $00
	add a, b
	ld [Sprite01+2], a
	ld a, $01
	add a, b
	ld [Sprite02+2], a
	ld a, $10
	add a, b
	ld [Sprite03+2], a
	ld a, $11
	add a, b
	ld [Sprite04+2], a
	ret

ResetPostureRight:
	ld a, [CurrentPosture]
	cp POSTURE_NORMAL
	jr z, .go_normal
	cp POSTURE_RIGHT
	jr z, .go_right
	cp POSTURE_LEFT
	jr z, .go_left
	cp POSTURE_UPSIDEDOWN
	jr z, .go_upsidedown
.go_normal
	ld b, $00
	call ResetSprite
	ret
.go_right
	ld b, $20
	call ResetSprite
	ret
.go_left
	ld b, $60
	call ResetSprite
	ret
.go_upsidedown
	ld b, $40
	call ResetSprite
	ret

ResetPostureLeft:
	ld a, [CurrentPosture]
	cp POSTURE_NORMAL
	jr z, .go_normal
	cp POSTURE_RIGHT
	jr z, .go_right
	cp POSTURE_LEFT
	jr z, .go_left
	cp POSTURE_UPSIDEDOWN
	jr z, .go_upsidedown
.go_normal
	ld b, $6E
	call ResetSprite
	ret
.go_right
	ld b, $0E
	call ResetSprite
	ret
.go_left
	ld b, $4E
	call ResetSprite
	ret
.go_upsidedown
	ld b, $2E
	call ResetSprite
	ret

map_Bank3:
	include "assets/output_map_tile.txt"
end_map_Bank3:

palette_Bank3:
	include "assets/output_palette_tile.txt"
end_palette_Bank3:

game_tiles_Bank3:
	include "assets/output_tile.txt"
game_tiles_end_Bank3:
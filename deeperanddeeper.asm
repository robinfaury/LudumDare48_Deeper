include "gbhw.inc"
include "dma.inc"
include "cgbhw.inc"

SECTION "Vblank", ROM0[$0040]
	jp	DMA_ROUTINE

SECTION "LCDC", ROM0[$0048]
	reti

SECTION "Timer", ROM0[$0050]
	reti

SECTION "Serial", ROM0[$0058]
	reti

SECTION "Joypad", ROM0[$0060]
	reti

SECTION "ROM_entry_point", ROM0[$0100]
	nop
	jp	code_begins


SECTION "rom header", ROM0[$0104]
	NINTENDO_LOGO
	DB "   Deeper      " ; Cart name - 15 characters / 15 bytes
	DB $80               ; $143 - GBC support. $80 = both. $C0 = only gbc
	DB 0,0               ; $144 - Licensee code (not important)
	DB 0                 ; $146 - SGB Support indicator
	DB $1B               ; $147 - Cart type / MBC type (0 => no mbc)
	DB $08               ; $148 - ROM Size (0 => 32KB)
	DB $04               ; $149 - RAM Size (0 => 0KB RAM on cartridge)
	DB 1                 ; $14a - Destination code
	DB $33               ; $14b - Old licensee code
	DB 0                 ; $14c - Mask ROM version
	DB 0                 ; $14d - Complement check (important) rgbds-fixed
	DW 0                 ; $14e - Checksum (not important)

include	"ibmpc1.inc"
include "memory.asm"

Sprite01 EQU _RAM
Sprite02 EQU Sprite01+4
Sprite03 EQU Sprite02+4
Sprite04 EQU Sprite03+4
Sprite05 EQU Sprite04+4
Sprite06 EQU Sprite05+4
Sprite07 EQU Sprite06+4
Sprite08 EQU Sprite07+4
Sprite09 EQU Sprite08+4
Sprite10 EQU Sprite09+4
Sprite11 EQU Sprite10+4
Sprite12 EQU Sprite11+4
Sprite13 EQU Sprite12+4
Sprite14 EQU Sprite13+4
Sprite15 EQU Sprite14+4
Sprite16 EQU Sprite15+4
Sprite17 EQU Sprite16+4
Sprite18 EQU Sprite17+4
Sprite19 EQU Sprite18+4
Sprite20 EQU Sprite19+4
Sprite21 EQU Sprite20+4
Sprite22 EQU Sprite21+4
Sprite23 EQU Sprite22+4
Sprite24 EQU Sprite23+4
Sprite25 EQU Sprite24+4
Sprite26 EQU Sprite25+4
Sprite27 EQU Sprite26+4
Sprite28 EQU Sprite27+4
Sprite29 EQU Sprite28+4
Sprite30 EQU Sprite29+4
Sprite31 EQU Sprite30+4
Sprite32 EQU Sprite31+4
Sprite33 EQU Sprite32+4
Sprite34 EQU Sprite33+4
Sprite35 EQU Sprite34+4
Sprite36 EQU Sprite35+4
Sprite37 EQU Sprite36+4
Sprite38 EQU Sprite37+4
Sprite39 EQU Sprite38+4
Sprite40 EQU Sprite39+4
CurrentLevel EQU Sprite40+4
CurrentBank EQU CurrentLevel+1
FreeRAM EQU CurrentBank+1

; \brief multiply hl by 32. reset a
MultiplyBy32:
	ld a, 0
	sla a
	sla l
	adc a, 0
	sla a
	sla l
	adc a, 0
	sla a
	sla l
	adc a, 0
	sla a
	sla l
	adc a, 0
	sla a
	sla l
	adc a, 0
	ld h, a
	ret

; \Brief Bank switch
; \Param a : the bank id
switch_bank:
	ld [$2000], a
	ld [CurrentBank], a
	ret

; \Brief If the current bank is different than the current lvl. Load the new lvl
check_lvl:
	ld a, [CurrentBank]
	ld b, a
	ld a, [CurrentLevel]
	cp b
	jr z, .end_next_lvl
.next_lvl:
	call switch_bank
	cp 2
	jr z, .bank_2
	cp 3
	jr z, .bank_3
	jr .end_next_lvl
.bank_2
	call SetupLvl_Bank2
	jr .end_next_lvl
.bank_3
	call SetupLvl_Bank3
.end_next_lvl
	ret

; \Brief Stop the LCD for VRAM write
LCD_Stop:
	ld a, [rLCDC]
	and LCDCF_ON
	ret z
.vblank
	ldh a, [rLY]
	cp 145
	jr nz, .vblank
.stop
	ld a, [rLCDC]
	xor LCDCF_ON
	ld [rLCDC], a
	ret

; \Brief Restart the LCD
LCD_Start:
	ld a, [rLCDC]
	or LCDCF_ON
	ld [rLCDC], a
	ret

; \Brief Get button press.
PoolEvent:
	ld a, JOYPAD_BUTTONS
	ld [rJOYPAD], a
	ld a, [rJOYPAD]
	ld a, [rJOYPAD]
	cpl
	and	$0f
	swap a
	ld b, a
	ld a, JOYPAD_ARROWS
	ld [rJOYPAD], a
	ld a, [rJOYPAD]
	ld a, [rJOYPAD]
	ld a, [rJOYPAD]
	ld a, [rJOYPAD]
	ld a, [rJOYPAD]
	ld a, [rJOYPAD]
	cpl
	and $0f
	or b
	ld b, a
	ld a, JOYPAD_BUTTONS|JOYPAD_ARROWS
	ld [rJOYPAD], a
	ld a, b
	ret

code_begins:
	di
	ld	SP, $FFFF

	ld hl, BackgroundPalette
	call SetupBackgroundPalette

	ld hl, SpritePalette
	call SetupSpritePalette

	dma_Copy2HRAM

	
	ld a, $00
	ld hl, _RAM
	ld bc, $28*$04+$01+$01
	call mem_Set

	ld a, $02
	ld [CurrentLevel], a
	call check_lvl

	ld a, %00011011
	ld [rBGP], a
	ld [rOBP0], a
	ld [rOBP1], a

	ld a, IEF_VBLANK
	ld [rIE], a
	ei
	ld a, [rLCDC]
	or LCDCF_OBJON
	or LCDCF_OBJ8
	ld [rLCDC], a

.loop
	halt
	nop
	call check_lvl
	call PoolEvent
	ld b, a
	ld a, [CurrentLevel]
	cp 2
	jr z, .bank_2
	cp 3
	jr z, .bank_3
	jr .bank_end
.bank_2
	call RunGame_Bank2
	jr .bank_end
.bank_3
	call RunGame_Bank3
.bank_end
	jp	.loop


CreateColor: MACRO
	DW ((\3>>3)<<10)+((\2>>3)<<5)+(\1>>3)
	ENDM
BackgroundPalette:
	; %10000000
	CreateColor 7, 5, 5
	CreateColor 20, 8, 5
	CreateColor 32, 25, 25
	CreateColor 0, 0, 0
	; %10111000
	CreateColor 15, 12, 13
	CreateColor 45, 18, 12
	CreateColor 72, 58, 57
	CreateColor 0, 0, 0
	; %10110000
	CreateColor 0, 0, 0
	CreateColor 25, 5, 5
	CreateColor 31, 21, 10
	CreateColor 35, 35, 40
	; %10101000
	CreateColor 0, 0, 0
	CreateColor 136, 26, 30
	CreateColor 172, 116, 56
	CreateColor 193, 188, 113
	; %10100000
	CreateColor 19, 5, 17
	CreateColor 10, 3, 15
	CreateColor 27, 10, 9
	CreateColor 27, 23, 7
	; %10011000
	CreateColor 52, 0, 54
	CreateColor 58, 17, 141
	CreateColor 204, 184, 87
	CreateColor 206, 96, 51
	; %10010000
	CreateColor 9, 9, 9
	CreateColor 33, 30, 29
	CreateColor 0, 0, 0
	CreateColor 0, 0, 0
	; %10001000
	CreateColor 51, 50, 51
	CreateColor 184, 164, 163
	CreateColor 0, 0, 0
	CreateColor 0, 0, 0
SetupBackgroundPalette:
	ld a, %10000000
	ldh [rBCPS], a
	ld bc, $4000|(rBCPD&$00FF)
.loop1
	di
.loop2
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, .loop2
	ld a, [hl+]
	ld [$FF00+c], a
	ei
	dec b
	jr nz, .loop1
	ret

SpritePalette:
	; %10000000 ; base
	CreateColor 0, 0, 0
	CreateColor 25, 25, 25
	CreateColor 70, 32, 24
	CreateColor 172, 172, 172
	; %10111000 ; alien
	CreateColor 0, 0, 0
	CreateColor 206, 96, 51
	CreateColor 52, 0, 54
	CreateColor 194, 189, 114
	; %10110000 ; stone
	CreateColor 0, 0, 0
	CreateColor 0, 0, 0
	CreateColor 137, 26, 31
	CreateColor 172, 116, 56
	; %10101000 ; dirt
	CreateColor 0, 0, 0
	CreateColor 15, 12, 13
	CreateColor 45, 18, 12
	CreateColor 72, 58,57
	; %10100000 ; metal
	CreateColor 0, 0, 0
	CreateColor 51, 51, 51
	CreateColor 184, 164, 163
	CreateColor 255, 255, 255
	; %10011000
	CreateColor 0, 0, 0
	CreateColor 255, 255, 255
	CreateColor 255, 255, 255
	CreateColor 255, 255, 255
	; %10010000
	CreateColor 0, 0, 0
	CreateColor 0, 0, 0
	CreateColor 0, 0, 0
	CreateColor 0, 0, 0
	; %10001000
	CreateColor 255, 255, 255
	CreateColor 255, 255, 255
	CreateColor 255, 255, 255
	CreateColor 255, 255, 255
SetupSpritePalette:
	ld a, %10000000
	ldh [rOCPS], a
	ld bc, $4000|(rOCPD&$00FF)
.loop1
	di
.loop2
	ldh a, [rSTAT]
	and STATF_BUSY
	jr nz, .loop2
	ld a, [hl+]
	ld [$FF00+c], a
	ei
	dec b
	jr nz, .loop1
	ret

include "bank2.asm"
include "bank3.asm"
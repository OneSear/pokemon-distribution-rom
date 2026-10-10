CopyDebugName:
	ld bc, NAME_LENGTH
	jp CopyData

PrepareTitleScreen::
	; These debug names are already copied later in PrepareOakSpeech.
	; Removing the unused copies below has no apparent impact.
	; CopyDebugName can also be safely deleted afterwards.
	ld hl, DebugNewGamePlayerName
	ld de, wPlayerName
	call CopyDebugName
	ld hl, DebugNewGameRivalName
	ld de, wRivalName
	call CopyDebugName
	xor a
	ldh [hWY], a
	ld [wLetterPrintingDelayFlags], a
	ld hl, wStatusFlags6
	ld [hli], a
	ASSERT wStatusFlags6 + 1 == wStatusFlags7
	ld [hli], a
	ASSERT wStatusFlags7 + 1 == wElite4Flags
	ld [hl], a
	ld a, BANK(Music_TitleScreen)
	ld [wAudioROMBank], a
	ld [wAudioSavedROMBank], a

DisplayTitleScreen:
	call GBPalWhiteOut
	ld a, $1
	ldh [hAutoBGTransferEnabled], a
	xor a
	ldh [hTileAnimations], a
	ldh [hSCX], a
	ld a, $40
	ldh [hSCY], a
	ld a, $90
	ldh [hWY], a
	call ClearScreen
	call DisableLCD
	call LoadFontTilePatterns
	; Distribution ROM: the Nintendo and GAME FREAK strips used to be loaded
	; here, into vTitleLogo2 tiles 16-30 (tile ids $41-$4F). Nothing referenced
	; them but the copyright row at the bottom of the screen, and that row is
	; gone, so nothing is loaded there at all now.
	ld hl, PokemonLogoGraphics
	ld de, vTitleLogo
	ld bc, $60 tiles
	ld a, BANK(PokemonLogoGraphics)
	call FarCopyData2          ; first chunk
	ld hl, PokemonLogoGraphics tile $60
	ld de, vTitleLogo2
	ld bc, $10 tiles
	ld a, BANK(PokemonLogoGraphics)
	call FarCopyData2          ; second chunk
	ld hl, DistributionBanner
	ld de, vChars2 tile $60
	ld bc, DistributionBannerEnd - DistributionBanner
	ld a, BANK(DistributionBanner)
	call FarCopyDataDouble
	call ClearBothBGMaps

; place tiles for pokemon logo (except for the last row)
	hlcoord 2, 1
	ld a, $80
	ld de, SCREEN_WIDTH
	ld c, 6
.pokemonLogoTileLoop
	ld b, $10
	push hl
.pokemonLogoTileRowLoop ; place tiles for one row
	ld [hli], a
	inc a
	dec b
	jr nz, .pokemonLogoTileRowLoop
	pop hl
	add hl, de
	dec c
	jr nz, .pokemonLogoTileLoop

; place tiles for the last row of the pokemon logo
	hlcoord 2, 7
	ld a, $31
	ld b, $10
.pokemonLogoLastTileRowLoop
	ld [hli], a
	inc a
	dec b
	jr nz, .pokemonLogoLastTileRowLoop

	call DrawPlayerCharacter

; put a pokeball in the player's hand
	ld hl, wShadowOAMSprite10
	ld a, $74
	ld [hl], a

	; The copyright row used to be placed here, at row 17. ClearScreen has
	; already blanked the tilemap, so leaving it out leaves the row empty.
	call PrintGameVersionOnTitleScreen ; bake "DISTRIBUTION ROM" into the title
	call SaveScreenTilesToBuffer2
	call LoadScreenTilesFromBuffer2
	call EnableLCD

	; Distribution ROM: the title mon is pinned to Mew instead of the version's
	; starter, and the random cycling below is gone, so this is the only mon the
	; title screen ever shows. Its cry is what plays when the operator presses
	; Start, since .finishedWaiting reads wTitleMonSpecies.
	ld a, MEW
	ld [wTitleMonSpecies], a
	call LoadTitleMonSprite

	ld a, HIGH(vBGMap0 + $300)
	call TitleScreenCopyTileMapToVRAM
	call SaveScreenTilesToBuffer1
	ld a, $40
	ldh [hWY], a
	call LoadScreenTilesFromBuffer2
	ld a, HIGH(vBGMap0)
	call TitleScreenCopyTileMapToVRAM
	ld b, SET_PAL_TITLE_SCREEN
	call RunPaletteCommand
	call GBPalNormal
	ld a, %11100100
	ldh [rOBP0], a

; make pokemon logo bounce up and down
	ld bc, hSCY ; background scroll Y
	ld hl, .TitleScreenPokemonLogoYScrolls
.bouncePokemonLogoLoop
	ld a, [hli]
	and a
	jr z, .finishedBouncingPokemonLogo
	ld d, a
	cp -3
	jr nz, .skipPlayingSound
	ld a, SFX_INTRO_CRASH
	call PlaySound
.skipPlayingSound
	ld a, [hli]
	ld e, a
	call .ScrollTitleScreenPokemonLogo
	jr .bouncePokemonLogoLoop

.TitleScreenPokemonLogoYScrolls:
; Controls the bouncing effect of the Pokemon logo on the title screen
	db -4,16  ; y scroll amount, number of times to scroll
	db 3,4
	db -3,4
	db 2,2
	db -2,2
	db 1,2
	db -1,2
	db 0      ; terminate list with 0

.ScrollTitleScreenPokemonLogo:
; Scrolls the Pokemon logo on the title screen to create the bouncing effect
; Scrolls d pixels e times
	call DelayFrame
	ld a, [bc] ; background scroll Y
	add d
	ld [bc], a
	dec e
	jr nz, .ScrollTitleScreenPokemonLogo
	ret

.finishedBouncingPokemonLogo
	call LoadScreenTilesFromBuffer1
	ld c, 36
	call DelayFrames
	ld a, SFX_INTRO_WHOOSH
	call PlaySound

; scroll game version in from the right
	call PrintGameVersionOnTitleScreen
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	ld d, 144
.scrollTitleScreenGameVersionLoop
	ld h, d
	ld l, 64
	call ScrollTitleScreenGameVersion
	ld h, 0
	ld l, 80
	call ScrollTitleScreenGameVersion
	ld a, d
	add 4
	ld d, a
	and a
	jr nz, .scrollTitleScreenGameVersionLoop

	ld a, HIGH(vBGMap1)
	call TitleScreenCopyTileMapToVRAM
	call LoadScreenTilesFromBuffer2
	call PrintGameVersionOnTitleScreen
	call Delay3
	call WaitForSoundToFinish
	ld a, MUSIC_TITLE_SCREEN
	ld [wNewSoundID], a
	call PlaySound
	xor a
	ld [wUnusedFlag], a

; The mon is pinned, so there is nothing to scroll out and swap: just hold the
; screen until the operator presses a button. hWY is still SCREEN_HEIGHT_PX from
; the version scroll above, which is the state the mon is already drawn in, and
; .finishedWaiting resets it itself.
.awaitUserInterruptionLoop
	ld c, 200
	call CheckForUserInterruption
	jr nc, .awaitUserInterruptionLoop

.finishedWaiting
	ld a, [wTitleMonSpecies]
	call PlayCry
	call WaitForSoundToFinish
	call GBPalWhiteOutWithDelay3
	call ClearSprites
	xor a
	ldh [hWY], a
	inc a
	ldh [hAutoBGTransferEnabled], a
	call ClearScreen
	ld a, HIGH(vBGMap0)
	call TitleScreenCopyTileMapToVRAM
	ld a, HIGH(vBGMap1)
	call TitleScreenCopyTileMapToVRAM
	call Delay3
	call LoadGBPal
	ldh a, [hJoyHeld]
	ld b, a
	and PAD_UP | PAD_SELECT | PAD_B
	cp PAD_UP | PAD_SELECT | PAD_B
	jp z, .doClearSaveDialogue
IF DEF(_DEBUG)
	ld a, b
	bit B_PAD_SELECT, a
	jp nz, DebugMenu
ENDC
	jpfar DistributionMain ; Distribution ROM: Start goes to the gift menu

.doClearSaveDialogue
	farjp DoClearSaveDialogue

TitleScreenPickNewMon:
	ld a, HIGH(vBGMap0)
	call TitleScreenCopyTileMapToVRAM

.loop
; Keep looping until a mon different from the current one is picked.
	call Random
	and $f
	ld c, a
	ld b, 0
	ld hl, TitleMons
	add hl, bc
	ld a, [hl]
	ld hl, wTitleMonSpecies

; Can't be the same as before.
	cp [hl]
	jr z, .loop

	ld [hl], a
	call LoadTitleMonSprite

	ld a, $90
	ldh [hWY], a
	ld d, 1 ; scroll out
	farcall TitleScroll
	ret

TitleScreenScrollInMon:
	ld d, 0 ; scroll in
	farcall TitleScroll
	xor a
	ldh [hWY], a
	ret

ScrollTitleScreenGameVersion:
.wait
	ldh a, [rLY]
	cp l
	jr nz, .wait

	ld a, h
	ldh [rSCX], a

.wait2
	ldh a, [rLY]
	cp h
	jr z, .wait2
	ret

DrawPlayerCharacter:
	ld hl, PlayerCharacterTitleGraphics
	ld de, vSprites
	ld bc, PlayerCharacterTitleGraphicsEnd - PlayerCharacterTitleGraphics
	ld a, BANK(PlayerCharacterTitleGraphics)
	call FarCopyData2
	call ClearSprites
	xor a
	ld [wPlayerCharacterOAMTile], a
	ld hl, wShadowOAM
	lb de, $60, $5a
	ld b, 7
.loop
	push de
	ld c, 5
.innerLoop
	ld a, d
	ld [hli], a ; Y
	ld a, e
	ld [hli], a ; X
	add 8
	ld e, a
	ld a, [wPlayerCharacterOAMTile]
	ld [hli], a ; tile
	inc a
	ld [wPlayerCharacterOAMTile], a
	inc hl
	dec c
	jr nz, .innerLoop
	pop de
	ld a, 8
	add d
	ld d, a
	dec b
	jr nz, .loop
	ret

ClearBothBGMaps:
	ld hl, vBGMap0
	ld bc, $400 * 2
	ld a, " "
	jp FillMemory

LoadTitleMonSprite:
	ld [wCurPartySpecies], a
	ld [wCurSpecies], a
	hlcoord 5, 10
	call GetMonHeader
	jp LoadFrontSpriteByMonIndex

TitleScreenCopyTileMapToVRAM:
	ldh [hAutoBGTransferDest + 1], a
	jp Delay3

LoadCopyrightAndTextBoxTiles:
	xor a
	ldh [hWY], a
	call ClearScreen
	call LoadTextBoxTilePatterns

LoadCopyrightTiles:
	ld de, NintendoCopyrightLogoGraphics
	ld hl, vChars2 tile $60
	lb bc, BANK(NintendoCopyrightLogoGraphics), (GameFreakLogoGraphicsEnd - NintendoCopyrightLogoGraphics) / $0f
	call CopyVideoData
	hlcoord 2, 7
	ld de, CopyrightTextString
	jp PlaceString

CopyrightTextString:
	db   $60,$61,$62,$63,$61,$62,$7C,$7F,$65,$66,$67,$68,$69,$6A             ; ©1995-1999 Nintendo
	next $60,$61,$62,$63,$61,$62,$7C,$7F,$6B,$6C,$6D,$6E,$6F,$70,$71,$72     ; ©1995-1999 Creatures inc.
	next $60,$61,$62,$63,$61,$62,$7C,$7F,$73,$74,$75,$76,$77,$78,$79,$7A,$7B ; ©1995-1999 GAME FREAK inc.
	db   "@"

INCLUDE "data/pokemon/title_mons.asm"

; prints version text (red, blue)
PrintGameVersionOnTitleScreen:
	hlcoord 2, 8
	ld de, VersionOnTitleScreenText
	jp PlaceString

VersionOnTitleScreenText:
	db $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6a,$6b,$6c,$6d,$6e,$6f,"@"

DebugNewGamePlayerName:
	db "NINTEN@"

DebugNewGameRivalName:
	db "SONY@"

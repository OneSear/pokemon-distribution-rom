; Pokémon distribution ROM front-end.
; Boots into a menu to pick a gift Pokémon and level, shows its sprite,
; builds a one-mon party, and hands off to the Cable Club so a linked
; real cartridge can receive the mon through a normal Trade Center trade.

DEF DIST_NUM_MONS      EQU 151 ; the full Pokédex, so the list scrolls
DEF DIST_VISIBLE_MONS  EQU 10 ; rows of the list shown at once
DEF DIST_LEVEL_DEFAULT EQU 50
DEF DIST_SPRITE_X      EQU 13
DEF DIST_SPRITE_Y      EQU 2
DEF DIST_LIST_Y        EQU 2  ; screen row of the first visible list entry
DEF DIST_TYPE_X        EQU 13 ; types, stacked under the Pokédex number
DEF DIST_TYPE_Y        EQU 10
DEF DIST_LEVEL_Y       EQU 13 ; screen row of the "NIVEAU:" line
DEF DIST_HINT_Y        EQU 16 ; first of the two control-hint rows
DEF DIST_SPRITE_DELAY  EQU 8  ; idle frames before the preview catches up
DEF DIST_NUM_SETTINGS  EQU 1  ; rows on the settings screen
DEF DIST_SET_Y         EQU 3  ; screen row of the first settings row
DEF DIST_DEXNO_X       EQU 13 ; Pokédex number, captioned under the sprite,
                              ; left-aligned with the type rows beneath it
DEF DIST_DEXNO_Y       EQU 9
DEF DIST_JUMP_Y        EQU 14 ; interior row of the "jump to a number" prompt

; Internal species indices, in National Pokédex order (#001 Bulbizarre to
; #151 Mew). The internal index is not the Pokédex number and the two
; orders are unrelated, so always go through the constants. Every French
; name is padded to 10 characters, which is exactly the width left beside
; the cursor column.
DistributionSpeciesList:
	db BULBASAUR   ;   1  BULBIZARRE
	db IVYSAUR     ;   2  HERBIZARRE
	db VENUSAUR    ;   3  FLORIZARRE
	db CHARMANDER  ;   4  SALAMECHE
	db CHARMELEON  ;   5  REPTINCEL
	db CHARIZARD   ;   6  DRACAUFEU
	db SQUIRTLE    ;   7  CARAPUCE
	db WARTORTLE   ;   8  CARABAFFE
	db BLASTOISE   ;   9  TORTANK
	db CATERPIE    ;  10  CHENIPAN
	db METAPOD     ;  11  CHRYSACIER
	db BUTTERFREE  ;  12  PAPILUSION
	db WEEDLE      ;  13  ASPICOT
	db KAKUNA      ;  14  COCONFORT
	db BEEDRILL    ;  15  DARDARGNAN
	db PIDGEY      ;  16  ROUCOOL
	db PIDGEOTTO   ;  17  ROUCOUPS
	db PIDGEOT     ;  18  ROUCARNAGE
	db RATTATA     ;  19
	db RATICATE    ;  20  RATTATAC
	db SPEAROW     ;  21  PIAFABEC
	db FEAROW      ;  22  RAPASDEPIC
	db EKANS       ;  23  ABO
	db ARBOK       ;  24
	db PIKACHU     ;  25
	db RAICHU      ;  26
	db SANDSHREW   ;  27  SABELETTE
	db SANDSLASH   ;  28  SABLAIREAU
	db NIDORAN_F   ;  29  NIDORAN♀
	db NIDORINA    ;  30
	db NIDOQUEEN   ;  31
	db NIDORAN_M   ;  32  NIDORAN♂
	db NIDORINO    ;  33
	db NIDOKING    ;  34
	db CLEFAIRY    ;  35  MELOFEE
	db CLEFABLE    ;  36  MELODELFE
	db VULPIX      ;  37  GOUPIX
	db NINETALES   ;  38  FEUNARD
	db JIGGLYPUFF  ;  39  RONDOUDOU
	db WIGGLYTUFF  ;  40  GRODOUDOU
	db ZUBAT       ;  41  NOSFERAPTI
	db GOLBAT      ;  42  NOSFERALTO
	db ODDISH      ;  43  MYSTHERBE
	db GLOOM       ;  44  ORTIDE
	db VILEPLUME   ;  45  RAFFLESIA
	db PARAS       ;  46
	db PARASECT    ;  47
	db VENONAT     ;  48  MIMITOSS
	db VENOMOTH    ;  49  AEROMITE
	db DIGLETT     ;  50  TAUPIQUEUR
	db DUGTRIO     ;  51  TRIOPIKEUR
	db MEOWTH      ;  52  MIAOUSS
	db PERSIAN     ;  53
	db PSYDUCK     ;  54  PSYKOKWAK
	db GOLDUCK     ;  55  AKWAKWAK
	db MANKEY      ;  56  FEROSINGE
	db PRIMEAPE    ;  57  COLOSSINGE
	db GROWLITHE   ;  58  CANINOS
	db ARCANINE    ;  59  ARCANIN
	db POLIWAG     ;  60  PTITARD
	db POLIWHIRL   ;  61  TETARTE
	db POLIWRATH   ;  62  TARTARD
	db ABRA        ;  63
	db KADABRA     ;  64
	db ALAKAZAM    ;  65
	db MACHOP      ;  66  MACHOC
	db MACHOKE     ;  67  MACHOPEUR
	db MACHAMP     ;  68  MACKOGNEUR
	db BELLSPROUT  ;  69  CHETIFLOR
	db WEEPINBELL  ;  70  BOUSTIFLOR
	db VICTREEBEL  ;  71  EMPIFLOR
	db TENTACOOL   ;  72
	db TENTACRUEL  ;  73
	db GEODUDE     ;  74  RACAILLOU
	db GRAVELER    ;  75  GRAVALANCH
	db GOLEM       ;  76  GROLEM
	db PONYTA      ;  77
	db RAPIDASH    ;  78  GALOPA
	db SLOWPOKE    ;  79  RAMOLOSS
	db SLOWBRO     ;  80  FLAGADOSS
	db MAGNEMITE   ;  81  MAGNETI
	db MAGNETON    ;  82
	db FARFETCHD   ;  83  CANARTICHO
	db DODUO       ;  84
	db DODRIO      ;  85
	db SEEL        ;  86  OTARIA
	db DEWGONG     ;  87  LAMANTINE
	db GRIMER      ;  88  TADMORV
	db MUK         ;  89  GROTADMORV
	db SHELLDER    ;  90  KOKIYAS
	db CLOYSTER    ;  91  CRUSTABRI
	db GASTLY      ;  92  FANTOMINUS
	db HAUNTER     ;  93  SPECTRUM
	db GENGAR      ;  94  ECTOPLASMA
	db ONIX        ;  95
	db DROWZEE     ;  96  SOPORIFIK
	db HYPNO       ;  97  HYPNOMADE
	db KRABBY      ;  98
	db KINGLER     ;  99  KRABBOSS
	db VOLTORB     ; 100  VOLTORBE
	db ELECTRODE   ; 101
	db EXEGGCUTE   ; 102  NOEUNOEUF
	db EXEGGUTOR   ; 103  NOADKOKO
	db CUBONE      ; 104  OSSELAIT
	db MAROWAK     ; 105  OSSATUEUR
	db HITMONLEE   ; 106  KICKLEE
	db HITMONCHAN  ; 107  TYGNON
	db LICKITUNG   ; 108  EXCELANGUE
	db KOFFING     ; 109  SMOGO
	db WEEZING     ; 110  SMOGOGO
	db RHYHORN     ; 111  RHINOCORNE
	db RHYDON      ; 112  RHINOFEROS
	db CHANSEY     ; 113  LEVEINARD
	db TANGELA     ; 114  SAQUEDENEU
	db KANGASKHAN  ; 115  KANGOUREX
	db HORSEA      ; 116  HYPOTREMPE
	db SEADRA      ; 117  HYPOCEAN
	db GOLDEEN     ; 118  POISSIRENE
	db SEAKING     ; 119  POISSOROY
	db STARYU      ; 120  STARI
	db STARMIE     ; 121  STAROSS
	db MR_MIME     ; 122  M.MIME
	db SCYTHER     ; 123  INSECATEUR
	db JYNX        ; 124  LIPPOUTOU
	db ELECTABUZZ  ; 125  ELEKTEK
	db MAGMAR      ; 126
	db PINSIR      ; 127  SCARABRUTE
	db TAUROS      ; 128
	db MAGIKARP    ; 129  MAGICARPE
	db GYARADOS    ; 130  LEVIATOR
	db LAPRAS      ; 131  LOKHLASS
	db DITTO       ; 132  METAMORPH
	db EEVEE       ; 133  EVOLI
	db VAPOREON    ; 134  AQUALI
	db JOLTEON     ; 135  VOLTALI
	db FLAREON     ; 136  PYROLI
	db PORYGON     ; 137
	db OMANYTE     ; 138  AMONITA
	db OMASTAR     ; 139  AMONISTAR
	db KABUTO      ; 140
	db KABUTOPS    ; 141
	db AERODACTYL  ; 142  PTERA
	db SNORLAX     ; 143  RONFLEX
	db ARTICUNO    ; 144  ARTIKODIN
	db ZAPDOS      ; 145  ELECTHOR
	db MOLTRES     ; 146  SULFURA
	db DRATINI     ; 147  MINIDRACO
	db DRAGONAIR   ; 148  DRACO
	db DRAGONITE   ; 149  DRACOLOSSE
	db MEWTWO      ; 150
	db MEW         ; 151

; Cold entry, from the title screen. Seeds the settings and falls through.
; DistributionReturnToMenu deliberately re-enters below this, at
; DistributionMenu, so an operator's OT name survives between gifts -- that is
; the entire reason the Start+Select return exists instead of a plain reset.
DistributionMain::
	ld hl, DistDefaultName ; seed the editable OT name
	ld de, wDistPlayerName
	ld bc, NAME_LENGTH
	call CopyData
	ld a, DIST_LEVEL_DEFAULT ; and the level, which is sticky between gifts:
	ld [wDistLevel], a       ; a whole event usually hands out one level

; Warm entry: everything below is per-gift state and is reset every time.
DistributionMenu::
	call ClearScreen
	; On a Super Game Boy the default palette command decides the colours, and
	; it is SetPal_GameFreakIntro that normally seeds it with SET_PAL_GENERIC.
	; We skip PlayIntro, so it would still be $00 (SET_PAL_BATTLE_BLACK), whose
	; PalPacket_Black maps colours 1-3 all to near-black: text survives (it only
	; uses colours 0 and 3) but the mon sprites turn into silhouettes. Harmless
	; on a plain DMG, where RunPaletteCommand returns early on wOnSGB = 0.
	ld a, SET_PAL_GENERIC
	ld [wDefaultPaletteCommand], a
	call RunDefaultPaletteCommand
	call LoadTextBoxTilePatterns
	call LoadFontTilePatterns
	farcall InitOptions
	xor a
	ld [wDistMonCursor], a
	ld [wDistScrollTop], a
	ld [wDistSetCursor], a
.mainLoop
	call DistDrawSelectScreen
	call DistChooseMon    ; returns when the player presses A
	call DistChooseLevel  ; returns carry set if the player backed out
	jr c, .mainLoop
	call DistributionBuildParty
	call DistReadyScreen
	jp DistributionEnterTrade ; warp into the Pokémon Center (does not return)

; --- Draw the static selection screen ------------------------------------

DistDrawSelectScreen:
	xor a
	ldh [hAutoBGTransferEnabled], a ; pause transfer during bulk draw
	call ClearScreen
	hlcoord 4, 0
	ld de, DistTitleStr
	call PlaceString
	hlcoord 0, 1
	ld b, DIST_VISIBLE_MONS
	ld c, 11
	call TextBoxBorder
	; the names themselves are drawn by DistDrawList, which redraws them
	; whenever the window scrolls
	hlcoord 1, DIST_LEVEL_Y
	ld de, DistNivStr
	call PlaceString
	; row 15 is deliberately left blank: it separates the mon's details from
	; the control hints, and the OT is already on the settings screen and in
	; the pre-trade recap, which is where it actually matters
	; Two hint rows, not four: "up/down moves" and "left/right pages" are
	; self-evident, and the rows they used to occupy are worth more as list
	; entries. Ten visible rows means 16 pages instead of 22.
	hlcoord 1, DIST_HINT_Y
	ld de, DistHintPickA ; no B here: B does nothing while choosing the mon
	call PlaceString
	hlcoord 1, DIST_HINT_Y + 1
	ld de, DistHintSelect
	call PlaceString
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ld c, 6
	call DelayFrames
	ret

; --- Choose which mon (live sprite preview) ------------------------------

; Loading a pic blocks for ~13 frames (blanking delay plus the VBlank tile
; copy), and the joypad is not read during that time, so a second press while
; it runs is simply lost — holding or tapping a direction felt like it was
; ignoring inputs. The cursor and list now redraw immediately on every press
; and only the preview is deferred: each move restarts a short idle countdown,
; and the pic loads once the player stops moving.
DistChooseMon:
	call DistScrollToCursor
	call DistDrawList
	call DistDrawSprite
	call DistDrawLevel
	xor a
	ld [wDistSpriteDelay], a
	; Let a held direction repeat, the way the Pokédex list does: hJoy7 makes
	; JoypadLowSensitivity report held buttons, after a 30 frame delay and then
	; every 5 frames. hJoy6 stays 0 so A and B do not repeat with it.
	ldh [hJoy6], a
	ld a, 1
	ldh [hJoy7], a
.loop
	call DelayFrame
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	ld b, a
	and a
	jr nz, .haveInput
	; idle frame: run down the countdown and refresh the preview when it ends
	ld a, [wDistSpriteDelay]
	and a
	jr z, .loop
	dec a
	ld [wDistSpriteDelay], a
	jr nz, .loop
	call DistDrawSprite
	jr .loop
.haveInput
	bit B_PAD_A, b
	jr nz, .chosen
	; Start and Select each open something, but held together they are the
	; return-to-menu combo, so neither fires while the other is down
	bit B_PAD_START, b
	jr z, .checkSelect
	ldh a, [hJoyHeld]
	and PAD_SELECT
	jr z, .jump
.checkSelect
	bit B_PAD_SELECT, b
	jr z, .checkUp
	ldh a, [hJoyHeld]
	and PAD_START
	jr z, .settings
.checkUp
	bit B_PAD_UP, b
	jr nz, .up
	bit B_PAD_DOWN, b
	jr nz, .down
	bit B_PAD_LEFT, b
	jr nz, .pageUp
	bit B_PAD_RIGHT, b
	jr nz, .pageDown
	jr .loop
.up
	ld a, [wDistMonCursor]
	and a
	jr nz, .decCursor
	ld a, DIST_NUM_MONS ; wrap to bottom
.decCursor
	dec a
	ld [wDistMonCursor], a
	jr .redraw
.down
	ld a, [wDistMonCursor]
	inc a
	cp DIST_NUM_MONS
	jr c, .storeCursor
	xor a ; wrap to top
	jr .storeCursor
; Left/right jump a whole screenful. These clamp rather than wrap, so holding a
; direction walks to the end of the list and stops there, which is easier to aim
; with than wrapping when the list is this long.
.pageUp
	ld a, [wDistMonCursor]
	sub DIST_VISIBLE_MONS
	jr nc, .storeCursor ; no borrow: still in range
	xor a               ; clamp to the first entry
	jr .storeCursor
.pageDown
	ld a, [wDistMonCursor]
	add DIST_VISIBLE_MONS
	cp DIST_NUM_MONS
	jr c, .storeCursor
	ld a, DIST_NUM_MONS - 1 ; clamp to the last entry
.storeCursor
	ld [wDistMonCursor], a
.redraw
	call DistScrollToCursor
	call DistDrawList ; cheap, so the cursor tracks the player with no lag
	ld a, DIST_SPRITE_DELAY
	ld [wDistSpriteDelay], a
	jp .loop ; out of jr range since the Start/Select handling grew
.jump
	call DistJumpToNumber
	call DistDrawSelectScreen ; the prompt box and its hints covered ours
	jp DistChooseMon
.settings
	; DistSettings owns the whole screen, so rebuild ours before re-entering.
	; This is a jp, not a call: it reuses the current invocation's stack frame,
	; so opening the settings screen repeatedly cannot grow the stack.
	call DistSettings
	call DistDrawSelectScreen
	jp DistChooseMon
.chosen
	; audible confirmation of the pick. Deliberately not PlayCry, which ends in
	; WaitForSoundToFinish and would stall the hand-off to the level screen.
	call DistCurrentSpecies
	call GetCryData
	call PlaySound
	; the level screen keeps showing this preview, so make sure a deferred load
	; has happened before leaving
	ld a, [wDistSpriteDelay]
	and a
	ret z
	xor a
	ld [wDistSpriteDelay], a
	jp DistDrawSprite

; --- Choose level --------------------------------------------------------

DistChooseLevel:
	; Both replacement strings are padded to at least the width of what they
	; overwrite, so no tail of the mon-screen hints survives.
	hlcoord 1, DIST_HINT_Y
	ld de, DistHintLevel
	call PlaceString
	hlcoord 1, DIST_HINT_Y + 1
	ld de, DistHintOkB
	call PlaceString
	xor a ; hold a direction to ramp the level, same repeat as the mon list
	ldh [hJoy6], a
	ld a, 1
	ldh [hJoy7], a
.loop
	call DistDrawLevel
.input
	call DelayFrame
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	ld b, a
	and a
	jr z, .input
	bit B_PAD_A, b
	jr nz, .confirm
	bit B_PAD_B, b
	jr nz, .back
	bit B_PAD_UP, b
	jr nz, .up
	bit B_PAD_DOWN, b
	jr nz, .down
	bit B_PAD_LEFT, b
	jr nz, .left
	bit B_PAD_RIGHT, b
	jr nz, .right
	jr .input
.up
	ld a, [wDistLevel]
	cp 100
	jr nc, .loop
	inc a
	ld [wDistLevel], a
	jr .loop
.down
	ld a, [wDistLevel]
	cp 2
	jr c, .loop
	dec a
	ld [wDistLevel], a
	jr .loop
.right
	ld a, [wDistLevel]
	add 10
	cp 100
	jr c, .rstore
	ld a, 100
.rstore
	ld [wDistLevel], a
	jr .loop
.left
	ld a, [wDistLevel]
	sub 10
	jr c, .clampLow
	and a
	jr nz, .lstore
.clampLow
	ld a, 1
.lstore
	ld [wDistLevel], a
	jr .loop
.confirm
	and a ; clear carry: proceed
	ret
.back
	scf ; set carry: return to mon select
	ret

; --- Drawing helpers -----------------------------------------------------

; Slide the visible window so the highlighted entry is inside it. The list is
; longer than the box, so only DIST_VISIBLE_MONS entries show at a time.
DistScrollToCursor:
	ld a, [wDistMonCursor]
	ld b, a
	ld a, [wDistScrollTop]
	cp b
	jr z, .checkBottom
	jr c, .checkBottom
	ld a, b ; cursor sits above the window: pull the window up to it
	ld [wDistScrollTop], a
	ret
.checkBottom
	ld a, [wDistScrollTop]
	add DIST_VISIBLE_MONS - 1 ; index of the last visible row
	cp b
	ret nc                    ; cursor already visible
	ld a, b                   ; cursor sits below: make it the last row
	sub DIST_VISIBLE_MONS - 1
	ld [wDistScrollTop], a
	ret

; Draw the visible slice of the list: cursor in column 1, name in columns 2-11.
DistDrawList:
	hlcoord 1, DIST_LIST_Y
	ld a, [wDistScrollTop]
	ld b, a ; absolute index of the row being drawn
	ld c, DIST_VISIBLE_MONS
.rowLoop
	push bc
	push hl
	; Blank the row first. The names are padded to 10 characters with the
	; string terminator, so PlaceString stops early on the shorter ones and
	; scrolling would otherwise leave the tail of a longer name behind
	; (SULFURA over FLORIZARRE printing as "SULFURARRE").
	ld a, " "
	ld d, 11
.clearLoop
	ld [hli], a
	dec d
	jr nz, .clearLoop
	pop hl
	push hl
	; cursor marker, in the column to the left of the name
	ld a, [wDistMonCursor]
	cp b
	ld a, " "
	jr nz, .noCursor
	ld a, "▶"
.noCursor
	ld [hli], a ; hl now points at the name column
	; this row's species name
	push hl
	ld hl, DistributionSpeciesList
	ld d, 0
	ld e, b
	add hl, de
	ld a, [hl]
	ld [wNamedObjectIndex], a
	call GetMonName ; de = wNameBuffer
	pop hl
	call PlaceString
	pop hl
	pop bc
	ld de, SCREEN_WIDTH
	add hl, de
	inc b
	dec c
	jr nz, .rowLoop
	; fallthrough: the number belongs to whatever the cursor is on, so it is
	; drawn with the list rather than with the pic, which lags behind on purpose

; Pokédex number of the highlighted mon, captioned under its sprite, so an
; operator can answer "can I have number 150?" without counting rows.
DistDrawDexNo:
	ld a, [wDistMonCursor]
	inc a ; list index 0-150 -> Pokédex number 1-151
	ld d, 0 ; hundreds
.h
	cp 100
	jr c, .hDone
	sub 100
	inc d
	jr .h
.hDone
	ld e, 0 ; tens
.t
	cp 10
	jr c, .tDone
	sub 10
	inc e
	jr .t
.tDone
	push af ; ones
	; "№" ($74) would be nicer, but that glyph only exists in the tileset
	; LoadPokedexTilePatterns installs; under our font that tile is a middle
	; dot, so it printed as "·025". Spell it out instead.
	ld a, "N"
	ldcoord_a DIST_DEXNO_X, DIST_DEXNO_Y
	ld a, "o"
	ldcoord_a DIST_DEXNO_X + 1, DIST_DEXNO_Y
	ld a, d ; leading zeros, the way the Pokédex itself numbers them
	add "0"
	ldcoord_a DIST_DEXNO_X + 2, DIST_DEXNO_Y
	ld a, e
	add "0"
	ldcoord_a DIST_DEXNO_X + 3, DIST_DEXNO_Y
	pop af
	add "0"
	ldcoord_a DIST_DEXNO_X + 4, DIST_DEXNO_Y
	; fallthrough

; Types, stacked under the Pokédex number in the 7-column strip beside the pic.
; The engine's own PrintMonType is a predef in bank $09 that hard-codes its own
; two-row spacing and blanks a fixed six tiles for single-type mons, neither of
; which lands where we need it -- hence the local table.
DistDrawTypes:
	hlcoord DIST_TYPE_X, DIST_TYPE_Y ; clear both rows: names vary in length
	ld b, 2
	ld a, " "
.blankRow
	push hl
	ld c, 7
.blankCol
	ld [hli], a
	dec c
	jr nz, .blankCol
	pop hl
	ld de, SCREEN_WIDTH
	add hl, de
	dec b
	jr nz, .blankRow
	call DistCurrentSpecies
	ld [wCurSpecies], a
	ld [wCurPartySpecies], a
	call GetMonHeader
	ld a, [wMonHType1]
	call DistTypeString
	hlcoord DIST_TYPE_X, DIST_TYPE_Y
	call PlaceString
	ld a, [wMonHType1]
	ld b, a
	ld a, [wMonHType2]
	cp b
	ret z ; the engine stores both types the same for single-type mons
	call DistTypeString
	hlcoord DIST_TYPE_X, DIST_TYPE_Y + 1
	jp PlaceString

; a = type id -> de = its name. The table is in this bank, so PlaceString can
; read it directly with no bankswitch.
DistTypeString:
	; the ids are sparse: $00-$08 physical, then $14-$1A special
	cp FIRE
	jr c, .dense
	sub FIRE - 9
.dense
	add a ; two bytes per pointer
	ld e, a
	ld d, 0
	ld hl, DistTypeNames
	add hl, de
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ret

; Internal species index of the highlighted entry, in a.
DistCurrentSpecies:
	ld a, [wDistMonCursor]
	ld e, a
	ld d, 0
	ld hl, DistributionSpeciesList
	add hl, de
	ld a, [hl]
	ret

; Swapping the preview used to blank the box first, which meant the player
; stared at an empty frame for the whole load. Measuring where a 7x7 pic's 55
; frames go explains why that was so bad: 44 of them are UncompressMonSprite,
; 2 the align/merge, and only 7 the copy into VRAM. Decompression touches
; nothing but the SRAM sprite buffers, so with no blanking the previous mon
; simply stays on screen for those 44 frames and the only visible change is the
; ~7-frame dissolve while the tiles themselves are overwritten. Same total
; latency -- that part is the Game Boy's CPU -- but roughly a fifth of the
; visible gap, and the name and number update on the keypress regardless.
DistDrawSprite:
	call DistCurrentSpecies
	ld [wCurSpecies], a
	ld [wCurPartySpecies], a
	call GetMonHeader
	hlcoord DIST_SPRITE_X, DIST_SPRITE_Y
	call LoadFrontSpriteByMonIndex
	ret

; Level, right-aligned in the three tiles after the "NIVEAU:" label.
DistDrawLevel:
	ld a, [wDistLevel]
	hlcoord 8, DIST_LEVEL_Y
	; fallthrough

; a = value, hl = destination. Three digits, blank-padded rather than
; zero-padded (a level reads as "50", not "050" -- unlike a Pokédex number).
DistPrint3Digits:
	ld d, 0 ; hundreds
.h
	cp 100
	jr c, .hDone
	sub 100
	inc d
	jr .h
.hDone
	ld e, 0 ; tens
.t
	cp 10
	jr c, .tDone
	sub 10
	inc e
	jr .t
.tDone
	push af ; a = ones
	ld a, d
	and a
	jr nz, .hDigit
	ld a, " "
	jr .hPlace
.hDigit
	add "0"
.hPlace
	ld [hli], a
	ld a, d
	or e
	jr nz, .tDigit
	ld a, " "
	jr .tPlace
.tDigit
	ld a, e
	add "0"
.tPlace
	ld [hli], a
	pop af
	add "0"
	ld [hl], a
	ret

; --- Jump to a Pokédex number (Start from the mon list) ------------------
; Paging through 22 screens is the wrong tool when the request arrives as a
; number. The three digits are edited in place: up/down spins the one in
; brackets, left/right picks which one. Seeded from the current cursor, so it
; opens showing where you already are.

DistJumpToNumber:
	ld a, [wDistMonCursor]
	inc a
	ld d, 0
.seedH
	cp 100
	jr c, .seedHDone
	sub 100
	inc d
	jr .seedH
.seedHDone
	ld e, 0
.seedT
	cp 10
	jr c, .seedTDone
	sub 10
	inc e
	jr .seedT
.seedTDone
	ld [wDistJumpDigits + 2], a
	ld a, d
	ld [wDistJumpDigits], a
	ld a, e
	ld [wDistJumpDigits + 1], a
	xor a
	ld [wDistJumpPos], a
	ldh [hJoy6], a
	ld a, 1
	ldh [hJoy7], a ; hold a direction to spin a digit
	call DistDrawJump
.loop
	call DistDrawJumpDigits
.input
	call DelayFrame
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	ld b, a
	and a
	jr z, .input
	bit B_PAD_A, b
	jr nz, .confirm
	bit B_PAD_B, b
	jr nz, .cancel
	bit B_PAD_UP, b
	jr nz, .digitUp
	bit B_PAD_DOWN, b
	jr nz, .digitDown
	bit B_PAD_LEFT, b
	jr nz, .posLeft
	bit B_PAD_RIGHT, b
	jr nz, .posRight
	jr .input
.digitUp
	call DistJumpDigitPtr
	ld a, [hl]
	inc a
	cp 10
	jr c, .storeDigit
	xor a ; wrap 9 -> 0
	jr .storeDigit
.digitDown
	call DistJumpDigitPtr
	ld a, [hl]
	and a
	jr nz, .decDigit
	ld a, 10 ; wrap 0 -> 9
.decDigit
	dec a
.storeDigit
	ld [hl], a
	jp .loop
.posLeft
	ld a, [wDistJumpPos]
	and a
	jr nz, .decPos
	ld a, 3
.decPos
	dec a
	jr .storePos
.posRight
	ld a, [wDistJumpPos]
	inc a
	cp 3
	jr c, .storePos
	xor a
.storePos
	ld [wDistJumpPos], a
	jp .loop
.cancel
	ret ; cursor untouched
.confirm
	ld a, [wDistJumpDigits]
	cp 2
	jr nc, .clampMax ; 200+ can only be past the end, and would overflow below
	ld c, 0
	and a
	jr z, .noHundreds
	ld c, 100
.noHundreds
	ld a, [wDistJumpDigits + 1]
	ld d, a
	add a ; 2
	add a ; 4
	add d ; 5
	add a ; 10 * tens, at most 90
	add c
	ld c, a
	ld a, [wDistJumpDigits + 2]
	add c ; at most 199, so this still fits in 8 bits
	and a
	jr z, .clampMin ; there is no number 0
	cp DIST_NUM_MONS + 1
	jr c, .store
.clampMax
	ld a, DIST_NUM_MONS
	jr .store
.clampMin
	ld a, 1
.store
	dec a ; Pokédex number -> list index
	ld [wDistMonCursor], a
	ret

DistJumpDigitPtr:
	ld hl, wDistJumpDigits
	ld a, [wDistJumpPos]
	ld d, 0
	ld e, a
	add hl, de
	ret

DistDrawJump:
	xor a
	ldh [hAutoBGTransferEnabled], a ; pause transfer during bulk draw
	hlcoord 0, DIST_JUMP_Y - 1
	ld b, 1
	ld c, 18
	call TextBoxBorder
	hlcoord 2, DIST_JUMP_Y
	ld de, DistJumpLabel
	call PlaceString
	call DistBlankHints
	hlcoord 1, DIST_HINT_Y
	ld de, DistJumpHint1
	call PlaceString
	hlcoord 1, DIST_HINT_Y + 1
	ld de, DistJumpHint2
	call PlaceString
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ret

; Each digit takes three columns: a bracket, the digit, a bracket. The brackets
; are blank unless that digit is the one being edited, so the field never
; changes width and never needs clearing.
DistDrawJumpDigits:
	hlcoord 5, DIST_JUMP_Y
	ld b, 0
.loop
	ld a, [wDistJumpPos]
	cp b
	ld a, " "
	jr nz, .noOpen
	ld a, "["
.noOpen
	ld [hli], a
	push hl
	ld hl, wDistJumpDigits
	ld d, 0
	ld e, b
	add hl, de
	ld a, [hl]
	pop hl
	add "0"
	ld [hli], a
	ld a, [wDistJumpPos]
	cp b
	ld a, " "
	jr nz, .noClose
	ld a, "]"
.noClose
	ld [hli], a
	inc b
	ld a, b
	cp 3
	jr nz, .loop
	ret

; Wipe both hint rows. Easier to reason about than padding every
; replacement string out to the width of whatever it covers, which is how the
; level screen does it and which has bitten us before.
DistBlankHints:
	hlcoord 0, DIST_HINT_Y
	ld b, 2 * SCREEN_WIDTH ; only two rows now -- 4 would run off the tilemap
	ld a, " "
.loop
	ld [hli], a
	dec b
	jr nz, .loop
	ret

; --- Return to the menu without a power cycle ----------------------------
; Reached from the Start+Select hook in _Joypad, so it can fire from anywhere
; that polls the joypad, at any call depth. Unlike the stock A+B+Start+Select
; reset it does NOT go through Init, which would clear all of WRAM and take the
; operator back to the title screen -- the whole point is that the settings and
; the OT name survive between gifts.
;
; Everything reset here is a measured difference between the state the menu runs
; in and the state the Pokemon Center overworld leaves behind; nothing else
; differs, and DistributionBuildParty re-runs InitPlayerData2 anyway.
DistributionReturnToMenu::
	di
	ld sp, wStack ; we are unwinding out of an arbitrary call depth
	xor a
	ldh [rIF], a
	ldh [rSB], a
	ldh [rSC], a ; every Pokecenter map script re-arms serial each frame
	ldh [hTileAnimations], a ; VBlank would keep animating tiles over the menu
	; The menu draws into the window map at $9C00 (that is where
	; hAutoBGTransferDest points), so the window has to cover the screen. The
	; overworld leaves it pushed off the bottom at SCREEN_HEIGHT_PX.
	ldh [hWY], a
	ldh [rWY], a
	ld a, IE_VBLANK | IE_TIMER | IE_SERIAL
	ldh [rIE], a
	ld a, 1
	ldh [hAutoBGTransferEnabled], a ; the overworld redraws without it
	ld a, $ff ; the value Init leaves; keeps UpdateSprites a no-op
	ld [wUpdateSpritesEnabled], a
	ei
	call StopAllSounds
	call ClearSprites
	jp DistributionMenu ; NOT DistributionMain: that would re-seed the OT name

; --- Settings screen (Select from the mon list) --------------------------
; One row per setting, so adding another needs only a string, a row in
; DistDrawSettings, a branch in .chosen and a bump to DIST_NUM_SETTINGS.

DistSettings:
	xor a
	; plain single presses here: no repeat, and A/B must not repeat either.
	; DistChooseMon re-arms hJoy7 for itself when we return.
	ldh [hJoy6], a
	ldh [hJoy7], a
	ld [wDistSetCursor], a
.redraw
	call DistDrawSettings
.loop
	call DelayFrame
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	ld b, a
	and a
	jr z, .loop
	bit B_PAD_B, b
	jr nz, .done
	bit B_PAD_A, b
	jr nz, .chosen
	bit B_PAD_UP, b
	jr nz, .up
	bit B_PAD_DOWN, b
	jr nz, .down
	jr .loop
.up
	ld a, [wDistSetCursor]
	and a
	jr nz, .decCursor
	ld a, DIST_NUM_SETTINGS ; wrap to the last row
.decCursor
	dec a
	jr .storeCursor
.down
	ld a, [wDistSetCursor]
	inc a
	cp DIST_NUM_SETTINGS
	jr c, .storeCursor
	xor a ; wrap to the first row
.storeCursor
	ld [wDistSetCursor], a
	call DistDrawSetCursor
	jr .loop
.chosen
	ld a, [wDistSetCursor]
	and a
	jr nz, .loop ; no other rows yet
	call DistEditPlayerName
	jr .redraw   ; the naming screen owned the whole screen
.done
	ret

DistDrawSettings:
	xor a
	ldh [hAutoBGTransferEnabled], a ; pause transfer during bulk draw
	call ClearScreen
	hlcoord 6, 0
	ld de, DistSetTitleStr
	call PlaceString
	hlcoord 0, DIST_SET_Y - 1
	ld b, DIST_NUM_SETTINGS
	ld c, 18
	call TextBoxBorder
	hlcoord 2, DIST_SET_Y
	ld de, DistSetNameStr
	call PlaceString
	hlcoord 7, DIST_SET_Y
	ld de, wDistPlayerName ; the value, straight out of RAM
	call PlaceString
	hlcoord 1, DIST_HINT_Y
	ld de, DistSetHintA
	call PlaceString
	hlcoord 1, DIST_HINT_Y + 1
	ld de, DistSetHintB
	call PlaceString
	call DistDrawSetCursor
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ld c, 6
	jp DelayFrames

DistDrawSetCursor:
	hlcoord 1, DIST_SET_Y
	ld b, 0 ; row being drawn
	ld c, DIST_NUM_SETTINGS
.loop
	ld a, [wDistSetCursor]
	cp b
	ld a, " "
	jr nz, .noCursor
	ld a, "▶"
.noCursor
	ld [hl], a
	ld de, SCREEN_WIDTH
	add hl, de
	inc b
	dec c
	jr nz, .loop
	ret

; Hand off to the game's own naming screen. NAME_PLAYER_SCREEN caps the entry at
; 7 characters, which is exactly what the OT field of a traded mon shows.
DistEditPlayerName:
	xor a
	; no overworld sprites exist on this screen, and DisplayNamingScreen calls
	; UpdateSprites; AskName does the same before naming a mon
	ld [wUpdateSpritesEnabled], a
	ld [wNamingScreenType], a ; NAME_PLAYER_SCREEN
	; It copies the result to hl even when nothing was entered, so aim it at
	; scratch and take the name from wStringBuffer only if there is one.
	ld hl, wBuffer
	farcall DisplayNamingScreen
	; on the way out it reloads the text box tiles but not the font
	call LoadFontTilePatterns
	ld a, [wStringBuffer]
	cp "@"
	ret z ; submitted an empty name: keep the current one
	ld hl, wStringBuffer
	ld de, wDistPlayerName
	ld bc, NAME_LENGTH
	jp CopyData

; --- Build the gift party ------------------------------------------------

DistributionBuildParty:
	xor a
	ldh [hJoy7], a ; back to the engine default before the overworld takes over
	predef InitPlayerData2 ; fresh player data, empty party, random ID
	ld hl, wDistPlayerName ; whatever the settings screen last left there
	ld de, wPlayerName
	ld bc, NAME_LENGTH
	call CopyData
	SetEvent EVENT_GOT_POKEDEX
	xor a
	ld [wIsInBattle], a
	; species
	ld a, [wDistMonCursor]
	ld e, a
	ld d, 0
	ld hl, DistributionSpeciesList
	add hl, de
	ld a, [hl]
	ld [wCurPartySpecies], a
	ld [wCurSpecies], a
	; level
	ld a, [wDistLevel]
	ld [wCurEnemyLevel], a
	; add to player party without a naming prompt
	ld a, $80
	ld [wMonDataLocation], a
	call AddPartyMon
	; give it the species name as its nickname
	ld a, [wCurPartySpecies]
	ld [wNamedObjectIndex], a
	call GetMonName
	ld hl, wNameBuffer
	ld de, wPartyMonNicks
	ld bc, NAME_LENGTH
	call CopyData
	ret

; --- "Ready" screen (placeholder; trade entry added next) ----------------

; The box sits over rows 12-17 so the pic, the Pokédex number, the types and
; the highlighted list row all stay visible behind it -- which is the whole
; recap the operator needs, so the box itself only carries instructions.
DistReadyScreen:
	hlcoord 0, 12
	ld b, 4
	ld c, 18
	call TextBoxBorder
	hlcoord 1, 13
	ld de, DistReadyStr
	call PlaceString
	hlcoord 1, 14
	ld de, DistReadyStr2
	call PlaceString
	; row 15 stays as TextBoxBorder left it -- blank, separating the
	; instruction from the operator-only shortcut below it
	hlcoord 1, 16
	ld de, DistReadyStr3 ; the operator is about to need this
	call PlaceString
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ld c, 6
	call DelayFrames
.wait
	call DelayFrame
	call JoypadLowSensitivity
	ldh a, [hJoy5]
	and PAD_A | PAD_B
	jr z, .wait
	ret

; --- Hand off to the Cable Club ------------------------------------------
; Warp the operator into the Viridian Pokémon Center, standing in front of
; the link receptionist. From there the stock Cable Club flow (talk to her,
; connect, Trade Center) runs unchanged so a linked cart receives the gift.

DistributionEnterTrade:
	xor a
	ld [wLinkState], a          ; LINK_STATE_NONE
	ld [wEnteringCableClub], a  ; normal map entry, not via the link menu
	; Copy the 8-byte special-warp record exactly like LoadSpecialWarpData:
	; 7 bytes -> wCurMap .. wXBlockCoord, 8th byte -> wCurMapTileset.
	ld hl, DistPCWarp
	ld de, wCurMap
	ld c, 7
.copyLoop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copyLoop
	ld a, [hl]
	ld [wCurMapTileset], a
	xor a
	ld [wYOffsetSinceLastSpecialWarp], a
	ld [wXOffsetSinceLastSpecialWarp], a
	ld a, VIRIDIAN_POKECENTER    ; keep the operator inside the Center
	ld [wLastMap], a
	ld a, -1                     ; keep the coords from the record (no warp lookup)
	ld [wDestinationWarpID], a
	predef LoadTilesetHeader
	jpfar SpecialEnterMap        ; resets sprite/timer, then jp EnterMap (overworld)

DistPCWarp:
	special_warp_spec VIRIDIAN_POKECENTER, 11, 3, POKECENTER

; --- Strings & data ------------------------------------------------------

DistTitleStr:  db "DISTRIBUTION@"
DistNivStr:    db "NIVEAU:@"
; Hint lines. The level screen overwrites both in place, so its strings are
; padded to match the longer mon-screen ones they cover.
DistHintPickA: db "A: CHOISIR START:No@"
DistHintSelect: db "SELECT: REGLAGES@"
DistHintLevel: db "HAUT/BAS:1 G/D:10  @" ; padded out to cover DistHintPickA
DistHintOkB:   db "A: OK   B: RETOUR@"
DistReadyStr:  db "PRET A ECHANGER!@"
DistReadyStr2: db "PARLEZ A LA DAME@"
DistReadyStr3: db "START+SELECT: MENU@" ; exactly the 18-column box interior

; Settings screen
DistSetTitleStr: db "REGLAGES@"
DistSetNameStr:  db "NOM:@"
DistSetHintA:    db "A: MODIFIER@"
DistSetHintB:    db "B: RETOUR@"

; "jump to a number" prompt
DistJumpLabel: db "No@"
DistJumpHint1: db "HAUT/BAS: CHIFFRE@"
DistJumpHint2: db "A: ALLER B: ANNULER@"

; Type names, duplicated from data/types/names.asm on purpose: those live in
; bank $09 behind PrintMonType, whose two-row layout does not fit this screen.
; Indexed densely -- $00-$08 as-is, then $14-$1A folded down to 9-15.
DistTypeNames:
	dw .normal, .combat, .vol, .poison, .sol, .roche, .oiseau, .insecte, .spectre
	dw .feu, .eau, .plante, .electrik, .psy, .glace, .dragon
.normal:   db "NORMAL@"
.combat:   db "COMBAT@"
.vol:      db "VOL@"
.poison:   db "POISON@"
.sol:      db "SOL@"
.roche:    db "ROCHE@"
.oiseau:   db "OISEAU@"
.insecte:  db "INSECTE@"
.spectre:  db "SPECTRE@"
.feu:      db "FEU@"
.eau:      db "EAU@"
.plante:   db "PLANTE@"
.electrik: db "ELECTR.@" ; the strip is 7 tiles wide and "ELECTRIK" is 8
.psy:      db "PSY@"
.glace:    db "GLACE@"
.dragon:   db "DRAGON@"

DistDefaultName: db "OneSear@"
	ds NAME_LENGTH - 8

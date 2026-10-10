_Joypad::
; hJoyReleased: (hJoyLast ^ hJoyInput) & hJoyLast
; hJoyPressed:  (hJoyLast ^ hJoyInput) & hJoyInput

	ldh a, [hJoyInput]
	cp PAD_BUTTONS ; soft reset
	jp z, TrySoftReset

	call CheckDistributionReturn ; may not return

	ldh a, [hJoyInput]
	ld b, a
	ldh a, [hJoyLast]
	ld e, a
	xor b
	ld d, a
	and e
	ldh [hJoyReleased], a
	ld a, d
	and b
	ldh [hJoyPressed], a
	ld a, b
	ldh [hJoyLast], a

	ld a, [wStatusFlags5]
	bit BIT_DISABLE_JOYPAD, a
	jr nz, DiscardButtonPresses

	ldh a, [hJoyLast]
	ldh [hJoyHeld], a

	ld a, [wJoyIgnore]
	and a
	ret z

	cpl
	ld b, a
	ldh a, [hJoyHeld]
	and b
	ldh [hJoyHeld], a
	ldh a, [hJoyPressed]
	and b
	ldh [hJoyPressed], a
	ret

DiscardButtonPresses:
	xor a
	ldh [hJoyHeld], a
	ldh [hJoyPressed], a
	ldh [hJoyReleased], a
	ret

; Distribution ROM: holding Start+Select, with nothing else pressed, drops the
; operator back on the gift menu so the next person can be served without a
; power cycle. Checked here rather than in the menu code so it works from the
; overworld after a trade, and it reads hJoyInput directly, so wJoyIgnore and
; BIT_DISABLE_JOYPAD cannot lock it out mid-script.
;
; Refuses to fire while a link is up: yanking the ROM out from under a trade in
; progress leaves the other console hanging mid-transfer, and that is somebody
; else's cartridge. Leaving the Cable Club clears wLinkState, so the combo is
; live again by the time a gift has actually been handed over.
DEF DIST_RETURN_FRAMES EQU 30

CheckDistributionReturn:
	ldh a, [hJoyInput]
	cp PAD_START | PAD_SELECT
	jr z, .held
.notHeld
	xor a
	ld [wDistReturnHold], a
	ret
.held
	ld a, [wLinkState]
	and a
	jr nz, .notHeld
	ld hl, wDistReturnHold
	inc [hl]
	ld a, [hl]
	cp DIST_RETURN_FRAMES
	ret c
	jpfar DistributionReturnToMenu

TrySoftReset:
	call DelayFrame

	; deselect (redundant)
	ld a, $30
	ldh [rJOYP], a

	ld hl, hSoftReset
	dec [hl]
	jp z, SoftReset

	jp Joypad

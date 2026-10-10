; English mode: the far-text half of the language switch.
;
; Every dialogue in the game reaches its text through a text_far, and in
; English mode TextCommand_FAR passes each one through here first. The French
; and English text files share their labels (see tools/make_english_text.py),
; so DistFarTextIndex holds, for each French text, where its English twin is.
; A text with no twin, or one that is not in a French text bank at all, comes
; back unchanged and prints in French.
;
; In:  c = bank, de = address of the text a text_far points at
; Out: a = bank, de = address of the text to print instead
; Preserves hl and c. Reached through DistTranslateFarText, with this bank
; loaded; the caller loads whatever bank comes back.
DistFarTextLookup::
	push hl
	ld hl, DistFarTextIndex
.findBank
	ld a, [hli]
	and a
	jr z, .notFound ; not a French text bank
	cp c
	jr z, .foundBank
	inc hl
	inc hl
	jr .findBank
.foundBank
	ld a, [hli]
	ld h, [hl]
	ld l, a
.search
	ld a, [hli]
	ld b, a ; French address, low byte
	ld a, [hli]
	and a
	jr z, .notFound ; end of this bank's table
	cp d
	jr nz, .next
	ld a, b
	cp e
	jr z, .found
.next
	inc hl
	inc hl
	inc hl
	jr .search
.found
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hl] ; English bank
	pop hl
	ret
.notFound
	ld a, c
	pop hl
	ret

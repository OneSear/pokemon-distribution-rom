TypeNames:
	table_width 2

	dw .Normal
	dw .Fighting
	dw .Flying
	dw .Poison
	dw .Ground
	dw .Rock
	dw .Bird
	dw .Bug
	dw .Ghost

REPT UNUSED_TYPES_END - UNUSED_TYPES
	dw .Normal
ENDR

	dw .Fire
	dw .Water
	dw .Grass
	dw .Electric
	dw .Psychic
	dw .Ice
	dw .Dragon

	assert_table_length NUM_TYPES

; French, then English for DistLangString (distribution ROM language switch)
.Normal:   db "NORMAL@", "NORMAL@"
.Fighting: db "COMBAT@", "FIGHTING@"
.Flying:   db "VOL@", "FLYING@"
.Poison:   db "POISON@", "POISON@"
.Fire:     db "FEU@", "FIRE@"
.Water:    db "EAU@", "WATER@"
.Grass:    db "PLANTE@", "GRASS@"
.Electric: db "ELECTRIK@", "ELECTRIC@"
.Psychic:  db "PSY@", "PSYCHIC@"
.Ice:      db "GLACE@", "ICE@"
.Ground:   db "SOL@", "GROUND@"
.Rock:     db "ROCHE@", "ROCK@"
.Bird:     db "OISEAU@", "BIRD@"
.Bug:      db "INSECTE@", "BUG@"
.Ghost:    db "SPECTRE@", "GHOST@"
.Dragon:   db "DRAGON@", "DRAGON@"

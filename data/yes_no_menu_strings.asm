MACRO two_option_menu
	db \1, \2, \3
	dw \4
ENDM

TwoOptionMenuStrings:
; Every menu is French, then English, for DistLangString -- the English one
; too where both are the same, or the skip would land in the next menu.
; entries correspond to *_MENU constants
	table_width 5
	; width, height, blank line before first menu item?, text pointer
	two_option_menu 4, 3, FALSE, .YesNoMenu
	two_option_menu 6, 3, FALSE, .NorthWestMenu
	two_option_menu 6, 3, FALSE, .SouthEastMenu
	two_option_menu 6, 3, FALSE, .YesNoMenu
	two_option_menu 6, 3, FALSE, .NorthEastMenu
	two_option_menu 8, 3, FALSE, .TradeCancelMenu
	two_option_menu 7, 4, TRUE,  .HealCancelMenu
	two_option_menu 4, 3, FALSE, .NoYesMenu
	assert_table_length NUM_TWO_OPTION_MENUS

.NorthWestMenu
	db   "NORTH"
	next "WEST@"
	db   "NORTH"
	next "WEST@"

.SouthEastMenu
	db   "SOUTH"
	next "EAST@"
	db   "SOUTH"
	next "EAST@"

.NorthEastMenu
	db   "NORTH"
	next "EAST@"
	db   "NORTH"
	next "EAST@"

.NoYesMenu
	db   "NON"
	next "OUI@"
	db   "NO"
	next "YES@"

.YesNoMenu
	db   "OUI"
	next "NON@"
	db   "YES"
	next "NO@"

.TradeCancelMenu
	db   "ECHANGE"
	next "RETOUR@"
	db   "TRADE"
	next "CANCEL@"

.HealCancelMenu
	db   "SOIN"
	next "RETOUR@"
	db   "HEAL"
	next "CANCEL@"

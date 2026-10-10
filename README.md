# Pokémon Distribution ROM [![Build Status][ci-badge]][ci]

A Game Boy cart for handing out Pokémon at events. Pick any of the 151 Pokémon
and a level, then trade it to a real Red, Blue or Yellow cartridge over a link
cable. In English or French.

<p align="center">
  <img src="docs/screenshots/title.png" width="42%"
       alt="Title screen: the Pokemon logo above the words DISTRIBUTION ROM, with Mew next to the player">
  <img src="docs/screenshots/menu.png" width="42%"
       alt="The menu: a list of Pokemon names with Mew selected, its sprite, number 151 and PSYCHIC type beside it">
  <br>
  <img src="docs/screenshots/level.png" width="42%"
       alt="The level screen: LEVEL: 50 under the list">
  <img src="docs/screenshots/ready.png" width="42%"
       alt="A box reading READY TO TRADE! / TALK TO THE LADY / START+SELECT: MENU">
</p>

## Handing out a Pokémon

1. Boot the cart, press Start and pick a language.
2. Pick a Pokémon with A, set the level, press A twice.
3. You are in a Pokémon Center. Link the two Game Boys, have both players talk
   to the receptionist, and trade.
4. Press Start + Select for the next visitor.

## Controls

| Button | Pokémon list | Level |
| --- | --- | --- |
| Up / Down | move | ±1 |
| Left / Right | page | ±10 |
| A | choose | confirm |
| B | | back |
| Start | jump to a Pokédex number | |
| Select | settings (OT name, language) | |

Hold Start + Select anywhere to return to the menu.

## Build

Install [rgbds](https://rgbds.gbdev.io/) 1.0.0 or newer (see
[INSTALL.md](INSTALL.md)), then run `make`. This writes
`pokemon_distribution.gb`.

## Credits

Built on [pret/pokered][pokered] and [einstein95/pokered-fr][pokered-fr].
Pokémon is a trademark of Nintendo, Creatures and GAME FREAK.

[pokered]: https://github.com/pret/pokered
[pokered-fr]: https://github.com/einstein95/pokered-fr
[ci]: https://github.com/OneSear/pokemon-distribution-rom/actions
[ci-badge]: https://github.com/OneSear/pokemon-distribution-rom/actions/workflows/main.yml/badge.svg

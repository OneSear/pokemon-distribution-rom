# Pokémon Distribution ROM [![Build Status][ci-badge]][ci]

A Game Boy **event-distribution cartridge** for French Pokémon: Version Rouge
and Bleue — the kind of cart Nintendo used to bring to events to hand out
Mew.

The ROM boots straight into a gift menu instead of the game. Pick any of the
151 Pokémon and a level, then link a second Game Boy running a real
Rouge / Bleue / Jaune cartridge and trade the gift across at the Cable Club,
exactly like a normal player-to-player trade.

## How it works

This is a **fork of the French [pokered][pokered-fr] disassembly**, not a
standalone ROM. That is the whole design decision: the receiving side is an
unmodified retail cartridge, so the link protocol has to be right down to the
byte — including the two players' movement sync in the trade room. Rather
than reimplement it, the distribution front-end builds a valid one-Pokémon
party in WRAM and then hands off to the game's **own, untouched Cable Club
code**. Protocol correctness is inherited, not written.

The gift is a legitimate Pokémon: correct species and level, stats computed
with the real Gen 1 formula from random DVs, the level-up moveset for that
level, the species name as its nickname, and the operator's name and a random
ID number as its OT.

## Controls

**Pokémon list**

| Button | Action |
| --- | --- |
| Up / Down | Move one entry (hold to repeat; wraps, so Mew is one press *up* from Bulbizarre) |
| Left / Right | Page by 10 |
| Start | Jump to a Pokédex number |
| Select | Settings |
| A | Choose this Pokémon |

**Level**

| Button | Action |
| --- | --- |
| Up / Down | ±1 |
| Left / Right | ±10 |
| A | Confirm and go to the Pokémon Center |
| B | Back to the list |

**Anywhere**

| Button | Action |
| --- | --- |
| Start + Select (held ~½ s) | Return to the gift menu |

Start + Select is the operator's reset between visitors — no power cycle, and
the settings survive it. It deliberately **refuses to fire during a link
session**, since bailing out mid-trade would leave the other console hanging.

## Settings

Select on the list opens the settings screen. `NOM:` sets the **OT name** that
every gift is stamped with, using the game's own naming screen; it defaults to
`OneSear` and is capped at 7 characters, which is what a traded Pokémon's OT
field shows. Both the name and the chosen level persist across
Start + Select, because one event usually means handing out one level under
one OT.

## Building

Needs [**rgbds**](https://rgbds.gbdev.io/) 0.9.3 or newer (developed on
1.0.3). See [**INSTALL.md**](INSTALL.md) for platform-by-platform setup.

```sh
make
```

That is the only target, and it produces **`pokemon_distribution.gb`** (1 MB).
The build is reproducible: a clean rebuild is byte-identical.

The extension is `.gb`, not the `.gbc` this disassembly used upstream, because
the ROM really is a plain DMG game — the CGB flag at `$0143` is `$00`. It runs
on a Game Boy, a Super Game Boy and a Game Boy Color in compatibility mode
alike, and all three are accounted for (the Super Game Boy needed its palette
set explicitly, since the removed intro was what used to do it).

## Running an event

1. Boot the cart. Press Start at the title.
2. Set the OT name once, via Select, if you want something other than `OneSear`.
3. Pick the Pokémon and the level, press A. The screen says `PRET A ECHANGER!`
   and you are standing in a Pokémon Center in front of the link receptionist.
4. Link the two Game Boys, have the visitor go to any Pokémon Center's Cable
   Club, and talk to the lady on both ends. Trade as normal.
5. Press Start + Select to come back for the next visitor.

The cart trades its only Pokémon away each time, which is why step 5 rebuilds
a fresh party rather than reusing the old one.

## What changed from upstream

| File | |
| --- | --- |
| `engine/menus/distribution.asm` | the whole front-end: list, sprite preview, level, settings, jump-to-number, party builder |
| `gfx/distribution_banner.asm` | the "DISTRIBUTION ROM" title banner, drawn from the game's own font |
| `engine/movie/title.asm` | banner in place of the version logo; title mon pinned to Mew; copyright row removed; Start enters the menu |
| `home/init.asm` | intro battle and copyright screen skipped |
| `engine/joypad.asm` | the Start + Select return hook |
| `main.asm`, `layout.link`, `ram/wram.asm` | bank `$2D` for the front-end, and its WRAM state |
| `Makefile` | one target instead of the red/blue/debug/VC matrix |

Everything else — the Cable Club, the trade, the sprites, the text engine — is
upstream, unmodified, and meant to stay that way.

## Status

Verified headlessly in [PyBoy][pyboy], on both DMG and CGB: every one of the
151 list positions and preview sprites, the scrolling and paging maths, the
jump-to-number clamping, party bytes against the real Gen 1 stat formula, the
OT name round trip, and nine consecutive Start + Select returns with no stack
growth.

**Not yet verified: the actual two-Game-Boy link trade.** PyBoy cannot emulate
a link cable, so this needs either two SameBoy instances (Connect menu) or, as
it should be, real hardware and a real cartridge.

## Credits

- [**pret/pokered**][pokered] — the Pokémon Red/Blue disassembly this is all built on
- [**einstein95/pokered-fr**][pokered-fr] — the French Rouge/Bleue disassembly forked here

Pokémon is a trademark of Nintendo / Creatures / GAME FREAK. This repository
contains no game data: you build the ROM yourself from the disassembled source.

[pokered]: https://github.com/pret/pokered
[pokered-fr]: https://github.com/einstein95/pokered-fr
[pyboy]: https://github.com/Baekalfen/PyBoy
[ci]: https://github.com/OneSear/pokemon-distribution-rom/actions
[ci-badge]: https://github.com/OneSear/pokemon-distribution-rom/actions/workflows/main.yml/badge.svg

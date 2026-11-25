---
name: "An fxpak state command"
description: "Read a running build's state from the console over USB —map, cell, timer, party, items, gold, switches, variables— by its .dbg symbols and its game's dump, for debugging on hardware"
type: feature
game: advocate
status: wishlist
author: taro
---

On 2026-11-23 Hornero read ABL's state off the FX Pak while taro played,
with a throwaway script: `fxpak peek` on the WRAM copy at `$F50000`, the
addresses from the build's `abl.sfc.dbg` (`map_current`, `tile_x`/`tile_y`,
`timer_sec`/`timer_active`/`timer_visible`, `party`/`party_n`, `gold`,
`FAR_ITEMS`, `FAR_HP`), the map index turned into the RM2k map through
the cartridge's map list, and the numbers into names through the game's
`data/`. It showed map 11, Lazer Teeth HQ, the timer running down, Talan
alone with the Portable Console.

> No es mala idea. Puede que nos sirva, en el futuro, para debuggear
> cositas.

(taro: "Not a bad idea. It may be useful to us in the future, to debug
little things.")

**What it asks**: a read-only command that takes a build's `.dbg` —and
whatever gives it the map list and the names— and prints the state, for
any game, not only ABL. Where the names come from is the open question:
`fxpak` is a `snes/` tool and knows nothing about RM2k, so the piece that
reads the dump probably lives in `rm2k-snes/`, using `fxpak` as a library
or calling it.

## Log

### 2026-11-23, Hornero: opened from taro's comment

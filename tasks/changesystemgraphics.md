---
name: "ChangeSystemGraphics"
description: "Sunset Over Imdahl changes the System in its startup event (map 11), which therefore does not run: white map and the menu with the wrong colors. Medium: the window with the System changed on the fly; cheap: ignore it"
type: feature
status: done
assignee: taro
agents: [Aguará, Cardón]
---

From Aguará's brief analysis (Sonnet), on 2026-10-05, of what taro saw playing the ROMs of the other games.

Today it is ignored: `ChangeSystemGraphics` is accepted doing nothing, as a debt (`ACCEPTED_UNDONE` in the events compiler), so that the page that uses it does not stay out; see `ignore-changesystemgraphics-for-now.md`. When this task is done, it has to be taken off that list.

It is not only Sunset: built on 2026-10-11 (the-advocate `fc6f7456`, ports `a85b7e3`), Vampires Dawn warns about it in maps 3 (the intro) and 27, and Sunset in 11 (to `SaveMeny`). Desert Nightmare does it in its common event 1, `Init`, from `Systemset_Intro` —the database's— to `Systemset_Spiel`, so today it plays entirely with the intro's; common events do not warn about it in the log. (Calandria, 2026-10-11.)

## The windows' background, by System (Cardón, 2026-10-12)

`[windows.background]` in `rm2k-snes.toml` is keyed by the System's name
(`windows-background-setting-and-flat-text-area.md`), so this command can
pick the entry of the System it switches to. What is done: the project
reads and checks every entry (`rm2k-snes-project`, `windows.rs`), and the
converter refuses a key that names no System of the game or the RTP. What
is left for this task:

* the converter asks `rm2k-snes-screens` for one set of windows today, the
  starting System's (`game_flags` in `convert/src/screens.rs` passes
  `--window-background` for `starting_system()`); with this command it has
  to ask once per System the game switches to, each with its own entry, and
  emit one window palette and set of tiles per System;
* the runtime has to swap them when the command runs.

The Systems the games switch to have no entry yet, because nothing draws
them: Desert Nightmare's `Systemset_Spiel` has one (black, like the
intro's); Sunset's `SaveMeny` and Vampires Dawn's `VDBlutsys2`,
`redblue-sys`, `Stone` and `Wood` do not. Their values are measured the
way "The setting for each game" in the research measured the others.

## Worklog (Cardón, 2026-10-12)

taro, through Hornero, in their words, translated:

> could we implement ChangeSystemGraphics and see it work (with different
> flat colours)?

Branches `cardon-change-system` in
the-advocate (from `a2b58945`), the-advocate-ports (from `6d7beed`) and
the-advocate-docs (from `e69efed`), each with main merged at the end.

**Scope: the message window only** —frame, background, text colours,
arrow, a choice's bar—. The menu, the slots, the item/equipment/shop
screens, End Game, the battle's windows and the title keep the starting
System: they are drawn into their banks once by the screens stage, and
per System they are that whole stage again. The System travels in the
save. Book: the decision
[`ChangeSystemGraphics` changes the message window](https://lautarodragan.github.io/the-advocate-docs/decisions/change-system-graphics-changes-the-message-window.html)
and the divergence
[What `ChangeSystemGraphics` does not model](https://lautarodragan.github.io/the-advocate-docs/divergences/what-changesystemgraphics-does-not-model.html).

How, in short:

* The converter lists the Systems (`convert/src/systems.rs`): the starting
  one plus every one a command of the cartridge's pages, commons, troops
  or test pages names, sorted. Opcode `OP_CHANGE_SYSTEM = 0x4D (system:
  byte)`; `CHANGE_SYSTEM_GRAPHICS` is off `ACCEPTED_UNDONE`. A command
  naming a System the game and RTP lack leaves its page out, with a
  warning.
* **The font's composed tables (~116 KB) are one for all Systems**: the
  text takes the same palette entries in every System —`text_rows`, the
  glyph rows split as finely as any System splits its text—, so a System
  is its palette and a few tiles.
* **The window's colour count is the starting System's** (with those
  rows), and a switched-to System is reduced to fit it: otherwise the maps
  lose colours to a second System. First tried with the max over Systems:
  A Blurred Line's map 7 patches moved for the test cartridge
  (`test_patches` red), and Sunset's painted maps stopped the build.
* Runtime: `window_system.s`, `WINDOW_NOW` (24 bytes of FARBSS) copied
  from `window_systems` at each map load and by the opcode; every reader of
  the window goes through `win_*` macros, which with one System assemble
  the old immediates. The swap uploads tiles + palette (from entry 1) +
  tilemap in the next vblank without a window line.
* Found on the way: `SAVE_BYTES` is hand-summed, and without the System's
  byte `save_game` panicked (the save test caught it). Wally: a painted
  map's black background took an entry, which fell on the painting's
  palette 1 once Sunset's window grew; it takes none now. A text row of
  two colours (VDBlutsys2) no longer stops the conversion: majority colour,
  with a warning.

`[windows.background]` added (ports): Sunset `SaveMeny = "#ae9b86"` (flat
already); VD `VDBlutsys2 = ["#18085a", "#180894"]` (VDBlutsys's background),
`redblue-sys = ["#002450", "#0048a0"]` (first and last row of its middle
column, a clean vertical gradient), `Stone = "#787068"` (the colour of most
of its square; the joints are lost), `Wood = "#6a4c29"` (the mean of its
89-colour grain). Measured with PIL over each System's 32x32 square.

ABL: cartridge `test-change-system` (map 7, cases `system-changes`,
`system-save`, `system-bar`, `system-bar-no-background`,
`system-arrow-no-background`), test `test_change_system_golden.py`: the
first window is `arrow-down`'s golden pixel for pixel; then Royal (RTP)
over `#1c2c5c`; bars and bare arrow; snes9x vs bsnes; the System through
save + reset. Red against main's tools. Royal was chosen over BLSys
because its one-colour text adds no entry to ablskin.

### Measured

* ROM per extra System: 14,558–14,656 B with a one-line text background
  (8 KB of it is the choice bar's four lines), 20.4 KB with four lines; plus
  24 B of table per System. Far RAM: 26 B per cartridge that switches.
  VRAM: the window's tiles padded to the largest frame (Desert Nightmare 9
  -> 13 tiles, 128 B).
* Bank 0: -8 B for every cartridge (the opcode's handler and dispatch
  entry); -81 B more for one that switches. `just space`-style
  (`rm2k-snes-space` on each release ROM), main -> branch: ABL 1,555 ->
  1,547; Desert Nightmare 1,701 -> 1,620; Sunset 1,633 -> 1,552; VD
  1,670 -> 1,589. Free data banks: ABL 23 -> 23, DN 13 -> 12, Sunset 21 ->
  21, VD 0 -> 0 (VD's `.msu` grows 62,720 B: its four extra windows spill
  there).
* Window entries (CGRAM_BASE): DN 16 -> 16, VD 16 -> 16, ABL release
  unchanged (one System); **Sunset 8 -> 15**: `System`'s black text
  against `SaveMeny`'s 8-row gradient takes 7 entries more, and the 5 of
  its 65 maps that are not painted have 7 colours fewer.
* Debt: the converter's "a page uses ChangeSystemGraphics and the ROM
  doesn't do it" goes from 1 to 0 in Sunset (map 11) and from 2 to 0 in
  VD (maps 3 and 27); DN's is in common event 1, which never warned. The
  pages that compile are the same (they compiled as debt); DN's shared
  bodies grow 2 B, the opcode in `Init`.

### Verified

A Blurred Line's suite green on the merged tree (1,250 tests); `just test`
and `just rust-test` green; `just boot` green for the seven ports and
Sunset's painted goldens, on the merged tree. Captures in
`~/scratch/cardon/capturas/2026-10-12-change-system/` with LEEME.txt.

Not covered by any test, also in ABL's `tests/UNTESTED.md`: the swap
with a big picture up or a window open; the framed window at the top or
middle with another System; the four-line backdrop with several Systems;
a troop page switching; Game Over / End Game after a switch.

Draft: [`the-other-screens-with-the-system-switched-to`](the-other-screens-with-the-system-switched-to.md).

## To install when merging

`screens events cartridge mapdata convert wally` (`cartridge` for the
runtime and the opcode's `.inc`); every cartridge rebuilds.

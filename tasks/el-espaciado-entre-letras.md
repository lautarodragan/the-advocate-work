---
name: "Letter spacing, as a knob"
description: "[text] letter_spacing in the project file: pixels added to the advance of every letter of a variable-width font, so that taro can compare +0, +1 and +2 by playing"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-03, after seeing the variable width: "can we add a
knob to adjust the spacing between letters, in pixels? … I'd like to try
one or two… but if it adds a lot of complexity, we leave it for another
time". Today every letter already carries one pixel of air inside its
advance (`tools/rm2k-snes/text/fonts/README.md`): the knob adds to that.

## Done (Tordo)

Tools worktree from `c69955b4`; ABL in a clone from `e660d18`, branch
`espaciado`.

### Where it is read and where it is applied

* **It is read** next to `[text] font`, in `FontChoice::of`
  (`convert/src/font.rs`), with `Project::int_or` —new in `rm2k-project`:
  an integer that may be missing, only for a knob whose "not there" means
  "as if it did not exist"; the others still fail if missing—.
  Optional, 0 by default; of any other type, an error.
* **It is applied** in `Font::with_spacing`, in the `text` crate, which adds
  to every advance —the space and the digits too, so numbers stay in
  columns—. The glyphs do not change. Everything that measures comes from
  there: the `refit` of the boxes, the screens that `rm2k-snes-screens`
  draws, the `font_advance` table the cartridge carries and the window with
  which the event compiler reflows the troop pages.
* **It travels** to `rm2k-snes-screens` as `letter_spacing` in its `boxes`
  and `convert` requests, next to `font`; without the key it is 0.
* **The range**, with the why in the error: from 0 to 3 (`SPACING_MAX`,
  taro's number); negative, no, because each letter's air is where its
  shadow falls. And **no letter may end up advancing more than one cell**
  (`SPACED_ADVANCE_MAX`, 8): the battle checks its victory lines by counting
  letters, one per cell, without knowing the font. With `low-variable`,
  whose widest letters (`#`, `M`, `W`, `m`) advance 6, **the real cap is 2**.
* **With `rm2k` it applies just the same**: it is one more font, with a
  fixed advance, and it stays fixed (6 + whatever is added). There is no
  special case to warn about.

### Advances hand-written in the ROM: none

Checked `messages.s` (the window's composer), `text_layer.s` (the fit to
cells, `tl_right` with the digits, `TL_FIGURE`, the composed text,
`tl_strip`), `battle.s` (`ba_fit`) and `battle_troop.s`: all of them read
`font_advance`, the digits and the space too. The only thing that takes
something for granted is the end of `tl_strip`, `(TL_X + 6) >> 3`: it
assumes the ink and the shadow of the last letter end before its advance,
which with more spacing holds all the more; at most it counts one column
too many, and the converter (`strip_tiles`) counts the same.

### What stops fitting

Measured with `rm2k-snes-screens boxes` over the boxes of the maps (240 px,
4 lines) and with the converter building `release`:

    spacing     boxes reflowed    split      extra boxes    menu bank
    +0          1                 0          0              314 tiles; the names ask for 78 of 134
    +1          154               37         37             355 tiles; they ask for 94 of 92   DOES NOT FIT
    +2          1736              447        457            368 tiles; they ask for 106 of 80  DOES NOT FIT

* **The menu bank is what breaks**, and the converter refuses to build:
  with +1 by 2 tiles, with +2 by 26. Both things grow at once: what is
  baked into the bank (headers, "File N", commands, terms) loses repeated
  tiles because the letters fall on other phases, and the composed names
  ask for more (the worst case: the four longest names and the longest
  medicine at once). The bank ends at the tilemap (`SLOT_MAP`), and in the
  ROM `tl_strip` has no cap: past that it overwrites the tilemap. Fixing it
  means moving `SLOT_MAP` —every layout leaves BG1 free up to `$4C00`— or
  composing the baked part too: it was not done.
* The boxes: the messages go from 3351 to 3377 boxes with +1 and to 3625
  with +2 in the converter (which also counts those of the troop pages).
* Names, against the cell cap of each place (counted by hand with the
  sheet's advances, not run in the ROM): the items fit in the list and in
  the equipment with +2; of the 13 actors of the cartridge, "Gang Member"
  stops fitting in the slot (7 cells) with +1; of the 367 named skills, in
  battle (11 cells) 6 do not fit with +0, 38 with +1 and 91 with +2
  ("Electric Shock", "Paralysis Pollen", "Mist of Silence"…).
* The shop and the battle: the converter says nothing. The pair pool of
  `text_layer.s` is not counted by the converter; the ROM, when it runs
  out, switches set earlier (`TL_FLUSH`).

### Verified

* With 0 —and without the key—, `abl.sfc` comes out byte for byte the same:
  `37dde95f59acb79eb6bc432aaa32128b9afbf2bb3179b2f2c5569cae5ec1ae08`.
* ABL's suite with the branch's tools (`convert` and `screens` local) and
  the key at 0: 1045 green.
* `cargo test` of `text`, `project`, `screens` and `convert`, and
  `just -f tools/justfile test`.
* What **no test covers**: the ROM with spacing greater than 0. The suite
  run against +1 and +2 gives 105 and 108 red, and what was looked at are
  goldens that change only letters and the `_dibujo` ones, which ask
  `rm2k-snes-screens` for the screen without `letter_spacing` and therefore
  expect +0. Both ROMs were built with the menu bank check turned off (see
  below).

## For taro

The three ROMs in `/shared/builds/espaciado/` (`abl-espaciado-0.sfc`, `-1`,
`-2`) with their `LEEME.txt`, and the side-by-side captures in
`/shared/capturas/2026-10-03-espaciado/`. **+1 and +2 were built with the
menu bank check turned off** —a local `screens`, uncommitted—: with the
usual party nothing should happen, but if the menu shows garbage, that's
why.

If one stays, the menu bank has to be fixed before putting it in
`rm2k-snes.toml`.

Branches: tools, `worktree-agent-abceeff6ccfffd250`; ABL, `espaciado` of
the clone `/extras/scratch/tordo/abl` (`e700650`): only the knob with its
comment, at 0.
When merging, reinstall `convert` and `screens`, which change behaviour;
and since `project` was touched —`int_or` was added, used only by
`convert`—, the rule in `tools/justfile` asks to reinstall everything.

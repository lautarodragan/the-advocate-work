---
name: "Sunset: the map 22 scene in black"
description: "In a small Sunset Over Imdahl cartridge (maps 11, 22, 21, 23 and 10) the map 22 scene stays black, with or without the party crutch"
type: bug
status: done
assignee: taro
agents: [Mulita]
---

Seen by Mulita on 2026-10-10, while closing `empty-party-at-the-start.md`: it is not about the empty party, it also happens with `party = [1]`.

## The cause: there are two, one behind the other

Map 11 tints the screen to black (`TintScreen` 0,0,0 over 25 frames) and jumps
to 22 (17, 13). There the scene is ev1, autorun: `PlayBGM`, rain,
`ShowPicture` of `WinterMist` and its `MovePicture`, the tint to
(110, 120, 120, 90) over 70 frames, the messages, and the jump to the shop
(21), with the shop's roofs and light as pictures.

1. **The page did not compile.** It asks for `ChangeScreenTransitions [1, 19]` —the
   cut for showing—, which the compiler rejected ("no ROM map uses
   them"): `rm2k-snes-events culprits` gives it as the only culprit of a
   page in the small cartridge. Without the page, nothing removes the black from the tint
   of 11. In the converter it showed as "map 22: 2 automatic event page(s),
   1 runnable".
2. **With the page running, it is still black: the mist covers the map.**
   `WinterMist` is a 320x240 mist that is shown at 100 %
   transparency and goes down to 95 %. The ROM carries it as a big picture —BG1 in
   mode 1, the map goes away— and the transparency darkens toward black, so
   at 95 % it is a black screen. It shows at the exact frame: with
   `sondear.py` the black lands on the tick of the `ShowPicture` and not on the one of the
   tint; removing the tint from the dump it is still black, removing both
   pictures the scene runs whole —panorama, tint, messages, and the jump
   to 21 with the shop—. There is no other cause behind it.

What RM2k does (easyrpg-player): `TransitionCutIn` lasts one frame
(`Transition::GetDefaultFrames`) and `TransitionNone` zero; pictures are
erased on changing map (`flags = 1 | 32 | 64` by default in
`Game_Pictures::ShowParams`), as the ROM does. The original with Wine
(RPG_RT of 2015, in `~/scratch/mulita/wine2/`, Xvfb :94) shows the
panorama with rain and the mist coming in.

## What got fixed: the cut for showing

* `rm2k-snes/events/src/compile.rs`: the cut (19) and "none" (20) for
  showing compile to `TRANSITION_CUTOFF`, the same as for erasing.
* `runtime/enter_map.s`, `fade_tick`: with `TRANSITION_SHOW` on the cut,
  the fade ends on the loading tick, with full brightness and that
  tick still frozen. The comments in `teleport_transition.s` and
  `far_ram.s`, up to date.
* ABL asks for it only in 302, which does not fit: `abl.sfc` changes because of the runtime
  code and the two new cases, not because of the game.

## What did not get fixed: the pictures over the map

It is not bounded. Sunset draws its roofs, ceilings, lights, shadows and
mists that way in almost every map: some 140 full-screen pictures
(320x240 to 656x480), most with the transparent color covering between
half and 99 % of the picture, or shown at 45-95 % transparency
(`~/scratch/mulita/bin/pics.py` lists them with their parameters). They are all
big pictures for the converter, which cover the map: **any Sunset
scene with one of those stays black or with the picture over black**. ABL's
are opaque screens (index 0 in 0-13 %), which is what they were designed for.

Two paths, not chosen:

* **Leave them out** (accepted without doing them) when they are "over the map":
  the game is seen without roofs or mists, but it is seen. It needs a criterion —a
  project knob or a rule by index 0 and transparency— and
  care for the ones that do go over black, like `ImdahlTitleImage` in 11.
* **Do them**: a layer above the map with the transparent color, and
  color math for the transparency, in a map that is already in
  mode 3 with the panorama. It is a whole feature.

See `sunset-the-pictures-over-the-map.md`.

## Log

* Small cartridge in the Sunset toml of my worktree, uncommitted:
  `[cartridges.arranque]` (starts at 11) and `arranque22` (starts at 22),
  `flags = ["--no-title"]`, `party = [1]`.
* `build/` does not notice a change in `data/`: `just cartridges` said "up
  to date" with `Map0022.json` touched, and the cartridge directory had to be
  deleted. For measuring it is enough; I did not follow it up.
* In the scene without pictures the message window comes out opaque and orange:
  the page asks for the transparent window and `ChangeSystemGraphics` (in
  11). It is not this task's.
* Red before the fix: with main's tools (5094ef11) ABL's suite
  does not even build —"transicion-mostrar-corte.json: the test page doesn't
  compile"—.
* Green: ABL's whole suite with `events` and `cartridge` from
  `mulita-sunset-22` ahead in the PATH, **1176** (the 1174 plus the two
  new ones); `abl.sfc` = `f81ae57da625…`, different from main's `5852b723…`
  because of the runtime and the new cases. `just crate-test events`, green.
* Afterwards I merged `main` into both branches (Tijereta in
  `rm2k-snes-audio`, Calandria in the other games' tomls) and did **not** run
  the suite again on the merge.

## When merging

Branches `mulita-sunset-22` in the-advocate, the-advocate-ports and
the-advocate-docs. Reinstall in the global: `events` and `cartridge` (the latter
because of the runtime).

## What the suite does not cover

* **Sunset**: it has no tests. That the page of 22 now runs was looked at
  with snes9x captures in the small cartridge, not with a test; that it is still
  black, too.
* `test_show_with_the_cut` covers the cut for showing on the jump from
  2 to 5 in ABL, with the default erase (the fade). The cut for
  erasing and for showing together —which is what Sunset asks for on the jump from
  the shop onward— is not run by any test.
* It was not looked at in bsnes or on hardware.

Captures, with the original alongside: `/shared/captures/2026-10-11-sunset-22/`.

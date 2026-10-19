---
name: "Frozen World: the B menu is still blind on the maps without room for it"
description: "On the maps whose sprites have no room for the menu's three pictures besides their own, B opens the menu and nothing is drawn, as before"
type: bug
status: testing
assignee: taro
agents: [Mulita, Aguará]
---

Seen by Mulita on 2026-10-17, with the-advocate `939a8bd7` (branch
`mulita-fw-b-menu`), building Frozen World's `release`: the converter's
log says on which maps "the common events' pictures 'MenuEquipPlates,
MenuItemManage, MenuPartyStats' aren't drawn here: the map has no room
for them besides its own". Not played on those maps.

What it is: the copy of common event 15 on each map (see
`common_pages.rs` in rm2k-snes-convert) puts the menu's three pictures in
the map's sprite bank whole, 320 tiles, though the three share a number
and only one is ever up. On a map where they do not fit as it is, Wally
converts it with its own pictures and the copy runs blind. What would
fit them everywhere is uploading a picture's tiles when it is shown,
with room reserved for the biggest of its number: option 5 of the book's
research "More pictures at once".

The maps the copy does not reach at all —any with no room left for one
more event— run the shared body, blind, as before; Frozen World's B
event is on none of them today.

Measured again by Aguará on 2026-10-19 with the menu's own flat pictures
(the-advocate `f19217a2`, ports `3bded23`, branches `aguara-fw-menu`): the
same 22 maps are blind, and each map still takes the three pictures in 18
objects and 320 tiles, as the converter's log says: drawing them flat and
smaller (88x56 against 88x59 scaled) does not move the count.

## Taken (2026-10-19)

taro: "this menu is not optional — the game is not playable without it".
Mulita takes it, to measure the ways out and implement the cheapest that
always draws it. taro's options, from the one they find most acceptable:

1. reserving it VRAM —and a palette, or sharing one of the map's whose
   colours are close enough, as the timer's red digits do in ABL; that
   second part only if it is needed, later—, and something else degrades;
2. the whole width, with tiles loaded in HBLANK;
3. the whole width and at the bottom edge: HBLANK to load, VBLANK for the
   way out, and a mode change if wanted;
4. a full-screen screen of its own, which owns VRAM like RM2k's menus.

Plus the draft's own: uploading the shown picture's tiles when it is
shown, with room for the biggest of the three, since only one is up at a
time (option 5 of the research "More pictures at once").

## Taro's new direction (2026-10-19, later)

The limit is the menu being `ShowPicture` at all. Two paths instead of the
four options above, which are dropped —the VRAM reservation, HBLANK, the
full-screen screen—:

1. **The cheap one, done here**: the menu as RM2k's own `ShowChoice`
   —Equip Plates / Item Management / Party Stats—, as Zounds does its
   Save / Quit / Status. It is the message window, BG2 with its own tile
   bank in every VRAM layout, so it does not compete with the map's
   sprites. **On every map**, taro's choice, for consistency; Aguará's
   pictures stop being used by the menu.
2. **The real one, to design and measure**: a "ShowWindow" command of our
   own, RPG Maker 2000 PLUS. Left as its own task with the measurements.

### How the common event gets to the port

Today's manual patches carried maps, new maps, ChipSets and files: no
common event. The smallest mechanism that can: **`patches/manual/
commonevents/NNNN.json`**, the whole record as Ditto dumps it, the id
inside the name's, and it **replaces** one the game has —adding one is
refused, nothing would call it—. Every stage reads the common events from
the dump on its own (the event compiler, Wally, the screens, the music
and the converter), so the converter builds one dump with ours in place
—`build/patches-manual/dump-<hash>/`, the game's `db/` and `maps/` by
symbolic links but `commonevents.json`— and hands that one to every stage:
`fork::with_common_events` in rm2k-snes-convert. When
`manual-patches-one-folder-per-kind-of-asset` lands, this folder is one
more lowercase one, a format of ours, as `chipsets/` is.

The new common event 15 is the original's three decision branches, each
under its option, and its cancel branch: the same teleports, tints and
`CallEvent` 31, without the pictures, without the `Cursor2`/`Cansel1`
the event played by hand —the choice plays the System's—, and without
the key loop: `ShowChoice` does it.

### What was measured (Mulita, 2026-10-19)

With the-advocate `018f1e4f` and the ports `0460abe` (branches
`mulita-fw-blind-menu`, on top of `hornero-integ`), Frozen World's
`release` built with those tools:

* **The converter's log names no blind map any more**: the only
  "aren't drawn" left are map 10's own pictures (`FrozenPic, ConceptProg,
  CustomChars`, palettes) and map 150's credits (tiles), both the map's
  own and both there before. Common event 15 has no `ShowPicture` now, so
  no map gets the copies' event (`common_pages.rs`), and it runs from the
  shared body.
* **The menu was opened on the beach and on each of the 22** with a
  throwaway script —a session per map, a harness teleport to where a door
  of the game leaves the hero, A until control, B, each row lit, B to
  cancel—. On 17 of them, and on two more after their arrival scene
  teleported elsewhere (84 to 73, 155 to 88), the window is **pixel for
  pixel the beach's**, at the top or, where the hero is under it, at the
  bottom (65, 69, 84, 127, 155). On 72, 133 and 140 a scene starts on
  arrival and the menu could not be opened (72 ends in a message on 88,
  133 and 140 in the command grid): each of those uses a VRAM layout that
  a map where it was opened also uses (72 = 132, 133 = 12, 13 and 138,
  140 = 131). Captures and contact sheet in
  `/shared/captures/2026-10-20-frozen-world-blind-menu/`.
* **Each option does what the original's did**, from the beach: Equip
  Plates goes to map 2, Item Management to map 14, Party Stats shows
  common event 31's lines; B cancels and switch 220 goes off.
* **Map 88 draws the Dark Wizard and Borto again**: they were left out
  to make room for the menu's pictures, and the log now says "a hidden
  row each". Read in the log, not played.

**Taro's question —could a message box be impossible on those 22 maps,
and would a font of one character per tile help?— is no on both.** The
message window owns a BG2 tile bank of 256 tiles in every VRAM layout,
apart from the sprites; the menu as a picture was objects, in the map's
sprite bank, which is what did not fit. The 22 show the window. The font
is not the limit: its 240 text tiles are one per cell already, whatever
the glyphs.

**What was not done**: uploading on show, the VRAM reservation, HBLANK
and the full-screen screen, dropped by taro's new direction before any
was built. Of uploading on show, only this was looked at: the three
menu pictures differ in all six of their 32x32 blocks, so a swap is the
whole picture, ~2.4 KB of drawn tiles, about the vblank's whole pose
budget, and the pose queue (`vram_queue`) would carry it in two frames.
The real path, a window of our own, is
[`show-window-a-window-command-of-our-own`](show-window-a-window-command-of-our-own.md).

**Opcodes**: none used; 0x53 is still free. `SAVE_BYTES` does not change.

**Covered by the suite**: `test_frozen_world.py` opens the menu on the
beach and on map 12 against the same three goldens; without the patch
the map 12 test is red ("only 0% of its box changed"). Not covered: the
other 21 maps (the script above, not a test), and what each option does
(the script above).

**To install when merging**: `ditto` and `convert` (the converter links
Ditto's new `Dump::with_section`), plus what the integration already
asks for.

**Run, with the branches' tools** (`just install-local .local-tools`
with project, cartridge, convert, events, images, mapdata, screens, wally,
rm2k-snes-audio, bytecode, patches and ditto): `just lint` and `just test`
green; `just crate-test ditto` and `convert` green; ABL's `just tests`
(cartridges included), 1573 passed and 2 skipped; `just boot` from the
ports' root, 79 passed, Frozen World's three included.

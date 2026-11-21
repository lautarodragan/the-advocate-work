---
name: "Desert Nightmare: the game's menu draws nothing"
description: "B opens the game's own menu —Inventory, Keys, Notes, Maps, Quit, made of 320x240 pictures— and the console draws none of it: the map stays on screen while the menu takes the buttons"
type: bug
status: done
assignee: taro
game: desert-nightmare
agents: [Hurón, Mulita]
---

Seen by Hurón on 2026-11-19, at the-advocate `62b6e5cb` and the ports
`1ea90bf`, for
[`desert-nightmare-what-it-takes-to-be-playable`](desert-nightmare-what-it-takes-to-be-playable.md).

**What is seen**: on the motel (map 16) and in the warehouse (map 26), B
turns on switch 5 (the menu), A turns on 6 (the inventory) and sets
variable 8 to the first item: the menu works, blind. Nothing is drawn: the
map stays, the hero stands. With nothing in it, A on the invisible
"Inventory" prints "You have no items" over the map. RPG_RT 2015 under
Wine draws the burning face, the five options and the item grid with its
description.

**What it is made of**: common event 4, a parallel `KeyInputProc` on
switch 1, and 5 to 14, which show **155 different pictures**, every one
a 320x240 canvas: `Introauswahl` behind, `Optionen1..5` over it, and
`Inventar`, `Gegenstand1..`, `Schlussel1..`, `Notiz1..`, `KarteG1..` and
the cursors in the grid. `degradations.json` lists them as
`picture-not-shown` (503 of the 584 are the commons'). The notes are
where the game writes its safe codes.

**To reproduce**: the stage `use_bulb` of `~/scratch/huron/dn/stages.py`;
captures in `/shared/captures/2026-11-19-desert-nightmare/menu.png`.

## The menu and the inventory, as windows (Mulita, 2026-11-20)

Since [`show-window-a-window-command-of-our-own`](show-window-a-window-command-of-our-own.md)
the options and the inventory are RPG Maker 2000 PLUS windows: common
events 4, 5 and 7 forked with a `@window` comment in front of each picture
(`desert-nightmare/patches/manual/commonevents/`, made from
`desert-nightmare/windows/menu.toml` in the ports). The burning face
behind them is a drawing, and is the big picture it was. **What is still
drawn as nothing**: the keys, the notes and the maps screens (commons 9 to
14), which are the same grid with other pictures. The keys and the notes'
names and descriptions read as text too, but the windows' text tiles are
counted per window id for the whole game, and the keys' longer names
("Clothing store key", eleven cells) in the same ids as the items' do not
fit the bank beside the inventory's; the notes themselves (`Notiz_Bild`)
and the maps (`KarteG`) are drawings. Ways on: other window ids for those
screens (a `@window` that stands in for a picture of another number), or
the description lines rewrapped narrower.

taro, on 2026-11-20, translated, on the build with the options and the
inventory as windows:

> In the menu, Inventory seems to work fine (and I could even use the
> lightbulb), but Keys, Notes and Maps show nothing on screen. They do
> seem to respond to input and play sounds.

> I could play until the first monster shows up, lock it in the room, and
> I _think_ I could go on, but I'm not sure because the Keys menu doesn't
> work, and the door on the left side is locked.

## Keys, notes and maps (Mulita, 2026-11-20)

Worktrees from the-advocate `7951af2a` and the ports `42f70e8`, branches
`mulita-dn-menu-keys`.

**No key is chosen in the menu.** In the keys screen (common 10) A only
plays `Cansel1`: the keys are a list to look at. The doors read switches
the pickup turns on, never the key slots (variables 141 to 158: no page of
any map reads them). What stops the player after the first monster is the
**safe** in the warehouse's room 6 (map 28, event 12 at (11,5)): it asks for
a five-digit number, and the number is only in the **notes** screen —the
note "Safe combination", picked up in room 2 (map 24), whose picture,
`Notiz_Bild1`, shows when A is pressed on it (common 12, picture 17)—. The
safe gives the warehouse key, which turns on switch 279, and that is what
opens the warehouse's door (map 21, event 4). The door on the left of room
6 (map 28, event 13 at (3,9)) is locked for good: its only page says so.
So the notes screen goes first, and the safe's note in it.

**The tiles: an id's are the most one of its windows takes.** The keys,
notes and maps screens are the inventory's grid with other pictures under
the same numbers, so their windows are the inventory's ids with other
text. With each line of an id sized to the widest text the game ever
writes on that line, the descriptions' box (id 9) alone grew past the bank
(the longest key description on line 3, the longest note on line 2, the
longest name on line 1). Two windows of the same id are never up together
—the second replaces the first, as a picture of the same number does—, so
`windows::Registry` now gives each id the most tiles one `@window` of it
takes, its lines packed, and `OP_WINDOW` gives each line its own cells:
the runtime already packed the lines by those cells, so it is a compiler
change only. Desert Nightmare's windows went from 232 tiles to 228 with the
three screens added (the description box from 94 to 86).

**The squares' labels are cut to the 64 pixels of a square**, with the
game's own words: "Room No. 4" for "Room key No. 4", "Combination" for
"Safe combination", "Symbols sheet" for "Indian symbols sheet". The full
name is the box's first line when the square is lit. The original draws an
icon there, not the name.

**The notes and the maps themselves are big pictures** (`Notiz_Bild1` to
11, `Karte1` to 4, picture 17, opaque 320x240 canvases), and the console
already drew them —"common events 12: every picture they show is big"—,
but under the windows: the big pictures are BG1 and the windows BG2's
tilemap. The safe's note showed "Safe" over the grid and the code under it.
So **a big picture covers the windows under its number**:
`OP_WINDOW_COVER` (0x5B, the one handed out) after every big picture's
`ShowPicture` —the slots of the ids under its number— and `ErasePicture`
—none—, emitted by the compiler only in a game with windows;
`show_window.s` leaves the covered slots out of the span and the overlay.
The notes that are text (1, 2, 6, 7) stay pictures too: as windows over
the whole menu their tiles would not fit beside it, and the picture reads.

**Built.** the-advocate `cec66dfd` (the tiles: `windows.rs` and
`compile_window`, the runtime's comments) and `810d483c`
(`OP_WINDOW_COVER` 0x5B: the declaration, `window_cover` in the compiler,
`sw_cover` and the covered slots left out of `sw_span` and `sw_overlay` in
`show_window.s`, the entry in `interpreter_message.s`). The ports
`38808d9` (common events 9, 11 and 13 forked from `windows/menu.toml`,
which now has the keys', notes' and maps' text and says which pictures
stay pictures; `prompt.md` with the rule for a label wider than its
square; the test) and `0fb2535` (the six goldens). The book: the
decision, the VRAM page and the port's known issues.

**Space** (`just space` on Desert Nightmare's release; before, main at
the-advocate `7951af2a` and the ports `42f70e8` with the global tools):
bank 0 4,122 → 4,113 bytes free, bank $C0 655 → 631, bank $C1 1,319 →
1,297, bank 1 1,747 and BSS 77 the same, far RAM 136 → 135, the text block
47,562 → 48,886 bytes, data banks 79 → 78 of 126 used (gaps 41,165 →
51,158: the packing moved).

**What the screens look like**, side by side with the main build and the
original's own pictures stacked: `/shared/captures/2026-11-20-desert-nightmare-menu-keys/`.

**Not done**: the face behind the menu is lost after a note or a map is
put away (draft
[`desert-nightmare-the-menu-loses-its-face-after-a-note`](desert-nightmare-the-menu-loses-its-face-after-a-note.md));
the maps' mark of where Sandra is shows on few maps (the existing draft
[`desert-nightmare-the-map-cursor-is-shared-on-ten-maps`](desert-nightmare-the-map-cursor-is-shared-on-ten-maps.md));
the four notes that are only writing stay the drawing (as windows over the
whole menu their tiles would not fit); the second page of each grid, with
more than six keys or notes, was not opened.

**PPU window 1 and the cover** (after Calandria's finding, 2026-11-20:
`sw_lost` leaves `WH0`/`WH1` at the windows' edges, and the next message
masked only between them; her fix, `3c5b9e1c`, points window 1 edge to
edge in `msg_hdma_build`). `OP_WINDOW_COVER` does not add a path that
moves or restores window 1: covering every slot leaves `sw_span` with
none up, and `sw_tick` takes the windows off through `SW_HIDE` and
`sw_hide`, which puts window 1 edge to edge, when they were shown; when a
big picture's load already turned them off (`sw_lost`), nothing is
written, and the leak is the one her fix closes at the next message.
`sw_lost` and `sw_hide` are untouched here.

**Verified** with the branch's tools (`events`, `convert`, `mapdata`,
`cartridge`, `rm2k-snes-audio` installed locally): the crates' tests of
events (two new: `each_id_gets_the_tiles_its_widest_window_takes`, and
`a_big_picture_covers_the_windows_under_its_number`, red before the
opcode existed), bytecode, convert, mapdata and cartridge; `just test`
(29); the ports' `test_desert_nightmare_menu.py` (four, the new one with
six goldens; the earlier goldens did not move) and
`test_desert_nightmare_safe.py`; the ports' `just boot`, 179 passed; ABL's
`just tests`, 1,723 passed and 2 skipped, `abl.sfc` `2185934c…`. **Not
covered by any test**: the keys and notes added by the game's own pickup
commons (15 to 18: the test writes their variables), the grids' second
page, a big picture shown over windows with a higher id than its own (no
game has one), the cover across a save and a load, and anything on real
hardware.

**To merge** (main had not moved: the-advocate `7951af2a`, the ports
`42f70e8`, the book `0d2f8d4`): the-advocate `mulita-dn-menu-keys`
(`OP_WINDOW_COVER` is 0x5B; whoever else took 0x5B renumbers), the
ports' and the book's `mulita-dn-menu-keys`. Install `events`,
`convert`, `mapdata`, `cartridge` and `rm2k-snes-audio`; the runtime is
the checkout's. The goldens are in their own commit, `0fb2535`.

**After merging main** (Cardón's walls: the-advocate `82ce793c`, the ports
`3fe8f6d`): his `map_pictures` rule is the converter's, for a map's own
pictures; the menu's commons and the cover opcode do not reach it. With
the merged tools: `just test` 29, the DN menu and safe tests 7 passed —
**none of the six new goldens moved**, nor the earlier ones—, the ports'
`just boot` 182 passed, ABL's `just tests` 1,723 passed and 2 skipped,
`abl.sfc` `6b0c217d…`.

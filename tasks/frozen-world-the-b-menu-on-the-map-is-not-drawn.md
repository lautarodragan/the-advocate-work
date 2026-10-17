---
name: "Frozen World: the menu B opens on the map is not drawn"
description: "Pressing B on the map opens something with three options that works blind —equipment, items, a stats message— but nothing is drawn"
type: bug
status: doing
assignee: Mulita
agents: [Mulita]
---

taro, on 2026-10-17, playing Frozen World on Mednafen: pressing B on the
map nothing is seen, but something reacts. Counting the up and down
presses, there are three options; A on them opens the equipment menu, the
items menu and a message with stats. Which system it is was not found in
the editor.

## Log

### 2026-10-17, Mulita: what reacts to B

Starting from the-advocate `b15c9408`, the ports `bd92975`, the book
`df2b2b8`.

* **Who reads B**: almost every map has a parallel event —map 11's event
  9, page 1, on switch 213— that does `KeyInputProc` into variable 79 and,
  on 6 (cancel), turns **switch 220** on.
* **What 220 runs**: common event 15, `BringUpMenu`, automatic on 220. A
  menu of three states built with labels: `ShowPicture` 1 at (160, 120)
  —`MenuEquipPlates`, `MenuItemManage` or `MenuPartyStats`, 109x64 each,
  the box with the option lit—, `KeyInputProc` into variable 80, and
  up/down jump to the other label and show the other picture; A erases it
  and calls the equipment menu, the item menu or common 31 (the stats
  message); B erases it and turns 220 off.
* **Why nothing is drawn**: an automatic common event is a shared body
  compiled once, without a map, so without pictures —the draft
  [`pictures-in-common-events-compiled-apart-are-not-shown`](pictures-in-common-events-compiled-apart-are-not-shown.md)—.
  The cartridge's `degradations.json` says it: nine `picture-not-shown`
  under `"common": 15`. The rest of the body —the keys, the labels, the
  menus it opens— runs, which is why it works blind.

Correction to the above: A on "Equip Plates" and "Item Management" does
not open a menu of the engine: it memorizes the place and teleports to
map 2 ("Plate Placement") or map 14, the game's own screens; on "Party
Stats" it calls common event 31, the message.

### 2026-10-17, Mulita: the fix

* **The copies**: the converter copies each automatic common event with a
  `ShowPicture` of its own into every map with room for one more event,
  as the automatic pages of an added event 0 on its switch —the place the
  test pages' event takes; not on the map they boot in—. Compiled with
  the map, its pictures are the map's. The scan says how many of a map's
  pictures are its own, and Wally takes the copies' only if they cost
  nothing —placed and fitting a layout as the map is—; otherwise the map
  is converted with its own and a `pictures-not-drawn` says so. On the
  first try map 6 lost a still animation to them, which is why they never
  cost anything now.
* **The order was not enough**: the B event is a parallel page; the switch
  it turns on is seen by `common_start` on the same frame, and the copy's
  page only on the next one. So the runtime's `switch_of` reads the switch
  of an automatic common event as off on the maps that carry its copy
  (`comauto_copied`, `comcopy_maps`, from mapdata).
* **Verified**: `test_b_draws_the_menu` in the ports' `tests/test_frozen_world.py`,
  red with the global tools (0% of the menu's box changed), green with the
  branch. Captures, before and after, in
  `/shared/captures/2026-10-17-frozen-world-b-menu/`. The menu fits most of
  the game's maps; the converter's log names the rest.
* **What remains**, as drafts:
  [`frozen-world-the-menu-s-lit-option-loses-its-text`](frozen-world-the-menu-s-lit-option-loses-its-text.md)
  and
  [`frozen-world-the-b-menu-is-blind-on-the-maps-without-room`](frozen-world-the-b-menu-is-blind-on-the-maps-without-room.md);
  and the draft this one hung from,
  [`pictures-in-common-events-compiled-apart-are-not-shown`](pictures-in-common-events-compiled-apart-are-not-shown.md),
  says what of it is still open.

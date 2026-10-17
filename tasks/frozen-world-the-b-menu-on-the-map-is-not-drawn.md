---
name: "Frozen World: the menu B opens on the map is not drawn"
description: "Pressing B on the map opens something with three options that works blind —equipment, items, a stats message— but nothing is drawn"
type: bug
status: done
assignee: taro
agents: [Mulita]
---

taro, on 2026-10-17, playing Frozen World on Mednafen: pressing B on the
map nothing is seen, but something reacts. Counting the up and down
presses, there are three options; A on them opens the equipment menu, the
items menu and a message with stats. Which system it is was not found in
the editor.

## Log

### 2026-10-17, taro's confirmation

Relayed by Hornero the same day: under Wine, with the original runtime,
pressing B on the map shows a custom menu, probably built with
`ShowPicture`, and the SNES ROM shows nothing there. It is what the data
says below: three pictures of common event 15. No capture of the original
was taken for this task: the game's own three pictures are next to the
console's in the captures' contact sheet.

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

### 2026-10-17, Mulita: three corrections after the suites

* **Only where the switch can be turned on**: copied into every map, A
  Blurred Line's two automatic common events with pictures (11 and 16,
  menus nothing starts) did not fit its release cartridge. Now a common
  event is copied only if something can turn its switch on, and only into
  the maps that can: their pages and what they call, or every map when a
  parallel or automatic common event can. A Blurred Line gets no copies.
* **Last, not event 0**: at index 0 the copies' event moved every event
  of the map one place, and the ports' test of Desert Nightmare's shop
  owner, which numbers events from the data, found no route slot. The
  copies go in a last event, with the id after the highest, and the map
  the test pages boot in carries it too.
* **The copies' pictures cost nothing else**: Wally compares the map's
  losses with them and with its own pictures only —the rain, a battle
  animation's box, a lent palette—, not just whether it fits.

Desert Nightmare (common events 12 and 14) and Sunset Over Imdahl (5)
get copies too; neither was played with them.

### 2026-10-17, Mulita: to testing

Branches `mulita-fw-b-menu` in the-advocate, the ports and the book, with
main merged (the-advocate `eb8fff44`, Aguará's lag fix, included).
Verified on the merged tree with the branch's tools: ABL's suite green,
and the ports' `just boot` green, `test_b_draws_the_menu` and Desert
Nightmare's shop owner included. Sunset Over Imdahl (common 5) and Desert
Nightmare (12, 14) get copies too, and nobody played them.

**To install when merging**: `cartridge events mapdata convert wally`
(the runtime changed: `switch_of` in `common_events.s`, with the tables
mapdata writes).

---
name: "Frozen World: the B menu is still blind on the maps without room for it"
description: "On the maps whose sprites have no room for the menu's three pictures besides their own, B opens the menu and nothing is drawn, as before"
type: bug
status: draft
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

The maps the copy does not reach at all —the one the test pages boot in,
and any with no room left for one more event— run the shared body,
blind, as before; Frozen World's B event is on none of them today.

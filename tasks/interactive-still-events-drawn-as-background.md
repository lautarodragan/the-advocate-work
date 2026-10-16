---
name: "Interactive still events drawn as background"
description: "A map with more still NPCs than the sprite VRAM holds could draw the ones that do not fit as background tiles and keep their action page: today only events with no commands go to the background"
type: feature
status: draft
---

Left by Calandria on 2026-10-16, from taro's plan for Dooms 2's map 1
(`dooms-2-slots-and-menu-dont-fit-in-their-bank.md`), tools `30ab0ca6`,
ports `f8aca68`: "a general optimization: events that do not fit drawn as
BG while keeping them interactive".

**What was measured**: it is not needed for the map it was thought of.
Dooms 2's map 1 —20x15, black, 18 events, 16 with a graphic, all still
and all on the action key, 11 distinct CharSets— gets through the converter
today with "31 characters, 29 slots, 500 tiles in VRAM, 8 palettes", with
21 graphics drawn with someone else's palette (`palette-lent`) and without
rain. What stopped the map was the slot screen's bank, fixed that day. No
map of the eight ports stops at the sprites' VRAM today: Vampires Dawn's
that did not fit are `vampires-dawn-maps-that-dont-fit-in-vram.md`.

**What exists already**, and what this would add:

* `[graphics] decorative_events` (`decorative-events-into-the-background.md`)
  bakes into the background the events that are **only** aesthetic: one
  page, no commands, nobody moves them. An NPC that is talked to has
  commands, so it stays a sprite.
* `108-with-shared-poses.md` makes the still ones that no camera shows
  together take turns on a VRAM slot, on the map that does not fit
  without it.
* What is missing is the middle: an event that **never moves** —no
  `move_type`, no route, no page that changes its graphic— but has an
  action page, drawn as background tiles in its cell while its page stays
  in the event table. Its cell is already a blocked one for the hero, and
  the action key looks at the table, not at the sprite, so the runtime
  would need nothing for the talk; what it needs is for the page's
  graphic to be one the map's background carries, and for a page change
  —a switch that flips the NPC to another graphic or makes it walk— to
  bring it back as a sprite, which is the hard part: a baked tile cannot
  move.

**How to see it**: there is no map that needs it today; measuring it
would be taking a map past the sprite limit on purpose, like
`vampires-dawn-maps-that-dont-fit-in-vram.md` lists.

---
name: "Interactive still events drawn as background"
description: "`baked_events` already paints still events with action or touch pages into BG1 when every pose fits their cell; what it refuses is a person-sized NPC (past its cell) and one that turns toward the hero when talked to. Painting those —a two-cell drawing, a turn that rewrites the cell— on a map past the sprite VRAM"
type: feature
status: wishlist
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

## Defined

On 2026-10-16, by Carpintero.

No map of the eight ports needs it today. **Done**: a still NPC with an
action page that does not fit in the sprite VRAM is baked into the
background, still talks, and goes back to a sprite when a page change
needs it —or the converter refuses that case and keeps it a sprite—,
shown on a map taken past the limit on purpose. Becomes `todo` when a map
stops at the sprites' VRAM.

## Log

### 2026-11-17, Hornero: reviewed

Much of this was done by `baked_events` (2026-11-02 to 11-17: see
[`still-events-that-change-pose-painted-into-the-background`](still-events-that-change-pose-painted-into-the-background.md)
and [`posed-events-tolerate-a-few-pixels-of-overflow`](posed-events-tolerate-a-few-pixels-of-overflow.md)):
the event stays whole —its action and touch pages too— and only its
drawing moves to BG1; ABL's signs and doors went in. What it still refuses
is a talking NPC: one that turns toward the hero (`posed.rs`, triggers
0/1/2) and any pose past its 16x16 cell, which a person always is. In ABL,
139 events stay objects for a pose past the cell and 43 for turning. And
`baked_events` bakes when allowed, not as a fallback when sprite VRAM runs
out; the only map stopped by VRAM is still Vampires Dawn's
([`vampires-dawn-maps-that-dont-fit-in-vram`](vampires-dawn-maps-that-dont-fit-in-vram.md)).

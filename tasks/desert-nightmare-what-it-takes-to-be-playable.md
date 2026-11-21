---
name: "Desert Nightmare: what it takes to be playable"
description: "A study: play Desert Nightmare's port through the harness as far as it goes, list what breaks or looks wrong against RM2k, find the causes, and rank what would make it playable by cost and gain"
type: research
status: done
assignee: taro
author: taro
agents: [Hurón]
game: desert-nightmare
---

taro, on 2026-11-19, translated:

> Desert Nightmare and Vampires have many bugs —they are too close to the
> limit of what we can make work on the SNES. Maybe it is worth doing a
> research on what we could do to make Desert Nightmare work well? That
> game surprised me a lot —it looks very good, but it is practically
> unplayable in our current port.

What is known (the book's port page, "Known issues", 2026-11-19): crowds
cut on 53 maps; the start menu over garbage; white rectangles where the
roofs go (map 4; 14, 61, 66 too); characters not shaded by the lights
(drawn into the map); the menus keep the intro's System; two apartments
keep their first background. Open tasks: `desert-nightmare-own-message-frame`
(todo), `desert-nightmare-start-menu-over-garbage` (todo),
`desert-nightmare-roofs-left-out-show-white` (draft),
`desert-nightmare-characters-cut-on-crowded-lines` (draft),
`desert-nightmare-title-is-silent-without-msu-1` (wishlist).

**Done means**: a research page in the book, under the port's page, dated,
with the commits it measured: how far the game plays through the harness
(and with RPG_RT/EasyRPG for comparison), each thing that breaks or looks
wrong with its cause, which limits are the console's and which are ours,
and a ranked list of tasks —cost, gain, what each unblocks— so the next
steps are clear. The new findings as drafts and Known issues lines.

## Log (Hurón, 2026-11-19)

At the-advocate `62b6e5cb` (the global tools, installed from it) and the
ports `1ea90bf`, Desert Nightmare's `release` built in my worktree of the
ports. Throwaway scripts in `~/scratch/huron/dn/`.

* **The build** (5 min): `degradations.json` counts 584
  `picture-not-shown`, 222 `pictures-not-drawn`, 183 `event-left-out`;
  `just culprits`: 28 of 30 commons compile, 6,769 of 6,773 map pages.
  The two commons out are **20, "Sache benutzen" (use an item)** and 14
  (the map screen), both for `ControlVars` of the hero's **map id**
  (`[0, 19, 19, 0, 6, 10001, 0]`); common 8 calls 20 and the call is
  skipped. The four pages out are the number locks: maps 28 (71456, the
  warehouse safe of day 1), 42, 123 (1759) and 156 (136264) —an
  `InputNumber` alone after the message, which the ROM does not do, and
  two numbers past sixteen bits—.
* **A sweep of every map** (`sweep.py`: a door's teleport, 240 ticks
  tapping A and walking): no map hangs the ROM except four that end on
  map 1 (93, 137, 147, 151 —"no tick in 3000 frames"—, to look at); every
  map with more than ~50 drawn events runs at **2 to 2.65 frames per
  tick**, half speed or less: 2, 3, 4, 5, 6, 11–14, 43, 59–62, 172…
  Under ~50, 1.0. The PPU's time over, every frame on 59 maps.
* **On map 2, with no event drawn (+14 of every row zeroed), 1.0 frame
  per tick; as is, 2.0.** The slowdown is drawing the events, not running
  them.
* **Map 2 has no buildings**: the motel, the store and the gate are 83
  still events cut from CharSets (`Motel`, `Allzweckladen`) over a
  panorama with white holes; the console draws none —the cache has 15
  slots for 80 on screen— and RPG_RT under Wine draws the whole street.
  `decor.rs` bakes only events inside their 16x16 cell; these are 24x32
  pieces, and the 16 it takes "moved the background's CGRAM split".
* **The game's own menu is invisible**: B opens it (common 4, a
  `KeyInputProc` in a parallel), its pictures (`Introauswahl`,
  `Optionen1..5`, the inventory's 155, every one a 320x240 canvas) are
  "not shown here", and A on the invisible "Inventory" says "You have no
  items". 
* **The playthrough** (`stages.py`, with save states): title, "With
  Intro", control on map 16 at tick 11,404, the desk, the street, the
  gate, the bar and Jake, the gate opened, the alley and the dog, the box.
  **Stop 1, map 12**: the box pushed to (12, 4) shares the cell with event
  87, the climb; `event_in_cell` returns the box's row and stops. With the
  box's row moved off by hand, the climb works. The same on map 2's gate:
  the dog's invisible row on (13, 0) hides twin 151. Past the box by
  hand: the warehouse, the bulb, and **stop 2, map 26**: B, Inventory, the
  bulb, nothing (common 20). **Stop 3**, not reached: the safe (map 28).
* **`baked_events = true`**, on a scratch build: 32 events into the
  background on maps 48, 104, 105, 182; 73 stay objects; no town map is
  a candidate. Not committed.
* **The sweep's four "hung" maps** run from a fresh boot; 147 is a death
  scene that ends in the title. No hang found.
* **Wine/EasyRPG**: the menu, map 2 and the motel under RPG_RT 2015; six
  towns under EasyRPG at the port's cells.

## Done (2026-11-19, Hurón)

* The research, in the book (branch `huron-dn-playable` of
  the-advocate-docs): `src/ports/desert-nightmare/research/2026-11-19-what-it-takes-to-be-playable.md`,
  in `SUMMARY.md`, linked from the port's page, and seven new lines in
  its "Known issues".
* Five drafts: [`a-second-event-on-a-cell-is-never-asked`](a-second-event-on-a-cell-is-never-asked.md),
  [`desert-nightmare-items-cannot-be-used`](desert-nightmare-items-cannot-be-used.md),
  [`desert-nightmare-the-number-locks-do-not-open`](desert-nightmare-the-number-locks-do-not-open.md),
  [`desert-nightmare-the-game-s-menu-draws-nothing`](desert-nightmare-the-game-s-menu-draws-nothing.md),
  [`desert-nightmare-the-towns-run-at-half-speed`](desert-nightmare-the-towns-run-at-half-speed.md);
  and sections added to
  [`desert-nightmare-roofs-left-out-show-white`](desert-nightmare-roofs-left-out-show-white.md)
  and [`desert-nightmare-own-message-frame`](desert-nightmare-own-message-frame.md).
* Captures: `/shared/captures/2026-11-19-desert-nightmare/`, with a
  `README.txt` and two contact sheets.
* Nothing to install: no code changed. The ports' branch
  `huron-dn-playable` has no commits.
* **Not fixed, on purpose** (a study): the cheap ones are the ranking's
  1 and 2 —every event on a cell, and the hero's map id—.
* **Seen and left as it is**: the start menu over garbage, still in the
  port's "Known issues", is not seen (the title and the menu are right,
  as Chajá saw on 2026-10-20); its line goes with the golden its task
  asks for.

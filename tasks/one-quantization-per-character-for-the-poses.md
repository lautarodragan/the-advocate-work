---
name: "One quantization per character for the poses"
description: "A character quantized differently in another map carries its own pose bank: in VD that's 420 of 1,239 banks, and the poses (4.26 MB) can't go into the .msu"
type: feature
status: done
agents: [Mulita]
assignee: taro
---

From `vampires-dawn-builds-from-its-toml.md` (Aguará, 2026-10-11):
mapdata's `record.rs` stores a bank of twelve poses per (CharSet, index,
data), and a character that comes out quantized differently in another map
carries a bank of its own —506 "goes with a pose bank of its own" warnings in
VD's build—. It's what would bring back the most VD maps: the nine left out
today because of the ROM (95, 164, 170, 219, 221, 222, 239, 338, 429), and room
for the ones that come back with the other fixes. How much it saves wasn't
measured; on the order of a MB by rough count.

## What was measured (Mulita, 2026-10-11)

Base: the-advocate `0bb1120a`, ports `c914245`, in own worktrees
(`mulita-poses-por-personaje` in both). The measurement is on the request
to `rm2k-snes-mapdata emit` of VD's build **with the nine "poses" ones
brought back** (14 left out), copied with a wrapper of `rm2k-snes-mapdata`
in the PATH; the scripts are in `~/scratch/mulita/poses/`. (That build
stops at the troops, 257 of 255 —Hurón's thing—, but the request is already there.)

* **985 characters with a bank, 1,498 banks, 103 characters with more than
  one: 513 extra banks.** Distinct poses: 10,095, 4.93 MB. With a single
  bank per character it would be 5,257, 2.57 MB: **2.4 MB ceiling**.
* **Six characters are 367 of those 513**: `Extra2:2` (75 banks),
  `F04:5` (70), `Darkages:1` (62), `Valnarposen:4` (57), `F04:1` (55) and
  `UnPoses2:1` (54), each in the 426 maps. They are the graphics of
  `ChangeSpriteAssociation` —Valnar's and Asgar's transformations into
  wolf and bat—: the compiler reserves them a spot in the graphics table of
  **every** map (`associations`), so Wally allocates
  them in each map as graphics of command 34, "while they fit".
  They almost never fit: they go **borrowed** (`drawn with someone else's`) in
  329, 224, 187, 136, 83 and 69 maps, and borrowed means quantized
  to the nearest color of someone else's palette —a different one in each map—.
  Just those six, with one bank each: 10,095 → 6,603 poses, **1.75 MB
  less**.
* **Why they change**: of the 513, 432 change the partition of the
  pixels (other colors grouped: borrowed, or a 15-color palette chosen
  over other poses, or the timer's cap) and 81 only the indices (the same
  drawing in another order inside a shared palette). The map's palette
  doesn't reduce colors: Adeleine doesn't step in on sprites except
  `merge_least_visible` for the one that goes over 15.
* **What is seen today**: those transformations are drawn with the colors
  of another character in most maps.

## What was chosen

The graphics that **only the hero shows** —those of `ChangeSpriteAssociation`
and those of command 34 on the hero, which no route gives to an event—
are another face of a leader, and go like the leaders that share the spot:
in the leaders' palette, with **their own colors**, which the console
uploads when the hero takes them (`hero_cgram`, as with a leader). So:

* its pose bank is the same in all maps (the color search
  is that of the character alone, sorted);
* they don't take a palette from the map: the NPCs and the borrowed tiles go down on their own;
* and they're seen with their colors, not with someone else's.

It changes in five places: `events` (which graphics a route gives to an
event: `graphics_on_events` in the scan), `convert` (`hero_graphics` to
Wally), `wally` (puts them in the leaders' palette, and gives the colors
of each graphic that falls in a leaders' palette), `mapdata` (the cartridge's
`hero_colors` table, and one byte per graphic after
`route_graphic`) and the runtime (`hero_poses_of_graphic` points
`hero_cgram` there, and `graphic_hero` runs `apply_tint`).

**Measured with that** (the same VD build with the nine): 1,498 → 1,163
banks, 10,095 → 6,717 poses, **4.93 → 3.28 MB, 1.65 MB less**. The
maps with something borrowed, from 365 to 77. What remains from quantization:
168 extra banks, 714 KB ceiling, spread out (`Object1:7` 10 banks,
`leuteposen3:4` 8, `chara07:4` 7…).

**Why those and not all**: the six are 1.65 of the 2.4 MB ceiling and
have a fix that also improves what is seen. The 168 banks that
remain are of characters quantized differently in a few maps each
(other visible poses, a shared palette in another order, the timer's
cap); unifying them asks Wally's palette allocation to respect an
order of indices per character across the whole cartridge, and that can cost
palettes —more borrowed ones, which is a visible error—. It wasn't done: 714 KB of
ceiling, and VD already fits.

## What was done

Branches `mulita-poses-por-personaje`:

* the-advocate: `d3f1c486` (events, convert, wally, mapdata and runtime) and
  the merge of origin/main (`5d7d5601`, Hurón's thing) in `335194a8`.
* ports: `ce6e7a7` (the `graphic-hero-own` case: command 34 on the
  hero to `Crown7:3`, and `Crown7:3` in `release`'s `test_graphics`),
  `41bbe3a` (its four goldens), merge of origin/main `0982cf0`, and
  `e575020` (VD: the eleven from "the ROM" come back).
* the-advocate-docs: `ff1e9ad`, the decision
  `decisions/the-graphics-only-the-hero-shows.md`, and a note in the
  one about command 34 on the hero. Links checked.

**Verified**, with `just install-local .local-tools events wally mapdata
convert cartridge`:

* `just test` (27) and `crate-test` of events, wally, mapdata and convert
  green. The hash tests against the Python strip the new stuff just as they already
  stripped the rest that came later (`without_hero_colors`, and
  `graphics_on_events` from the scan), and with that they give the same hashes.
* ABL's suite: 1202 green before the new case, without moving a
  golden; with the case and on top of the merge, **1203 green**, `abl.sfc`
  `27d989db75901791…`. The new case, seen red without the `apply_tint`
  of `graphic_hero`: 212 pixels in frame 20.
* VD with the eleven brought back (**10 left out**, of 21: 1, 15, 57,
  99, 150, 165, 225, 399, 402, 403): `just cartridges` rc 0, 138 s; 12,362
  pieces in 127 banks and 1,281 in the `.msu` (6,092,634 B). Poses: 6,744
  distinct, 3.45 MB. Whole free banks: 0 (the allocation fills the ROM
  with what could go into the `.msu`); what's left of margin are the
  LZ2 streams that are still in the ROM and can leave: ~0.64 MB.
  In snes9x with the `.msu`: it starts in 3 and with A goes to the house.

Captures in `/shared/captures/2026-10-11-una-cuantizacion-por-personaje/`.

**What nothing covers**: a `ChangeSpriteAssociation` to a graphic that
isn't a leader's (the suite's one, `sprite-actor`, is `Future1`; it goes through
the same routine as command 34); no VD transformation was looked at on
the console, nor the eleven maps brought back. Command 34 on the hero now
runs `apply_tint`, which costs CPU in that frame: it wasn't measured whether it shows.

On merging: reinstall `events`, `wally`, `mapdata`, `convert` and
`cartridge` (the runtime changed).

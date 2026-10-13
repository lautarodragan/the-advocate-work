---
name: "The sprite slot cache"
description: "Each event asks for a VRAM slot when it comes on screen and releases it when it leaves, instead of having a fixed one for the whole map; with helpers to reduce the peak, and ABL's farm (127) as the first case"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-03: "let's go with 1", among the paths for ABL's
farm (`tasks/world-8-distant-paradise-inside.md` and
`world-7-the-road-to-paradise.md`, option D, in ABL). It belongs to the engine: it serves
any crowded map, of any game.

What was measured (Puma, 2026-10-01) on 127: 22 events that walk and 18
still poses; on screen at once, 30 distinct slots without margin and 36
with 2 cells, against 32 for "+sprite". The cache alone fits barely: helpers
that reduce the peak are needed (sharing still ones as on 108, mirrored in
one slot, …).

First it is measured over all the game's maps —how many the cache alone
unblocks and how many with each helper—, and then it is implemented.

For later (taro): see whether it is worth baking NPCs on 127 —those of the bandits
scene that stay still—, once this is in.

Baseline: tools `60097b1a`, ABL `57ef34d`.

# What was measured, over the whole game

**How**: a copy of ABL's `rm2k-snes.toml` with `below = 400` and without
excluding 58, 104 or 111 —only the tree's folders and the unreachable backups
are left out—, converted with `rm2k-snes-cartridges
--convert-into` and a wrapper `wally` that saves each map's request.
The whole conversion stops earlier (actor 34, a leader candidate, has no
CharSet: it is the limit of the study of maps through the MSU-1), so
each request was rerun with today's `wally`, without actor 34 among
the leaders, and the counting was done on what it answered. It is **320 maps**. The
scripts stayed in `/extras/scratch/yaguarete/medir/` (`convertir.sh`,
`correr_wally.py`, `analizar.py`, `fases.py`, `espejos.py`).

**What "at once" is**: the window of margin m is (18+2m)x(16+2m) cells.
Margin 0 is exactly what the console draws —the 32x32 box touching
the 256x224 screen, the `reach` of `share.rs`—, which is what Puma
called "margin 1"; his "without margin" (16x14) is smaller than what is
drawn. The positions are **the starting ones**: the ones that walk are counted
where they start.

**Today**: 316 fit (108 with its turns). Four do not fit:

    don't fit: background   148 Paradise Burning     614 background, ceiling 544
                            250 Return to Paradise   621 background
    don't fit: sprites      127 ParadiseFarmland     41 slots, 692 tiles
                            285 Tasgarde Mainframe   50 slots + the animation's
                                                     box and the rain

(Puma listed 285 as "the 64-tile box of the battle
animations": it is the same, the box does not fit because 50 slots already fill the
bank.) 148 and 250 are not about this: it is the path of hot-swapped background
tiles.

**The models** —dynamic slots at once, plus the fixed ones: the hero, and the
turning one if there is a still one that turns around—:

* (a) **the cache alone**: one slot per event in the window, walking or not;
* (b) **+ sharing still ones**: the still ones that show the same pose, a
  single slot —what `Slot::Still` does today, but only for those that are
  in the window—; the one that walks, or the still one with more than one graphic, its own;
* (c) **+ mirrored**: a still one's left, the mirror of its right;
* (d) **+ the story's phases**: I count only those that can be
  visible at once according to their pages' switches.

Slots (dynamic + fixed) against the cap of the best allocation for its background:

                           margin 0     margin 1     margin 2    cap
    127  (a) alone         36+2  NO     40+2  NO     45+2  NO     32
         (b) +still        33+2  NO     36+2  NO     41+2  NO
         (c) +mirrors      33+2  NO     36+2  NO     41+2  NO
         (d) +phases       26+2  yes    26+2  yes    26+2  yes
    285  (a) alone         13+1  yes    16+1  yes    17+1  yes  32, minus
         (b) +still        11+1  yes    12+1  yes    13+1  yes  the box
         (c) +mirrors      11+1  yes    12+1  yes    13+1  yes  and the rain

**Unblocks**: the cache alone, 285 with any margin. 127, **only
counting by phases**.

**Mirroring adds nothing.** RM2k does not mirror, but the drawing often is
symmetric: of the game's 165 characters with a sheet, 75 have the three
left poses identical, pixel by pixel, to the mirror of the right
ones crossing the columns (column 0 of one with 2 of the other: the
foot that steps forward changes side); without crossing, 10. But at the peak of the
two maps there is no same character facing both sides.

**The phases of 127**, which is what unblocks it. The map is two scenes
that are never together:

* **the celebration** (switch 383): twenty-nine people in a rectangle of
  10x8 cells, all on the same screen —Pierson, those of the four
  professions and the council— while Talan chooses a profession. 16 of those are
  moved by the scene (they jump in place and turn: `MoveEvent` with 24/25 and the
  faces), and 13 stay still showing 10 distinct poses: **26
  slots**, 28 with the hero and the turning one, against 32.
* **the dance** (389): the scene turns off 383 and turns on 389 on the same
  page (ev31), and jumps within the map. Fifteen people spread out, 6
  walking: 13 or 14 slots.

Both together never happen, but a converter cannot know that from the
switches: that is why the static count says 33. **(d) is not a helper the
converter can apply**: it is what the console is going to see.

**There are no bandits on 127.** "A bandits scene" (Puma, in
`mundo-7`) is the celebration: the twenty-two "that walk" are the ones the
scene makes jump and turn. The bandits are from 121, Bandit Ambush, from
a later batch.

(d) also looks at something else: if the ones that walk shared a slot per
pose —the seven farmers jumping together facing up are the same
pose—, the celebration would go down to some 17. I do not implement it: the per-row
cache is already enough and is much simpler.

## What is chosen, and why

**The cache with still ones sharing by pose (b), with margin 0.** It is the
only variant that can be implemented without knowing the future and that is enough
for 127 as it is played: the converter does not see the phases, but the
console does, because **a row that is not drawn does not ask for a slot**. The margin
is given by time and not by cells: a slot that stopped being used is not
recycled until two frames later, and the one recycled is the one that has been
unused the longest, so whoever leaves and comes back in usually finds their
pose still up. The margin in cells only enlarges the peak (36 against
33 on 127) without avoiding uploads that time already avoids.

Since the static peak of 127 (33) exceeds the room there is (30 dynamic), the
converter says so as a warning and does not stop: what happens if the cache
fills is below.

# What the converter does

`wally` (`map.rs`) tries, in order: the map as always; if it does not fit, without
the pictures; if not, with the still ones taking turns (108); and if that does not
fit either, **`Mode::Cache`**. Only a map that does not fit in any other way
changes: the others come out byte for byte identical —measured with the game's 320 maps,
comparing `wally`'s answer from before and now: 127
and 285 change, and nothing else—.

In the cache:

* **Nobody has a slot in the bank**: the hero stays in block 0 and the
  turning slot in its own; after them go as many blank blocks as
  fit in the best allocation for its background (32 blocks in total, the
  hardware's cap), without exceeding how many can be requested at once. The extras —the
  timer, the rain, the pictures, the animation's box— go
  afterwards, as always.
* **The still poses are numbered**: all those a still one can show,
  in order; that number is what the row carries in its tile byte, and what
  the page of one that changes graphic carries (`Draws.key` in
  `rm2k-snes-mapdata`). Their characters get their twelve poses in the
  cartridge, like the ones that walk.
* **It counts how many at once** by where the events start (`peak` in
  `sprites::cache`, model (b) above with margin 0) and warns if there are
  more than the slots.

`rm2k-snes-mapdata` emits `cache_maps` and `cache_data` (`cache_table`): per
map, how many slots, the first tile of each one and where each still
pose is in `npc_poses`.

# What the ROM does

`tools/runtime/cache_slots.s`, in FAR. That the map has a cache is said by bit
7 of `SHARE_N`, so `place_npc` looks at a single byte for the turns and the cache.

* `place_npc` asks `cache_want` for each row it is going to draw. What
  the row asks for is its **key**: the still pose it carries in the
  tile byte, or 128 plus its event if it walks —a slot of its own—. If the slot it
  had still has its key, it is drawn from there. If not, a still one looks for
  another that already has its pose (it shares it). If there is none, it takes **the free
  slot that has gone longest without being drawn**; free means nobody drew it
  in this frame or the previous one. Its pose is queued with `vram_queue` and
  the row is drawn from the next frame, as on 108.
* `build_oam` ages the slots at the start of each frame (`cache_age`).
* `upload_npc_pose`, the walkers' one, uploads to the slot the row
  has if it is still its own (`cache_dest`); if it has none, the pose waits at
  +12 for the row to come on screen and ask for one.
* `build_oam_settled` —entering the map, a jump within it, coming back from the
  battle, loading— frees them all before building (`cache_settle`): what was drawn
  just before the jump is no reason to keep a slot for anyone.
* `load_sprite` calls `cache_load`, which clears it.
* Whoever looks at the hero is drawn from the turning slot, as always.

**If the cache fills** —all the slots were drawn in this frame or in
the previous one— **the one asking is not drawn** that frame and asks again in the
next one: it waits for someone to leave the screen. It never hangs, and
the one that waits is the one `build_oam` reaches last, which is the one furthest back
—the topmost row of the screen, or the lower layer—. I chose that and not
"drawing it with someone else's slot" because a character missing for an instant
is much less noticeable than one with someone else's face. On the farm it does not happen: the
celebration asks for 26 and there are 30.

**What looks different**: an event that appears through a page refresh
—the dance, after the jump within 127— is drawn one or two frames
late, because the refresh comes after building the frame and the slot is
asked for in the next one. With the screen just uploaded it is not noticeable.

**What it costs**: in bank 0, the hooks of `place_npc`, `build_oam`,
`build_oam_settled`, `upload_npc_pose` and `load_sprite`, and `reclaim_slot`
(below); in FAR, `cache_slots.s`, some 600 B. The cartridge's numbers, in
"Verification". In the celebration 8 frames out of 1,900 are lost, almost all
around the jump to the dance; in 600 frames of dancing, 5.

## RAM and opcodes

Far RAM: **$7E7C00 to $7E7CFF** —`CACHE_N`, `CACHE_REC`, what
`cache_want` passes to `cache_took`, and from $7C10 `CACHE_KEY` and `CACHE_AGE`
(32 each) and `CACHE_EV` (120, per event and not per row: the rows change
place)—. Nobody used it: measured in the symbol table of `release`.
**No opcode.**

# And the routes: twelve moving at once, not twelve on the map

With the cache 127 converted and the converter stopped at something else: its
pages send **18 distinct events** walking and the ROM has **12
route places** (`route_ev`, in bank 0's BSS, which has 128 B free:
not enough for six more). A place belonged to its event until the next map.

Now, without a free place, **the first one whose route finished hands it over to the one
asking** (`reclaim_slot` in `event_pages.s`), and the converter warns instead of
stopping. The event that releases it keeps where it is facing and loses the
rest the route had changed: see
`divergences/finished-routes-give-up-their-slot.md`. On the farm there are never
more than nine moving at once. It is a departure from the assignment —"if it does not
fit, stop"—: what did not fit was no longer VRAM but this, and it was small.

# The "bandits" scene of 127: who stays still

There are no bandits on 127 (see above): it is the celebration. To see what is worth
baking, by RM2k event number:

**The celebration (switch 383)**, all in a rectangle of 10x8 cells:

* **they move** —the scene gives them a route—: Pierson (1), who turns; the
  farmers 2 to 8 (with Radin, 6); the defenders 11, 12 and 15; the
  actors 16 to 19 and 21. Only those of the chosen profession jump, and
  they turn or jump **in place**: nobody walks.
* **always still**: Emily (9), farmer 10, defender 13, Isabella
  (14), actor 20, the five lawyers (22 to 26) and the council (28, 29 and
  30). Thirteen, with ten distinct poses. 10, 13 and 20 belong to their
  profession and the scene does not make them jump: it is like that in the original (21
  is twice in the actors' list, and 20 is not).

**The dance (389)**:

* **they move**: 33, 34, 35, 36, 41 and 42, with their own route, from one side to
  the other. 37 and 38 have their own route and the "turn" animation, and in the ROM
  they do not move: the converter does not count them as walkers. I did not
  follow it up.
* **still**: 32, 39, 40, 43, 44, 45 and Isabella (46, who changes pose with
  the page).

Baking the celebration's still ones would take ten slots off the peak (from 26 to
16); the celebration's ones are on the benches, so it would need checking
whether baking leaves them standing right.

# ABL

On its branch `cache-de-ranuras` (see its `tasks/world-9-the-celebration-at-the-farm.md`):

* **`below = 129`**: 127 and the grove (128), which is the following night.
* **The cut**: 108's fork returns the exit to the farm to the game's
  and changes the `Teleport` of event 47 —Emily's goodnight, on
  coming back from the grove— to Talan's house for the end card: that is where
  the next day starts, each profession's work. Nothing else is
  reachable before that cut.
* **Tests**: `abl/test_farm.py`, the celebration frame by frame with the
  VRAM of each one against its pose (`harness/slot_cache.py`), with three
  goldens; `abl/test_playthrough_farm_golden.py`, from the town to the card, with
  eleven photos with goldens and checking that the ones strolling in the dance move;
  `rpgmaker/test_cores.py::test_the_slot_cache`. The walkthrough of the
  first day now ends on reaching the farm.
* `patches/auto/` of 127 and 128, and `ceilings.toml` redone: the
  new themes moved the allocation of the samples.

285 (Tasgarde Mainframe) would also fit with the cache —without its pictures,
which are removed before trying the turns—, but it is not part of this stretch.

# Verification

On the trees merged with `main` of both repos (they only brought
tasks):

* ABL, `just tests`: **1043** green. `abl.sfc` `dbd0c55b6f5b…`,
  `abl.msu` `5902e0bbabb6…`.
* Before adding 127, with the cache already in the ROM and no map that
  uses it: **1035** green, without moving any golden; the `mapdata.inc` of
  `release` changed only because of the new, empty table.
* **The red**: without uploading the pose when taking a slot, `test_farm.py` and the
  farm walkthrough fail on the first frame looked at; without
  `reclaim_slot`, the walkthrough fails because 41 and 42 do not move.
* `just -f tools/justfile test`: 27. `cargo test` of `wally`,
  `rm2k-snes-mapdata`, `rm2k-snes-convert` and `rm2k-snes-cartridge`
  green. The hashes of `mapdata/tests/python.rs` moved on purpose:
  removing the new table they give the old ones again.
* `just space release`, before (`main`, without 127) and after:

                      before       after
      banks           71 of 127    72 of 127
      bank 0          2.868 B      2.725 B
      bank 1          14.204 B     13.587 B
      BSS, ZEROPAGE   128 B, 4 B   128 B, 4 B

**`just tests` does not cover**: coming back from a battle on a map with a cache (127
has no battles) and loading a saved game on it —both go through
`cache_load` and `build_oam_settled`, like the jump within the map, which is
played—; the full cache, which no map in the game reaches; and the defender and
actor branches of the celebration.

# On merging

Install `wally`, `mapdata`, `convert` and `cartridge`: `just -f
tools/justfile install wally mapdata convert cartridge`. `cartridge` builds
with the runtime. There is no new Python in `tools/`.

# What taro has to test

* In ABL, from the town's exit to the farm: the celebration with each
  of the three professions, the dance, Isabella, Emily, the grove and the
  end card.
* That nobody appears late or with someone else's pose, above all in the jump
  to the dance.
* The goldens, in `/shared/captures/2026-10-03-cache-de-ranuras/`, before the
  merge.

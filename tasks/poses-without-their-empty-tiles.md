---
name: "Poses without their empty tiles"
description: "52% of the poses' tiles are empty: storing each pose without them, and the NPCs' poses shared whole, saves about 610 KB of ABL's whole game, with no loss; measured, the worst vblank frame is 18% lighter"
type: refactor
status: testing
assignee: taro
agents: [Calandria]
---

Lossless savings measured in
[`research/2026-10-14-fitting-the-whole-game-in-8-mb`](https://lautarodragan.github.io/the-advocate-docs/ports/abl/research/2026-10-14-fitting-the-whole-game-in-8-mb.html)
for [`abl-the-whole-game-does-not-fit-in-8-mb`](abl-the-whole-game-does-not-fit-in-8-mb.md);
taro said go on 2026-10-14:

* **Poses without their empty tiles**: about 571 KB. A walking step
  uploads 240 B on average against 512 today; the worst step, +14% of the
  vblank (modelled, not measured: it is measured in the emulator before
  merging).
* **`npc_poses_` shared whole**: about 41 KB, with an index in the
  runtime.

## Log

### 2026-10-14, Calandria: the design

From the-advocate `1b4ff5ea`, the ports `9e47100`, the book `beed835`;
branches `calandria-empty-tiles` in the three.

* **The record**: a 16-bit mask —bit *i* is tile *i* of the 4x4, by
  rows— and behind it only the tiles that draw something, in order. It is
  built in the emitter (`record::poses`), from Wally's 512 bytes as they
  are: Wally does not change.
* **The empty tiles are zeroed by the slot, not skipped by the OAM.** A
  32x32 object reads its sixteen tiles whatever they hold, and splitting
  it into smaller objects is what the decision ruled out (128 OAM entries).
  Pre-clearing once per slot is not enough either: a tile drawn in one
  pose and empty in the next keeps the old one. So each slot remembers
  which of its tiles may hold something —a 16-bit mask per 32x32 block,
  32 of them, in far RAM— and the drain zeroes only those that go from
  drawn to empty, with a fixed-source DMA on channel 7. `load_sprite`
  sets all 32 to "anything", since the bank it uploads brings whatever
  the converter put there.
* **The drain, without new state in the queue**: the entry is still
  source and destination, so the hero-first rule is untouched. The mask
  is read from the source with the data bank pointed at it; the slot,
  from the destination (`block_tile`'s layout). Each row's runs come from
  a 16-entry table of nibbles —at most two runs per four tiles—, and the
  DMA source is not reprogrammed between runs: the A-bus address goes on
  advancing by itself, and the drawn tiles are stored contiguous.
* **`npc_poses_` shared whole**: stored once by its text, under the label
  of the first map that brings it; the record already carries a 24-bit
  pointer, so the runtime needs no index.

### 2026-10-14, Calandria: what changed from the design, and what was measured

* **The masks at load come from the converter**, not "anything". With every
  block as "anything", each walker's first step zeroed all its empty tiles:
  512 bytes and more transfers than a whole pose, and Lashe City's
  `mechanic` and `bum` goldens moved —the message window's line ran past
  the vblank—. `pose_masks_table` (mapdata) emits what the sprite bank
  leaves in each block, per map and shared, in the tables
  (`pose_masks_maps`, `pose_masks_data`): the map record is full.
* **The masks are in bank 0's BSS, not in far RAM**: `FARBSS` is full on
  purpose —its room is the materials' table for every actor of the whole
  game, and ABL's `test_wram_reservations.py` went red with them there—.
  It leaves 20 bytes of BSS (83 on main).
* **The drain had to be faster than the old one, not only lighter**: the
  first version, which shifted the masks a row at a time, cost 5% more per
  pose than uploading it whole, and **main is already at the vblank's
  edge**: with five of Lashe City's walkers stepping together, the window's
  line ends 36.95 lines into vblank, of 37. The rows are now unrolled
  (`POSE_ROW`) and the drain lives in bank 1 with its tables, with the data
  bank at its own; `test_jumps_between_banks.py` is told so.

**The vblank, measured in bsnes** with throwaway instrumentation —the H/V
counters latched around `vram_drain` and after the window's line—, main
against this, same ROM otherwise (`~/scratch/calandria/poses/`,
`instrument.py`, `measure.py`, `measure_bot.py`):

    ABL release, every map, walking 240 frames each   main     this
      one pose (1,023 frames)                  dots   1,990    1,618 avg, 2,070 max
      two poses                                       3,759    2,993 avg, 3,271 max
      four poses                                      7,303    5,975 avg, 6,076 max
      five poses, the worst frame (map 49)            9,069    7,475   (-18%)
      the last VRAM upload ends, worst frame   lines  37.06    32.36 into vblank
    Lashe City, the `bum` case                 lines  36.95    32.13
    The Book of Three, map 2 to the forge on map 4
      one pose                                 dots   1,992    1,590
      three poses (the most on one frame)             5,534    2,843

So the model's "+14% on the worst step" is, measured: **+4% on the worst
single pose** (2,070 against 1,990: a step that zeroes and uploads in
several runs) and **-18% on the worst frame**. In theory a pose that
alternates drawn and zeroed tiles in every row (sixteen transfers) costs
more than that; none of the maps walked has one. The hero still goes first:
`vram_queue_hero` is untouched, and `test_book_of_three.py` still sees
Taran's poses on map 4.

**Saved** (`just space` and the generated `.inc`, by label):

    release        main        this
      pose_        771,584     368,870
      npc_poses_    60,732      50,004
      masks              0       7,618
      data banks   86 of 127   80 of 127
      bank 0       1,183 free  1,324 free   (the drain moved to bank 1)
      bank 1       2,716 free  1,855 free
      BSS             83 free     20 free
    the whole game (Carpintero's `wholemsu`, the MSU-1 required)
      pose_      1,095,680     524,312
      npc_poses_   127,008      86,580
      masks              0      15,782
      data banks   66 of 127   56 of 127

**Verified**, with the tools of the branch (`.local-tools`: mapdata,
cartridge, project): ABL's `just tests` 1308 passed; `just boot` 12 passed
(The Book of Three's walkthrough included); the tools' `just test` 27 and
`just rust-test` all green; `NO_CACHE=1` gives the same `abl.sfc`
(`15ad0432…`) and `abl.msu` as the cached build. No golden moved.

What the suite does **not** cover: a pose whose zeroing is wrong only shows
if a test looks at that slot after a step that leaves a tile empty that
was drawn; the slot cache's and 108's tests compare the whole slot with
the pose, and The Book of Three's the hero's block, and those passed, but
no test compares every walker's slot every frame. And the vblank numbers
are from the instrumentation, which is not in the tree.

**When merging**: the tools' `calandria-empty-tiles` and the ports' go
together —the harness reads poses as mask and tiles—; reinstall `mapdata`
(`just install mapdata`); the runtime goes with the checkout.

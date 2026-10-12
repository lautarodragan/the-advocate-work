---
name: "108 with shared poses"
description: "The still ones that no camera shows together take turns on a VRAM slot, only on the map that does not fit without it; Distant Paradise (108) goes into release and the demo ends on its arrival"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-01, among the options of `world-7-the-road-to-paradise.md`
(Puma): option A. 108 asks for 42 still-pose slots (15 characters facing 3 or 4
sides) and the VRAM gives 24, but on screen at the same time there are between
12 and 19. It extends the decision of hot poses
(`decisions/poses-are-uploaded-on-the-fly.md`, which now says so).

Base: `387b1e49`, `abl.sfc` `58fce320…`; merged with Pirincho's `main`
(`4d427f34`).

# Who takes turns with whom

`wally` decides it (`plan_sharing` in `map.rs`), with the colouring in
`rm2k-snes-map-sprites` (`share.rs`). The still ones that take turns are those
that:

* nobody moves: neither their own route nor `SetMoveRoute` (`movable`), nor
  still animation, nor `SetEventLocation`/`SwapEventLocations` from a page of
  the map or from a common event —one from a common event that moves "this
  event" turns off the turns for the whole map, because it can be any of
  them—;
* are not baked;
* draw **a single graphic** in all their pages (the ones that draw nothing do
  not count: the one that appears and disappears takes turns anyway).

The one that shows a pose that a still one that does not take turns already
has uses that slot, as always. The rest are coloured: two go together if they
show the same pose or if they are never both on screen. "On screen" is what
`build_oam` does not discard —the 32x32 box touches the 256x224 screen—, so for
any camera two are on screen at once only if |dx| < 288 px and |dy| < 256 px:
fewer than 18 cells in x and 16 in y. It is exactly Puma's "margin 1" (16x14
cells plus one around), and I did not add another margin: the ROM decides with
the same comparison, so it is exact. A slot where everyone shows the same pose
stays as a regular still one; only those with more than one go to the ROM.

**It only kicks in on a map that does not fit without it**: `wally` converts as
always, checks whether some VRAM layout fits —the layouts reach it in the
request, `layouts`, from `vram.LAYOUTS`— and only if not, converts again with
turns. The other maps come out byte for byte identical.

108 ends up at 22 slots, 376 sprite tiles, and fits in "+ambos" (384). 13 slots
are shared by 74 still ones, with 32 poses. The timer does not go on 108 —it is
not a timer map—; if it did, its glyphs start on the next row and it would be
411 tiles: it would not fit.

# What the runtime does

`tools/runtime/shared_poses.s`, in FAR. Tables from `share_table`
(`rm2k-snes-mapdata`): `share_maps`, one word per map, and `share_data`, with
one record per map that takes turns (slots, event → slot and pose, pose →
place in `npc_poses`). Far RAM: `SHARE_N` and `SHARE_OWNER` at $2590-$259F, 15
slots at most (`SHARE_MAX`, which the `.inc` asserts).

* `place_npc`: if `SHARE_N` is not zero, `share_want` looks at the row's slot;
  if it has another pose, it queues its own with `vram_queue` and **the row is
  not drawn that frame**, but on the next one, with the pose up. If the queue
  is full, it asks again on the next frame. The one looking at the hero is in
  the turn slot and is not looked at.
* `load_sprite` calls `share_load`: how many slots the map has and "nobody
  knows what they have". It covers entering the map and coming back from the
  battle.
* `build_oam_settled`, in bank 0: the map's first OAM —entering, coming back
  from the battle, a jump within the same map (`FADE_SAME`), loading from the
  title or on power-up— is built with the screen off, uploads the queue and
  rebuilds it until nobody is missing. On a map without turns it is a single
  `build_oam`, as before.
* `share_boot` sets `SHARE_N` to zero on power-up: far RAM starts with
  garbage.

What it does **not** cover, and it is said in the header of `shared_poses.s`:
if two consecutive vblanks have no room for poses —a line of the window going
up with the camera scrolling—, the row is drawn before its pose is uploaded,
and that frame shows the previous pose. The hero's and those of the ones that
walk have the same limit.

# 108 in release, and the end of the demo

`below = 109`. On the other side of 108 is another chapter: the arrival scene
(108 ev5) jumps right away to the Council (110), which chains the memory of the
mountain (175), Talan's house (114), 108 at night with the girl who cries, the
lookout (109) and the dream (122). None of that is cheap, so the cut is the
first one: **108's fork changes the `Teleport` to the Council for the end
sign** ("END OF THE DEMO / The Council of Paradise is not / in the cartridge
yet. / Thanks for playing!") and the return to the title. 107's fork is gone:
the tunnel jumps to 108 again, with its save question. What would be missing
for the next natural cut —the jump to the dream at the lookout (109 ev6)—: 110,
175, 114, 109 and 122.

The 26 pages of 108 that jump to 109, 110, 112 to 118, 120, 126, 127 and 150 do
not compile: the houses do not open, like the world's doors whose destination
is not there. The town, on arrival, is almost empty: the neighbours have pages
from later batches (switches 350, 376, 396, 427…).

# Tests

In `rom/pruebas/abl/test_paradise.py`:

* `test_recien_llegado[paradise-108-llegada]`: the arrival at (19,19) with the
  scene seen (333), golden and cells against `fill_window`, like the others.
* `test_los_quietos_del_108_se_turnan`: the full town (333, 396, 386, 388),
  walking along the plaza's path down and back, with a golden at each stop. At
  each one, each still one that takes turns and is on screen has to have in
  VRAM the bytes of its pose in the cartridge, read from the tables as
  `share_want` reads them; and some slot has to have shown two poses along the
  way (6: 79 and 75).
* `test_el_108_se_turna_al_saltar_dentro_del_mapa_y_al_cargar`: a `FADE_SAME`
  jump from (20,19) to (20,45), and saving through the menu and loading there.

And `rpgmaker/test_cores.py::test_los_quietos_que_se_turnan_una_ranura`: the
walk in snes9x and in bsnes.

**The red**: without the fix, 108 does not convert (with the global tools:
"this map can't carry a message window: it spends 462 background tiles, 696
sprite tiles"). With the fix and `share_want` always returning "as it is", the
two turn tests fail: two still ones drawn with another's pose. Besides, before
freezing the goldens I compared the silhouette of each still one that takes
turns and is whole on screen against its frame of the original CharSet: they
all match.

`test_recorrido_paradise_golden.py` now continues from the tunnel to 108: it
answers no to the save question and the sign comes out on 108. Its shots are
still not blessed.

In Rust: `wally` (`tests/shared_slots.rs`: they take turns only if it does not
fit, and not the one something changes place), `rm2k-snes-map-sprites` (the
reach and the colouring) and `rm2k-snes-mapdata` (`share_table`). The hashes of
`mapdata/tests/python.rs` were regenerated on purpose, on the tree merged with
Pirincho.

# What `just pruebas` does not cover

* **Coming back from a battle on 108**: `back_from_battle` uploads the bank
  (`share_load`) and `battle_fade_to_map` goes through `build_oam_settled`, but
  108 has neither encounters nor event battles, so no test executes it.
* The limit of the two vblanks without room, from above.

# Space

`just espacio release`, on the tree merged with Pirincho:

                   main (Pirincho)       with 108
    banks          —                     64 of 128, 44 free
    bank 0         1,220 B               1,165 B
    bank 1         —                     3,204 B
    BSS, ZEROPAGE  —                     128 B, 4 B
    texts          —                     112,717 B

The turns code in bank 0 is some 55 B (the `place_npc` hook,
`build_oam_settled` and two `jsl`); the rest goes in FAR.

# Verification

On the merged tree (`abl.sfc` `e1e0d591…`): `NO_CACHE=1 just cartuchos` and
`just cartuchos` with cache give the same fingerprints; `just pruebas` 966
green (961 + the five new ones), with `test_musica_techos.py` included; `just
-f tools/justfile test` 39; `cargo test` of `wally`, `rm2k-snes-map-sprites`
and `rm2k-snes-mapdata`. Before adding 108 —with the turns already in the ROM
and 108 outside— `NO_CACHE=1 just cartuchos` changed only the ROMs and
`mapdata.inc`, and `just pruebas` gave 961 without moving any golden.

# Goldens

Five new ones, in their commit, without touching any existing one:
`paradise-108-llegada` and
`paradise-108-turnos-{arriba,al-medio,abajo,de-vuelta}`. Side by side in
`/shared/capturas/2026-10-01-el-108/`, with a `LEEME.txt`. **The merge waits
for taro's approval.**

# When merging

Install `wally`, `mapdata` and `cartridge` (`just -f tools/justfile install
wally mapdata cartridge`): `wally` carries `rm2k-snes-map-sprites` inside, and
`cartridge` builds with the runtime. Python: `map_convert.py` and
`snes_convert.py` changed, without new or renamed files.

# What taro has to test

* From the tunnel (107) to Paradise: the save question, the arrival scene and
  the end sign.
* Walking 108 with people: playing, the town is almost empty until batches of
  the story that do not fit; 396, 386 and 388 have to be turned on in an
  emulator (or ask me for a case). That each neighbour has their face and
  faces their side on entering the screen, above all at the edges.

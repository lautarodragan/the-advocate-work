---
name: "World 8: Distant Paradise inside"
description: "The first day in Paradise in release —the Council and Pierson's memory, the houses, the night, the dreams, the day of the Trials— up to the exit to the farm (127), which does not fit in VRAM and is the new end of the demo"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-02: keep going with ABL in parallel, "add more maps".
Today the demo ends at the arrival in Distant Paradise: 108's fork
(`parches/manual/mapas/Map0108.json`) changes the `Teleport` to the Council
(110) for the end sign. This is what comes next: the chapter of Paradise
inside, measured first —which maps, what each one weighs, what does not fit and
why— and put in afterwards, up to the next natural cut.

Base: ABL `a454257`, tools `4b8b0e10` (`abl.sfc` `8c9e670f…`, suite 993).

# The cut: the whole first day

Following the pages from the arrival (108 ev5) and the switches each scene
turns on:

    108  the arrival: Isabella takes Talan to the Council
    110  the Council: Pierson (ev11) tells the story, a memory in three
         maps —175 the mountain, 176 the lookout, 177 the valley— that comes
         back to 110 (484) to explain the Trials (350, 349)
    108  the town, at dusk (361): the houses can be walked through —112 to 120—
    110  Pierson (ev10, with 361 and 350): "Yes" leads to Talan's house (362)
    114  the night: the rain and, if AG7 came (357), his memory in the
         rain (common 32, to 125); exits to the town at night
    108  the girl who cries (ev34): Talan follows her to the lookout
    109  the lookout: Emily, and the jump to the dream (ev6, with 363)
    122  the dream -> 123 -> 114 (367): the morning -> 124, the second dream
    114  Talan wakes up (372, 374); on leaving, Pierson excuses him from the
         Trials (ev7: 376)
    108  the day: the lookout by day (126, Emily: 380) and her house (113 ev6:
         381; on leaving, ev7 leaves her thinking and takes Talan to his house)
    114  time for the celebration (ev2 p6: 382)
    108  "I'm running late" (ev34 p2: 383), and the exit to the farm: events
         20 and 21, with 382, jump to 127

**The natural cut is the farm (127)**: the celebration starts there, which is
the choice of profession —and behind it, the rest of the chapter: the quarry,
the bandits, the theatre—. And 127 is one of the maps that do not fit in VRAM
(731 sprite tiles, 22 events that walk: `world-7-the-road-to-paradise.md`). In
`108-with-shared-poses.md` the next cut was the jump to the dream (109
ev6); the next day fits whole without asking for anything more than 126 and
113, so the cut moved all the way to the farm's door.

**108's fork** leaves event 5 as the original again —the arrival jumps to the
Council— and changes the `Teleport` to 127 of the 382 page of events 20 and 21
for the sign ("END OF THE DEMO / The celebration at the farm is / not in the
cartridge yet. / Thanks for playing!") and the return to the title. The other
pages of those events that jump to 127 are from later batches (396, 427, 441)
and do not compile, as before.

**The rule**: `below = 127`, with two more exclusions —111, a test by the
author that nothing leads to, and 121, from a later batch, which stays as a
test map— and the memory (175 to 177) in `added`. 119, the armoury, was a test
map and becomes part of the game.

# What was measured

With a variant of `release` plus the maps above —the one that stayed—, the
instrumented compiler (it records the command that stops each page, swaps it
for a `Comment` and tries again, to collect them all; in a separate `target/`,
uncommitted) and `peso.py`, which adds up what each map names in its
`map_table` record and its `map_code`, following the references of
`mapdata.inc` and measured in the `.dbg`. "Own" is what no other map uses: the
poses and tiles it shares do not count. The scripts and the compiler patch were
left in `/extras/scratch/nandu/medir/`.

    map                    own      bg     above   sprite  palettes
    109 Paradise Overlook   1.8 KB   121     9      83     4
    110 Council Chambers   19.7 KB    67     1     188     8
    112 ParadiseInteriors  11.3 KB   153     7     147     5
    113 Emily's House      11.5 KB   154    11     147     4
    114 Talan's House      11.9 KB   100     5     192     8
    115 House1             10.4 KB   163     5     147     4
    116 House2             13.2 KB   182    11     147     4
    117 House3             26.2 KB   137     5     403     7
    118 House4             20.6 KB   184     7     128     8
    119 Weapons and Armor  12.8 KB   166     3     147     5
    120 ConstructionTent    6.4 KB   114     1      83     3
    122 DreamSequence       6.2 KB    68     1      83     3
    123 Talan'sDream1       2.2 KB     2     1     147     4
    124 Talan'sDream2       2.9 KB     2     1     147     6
    125 AG7 in the Rain     2.3 KB   102     1     147     5
    126 OverlookAtDay       4.6 KB   121     9      83     4
    175 Mountain Flashback  7.4 KB   102     1     147     7
    176 Overlook            3.5 KB    20     1     147     6
    177 Paradise Found ;)  10.1 KB   150    29     147     6

**They all fit in VRAM** with today's layouts, and **all their pages compile**
except the ones that jump to maps of later batches: 114 ev10 p3 (to 160, with
427) and 117 ev20 (to 142, with 427). Of 108, the ones that jump to the farm
(127) and to the quarry (150). No new command was needed.

**108 ended up tight**: 24 slots, 384 sprite tiles of the 384 of "+ambos".
Before it was 23 and 380: with the Council and the houses in the cartridge more
pages of 108 compile —the one of the girl who cries moves Emily with
`SetEventLocation`, and the "I'm running late" one gives a route to three
neighbours—, and the ones something moves stop taking turns (70 still ones in
12 slots; it was 72 in 13). It fits without margin: one more still one that
stops taking turns and it does not convert.

## Space

`just espacio release`, before (the `release` of `/shared/abl-snes`,
`a454257`) and after:

                   before                after
    banks          65 of 127, 3 slow     71 of 127, 9 slow
    free           43 banks              37 banks
    gaps           59,217 B              94,332 B
    bank 0         2,868 B               2,868 B
    bank 1         14,204 B              14,204 B
    bank $C0       16,852 B              16,852 B
    BSS, ZEROPAGE  128 B, 4 B            128 B, 4 B
    texts          115,978 B             134,893 B (127,251 free)

Six banks for nineteen maps and nine themes. `test-special` and
`test-encounter-every-step` did not move.

# What had to be touched in the tools

Branch `worktree-agent-a140cce898ba673eb` of the tools repo:

* **`BOOT_FRAMES` from 40 to 44** (`tools/runtime/far_ram.s`). The audio
  package of the starting map went from 14,976 to 15,651 B —the sample split is
  done over all the packages— and the `boot_frames` count gave 40 against 40:
  the converter refused to build. It is what the tools'
  `decisiones/el-arranque-esta-dimensionado-para-el-paquete-de-arranque.md`
  says is done, by hand. It did not move any golden.
* **An MSU-1 track for the RTP themes the game names** (`rm2k-snes-audio`).
  `Farewell2`, the one of Talan's house the first night, is from the RTP and
  the `System` does not name it: it had no number and played through the
  SPC700 even if there was MSU-1 (`test_todo_tema_tiene_su_pista`, red without
  the change). They go at the end, after the `System` ones, and they are the
  ones **the whole game** names, not the cartridge, so no number from before
  moved. In ABL there is only one: track **235**.

No new opcode (`0x41`-`0x44` were left unused) and no RAM.

# Tests

* `abl/test_recorrido_paradise_dia_golden.py`: the whole first day, from 108 to
  the end sign and the title, with twenty-two shots **not blessed** (in
  `pendientes.txt`). It turns on 357 by hand, so that the memory in the rain is
  on the path.
* `abl/test_recorrido_paradise_golden.py` now ends on arriving at the Council:
  its shots of the sign and the title are gone, and the Council one is new and
  pending.
* `abl/test_paradise_por_dentro.py`: thirteen arrivals with a golden and
  `celdas_mal_dibujadas` at zero: 109, 110, 112 to 120, 125 and 126. The maps
  that are only a scene (175 to 177, 122 to 124) are played by the
  walkthrough.
* `parches/auto/mapas/`: nineteen new patches, from `just parches`; the ones
  that existed did not move.

`just pruebas`: **1023 of 1026**. The three red ones are from
`test_musica_techos.py` —`T_VGFighterMAX_Masako` and `rshinld` clip, and the
table is not this mix's—: the new themes moved the split. **`just techos` was
not run.** `just -f tools/justfile test` 52 green; `cargo test -p
rm2k-snes-audio -p rm2k-snes-cartridge -p rm2k-snes-bytecode` green.
`NO_CACHE=1 just cartuchos` gives the same fingerprints as with cache:
`abl.sfc` `6041a546…`, `abl.msu` `a654f637…`.

The arrivals and the walkthrough are new: they catch regressions from here on,
not birth errors. That is said by taro looking.

## Goldens

**New**: the thirteen `paradise-1NN-llegada`, in their commit. **No existing
one moved**: not even those of 108's turns, although other slots take turns
now. The thirteen and the shots of the two walkthroughs are in
`/shared/capturas/2026-10-02-paradise/`, with a `LEEME.txt`. **The merge waits
for taro's approval.**

# What is not done, and what looks different

* **The farm (127)**, and with it the rest of the chapter: it needs the slot
  cache (option D of `world-7-the-road-to-paradise.md`), and even so it does not
  fit with room to spare. It is what comes next, and it is taro's choice.
* **The panoramas** of the lookout (109, Night1), of the day one (126,
  Morning1) and of the memory (175 and 176, Night1) come out black, as on all
  maps with a panorama: `panorama-of-map-2.md`.
* **The night rain is not seen** on 108, 110, 114 and 118: the drops do not fit
  in the sprite palettes (the converter says so). `Rain1` plays; on 125 it does
  rain.
* **The music** of the new maps was not listened to, and
  `test_musica_techos.py` is red (above).
* The memory in the rain (125) depends on 357, which the tunnel turns on if AG7
  came: the branch without him is played by no test.

# What `just pruebas` does not cover

* The town's houses beyond the arrival: nobody talks to the neighbours.
* The armoury (119) as a shop.

# When merging

* Tools: install `cartridge` (the runtime changed: `BOOT_FRAMES`) and
  `rm2k-snes-audio` (`just -f tools/justfile install cartridge
  rm2k-snes-audio`). There is no new or renamed Python in `tools/`.
* ABL: track **235** (`Farewell2`) is new: `just entregar` is going to warn
  that the ones in `/shared/msu/` do not match; it goes with
  `--actualizar-msu`.
* `just techos`, once, on the merged tree.

# What taro has to test

* From the arrival in Paradise: the Council and Pierson's memory; the town at
  dusk and its houses; Pierson and the night in Talan's house (with AG7 in the
  party before the tunnel, the memory in the rain); the girl who cries, the
  lookout, the dream and the morning; Pierson at the door; Emily at the
  lookout by day and in her house; the time for the celebration and the sign
  on leaving for the farm.
* Whether the town at night and the lookouts hold up without the rain or the
  panorama, or whether they have to be prioritised.
* What to do with the farm.

---
name: "World 7: the road to Paradise"
description: "105 Mountain Path, 106 and 107 in release, fleeing with escape_mode 1, the end of the demo in 107's tunnel; 108 doesn't fit in VRAM and its options, measured, await taro"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-01: "let's add maps first". The demo ends today at the
"Continue onward" of the tunnel to Paradise (66 ev18). On the other side: 105
Mountain Path, 106 and 108 Distant Paradise, which is another chapter (parent 0 in
the tree). 108 is one of the five maps that don't fit in VRAM
(`docs/research/2026-10-01-los-mapas-por-el-msu-1.md`): 462 background tiles and
696 sprite ones, and there's no room left for the message window.

# 108 doesn't fit, and fixing it is a decision for taro

Measured on 2026-10-01 on `2de10ea4`, with a variant of `release` plus
105, 106 and 108, built separately (an `rm2k-snes.toml` copied to the
scratchpad; neither `release` nor the converter were touched). With today's code the
converter says:

    Map 108 'Distant Paradise': 120x120 cells of 8x8 px
      462 unique tiles
      sprites: 24 characters, 42 slots, 731 tiles in VRAM, 8 palettes;
               22 with their twelve poses in the cartridge
      83 NPCs with a CharSet out of 114 events

(731 and not Lechuza's study's 696: where the 35 difference comes from
wasn't followed up; the calculations below are on the 731.)

**What eats it: the still poses, not the walkers.** Of the 42 slots of
16 tiles, 1 is the hero, 3 are events that walk (the `*Running` ones), 1 is the
turning one and **37 are distinct still poses**: today a still one shares a slot
with those showing **the same** (CharSet, index, pose), and the town has
15 characters facing three or four ways. Per character:

    Chara1:2   1 4 7 10     Crown3:1   1 4 7 10     People3:2  1 4 7 10
    People1:3  4 7 10       People3:1  4 7 10       People3:3  4 7 10
    People4:2  1 4 10       Chara1:3   1 4          Chara4:1   1 7
    Crown1:2   1 7          emily:4    4 10         and five with one pose

**Why it doesn't fit in any layout**: with 462 background tiles, the ones giving
480 or 544 work —"+fondo", "+ambos" and "+techo"—, which leave at most 384 sprite
tiles, that is 24 slots minus the timer (8 tiles). 42 are needed. And
bringing the background down to 384 or less —which Adeleine can't do without changing pixels—
the sprite ceiling is 512, 32 slots: not enough either. It's not a new layout: the
hardware doesn't have one that's enough.

**What is enough is what's seen at once.** Counting, for each camera
position, how many distinct slots are needed by what falls on the 16x14-cell
screen with a margin around it:

    margin (cells)                0    1    2    4
    distinct slots at once       12   14   16   19

So 108's problem is that the ROM uploads **the whole town** to VRAM
on entering, and on screen there's never more than half of it.

## The options, with numbers

**A. Slots shared by distance** (recommended). The converter allots
the still poses like a colouring: two still events share a slot if
they show the same pose **or** if they can never both be on screen —their
cells are farther apart than the screen plus a margin—. The ROM uploads the pose
needed when the event comes on screen, through the same `vram_queue`
the hot-loaded poses already use. For 108, counting as candidates only
the still ones with **a single graphic** across all their pages (78 of 83; the others
and those moved by a `ChangeEventLocation` stay as today):

    margin   shared slots (with more than one pose)      total   tiles
      0        12 (11)                                     20     320
      1        14 (14)                                     22     352
      2        16 (14)                                     24     384
      4        19 (17)                                     27     432

With margin 1 —which is what the ROM already discards as "off screen" in
`build_oam`— it's **22 slots, 352 tiles plus the timer's 8: it fits in
"+ambos"** (384 sprite, 480 background) with 24 to spare.

What it costs: it's extending `decisiones/las-poses-se-suben-en-caliente.md`
("los quietos siguen compartiendo ranura por (CharSet, índice, pose), porque
no cambian") to the still ones. In the ROM: a per-map table of which (character,
pose) each shared event wants, one byte per shared slot with what
it has now (14 for 108: fits in the 16 at `$25A0`), the check in
`place_npc` —which is `build_oam`'s hot loop—, forgetting it in
`npc_poses_forget` on returning from battle, and not drawing the frame in which the
queue is full. In the converter, the colouring in `wally` and the table in
`rm2k-snes-mapdata`. And `M_*` has no room: the map record is full
(128 of 128), so the table goes somewhere else —a global table by map
index, or behind `npc_poses`—. Bank 0 has 245 bytes free; the new
code is better off in `FAR`.

**B. One pose per still character.** All the still ones of the same character
are drawn facing the same way —the most common— until you talk to them,
when they turn as today. 42 → 21 slots, it fits. It's converter only, but **it changes
what's seen**: a town where everyone faces down. It's one for taro to
look at.

**C. Mirror left and right** with the OAM bit, for the CharSets
whose left side is the exact mirror of the right (seven of the nine
above are; People1:3 and People4:2 aren't). 42 → 36. **It isn't enough on its own**, but
it's almost free —the attribute already travels in the row and in the page; `turn_apply`
would have to clear the bit— and it would give A some margin.

**D. A real slot cache**: each event, still or not, asks for a slot
on coming on screen and releases it on leaving. It's the only thing that would also cover
127 (see below), and it's the big decision.

## The other four: A doesn't cover them

* **127 ParadiseFarmland**: 138 background, 731 sprite (measured with a
  variant of `release` plus 127). There the problem is **the walkers**:
  22 events with a route —a bandit scene—, one slot each, plus 18
  still poses. A doesn't help (it has no candidates: all the still ones have
  more than one graphic or walk). On screen at once there are 30 distinct slots
  with no margin and 36 with 2: not even a cache (D) would fit comfortably in the 32 of
  "+sprite".
* **148 and 250**: 614 and 621 background tiles, above the ceiling of 544 with
  any number of sprites. It's path 2 of the world plan —background tiles
  hot-loaded—, not this one.
* **285**: the 64-tile box of the battle animations.

# What was done

While taro decides about 108, the chapter reaches its door.

## Which maps, following the doors

    105 Mountain Path     parent 66  -> 106 (ev3, and ev7 at the end of its scene)
    106 TalanGetsAmnesty  parent 108 -> 107 (ev2, ev3, and the autorun ev7)
    107 TunnelToParadise  parent 108 -> 106 and 108 (the autorun ev4; ev10 and ev11)
    108 Distant Paradise  parent 0   -> 109, 110, 112 to 120, 126, 127, 150...

106 and 107 hang from 108 in the tree: they're already Paradise's, but they're the
road to its door. From 108 inwards it's a whole other chapter —the
houses, the Council, the farm (127), the quarry (150), the area (158)—, which
without 108 makes no sense to add.

**The rule**: `below = 108`. All three go in by id, and nothing had to be excluded
or added.

## What didn't compile

With the compiler instrumented (an `eprintln` in the `scan`, in a `target/`
in the scratchpad, uncommitted), over `release`'s request with the three:

* **105 ev5 p2 and p3, and ev7 p1**: `EnemyEncounter` with `escape_mode` 1, "fleeing
  ends the event". It's `abort_on_escape` in easyrpg's `CommandEnemyEncounter`
  (`game_interpreter_map.cpp`), which on returning by fleeing calls
  `EndEventProcessing`. It compiles without touching the ROM: fleeing goes to an `OP_DONE`
  right after the opcode; with handlers, to one behind an `OP_GOTO`
  at the end of the block. 105's are the guard who chases —stepping on him is
  fighting, and winning puts him back up top— and the ambush before the tunnel,
  which is the one that jumps to 106.
* 106 and 107 compiled whole. Of 107, ev10 and ev11 don't compile,
  the return to 108 from the tunnel, because 108 isn't there.

## The end of the demo

At the end of Isabella's scene in the tunnel (107 ev4): 107's fork
replaces the tint to black, the `Teleport` to 108 and the save question that
came after with the sign ("END OF THE DEMO / Paradise is not in the /
cartridge yet. Thanks for playing!") and the return to the title. The text is the
same as before: it's still true. **66's fork was deleted**: it was only
the earlier end, and 66 ev18 leads to 105 again.

## Tests

Mulita enlarged the test page table while this was running, so
there's a new case:

* `casos/huir-corta.json` and `rpgmaker/test_batalla.py`,
  `test_huir_con_escape_mode_1_termina_la_pagina`: fights, flees (with
  `BA_ESCAPE` at 100) and the `ControlSwitches` afterwards doesn't run. **It was seen
  red**: with the global tools the converter refused to build ("a
  test page's EnemyEncounter does not compile"). The compiler's two
  look at the destinations with and without handlers.
* `abl/test_paradise.py`: 105, 106 and 107 just arrived at, with
  golden; 106 and 107 with their scene already seen (331 and 332).
* `abl/test_recorrido_paradise_golden.py`: from 105 to the title, with Talan and
  Arden at level 20: the vehicles, the guard, the ambush (wins the
  battle with troop 184), Arden staying behind, the amnesty, Isabella and the
  sign. Its photos aren't blessed.
* `abl/test_recorrido_tangle_golden.py` now ends on reaching 105.

`just pruebas`: all green except `test_musica_techos.py` (see below).
`just -f tools/justfile test` green. `cargo test -p rm2k-snes-events`
green. `NO_CACHE=1 just cartuchos` gives the same fingerprints as with cache.

## Goldens

**New**: `paradise-105-llegada`, `paradise-106-llegada` and
`paradise-107-llegada`, in their commit. **No existing one moved.** The
three and the walkthrough's photos are in `/shared/capturas/2026-10-01-paradise/`.
**The merge awaits taro.** 105's sky comes out black: its panorama
(Evening1) isn't drawn, as in every map with a panorama
(`panorama-of-map-2.md`).

## Space

`just espacio release`, before (`a0863e9e`) and after:

                   before                after
    banks          58 of 128, 50 free    59 of 128, 49 free
    gaps           10,580 B              22,948 B
    bank 0         245 B                 239 B
    bank 1         3,828 B               3,828 B
    BSS, ZEROPAGE  128 B, 4 B            128 B, 4 B
    texts          94,417 B              96,945 B

# What isn't done

* **108**, and with it Paradise: they await the decision above.
* **`test_musica_techos.py` fails**: the new theme is `lf-st5`, 105's
  chase. `just techos` wasn't run.
* The music from 105 to 107 wasn't listened to.
* Fleeing from the chasing guard ends his page, so he touches the
  hero again right away: that's what RM2k does. The walkthrough test doesn't flee.
* Saldra's branch (switch 56) of the ambush isn't played by any test:
  it's the same scene with the other companion.

# What `just pruebas` doesn't cover

* Fleeing in a battle with handlers and `escape_mode` 1: the game doesn't use it;
  only the compiler's test covers it.
* AG7's branch in the tunnel (switch 150): Isabella leaves him out.

# On merging

Install `events` (`just -f tools/justfile install events`). The `cartridge`
in my local `bin/` was `main`'s: it wasn't touched. There's no new Python in
`tools/`.

# What taro has to test

* From the world's tunnel, "Continue onward": Mountain Path, the vehicles,
  the chasing guard (fight, and flee), the ambush and Arden's or Saldra's
  scene, the amnesty, Isabella and the sign.
* Choose what to do with 108: A, B, C or D above.

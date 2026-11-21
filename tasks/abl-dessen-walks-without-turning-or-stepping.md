---
name: "ABL: Dessen walks without turning or stepping"
description: "Arriving at Delcentric Factory (map 17), RunFactoryScene walks Dessen to Talan: he moves, but keeps one pose, no turn and no step animation; talking to him afterwards turns him fine. It used to work"
type: bug
status: done
assignee: taro
author: taro
agents: [Mulita]
game: abl
---

taro, on 2026-11-18, playing the build of the ports `d91f170` and
the-advocate `78d2a560`, translated:

> A small bug, of something that worked fine in the past and broke at some
> point: in ABL, arriving at Delcentric Factory (map 17), Dessen walks
> toward Talan. The event `RunFactoryScene` does a `Move Event: Dessen,
> Move Left, Move Left, Move Left, Move Down...`. The movement works, but
> Dessen walks without turning and without animation. The odd thing is
> that, after the cutscene, when I talk to him, he does turn toward Talan.

A regression: bisect it over the merges of the last days —suspects, in
order: poses only when an event can show them (2026-11-17), still events
spilling out of their cell (2026-11-18, the Hover-Tram's stage 1),
baked events, the cache slots' turn fix (Arden, 2026-11-17)—, fix it, and
add a ROM test of the scene that holds Dessen's facing and step pattern
while he walks.

## The cause (Mulita, 2026-11-18)

From the-advocate `78d2a560` and the ports `d91f170`, branches
`mulita-dessen` in both.

Map 17 converted alone with a throwaway `wally` on the PATH that keeps
each `map` call's request and answer. The request is right: page 1 of
`RunFactoryScene` (index 44) compiles and its scan says `route_targets:
[27]`, Dessen. The answer is not: `movable` is `[39]` alone, and Dessen
(27) is only in `turning`. So his row is a still one, and a still row
that a route walks in a map without a cache of slots changes cell and
nothing else: `still_turn` in `cache_slots.s` returns before touching the
pose when `SHARE_N` has no cache. That is the "no turn, no step".

Why he is not in `movable`: `RunFactoryScene` draws ChipSet tile 33, a
still event, and with `baked_events` on it is drawn into the background
(the log: "4 still event(s) drawn into the background, a block per pose:
7, 45, 50, 51"). Wally then drops **its pages** from what `moves` reads
—`.filter(|p| … && !posed_set.contains(&p.event))` in `convert_with`—,
so the route it sends Dessen is never seen. A baked event keeps its row
and its pages run; only its own walking or turning stops counting.

Which commit: the filter came with the-advocate `07de4003` (Cardón,
2026-11-02, "Still events that change pose, drawn into the background a
block per pose"), harmless while ABL did not bake; ABL turned
`baked_events` on for the whole game in the ports `b5d2082` (mine, in
`mulita-pages-lz2`, merged `8042dc8` on 2026-11-16). The study dump of
2026-11-17 (`c48be14b`, before the poses change) already has `movable:
[39]`: my poses change and the cache-slots fix are not the cause.

**Why no test caught it**: nothing in ABL's suite looks at an event that
a baked event walks. The playthrough crosses map 17
(`test_from_talans_house_to_the_auditorium`), but it photographs Talan on
arrival and only asserts cells afterwards, and the cells were right: the
route moved Dessen, it just did not pose him. Wally's tests of `moves`
hand it the pages directly, never through `convert_with`'s filter.

## The fix (Mulita, 2026-11-18)

the-advocate `54b31bc9`, in Wally: `pages_that_move` keeps a baked
event's pages for `moves`, with its own route and its turn toward the
hero taken out (it is no character), and still drops a decoration's (it
is no event). Map 17's answer goes from `movable: [39]` to `[27, 39]`.

Tests, red before:

* Wally's `a_baked_event_still_sends_others_walking` (red with the old
  filter by assertion: the scene's page was dropped).
* ABL's `tests/abl/test_factory_scene.py`: `party-11-in-17` with switch
  77, to map 17 at Talan's arrival cell, closing each box once typed, and
  every tick Dessen's `npc_buf` row until he reaches (36, 69): the row is
  not `NPC_STILL`, and its pose up (+12) faces left (9-11) while he walks
  left and down (6-8) while he walks down, with more than one column in
  each. Red on main's tools at the first tick ("Dessen's row is a still
  one"); green with the fix, poses 7 → 11, 10, 9, 10, 11, 10 → 6, 7, 8.

## The same class elsewhere (Mulita, 2026-11-18)

Only ABL and Zounds turn `baked_events` on. Both `release`s converted
with the global `wally` and with the fixed one (`--convert-into`, the same
runtime), keeping every map's Wally answer, and compared:

* **ABL: 8 maps, 22 events** that a baked event's page walks and that
  had lost their walk —now in `movable`—: map 1 DummyKersh (8); map 17
  Dessen (28); map 37 Saldra (15) and Arden (16); map 122 Emily (2); map
  141 the three chairs (1, 2, 3); map 169 Eisen (2); map 261 Kersh (4),
  Emily (5), Kersh2 (6) and The Package (17); map 277 Eisen (2), Manta (5),
  Manta2 (7), Manta3 (8), Guard1 (9), Guard2 (10), Eisen2 (11), Manta5 (12)
  and Eisen5 (13). All of them fit: the converter's log only moves those
  maps' `sprites:` lines (map 277: 10 → 14 slots, 184 → 248 tiles), and
  the LZ2 data of `release` goes from 2311.2 to 2310.8 KB.
* **Zounds: 0.** No answer changes and the ROM comes out byte for byte
  the same.

Only map 17's is held by a ROM test; the other seven maps' scenes are not
looked at by any test (see the report).

## Tests and what is left (Mulita, 2026-11-18)

On the-advocate `mulita-dessen` (`54b31bc9`) and the ports
`mulita-dessen` (`0b0ba2c`), both over the `main` they started from,
which did not move; `wally` from the branch (`install-local … wally`),
the rest global:

* `just test`: 29 passed; `crate-test wally`: 65 passed.
* ABL's `just tests`: 1689 passed, 2 skipped, `test_cores.py` included;
  **no golden moved**. The `release` it built: md5
  `9b4ea773522ae37220b9ccaacbdc6b1b`, without MSU-1 tracks.
* `just boot` at the ports' root: 167 passed.

What the suite does not cover: the other seven ABL maps the sweep found
(1, 37, 122, 141, 169, 261, 277) —their scenes now walk their people
with their own poses, and no test looks at any of them—; and an event a
baked one walks in a map with a cache of slots, where it may be one of
the cache's `turners` instead.

**To install when merging**: `wally`.

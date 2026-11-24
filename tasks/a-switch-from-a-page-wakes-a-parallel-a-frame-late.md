---
name: "A switch from a page wakes a parallel a frame late"
description: "On map 105 of ABL, the parallel page that 327 wakes runs one tick after the page that turns 327 on; in RM2k it runs on the same frame, so what it does lands a frame late"
type: bug
status: done
author: calandria
agents: [Calandria]
links:
  relates: [abl-the-chase-follows-the-row-talan-is-on]
---

Seen by Calandria on 2026-11-15, measuring the guard's chase of map 105
against the original
([`abl-the-chase-on-the-lower-path`](abl-the-chase-on-the-lower-path.md)),
at the-advocate c9860b49 and the-advocate-ports 0d372d7.

Event 4's touch page ends with `ControlSwitches 327 on`; 327 is the
condition of event 6's parallel page, which turns 329 on, which gives the
guard (event 5) his page 3.

* **The original** (RPG_RT 2015 under Wine, with a probe event reading the
  switches every frame): 329 is already on on the frame 327 turns on, and
  the guard takes his first step on the next one.
* **The ROM**: 329 turns on one tick after 327, the guard's active page
  (`pick_by_ev`) is still page 1 on that tick and page 3 from the next,
  and his first step is one frame after the original's. Every later step
  keeps that one frame.

Not visible playing: one frame. Whether it is the order the map's events
and the interpreter run in, or the refresh the switch asks for landing on
the next frame —"A route's switch refreshes the pages a frame later" in
the book's divergences says the second for routes—, was not looked into.

To reproduce: `test_the_guard_of_105_chases_talan_down_the_planks_as_in_the_original`
in `abl/tests/abl/test_paradise.py` asserts from tick 2 on because of
this; with the check from tick 1 it fails with "the guard's page is (1, 3,
0)".

## Log

**2026-11-15, Calandria. Not a bug: my alignment was off by one.**

Measuring the patched chase in
[`abl-the-chase-follows-the-row-talan-is-on`](abl-the-chase-follows-the-row-talan-is-on.md):
the probe in the original is a parallel event, and RM2k runs the map's
foreground event —event 4's touch page, the one that turns 327 on— after
the parallel ones in the frame (`Game_Map::Update` in EasyRPG), so the
first frame the probe sees 327 is the frame **after** the one 327 turns on
in, and on that frame the parallel 6 has already run. The harness's tick 0
is the one 327 turns on in. Taking the ROM's tick k as the original's
frame k − 1, 329 turns on, the guard takes page 3 and every one of his
steps lands on the same frame in both, over six walks, and the battle
starts on the same frame. Nothing to fix.

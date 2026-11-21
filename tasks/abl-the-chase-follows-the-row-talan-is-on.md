---
name: "ABL: the chase follows the row Talan is on"
description: "Patch map 105 so event 6 turns the other switch off, and the guard's page follows Talan's row during the whole chase, as the event seems meant to"
type: feature
status: testing
assignee: taro
author: taro
agents: [Calandria]
---

Follows [`abl-the-chase-on-the-lower-path`](abl-the-chase-on-the-lower-path.md),
which measured that the original does exactly what the port does: event 6
turns 328 or 329 on by Talan's row and never turns either off, so 329 is on
from the first frame and page 3 wins the whole chase. A bug of ABL itself.
taro, on 2026-11-15:

> Could you apply a patch that fixes this bug directly in A Blurred Line?
> I suppose it could be fixed just by adding two commands: one that turns
> the switch off, for each of the two switches, in the two branches of
> the `if`, right?

Done means: map 105 forked in `patches/manual/maps/` (the only way the
port changes a map's events today), with event 6 turning 329 off where it
turns 328 on and 328 off where it turns 329 on; the guard's page follows
Talan's row in the ROM; the tests that asserted the original's behaviour
say the new one, on purpose; the book says it is a change to the game.

## Log

### 2026-11-15, Calandria: the fork, and the patched game measured in both

The fork is `abl/patches/manual/maps/Map0105.{json,tiles}` on
`calandria-chase-patched` in the ports: the dump's JSON as text with three
lines added —`ControlSwitches 329 OFF` after `328 ON` in the `>= 18`
branch, `328 OFF` after `329 ON` in the else, and `"id": 105`—, so `diff`
against `data/maps/Map0105.json` is those three lines, and loading both
and taking them out leaves the same object; the `.tiles` is a copy, `cmp`
equal.

**The original with the same patch.** The Wine measuring copy of the
previous task (`~/scratch/calandria/chase-lower/`) was copied to
`~/scratch/calandria/chase-patched/` and its map 105 rewritten with Ditto
with the same two commands. Seven walks, on each side: standing; the upper
path and the lower one, from the trigger and after waiting 30 frames; and
a new one, `zig`, which goes down to (48,18) and back up to (48,17) and on
along the upper path, from the trigger and after waiting —the only one
where the page goes 3 → 2 → 3—.

In RPG_RT with the patch, 328/329 flip with Talan's row (328 on and 329
off on the frame he reaches row 18, back on coming up), and the guard
catches him on every walk with battle 184: standing at (52,17) on frame
84, the upper path at (15,16) on 419, the lower one at (36,21) from
(37,21) on 164 —the same three as without the patch: the upper and the
standing never leave row 17, and on the lower the guard's cells happen to
be the same—; the lower after waiting at (40,21) on 156 but along other
cells than without the patch (the page changes at frame 65 and the track
splits from frame 109); `zig` at (38,13) on 164; `zig` after waiting at
(43,14) from (44,14) on 140.

**The ROM does the same, frame for frame**, once the frames are aligned
right. The guard's cell and 328/329 are the same on every frame of all six
walks, and the battle starts on the same frame, with the ROM's tick k
taken as the original's frame k − 1. That shift is the one thing I had
wrong in the previous task: the probe's frame 0 is not the frame 327 turns
on, it is the next one, because RM2k runs the map's foreground event after
the parallel ones (`Game_Map::Update` in EasyRPG: parallels, then the
player, then `UpdateForegroundEvents`), and the probe is a parallel. So
the "guard one frame late" of the previous task is an artifact of my
alignment, not of the ROM: 329 turns on on the ROM's tick 1, which is the
original's frame 0, and the guard's first step on tick 2, the original's
frame 1. The draft
[`a-switch-from-a-page-wakes-a-parallel-a-frame-late`](a-switch-from-a-page-wakes-a-parallel-a-frame-late.md)
was that, and goes to `done` with a note. The earlier alignment (Talan's
walk from tick 6, which put his first step on the original's frame counted
from the wrong 0) matched in the unpatched game because nothing there
depends on the guard's phase against Talan; with the patch, `zig` after
waiting caught Talan at (40,13) on tick 172 instead of (43,14) on 141. With
the walk from tick 7 —and 32 after waiting— everything matches; with 8 and
33 four of six walks diverge, so 7 it is.

**The page change and the own route.** EasyRPG's `Game_Event::RefreshPage`
(what the brief called `Setup`) restarts the page's route from command 0
on a page change, unless both pages' routes have the same length and the
same command codes, which here they do not (page 2 `T D T U T`, page 3
`T U T D T`). The ROM's `page_routes`/`apply_pages` restarts it always. A
replay of the routes against the measured runs (skip semantics, reset on
change, with the hero's passability) reproduces the two ROM runs it was
tried on and every original one but a stretch of the upper path, where the guard's
passability is not the hero's; keeping the index across the change
instead does not reproduce `zig` after waiting. So the
two agree for this map. What the ROM lacks is the exception —same codes,
keep the index—: no ABL map is known to need it; a draft,
[`a-page-change-restarts-a-route-with-the-same-commands`](a-page-change-restarts-a-route-with-the-same-commands.md).

**The tests**, in `tests/abl/test_paradise.py`: the module comment says
the map is the fork and diverges on purpose; the standing test keeps
checking 329 on, 328 off and page 3 every frame, which the patch does not
change; the lower-path test became
`test_the_guard_of_105_follows_the_row_talan_is_on`, over two walks
—down the planks, and `zig` after waiting—: every tick exactly one of
328/329 on and 328 == (variable 53 >= 18), the guard's page the one of the
switches of the tick before, variable 53 on Talan's row a tick behind at
most, the ticks 328 flips (41; 66 and 74), and the catch cell, the cell
the guard came from and the tick (165, 141) ±1. Red without the fork
(moved aside, `release` rebuilt): both walks fail with "tick 41, Talan at
(48, 18): 328 is True and 329 is True, and only one has to be on" (66 for
the second); green with it.

**What ran**, on `calandria-chase-patched` in the ports (a6c90a2) with the
global tools (the-advocate c9860b49, nothing reinstalled): ABL's `just
tests` —1658 passed, 2 skipped; no golden moved: the arrivals' and the
guard's golden are taken with Talan on row 17, where the patch changes
nothing—; `just boot` at the ports root —151 passed—; and
`tests/abl/test_paradise.py -k guard` red without the fork and green with
it. `release`'s `abl.sfc` with the fork: sha256 `94110129…bcfbe`.

What the suite does not cover: the other four walks (upper path, lower
path after waiting, `zig` from the trigger, standing is covered), measured
here and not in a test; the chase after the first battle, where the
guard's page puts him back at (69,18); and the page 3 → 2 → 3 change with
Talan going down **while the guard is on the planks too**, which no walk
did.

**The book**, on `calandria-chase-patched` in the-advocate-docs (7ceaf40):
a decision of ABL's, "The chasing guard follows Talan's row"
(`src/ports/abl/decisions/the-chasing-guard-follows-talans-row.md`), in
the port's decisions list and in `SUMMARY.md`, and a paragraph in the
port's page saying the port changes one thing the game does. Relative
links checked.

Captures for taro —the guard's track per walk on map 105: the original as
it is, the original with the patch, the ROM with the patch— in
`/shared/captures/2026-11-15-chase-patched/`, with a README. The scratch
setup —the patched Wine copy, the drivers, the runs, the replay— is in
`~/scratch/calandria/chase-patched/`.

**Nothing to install when merging**: the fork and the tests are ABL's;
the tools were not touched.

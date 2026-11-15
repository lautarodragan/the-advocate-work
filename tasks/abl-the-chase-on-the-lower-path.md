---
name: "ABL: the chase on the lower path"
description: "Compare the guard of map 105 against the original with Talan walking, along the lower path too, and make the ROM test check the page that the parallel event 6 picks"
type: bug
status: done
assignee: taro
agents: [Calandria]
---

taro, on 2026-11-15, reading map 105 in RPG Maker:

> Looking at the event now, I see it stores the hero's Y position in
> `0053: AgentsChasingHeroY`, and then uses it to decide which switch it
> turns on (`0328: AgentGoSouth` / `0329: AgentGoNorth`). [...] Maybe we
> have a bug or a missing implementation of that system, and that is why
> the agent did not chase me properly, and we reached the wrong
> conclusion back then.

And, on launching this:

> It seems to be a bug of ABL itself, but better to test it against the
> original and get rid of the doubt.

What was already known, from
[`abl-the-chasing-agents-get-stuck`](abl-the-chasing-agents-get-stuck.md)
and [`abl-the-agents-on-the-road-to-paradise-do-not-come`](abl-the-agents-on-the-road-to-paradise-do-not-come.md),
and from reading the data (Hornero): event 6 never turns 328 or 329 off
—only the ambush, event 7, does—, the chase starts on row 17 (event 4 at
(52,17)), so 329 is on from the first frame and page 3, the higher one,
wins for the rest of the chase. Page 2 is only reached if Talan were on
row 18 or below when 327 turns on, which normal play does not do.

What the October comparison did **not** cover: every position measured
was Talan standing still on the upper path. The lower path, and Talan
walking while chased, were never compared with the original. And
`tests/abl/test_paradise.py` names 328 and 329 only in a comment.

Done means: the original and the ROM compared with Talan walking along
the lower path (and the upper one, walking), with the guard's cells; if
they differ, the cause found and fixed; either way, the ROM test checks
that 329 is on and the guard is on page 3.

## Log

**2026-11-15, Calandria. Measured with Talan walking: the original does
the same, cell for cell.**

The October setup was gone, so it was rebuilt in
`~/scratch/calandria/chase-lower/`. The original is RPG_RT 2015 under Wine
on a copy of the game where a new game starts on 105 at (53,17) with
Talan, and 105 carries one more event, a parallel with no condition, that
writes every frame into variables 241-250 a frame counter, the guard's and
Talan's cells and 327/328/329. A small Windows program in the same Wine
prefix reads them with `ReadProcessMemory` —from Linux, `/proc/<pid>/mem`
is refused: ptrace scope 1 and only the wineserver may attach— and prints
one line per RPG_RT frame, with the values the probe left at the end of
it. A Python driver reads those lines and presses keys with `xdotool`: Left
until Talan is on (52,17), Return every 20 frames through the two messages,
and from the frame 327 turns on (F0) the path, one cell after another, the
next step's key held from the frame Talan's cell becomes the current one.
The ROM side is the same driver in the harness, by ticks.

The paths are BFS over the map's passability: the upper one along the dirt
up to row 9 and down to (14,16) without touching row 18; the lower one down
onto the planks through (48,19), (42,21) and along row 21 and row 18 to the
same place.

Five runs on each side —standing, upper and lower run twice in the
original, with the same frames both times—: Talan standing; walking the
upper path from F0; the lower path from F0; and each path after waiting
30 frames. **The guard steps on the
same sequence of cells in all five** —22, 76, 42, 40 and 38 cells—, each
step 0 or 1 frame later in the ROM, and the battle (184) starts with the
same two cells: standing at (52,17) on frame 84 (ROM 85); upper at (15,16)
on frame 419 in both, after the guard has followed along the planks below
the whole way; lower at (36,21), the guard coming from (37,21), on frame
164 (ROM 165).

In both, 329 is on from the start, 328 turns on when Talan reaches row 18
(frame 40 on the lower path, 65 after waiting) and variable 53 follows
Talan's row. In the ROM the guard is on page 3 every frame of every run;
in the original the page is not readable, but the cells are page 3's
route —toward, **up**, toward, down, toward— and not page 2's, which goes
down first. So taro's reading of the event is right, and the port does
it: what makes the chase look stuck is ABL's own design, as October found.

How close the timing is: the original holds Talan still for the eight
frames the last message takes to close —already in the book, "The eight
frames of a message closing"—, so the ROM's walk starts 6 ticks after F0
to put his first step on the original's frame; from there his steps land
on the same frame, a frame apart at most (where each side reads the cell:
the logical cell at the start of a step in RM2k, the first pixel in the
ROM). In the original the driver's keys arrive about 3 frames after the
data they react to (measured: key decided on frame 30, first step on 33);
it does not matter, because the next step's key goes down at the start of
the current step, eight frames before it is needed. The guard's one frame
late is the parallel 6 running a tick after 327 in the ROM, where the
original runs it on the same frame: a draft,
[`a-switch-from-a-page-wakes-a-parallel-a-frame-late`](a-switch-from-a-page-wakes-a-parallel-a-frame-late.md).

**The test**, on `calandria-chase-lower` in the ports (df3da00). The
harness had no way to ask for an event's active page, so
`Session.active_page` reads `pick_by_ev` against the cartridge's page
table, with how many pages the table carries for the event. The guard
test checks 329 on, 328 off and page 3 every frame, and
`test_the_guard_of_105_chases_talan_down_the_planks_as_in_the_original`
walks the lower path from the trigger: 329 and page 3 every tick from the
second, variable 53 on Talan's row, 328 on on the original's frame without
the page moving, and the catch at (36,21) from (37,21) with battle 184,
within two frames of the original's. Shown red by clearing 329 at tick
45: "329 is off". Run: `tests/abl/test_paradise.py` (6 passed, 2 skipped
as before) and `tests/tooling` (156 passed). No ROM change, no golden.

What the suite does not cover: the upper path walking (measured here,
not in a test), and the chase after the first battle, where the guard's
page puts him back at (69,18).

Captures —tracks on the map, original above and ROM below, and screens
side by side— in `/shared/captures/2026-11-15-chase-lower/`, with a
README. The scratch setup —the measuring copy of the game, the probe
inside Wine, the drivers of both sides— is in
`~/scratch/calandria/chase-lower/`.

**Nothing to install when merging**: only tests changed.

**2026-11-15, Hornero**: closed, taro accepted the measurement ("Genial, entonces") and asked for the patch, in [`abl-the-chase-follows-the-row-talan-is-on`](abl-the-chase-follows-the-row-talan-is-on.md).

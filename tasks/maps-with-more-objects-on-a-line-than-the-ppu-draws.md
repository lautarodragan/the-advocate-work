---
name: "Maps with more objects on a line than the PPU draws"
description: "Nothing tells today when a map puts more than 32 objects or 34 slivers on a line; a sweep in the harness over every map of every game, and the PPU's own flags counted in the debug screen"
type: feature
status: done
assignee: taro
author: taro
agents: [Mulita]
---

Opened by Hornero on 2026-11-17, at the-advocate `7dab7d82` and the ports
`e87e936`, from
[`abl-the-hover-tram-s-crowd-is-cut`](abl-the-hover-tram-s-crowd-is-cut.md):
map 13's crowd was found by taro playing. taro, translated:

> Question: does the build log today the cases where we have more objects
> on a line than the SNES allows?

It does not: the converter does not count objects per line, the runtime
does not read `$213E` (STAT77: range over, more than 32 objects on a
line; time over, more than 34 slivers of 8 px), and no test looks. Two
things, in this order (taro: "Dale!"):

1. **A sweep in the harness**: enter every map of every game, let it
   settle, and count objects and slivers per line from the OAM the way the
   PPU reads it (`sheet.drawn_silhouettes`). Out: a list of the maps that
   go over, with the line, the count and the events on it. No ROM cost.
   Whether it becomes a test (a ceiling per game) or a report recipe is
   part of the decision.
2. **The PPU's flags in the debug screen**: read `$213E` once per frame
   and count the frames with range over or time over, shown in the debug
   screen and readable by the harness, for what the sweep cannot see (a
   scene that adds people while it plays). Its per-frame cost, measured;
   gated like the rest of the debug screen.

## Log

**2026-11-17, Mulita.** Worktrees at the-advocate `7dab7d82` and the ports
`e87e936`, branches `mulita-objects-per-line`.

The PPU's rules, read in bsnes's accurate PPU (`sfc/ppu/object.cpp`) and
Mesen2's (`SnesPpu.cpp`), which agree, and fullsnes for `STAT77`:

* sizes from OBSEL bits 5-7 and the high table's bit; X nine bits, an
  object starting in 257..511 and ending before 512 is out of range, and
  one at exactly 256 (-256) **is in range** and all its slivers count,
  though it is never drawn;
* Y wraps past 255; lines 0..223 are evaluated, each drawn one line lower;
* range over: more than 32 in range, counted from the first object
  (`$2103` bit 7 rotates it; the runtime never sets it);
* time over: more than 34 slivers among the first 32 in range, **the
  transparent ones too** —the fetch does not look at the pixels—, a sliver
  skipped only when wholly off screen;
* both flags are cleared at V=0, the end of the vblank (fullsnes: not
  during forced blank; bsnes and snes9x clear them anyway), and set during
  the lines: read in the NMI they hold the whole frame just drawn.

**What that means for this runtime**: every character is a 32x32 object,
4 slivers, so **time over comes at 9 characters on a line**, long before
range over (33). The Hover-Tram goes over by slivers, not by objects.

**Part 1, the sweep.** `abl/tests/harness/ppu_objects.py` in the ports
counts an OAM with those rules, knowing no game; `tests/objects_per_line.py`
at the ports' root enters every map of every game —ABL's `release` and the
eight others'— with a door's teleport to the map's start cell, runs 30
ticks, and counts two things: the OAM as it is, at the entrance's camera,
and every `npc_buf` row the runtime draws as an object moved under every
camera X the map allows (the X where an edge or a sliver crosses a side of
the screen; wrapping maps a lap each side, each event once). First run,
2026-11-17: 1536 maps entered, 1528 counted, **126 over**, 10 more that
the hero tips over; Vampires Dawn 58, Desert Nightmare 53, ABL 8 (13
among them: 14 characters, 56 slivers on cell row 8), Zounds 3, and one
each in The Book of Three, El Dorado, The Frozen World and Sunset; Dooms 2
none. Range over —33 objects— only in Vampires Dawn's 341, 347 and 429.
Not counted: The Frozen World's 1-4 and 7 (the jump does not arrive) and
three Zounds maps whose scene sends the hero away. Report, JSON and
captures of four maps in both cores, which show the cut alike, in
`/shared/captures/2026-11-17-objects-per-line/`.

**A recipe, not a test**: `just objects-per-line` at the ports' root. It
costs under a minute once the games are built (51 s, six processes), so
cost is not the reason: what it finds is a backlog —crowds the original
drew— whose fix is a call per game and per map (bake, patch, leave), and a
ceiling in a test would be a number of the state of our work that every
bake moves, which AGENTS.md says not to write. Drafts, one per game:
`<game>-characters-cut-on-crowded-lines`, with a Known issues line in each
port's page.

**Part 2, the PPU's flags.** The NMI (`nmi_boot`, bank 0) reads `STAT77`
behind `.if DEBUG_SCREEN`: `lda`/`and #$C0`/`beq`, 9 cycles a frame, and
on a frame that went over a `jsl` to `dbg_over_count` in bank 1, which
saves A's high byte (the NMI saves only the low one) and adds to
`dbg_range_over`/`dbg_time_over`, held at 32767. They show as rows 4 and
5 of the debug screen's state page, right-aligned, and A zeroes one. They
are **zeroed on entering a map** (`enter_map_no_events`): counted from the
boot, the title screen counted every frame —its OAM is never uploaded,
128 objects at 0,0 on snes9x, in range though never shown—. Measured with
`just space` on each `release` against the global tools' build:

| game | bank 0 | bank 1 | $C0 | $C1 | far RAM |
|---|---|---|---|---|---|
| ABL | 3992 (-15) | 713 (-112) | 2290 (+7) | 1569 (-39) | 119 (-4) |
| Sunset over Imdahl | 4013 (-15) | 732 (-112) | 76 (+7) | 2846 (-39) | 2935 (-4) |
| Vampires Dawn | 4042 (-15) | 117 (-112) | 2161 (+7) | 2635 (-39) | 1222 (-4) |
| Zounds | 4028 (-15) | 671 (-112) | 2333 (+7) | 90 (-39) | 1249 (-4) |

Free bytes after, and the change. The other five games moved the same
(measured before the last commit, which only moved bytes from `$C1` to bank
1). bank 0 is the NMI's eleven bytes and `enter_map`'s four; `$C0` gains
seven because `dbg_off_boot` went to bank 1, next to the NMI's routine;
the page's code stays in `$C1` with the screen, and its tables —bits,
names, offsets, read with long addresses— went to bank 1, which took
Zounds' `$C1` from 42 B left to 90. Per frame: 9 cycles when nothing went
over, about 80 more on a frame that did. The far RAM is the two words.

STAT77's timing, checked: the flags are set while the lines are drawn and
cleared at V=0, so in the NMI they are the frame just drawn —the OAM
uploaded the vblank before—. The test (`test_debug_screen_golden.py`)
predicts each frame's flags from the OAM shadow with `ppu_objects` on the
Hover-Tram and the count matches within two frames; map 278 counts none.
Red first: no `dbg_time_over` in the cartridge. Goldens:
`debug-screen-state` and `-off` gain the two rows; `-counts` is new.

**What is left, for whoever comes next**: the sweep counts a new game with
every switch off and the hero where the map starts; scenes that bring
people in, pages behind other switches and the hero's own place are the
debug screen's to see, playing. A character is four slivers because it is a
32x32 object even when what it draws is a 16x16 ChipSet tile —Desert
Nightmare's roofs and walls—; drawing tile events as 16x16 objects would
halve what they cost, and is not measured. And on the console a forced
blank keeps the last frame's flags, so a load right after a frame that went
over adds its black frames to the count; the emulators clear them.

**To merge**: the-advocate `mulita-objects-per-line` (runtime only, no
Rust: **nothing to install** —the global tools assemble the runtime of the
checkout they were installed from, `~/the-advocate`; the worktree installed
`cartridge` locally only to point at its own—), the ports'
`mulita-objects-per-line` (the sweep and its recipe, the test and three
goldens), the book's `mulita-objects-per-line` (the pause menu's section
and eight Known issues lines). Map 13's numbers move with Cardón's baking;
the counting test says so if the Hover-Tram stops going over by slivers.

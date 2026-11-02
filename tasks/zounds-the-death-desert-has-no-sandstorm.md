---
name: "Zounds: the Death Desert has no sandstorm"
description: "From map 34 into the Death Desert (50, 14, 111, 112, 113) RM2k blows a sandstorm over the screen; the port shows clear sand"
type: bug
status: testing
assignee: taro
agents: [Tijereta]
---

Seen by Mulita on 2026-11-02, with the ports at `1e6663b` and the tools
from the-advocate `3656d606`, taking the debug room's maze door (map 113,
`tasks/zounds-a-debug-door-to-the-desert-jail.md`): the sand is clear.

34's jumps into the Death Desert (events 55, 83 and 84) run
`WeatherEffects` with type 4, the sandstorm, at strength 2, and its way
out and the desert's cave mouth (113, event 1) turn it off. The compiler
accepts the command and the ROM draws only the rain, type 1 —see
`WEATHER_EFFECTS` in `rm2k-snes/events/src/compile.rs` in the-advocate,
and `tasks/weather.md`—, so the sandstorm is left out without a word.

To reproduce: "New Game", the sixth door of the room, "Go"; or play from
map 34 north into map 50.

## Asked

taro, on 2026-11-02, in their words, translated:

> Meanwhile: could you implement the sandstorm? I don't know how feasible
> it is... if it can't be done, it can't be done.

Taken by Tijereta, launched by Hornero the same day.

## What RM2k does

Read from easyrpg-player (`Game_Screen::UpdateSandstorm`,
`Weather::DrawSandstorm`), not from memory. The sandstorm is two things:

* **An overlay**, the fog's with the sand's colours: a 16x16 tile of
  random pixels among (220,220,160), (230,230,170) and (240,240,180),
  pasted twice over the whole screen —a back layer that drifts one pixel
  every four frames and a front one that drifts one every eight and
  bobs—, at opacities 32 and 64, 64 and 80, or 96 and 160 by strength.
  Together that is 34%, 49% and 77% of sand over the map. It is drawn
  at `Priority_Weather`: over the map, its upper layer and every event,
  under the screen flash, the pictures, the windows and the timer. It
  takes the screen's tone.
* **Particles**: 128, 191 or 255 of them, 1x2 pixels, yellow, orange,
  red and white by index. A dead one is born with a ten percent chance
  per frame and lives eighty: it starts on a half ellipse below the
  top-centre of the screen —`d` from 16 to 95, the x doubled— and
  accelerates outward, two pixels per frame squared, so it bursts off the
  screen in ten to fifteen frames. Its alpha starts at 180 and grows.
  They are in screen space, not stuck to the map, and also take the tone.
  Note that the cosine and the sine come from **two different** random
  angles.

Simulated in Python at 256x224 (in my scratch): on screen there are 20,
29 and 38 on average by strength, up to 38, 50 and 68; ~1.5, 2.2 and 2.9
are born per frame. And the first time the weather starts all the
particles become eligible within forty frames, so it bursts.

## The console's way

Worktrees in `~/scratch/tijereta/`, branch `tijereta-sandstorm` in the
three repos, from the-advocate `3656d606`, ports `4ba709b`, docs
`2adb110`.

**The overlay goes in the tint's tables, not in color math.** RM2k's
overlay is drawn over exactly what the tint already transforms here —the
map, its upper layer, the panorama and the characters; not the window,
the pictures, the battle animation or the timer—, and it takes the tone.
A blend toward a colour is per channel, so it is one more step of the
three channel tables: `i -> i * (1 - a) + tone(sand) * a`. That gives any
opacity —RM2k's 34/49/77%, where half-add color math would only give 50%—
costs nothing per frame, and leaves the colour math and BG2 —Zounds'
baked poses— alone. It goes in `pure` too, because a character's flash
ends rebuilding its palette from there. The grain of the 16x16 tile is
lost: its three colours are a step apart at five bits, so it goes flat
and still, as their average.

**The grains are objects, as the drops.** Simulating 255 particles a
frame does not pay when ~40 are seen, so the screen has 64 slots and the
rest are a count: a ring of 81 entries with how many come back to life
each frame, and a pool of those waiting; `pool * 26 / 256` are born per
frame, rounded at random —the expected count of RM2k's ten percent each—.
A new sandstorm puts its particles alive over forty frames, which is
RM2k's first time. Each grain is an 8x8 object with its 1x2 pixels in the
corner, priority 2, at the end of the OAM. Their four colours go new and
in a row in one sprite palette (Wally's `sand_grains`), and the runtime
writes them again after the tint with the tint alone, so the overlay does
not pale them.

**It all assembles only in a cartridge with a sandstorm**: the converter
emits `sand_table` (four bytes per map: first tile, palette, first entry)
when some page —a map's, a common event's or a test page's— starts one,
and the five doors in bank 0 —`weather_set`, the frame, `build_oam` and
twice `apply_tint`— go inside `.ifdef sand_table`. So ABL and Vampires
Dawn come out byte for byte as before. The code is in `FAR3`,
`runtime/sandstorm.s`.

Snow and fog are not done, but the fog is the same overlay with other
colours and no grains: `sand_tint` takes its colour and cover from
constants that a fog would choose by type.

### What it cost, and what changed on the way

* **Far RAM was the limit.** Zounds' release had 829 B of far RAM left;
  the first layout —64 slots of eight words— wanted 1,120. Now a slot is
  a 9-byte record (life, x, y, the two angles with the side in a bit, and
  the two speeds; the accelerations are read from a table by angle) and
  there are 48: 527 B in all, 302 left. With 48 slots, 1.4% of the grains
  of a strong storm find none (simulated).
* **The grains first went on every map, as the rain's drops**, and that
  cost Zounds things elsewhere: a new palette pushed on full maps took the
  message arrow's on 34, 149 and 155, and the common events' small
  pictures fit on one map fewer each. So they go only where the storm can
  blow, `scan::sandstorm_reach` in the converter: the timer's walk, except
  that the map a page starts it on and then leaves is not counted —34
  starts it in the jump out, and counting it would carry it through every
  exit of 34—. In Zounds: 14, 50, 88, 111, 112 and 113, all with room, and
  the converter's log is otherwise the same line for line.
* Space in Zounds' release: bank 0 298 -> 278 B, `$C1` 8,302 -> 6,702 B,
  far RAM 829 -> 302 B. `test-exits`, without a sandstorm, unchanged.
  Only Zounds has a sandstorm page among the nine games, so ABL, Vampires
  Dawn and the rest assemble none of it.

### Measured on the ROM

On 113 through the maze door, 600 frames: 35.8 grains on screen on
average over the last 400, up to 48, in waves of ~90 frames that RM2k's
own rule also makes (simulated: 4 -> 71 -> 14 -> 61 ...). The OAM holds
exactly the live grains; `flush_high`'s hidden completers at line 224
keep a stale tile, so the test filters them.

The new test was red with the tools at `3656d606` (no `SAND_STRIDE`: no
sandstorm), and green with these. The maze door's golden moves —all of its
pixels, by the overlay— and the new test has one; both side by side in
`/shared/captures/2026-11-02-zounds-sandstorm/`, with frames of 113 and of
50 (50 reached with the harness's jump, which clears the tint).

### A character's flash paled the grains

A character's flash rebuilds its whole palette, and its last frame does it
from `pure`, which carries the overlay: grains sharing the palette stayed
pale until the next tint. RM2k's flash does not reach the weather, so
`sand_flash`, from `palette_with_flash`, writes them again with the tint
alone —one more door in bank 0, four bytes—. Zounds' 113 has an event in
the grains' palette; the ports' second test flashes it by RAM and was red
with the door out ([189, 79, …] against [255, 31, …]) and green with it.

## Verified

With the local tools (`events wally mapdata convert`, plus `project
cartridge` for the runtime's path):

* the-advocate: `just test` 29 passed; `just rust-test` 1,143 passed;
  `just lint` clean, with the machine's 1.98 rustfmt and clippy and not
  CI's pinned 1.96, which is not installed here.
* ABL: `just tests` 1,637 passed, 2 skipped. `abl.sfc` is byte for byte
  the main checkout's (`a85df642…`), also after the last commit. Vampires
  Dawn's `release` is byte for byte too. No game but Zounds has a
  sandstorm page, so none of this code assembles in the others and their
  space does not move.
* Ports: `just boot` 141 passed, the two new tests in
  `tests/test_zounds_sandstorm.py` among them.
* Zounds' `release` space: bank 0 298 -> 274 B, `$C1` 8,302 -> 6,634 B,
  far RAM 829 -> 302 B.

No test covers these: the sandstorm in a map with a mode-1 panorama or a
painted map (the objects' priority step is the rain's code, copied),
across a battle and back, after loading a game, and at strengths 0 and 1
(only Zounds' strong one is played). The test game does not use it, and
`just test-game` was not run.

## To merge

Reinstall `events wally mapdata convert`. The runtime goes with the
checkout. The branches are `tijereta-sandstorm` in the-advocate, the ports
and the docs. The goldens: `zounds-debug-maze` moves (all of its pixels,
because of the overlay) and `zounds-sandstorm-113` is new. Both are side
by side in `/shared/captures/2026-11-02-zounds-sandstorm/`.

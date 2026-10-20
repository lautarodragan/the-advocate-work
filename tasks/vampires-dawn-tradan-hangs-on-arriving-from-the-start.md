---
name: "Vampires Dawn: Tradan hangs on arriving from the start"
description: "Jumping to Tradan (170) right after the opening leaves a page active and the main loop without ticks, with main's tools too; maybe a page that waits for state the jump does not give, maybe a hang"
type: bug
status: doing
assignee: Mulita
agents: [Mulita]
---

Seen by Hurón on 2026-10-14, with the-advocate `51b4b1b2` and the ports
`d91049e` —the `release` of `~/the-advocate-ports`, built with the global
tools— while looking for a map to test the zombies that run at the hero
for
[`events-that-walk-by-a-movement-type-stand-still`](events-that-walk-by-a-movement-type-stand-still.md).
**Not played**: a jump the game itself never makes, so it may be nothing.

**What happens**: past the opening (`until_control`), a door jump to map
170 at (49,27) —the cell map 1's door leaves you on— loads the map, and
about 250 frames later `ev_active` is 1 and `ticks` stops for good: the
harness's `advance` gives up with "no tick in 3000 frames". No message,
no menu, no fade.

**To reproduce**: the ports' `tests/`, `Session(build("vampires-dawn"),
SNES9X)`, `pass_the_title()`, `until_control(30000)`, and write the door
request by hand (`fade_map`, `entry_x`/`entry_y`, `fade_kind =
FADE_DOOR`, `fade = 1`) to 170; run 900 frames reading `ticks`.

To look at first: which page is active then, and whether the ROM is in a
loop of the interpreter or waiting on something —a page that only runs
when the story got there from map 1 should still let the loop tick—.

## Defined

**2026-10-16, Hurón**, checked against the-advocate `f4709d0b` and the ports `66ed09c`.
Whatever page is waiting, the main loop should keep ticking: `ticks`
stopping for good is a hang of the ROM, not of the story, so this is a bug
with a repro whether or not the game itself makes that jump. **Done** is
the cause found and fixed, and a test in the ports that makes the draft's
jump and sees `ticks` go on for 900 frames. First step: the draft's own
—which page is active and where the CPU loops when `ticks` stops—.

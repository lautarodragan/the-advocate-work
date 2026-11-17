---
name: "Debug switches for the global state"
description: "Switches in the debug screen to turn off the state the game leaves on across maps —the tint, the on-screen timer, the weather…— so lag and other bugs can be bisected in taro's own game"
type: feature
status: testing
assignee: taro
agents: [Tijereta]
---

Opened by Hornero on 2026-11-17, at the-advocate `ed8d8590` and the ports
`f62e91b`, after
[`abl-lazer-teeth-s-rock-lags`](abl-lazer-teeth-s-rock-lags.md): the ~35
lag frames per stone came from the opening's tint (saturation 40), which
the game leaves on across maps and the harness cleared; the on-screen
timer cost ~3 more.

taro, translated:

> I suppose in the future we can turn off the tint, bisect-style, to test
> lag and other things.

and, about this task and
[`mesen2-s-core-in-the-harness`](mesen2-s-core-in-the-harness.md):

> Good idea! I like both. I'd go for the two in parallel, I think.

**What**: in the debug screen (which lives in the `.msu`, and yields room
and speed to the game), switches that force off, while set: the screen
tint, the on-screen timer, the weather (rain, sandstorm…), and whatever
else of that kind the runtime keeps across maps and costs per frame (find
them). Off in a clean delivery, like phasing.

**Done**: the switches work from the debug screen in ABL and Zounds; with
them off nothing changes (ROM tests); with one on, its cost leaves the
frame (measured on Lazer Teeth under the opening's tint); bank 0 and far
RAM measured with `just space` (far RAM in ABL's `release` has ~131 B).

## Log

### 2026-11-17, Tijereta: the design

From the-advocate `ed8d8590` and the ports `f62e91b`, branches
`tijereta-debug-switches` in both.

**What is global, per frame, and survives a door** —read in `runtime/`—:

* the tint, `tint_r/g/b/s`: it changes the paths the palettes and the
  flashes take (`flash_direct`'s saturation, `build_palette`), `timer_repaint`;
* the timer, `timer_visible`: `timer_oam` every frame it shows;
* the weather, `far_weather`: `rain_tick`/`rain_oam` and
  `sand_tick`/`sand_oam`, and the sand's overlay in the tint's tables.

Left out, and why: the screen flash and shake end on their own in RM2k 2000
(no continuous mode), so they do not stay across maps; the pictures and the
panorama are what the game shows (Zounds' menus are pictures) and cost per
frame only while they move; the counter's digits are hidden by `enter_map`;
the parallel common events are the game's logic.

**No per-frame cost.** The forced state is the game's own off state —tint
neutral, timer hidden, no weather—, so the main loop asks nothing. What the
game wants goes to `state_kept`, in far RAM (8 B with the bits), and comes
back when the switch goes on again. What the game asks for while forced
goes there too: three hooks, a `jsl` each in bank 0, in `op_tint`,
`op_timer`'s start and `op_weather`. A timer that stops while forced needs
no hook: one that does not run never shows, so giving it back looks at
`timer_active`. `save_game` saves the game's tint and timer, not the forced
ones. A reset turns them all on again.

**Gated by `[debug] debug_screen`**, not a knob of its own: the switches are
rows of the screen and cost nothing per frame, so a second knob would buy
nothing and take three crates of plumbing (cartridge, convert, mapdata).
A clean delivery, `debug_screen = false`, carries nothing of it. And
without the MSU-1 there is no debug screen, so no switches either.

**Where they are**: the screen's last page, after the variables' —left
from the first page—, `D[0001-0003]`: `Tint`, `Timer`, `Weather`, `[ON]`
while the game has its way, `[OFF]` once A forced it off. The names are in
the ROM, in ASCII, which the screen's font always carries.

### 2026-11-17, Tijereta: done, measured

the-advocate `230325f9` (`runtime/debug_switches.s`, the page in
`debug_screen.s`, the three hooks, `boot_init` and `save_game`), then
`b3cc286e` and `877c0954`: in `FAR3` alone Zounds' build overflowed `$C1`
by 82 B, in `FAR2` alone Sunset's overflowed `$C0` by 128 B, so what the
commands and `save_game` call is in `FAR2` (195 B) and what only the screen
calls in `FAR3` (332 B with the screen's own lines). The ports: the tests
and two goldens, main merged. The book `9f29cf5`.

**`just space` on `release`**, main's build against the branch's: ABL bank 0
4019 → 4007 B free (the three `jsl`), far RAM 131 → 123 B (`dbg_off` and
`dbg_kept`), `$C0` 2478 → 2283, `$C1` 1940 → 1608; Sunset `$C0` 264 → 69;
Zounds `$C1` 461 → 129. Those two are nearly full: draft
[`the-far-code-banks-are-nearly-full`](the-far-code-banks-are-nearly-full.md).

**Lazer Teeth, Light4 from (15,48), snes9x with the MSU-1** —the screen
needs it—: neutral screen 7 frames lost; the opening's tint forced off from
the screen 7; the opening's tint not forced 8. The new test,
`test_with_the_tint_forced_off_a_stone_loses_what_it_loses_without_it`,
asserts forced == neutral, so a switch that did nothing would be red with
8 against 7 (measured with that third throw).

**How taro reaches them**: B (pause menu), up (the menu's last row, Debug),
A; then **left** —from the first page it goes round to the last, the
state's—, A into its list, up and down to the row, A to flip it; B, B, B
back to the map, which takes the change. `[OFF]` is forced off. A reset
turns them all on again.

### Verified (the-advocate `877c0954` on `ed8d8590`, main had not moved; the ports with main `f52357e` merged; the book on `94dac96`)

With the branch's `cartridge` installed locally —the runtime goes with the
checkout `project` was compiled from—:

* ABL's `just tests`: 1684 passed, 2 skipped, test_cores included; no
  golden moved. New: two goldens, `debug-screen-state` and
  `debug-screen-state-off`; `test_a_variable_moves_by_one_and_by_ten` takes
  one more left, since left from the first page now goes round to this one.
* `just boot` at the ports' root, the nine games: 166 passed, with
  `test_the_state_s_switches_force_it_off_and_give_it_back` on each —the
  sandstorm on Zounds, the rain elsewhere—.
* `abl.sfc` sha256 `4216d349c5b8e72f…`.
* Not run: `just test` in the-advocate —no Rust or Python of the tools
  changed, only `runtime/`—.

**What no test runs**: a `TintScreen`, a timer start or a `WeatherEffects`
reaching its hook while forced off —the tests write the state from
outside—; a save made while forced off (`dbg_unforce`/`dbg_force` around
`save_game`'s copy); the FX Pak.

**To install when merging**: nothing to compile —only the runtime
changed—; the global install's runtime is `~/the-advocate`'s, so the merged
checkout is what goes in.

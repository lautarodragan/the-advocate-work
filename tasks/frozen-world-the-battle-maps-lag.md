---
name: "Frozen World: the battle maps, the battles and the Use Menu lag"
description: "The custom systems run far below 60 frames: Command Grid, Plate Placement, the fights and the Use Menu, with no parallel event or heavy graphics to explain it"
type: bug
status: testing
assignee: taro
agents: [Aguará]
---

taro, on 2026-10-17, playing Frozen World on Mednafen: the intro, moving,
the special menu and several fights work, but the special systems lag a
lot.

* `Battle Screen / Command Grid`: each plate has 24 pages, but there is no
  parallel event or heavy graphic to justify it. The LutineMeter picks
  its graphic with page conditions on a variable (>90, >80…); the
  StaminaPool, the same.
* `Battle Screen / Plate Placement`: practically the same map, the same
  lag.
* The fights and the Use Menu lag too.

taro's question: are the page conditions checked every frame? On that map
which page each event shows could be decided when entering, but even
without that optimisation the lag is not understood.

What is known, from
[`frozen-world-the-custom-battle-system`](frozen-world-the-custom-battle-system.md):
map 1 has two parallel pages (`BackdropSetter`, event 29
`CalculateHPPercents`, whose writes ask for a refresh of every page of
the map each frame), map 2 has one.

taro, also on 2026-10-17: Zounds lags quite a bit on some of the ship's
maps, worst of all in Uname's room. Measured here the same way, as the
check that the cause is generic and not Frozen World's.

## Log

* 2026-10-17, Aguará: taken from the-advocate `b15c9408`, the ports
  `bd92975`, the book `df2b2b8`; branches `aguara-lag`.

### How it is measured

snes9x through ABL's harness (`emulator/retro.py`) and the ports'
`tests/games.py`, with a line profiler that is not committed: a mark at
each boundary of the main loop —and inside the map load— reads the PPU's
vertical counter and the NMI count and adds the scanlines to its bucket
(~1 line per mark). Hardware frames per tick are counted by the harness.
The Frozen World is played: intro to map 11, a jump to map 12 and walking
into Sandflower.1, which starts a real fight (map 1, then the command
grid, map 3); switch 6 is turned on to have a plate in Lutine's first
slot, and A on it plays a round (map 3 → map 1, walk to Monster A, A,
until map 3 has control again). Maps 2 and 14 by jumping there from the
fight. Zounds: boot to control and jump to each ship map.

### Before (the-advocate `b15c9408`)

Idle, hardware frames per tick, and the lines per tick of the refresh:

    The Frozen World map 1 (fight)   4.00   refresh 622 (pick 420, apply 203), parallels 140
    The Frozen World map 2           6.00   refresh 1,290 (pick 1,037, apply 252)
    The Frozen World map 3           1.00   no refresh; one forced costs 1,163
    The Frozen World map 14          2.00   refresh 184, parallels 35
    Zounds map 17, Unamë's room      2.00   refresh 266
    Zounds map 21                    1.94   refresh 170
    Zounds map 19                    1.23   refresh 163
    a whole round of the fight       619 frames in 155 ticks

**The cause**: a refresh of every page on every frame, asked by writes that
change nothing. Map 2's parallel EV0038 turns switch 186 off every frame;
maps 1 and 14 call common event 38 (`CalculateHPPercents`) every frame,
which computes each percentage in place, so the variable goes through
HP and HP*100 and comes back to the value it had. Zounds' map 17 has no
parallel page of its own: a parallel common event does it. And each
refresh is expensive: ~2.5 lines per page to choose, ~4 per event to
apply.

### What changed (the-advocate, `aguara-lag`)

1. `dfbd6aca` **A refresh only when a switch or a variable really
   changes.** A switch flags it, and owes the pure parallels their run,
   only when its bit flips. A variable write that asks for one notes the
   variable and the value it had (`var_note`); where the refresh is looked
   at, `var_settle` flags it only if one ended up different —which is what
   catches `CalculateHPPercents` going through two values and back—. Past
   eight noted variables it refreshes anyway. `OP_CELL_TEST` too
   (`b05625f4` moves its call out of the macro, for
   `test_jumps_between_banks.py`).
2. `076c5cd9` **A refresh sets up only the events whose page changed**
   (`applied_page`): RM2k's `SetupFromPage`. It closes the draft
   `a-refresh-sets-up-every-page-again` (deleted).
3. `5ab89166` **Choosing pages reads only the first fourteen bytes** of
   each page, and `seek_event_page` (A, touch) compares the event before
   reading the page.
4. `a15a9111` **Pure parallel map pages** run only when what they read
   changes, the rule the pure parallel common events already had, with
   `ChangePBG` allowed: `pure_page` in the events compiler, bit 7 of the
   trigger, `pure_due` in the runtime. Compiler, converter and emission
   changed: to install `events`, `mapdata`, `convert` and `cartridge`.

### After (merged with main `8f38269e`)

    map                               before   after (frames per tick, idle / walking)
    The Frozen World map 1 (fight)    4.00     1.00 / 1.00   (parallels 146 → 39 lines)
    The Frozen World map 2            6.00     1.00 / 1.00
    The Frozen World map 3            1.00     1.00 / 1.01
    The Frozen World map 14           2.00     1.00 / 1.00
    Zounds map 17, Unamë's room       2.00     1.00 / 1.00
    Zounds map 19                     1.23     1.00 / 1.00
    Zounds map 21                     1.94     1.00 (+ its arrival tick) / 1.10
    a whole round of the fight        619 frames → 273, in 155 ticks

The limit of each path, measured:

* **No refresh when nothing changed**: all of the idle lag. It cannot help
  a refresh that is due: a switch flip on a map of ~420 pages still costs
  the refresh whole.
* **Setting up only what changed**: `apply_pages` with a refresh forced
  every frame, 139 → 72 lines on map 3, 204 → 137 on map 1, 250 → 154 on
  map 2. What is left is walking the events, reading the active page of
  each and the hidden ones.
* **Reading fourteen bytes**: `pick_pages` forced, 1,018 → 766 lines on map
  3, 423 → 318 on map 1, 1,031 → 771 on map 2: ~1.85 lines a page. What is
  left is each page's conditions and the walk; a refresh still costs ~3
  frames on maps 2 and 3. Going further needs a refresh that looks only at
  the events whose conditions read what changed: draft
  [`a-refresh-costs-frames-on-maps-of-many-pages`](a-refresh-costs-frames-on-maps-of-many-pages.md).
* **Pure parallel pages**: `BackdropSetter`'s ~107 lines on every frame
  without a change, to zero; it still runs on the frames after a switch
  flips. Map 1's other parallel, event 29 (`CalculateHPPercents`, ~35
  lines), reads HP and writes variables: not pure, and it stays.
* A faster `op_if` on a switch (~1 line each) was not done: with the
  pure pages it no longer matters on these maps.

What a round still costs is mostly the two map loads, ~62 and ~34 frames
with the screen black, uploading each map's audio package again: draft
[`frozen-world-every-turn-re-uploads-the-battle-screens-audio`](frozen-world-every-turn-re-uploads-the-battle-screens-audio.md),
and a line in the book's Known issues.

### Verified (merged with main: the-advocate `8f38269e`, the ports `440a4ae`)

With the branch's tools installed locally —`cartridge`, `events`,
`mapdata`, `convert`, and main's `wally` and `adeleine`, which the global
ones did not have yet—:

* ABL's suite: 1565 passed, 2 skipped; no golden moved. `abl.sfc`
  `410904f5428c0a7e…` (sha256).
* The other games' `just boot` (BoT's boot and milestones included): 60
  passed.
* The test game, `just test-game`: 38 passed, 1 skipped.
* `just rust-test`: 964 passed. `pure_page`'s two tests shown red first
  (with it answering false).

**What the suite does not cover**: no test plays a fight of The Frozen
World, Plate Placement or the Use Menu, or Zounds' ship; the numbers above
are from scripts, not from the suite. No test asserts frames per tick on
those maps, and none runs a pure parallel page of a map (ABL has none
that changes the panorama; its pure ones are common events). That
`BackdropSetter` still sets the right backdrop was not looked at: map 1
has no panorama, so its `ChangePBG` sets nothing on the console today.

**To install when merging**: `just install cartridge events mapdata
convert`.

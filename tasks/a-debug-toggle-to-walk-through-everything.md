---
name: "A debug toggle to walk through everything"
description: "In a debug build, Select turns on and off walking through walls, events and tiles, as RPG_RT's test play does holding Ctrl"
type: feature
status: testing
assignee: taro
agents: [Carpintero]
---

taro, on 2026-11-02, in their words, translated:

> Another debug option: _phasing_ or whatever it's called, like the
> original RPG_RT.exe, which, in debug mode, let you hold Ctrl (if I
> remember right) to go through things.
>
> In our case, I think we have the Select button free. Maybe we could use
> it to toggle phasing on/off, no?

## What is asked

* Only in a build with debug on —whatever `[debug]` in a port's
  `advocate.toml` turns on today, as Zounds' debug room—; a release
  without debug behaves as before, byte for byte if it can.
* Select toggles it; RPG_RT holds Ctrl instead, and that difference is
  declared.
* What RPG_RT lets through while it is held is read from
  `~/ref/easyrpg-player` (`Game_Player`, `Game_Character::MakeWay` /
  `IsPassable`, the debug "through" check), not from memory.

## Log

### 2026-11-02, Carpintero

From the-advocate `5ef467fe`, ports `1f1d0ea`, docs `5a87d0a`; branches
`carpintero-phasing` in the three.

**What RPG_RT does**, read from easyrpg-player: `Game_Player::
UpdateNextMovementAction` calls `SetThrough((Player::debug_flag &&
Input::IsPressed(DEBUG_THROUGH)) || move_route_through)` around the pad's
`Move` only, and `ResetThrough` after (`DEBUG_THROUGH` is LCTRL/RCTRL).
`Game_Map::CheckOrMakeWayEx` returns false for a cell that is not
`IsValid` —the map's edge, after rounding for looping maps— and then true
for a `through` character, before tiles, events and vehicles. So: tiles,
tile events, same-layer events and vehicles let it through; the edge
does not. Touch "here" (`CheckEventTriggerHere` after a step, layers other
than the hero's) still fires; the bump (`CheckEventTriggerThere`) only
when the move failed, so only at the edge. Events walking into the hero
still collide —`WouldCollide` looks at each side's `through`, and the
hero's is reset after his `Move`—. `UpdateEncounterSteps` returns first
thing while it is held. In a vehicle it applies too (the `through` check
comes before the vehicle type); the runtime has no vehicles.

**How debug exists today**: three required keys in `[debug]` —
`debug_map`, `enemy_hp`, `debug_screen`—, read by `rm2k-snes-cartridges`
and passed as converter flags; `--debug-screen` becomes `DEBUG_SCREEN`
in `mapdata.inc`, which the runtime looks at with `.if`. No single
runtime-level "debug" flag. **Every port has `debug_screen = true`**, and
ABL also `debug_map = true`, so tying phasing to any of them would change
ABL's and Vampires Dawn's ROMs. Hence **its own key, `[debug] phasing`**:
`--phasing` → `DEBUG_PHASING` → `.if` in the runtime. On only in Zounds.

**Select is free**: the runtime names A, B, X, L, R, Start and the arrows
(`registers.s`); a grep for every read of `pad`/`JOY1H`/`JOY1L` with a
literal mask finds no `$20` (Select) —nor `$40`, Y—. The debug screen
reads JOY1L itself.

**Implementation**: the runtime already had RM2k's `through` for the
hero, `crossing`, which `can_leave`, `can_enter`, `cell_allowed` (the
diagonal and the wrap seams) and `hero_blocked` honour. `move_hero` sets
it from `phasing` around the pad's `try_toward` only; `phasing_keys`
(FAR3, from the main loop next to `speed_keys`) toggles on Select's
edge; `encounter_step` returns at once while on; `place_hero` skips
drawing the hero 4 ticks of 16 while on —the cue for the console—. All
under `.if ::DEBUG_PHASING`; the variable is a `.res` in BSS inside
`runtime/phasing.s`, cleared at boot.

`convert.rs`'s request literal is at `json!`'s recursion limit: one more
key does not compile, so `phasing` goes in apart, like `switch_top`.

**Byte for byte**: ABL's and Vampires Dawn's cartridges —all eleven
`.sfc`, `release` included— built with main's tools and then with
`carpintero-phasing`'s (`project cartridge mapdata convert` installed
locally) have the same sha256: `abl.sfc` `a85df642…`, Vampires Dawn's
`release` `77b87486…`.

**Space, Zounds' `release`**: bank 0 244 B free (274 before: the cost is
30 B —the `jsl`, the `stz` at boot, the `jmp` the `jsl` forced on the main
loop's `bra loop`, the step's `crossing` and the blink—), BSS 79 B, far
RAM 302 B unchanged. Everything else is in `FAR3`.

**The test**: `tests/test_zounds_phasing.py` in the ports. Red with
main's tools —"the trainer still stops the hero: he is at (10, 7)"—,
green with the branch's.

**The cue**: the hero blinks, four ticks of sixteen not drawn. Captures in
`/shared/captures/2026-11-02-zounds-phasing/`, with a contact sheet.

**Not modeled or not covered**: vehicles (the runtime has none); no test
executes the blink (seen in captures), the encounter skip, a phased step
across a looping map's seam, or a forced move route while phasing is on
—the route keeps its own `through`, by construction—. It outlives a
teleport and a battle, unlike RPG_RT's held key; reset clears it, the save
does not carry it.

**Suites, with the branch's tools first on the PATH**: `just test` 29
passed; `just lint` clean (after `cargo fmt`); `crate-test` cartridge,
mapdata and convert green; ABL `just cartridges` + `just tests` 1637
passed, 2 skipped (as main); ports `just boot` 142 passed (main's 141 and
the new one); `just test-game` 63 passed, 1 skipped —its project file
got the new key—.

**To install when merging**: `just install cartridge mapdata convert`.
`project` is not touched: the runtime reaches the cartridges from the
checkout, as always. Zounds has `[debug] phasing = true`: `false` for a
clean delivery.

**For taro, on the console**: in Zounds' debug room, Select, and walk into
the trainer or a wall; the hero blinks while it is on. Select again and
walls stop him.

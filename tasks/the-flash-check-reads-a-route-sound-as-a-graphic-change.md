---
name: "The flash check reads a route's sound as a graphic change"
description: "The converter's walk over a route on the hero, to know its graphic when a flash comes, steps over command 35 without its two operand bytes"
type: bug
status: testing
assignee: taro
author: calandria
agents: [Calandria, Hurón]
---

Seen by Calandria on 2026-10-19, reading `rm2k-snes/convert/src/convert.rs`
at the-advocate `9592b88b`, while writing the scan's `route_graphics`
(`pages.rs` in the events compiler), which walks the same bytecode. Not
seen in any game's build.

The converter's second round walks each `OP_ROUTE` on the hero to know
which graphic the hero has when an `OP_FLASH` comes ("the graphic the hero
has then is the last one a route on the hero gave it"). It skips command
34's operand, but not command 35's two —the sound's index, low byte
first—: a sound whose index's low byte is 34 is read as a graphic change,
with the high byte as the graphic, and a 34 among them as the start of
another command. What it decides is only whether two flashes share a
graphic, so the worst is a refusal or a missed one, not a wrong ROM.

How to see it: a route on the hero with a sound effect whose index in the
map's audio package is 34, followed by a flash of the hero.

## Defined

On 2026-10-20, by Tijereta.

Checked against the-advocate `8f290c39`: still so. The walk in
`rm2k-snes/convert/src/convert.rs` (the flashes' second round, "the
graphic the hero has then") skips one byte after a 34 and none after a 35,
while `route_graphics` in `rm2k-snes/events/src/pages.rs` walks the same
path right —`ROUTE_CHANGE_GRAPHIC` two bytes, `ROUTE_SOUND` three—.
**Done**: the converter's walk steps over command 35's two operand bytes,
ideally through one helper both walks share, so that a third command with
operands cannot split them again; a converter unit test with a hero route
whose sound index's low byte is 34, followed by a flash, that does not
read it as a graphic change. **First step**: that test, red.

## Log

### 2026-11-22, Hornero: the skip was already fixed; taken by Calandria

The converter's walk already steps over 35's two bytes since the-advocate
`9329f602` (2026-10-20, Mulita, "Routes turn switches on and off"), which
added 32 and 33 with two bytes too and fixed both walks; Tijereta's check
that day was on `8f290c39`, before it. `convert.rs` has
`32 | 33 | 35 => k += 2` today.

What is left of "Done" is the shared helper and the unit test. taro,
translated, choosing between closing it and doing those:

> Let's go with 2

### 2026-11-22, Calandria: one walk of a compiled path, and its tests

From the-advocate `6a8f4162`, on branch `calandria-route-walk`.

#### The walkers

Three walks of a compiled `OP_ROUTE` path carried their own copy of the
operand widths: `route_graphics` and `route_turns` in
`rm2k-snes/events/src/pages.rs`, and the converter's hero graphic at a
flash in `rm2k-snes/convert/src/convert.rs`. The writer is
`compile_route`; the ROM's readers are `change_graphic`, `sound_ev` and
`switch_ev` in `runtime/event_routes.s` and their `_hero` twins in
`runtime/hero_route.s`, which agree: 34 one byte, 32, 33 and 35 two.
Nothing else walks a compiled path: `landings.rs`, `route::decode` and
`min_frequency` read RM2k's integers or bare codes, and Wally and
mapdata only read what `pages.rs` answers.

#### The change

`route::operand_bytes` and `route::path_commands` in the events crate —an
iterator of `(command, operands)`—, and the three walks use it. The
converter's flash walk moved out of `run` into `hero_flashes`, so it can
be tested without a game.

#### The tests

* `route::tests::a_compiled_path_s_operands_are_not_commands`: a sound and
  two switches whose low bytes are 34, a step, a graphic and a graphic cut
  short, split right.
* `compile::tests::a_compiled_route_walks_with_its_operands`: what
  `compile_route` writes for switch 34 on, a sound, switch 290 off and a
  step, walked by `path_commands` into those four commands; it ties the
  writer to the reader.
* `convert::tests::a_hero_route_s_sound_is_not_a_graphic_change_at_a_flash`
  and `…_switch_is_not_…`: a hero route with sound 290 (low byte 34) or
  switches 290 and 34, then a flash; the hero's graphic at the flash is
  the one it had.

The sound one was shown red with the walk as it was before `9329f602`
—`operand_bytes` giving 35 no bytes, which is that walk exactly; the
switches were not compiled before then—: the flash ran with `Other[2]`,
the high byte read as the graphic.

#### No ROM changes

With the global tools (installed from `6a8f4162`) and then with
`PATH=<worktree>/.local-tools/bin:$PATH` —`convert` and `events` of the
branch, `just install-local .local-tools convert events`—, in a ports
worktree at `001cfb7`: `just cartridges --force --without-tracks release`
in `abl/`, and `just cartridges --force release` in `zounds/` and
`frozen-world/` —Frozen World because its common event 3 is the hero
route then flash the walk is for—. The `.sfc` and the `.msu` of the
three come out byte for byte equal, so the ROM suites were not run.
`just test` and `just crate-test events` and `convert` pass.

the-advocate: branch `calandria-route-walk`, `a9545933`, with `main`
merged. To install when merging: `just install convert events`.

Not touched, and stale since the sound came in on 2026-09-27: two comments
in the runtime still call 34 "the only one with an operand" —the
`graphic_hero` dispatch in `runtime/hero_route.s` and the header of
`change_graphic` in `runtime/event_routes.s`—. Left alone so this change
stays out of the runtime.

### 2026-11-22, Hurón: no capture

Nothing to see: no game has a hero route with a sound whose index's low
byte is 34 before a flash, and Calandria rebuilt ABL, Zounds and Frozen
World before and after with the `.sfc` and `.msu` byte for byte equal.
It is checked by the converter's and the events crate's unit tests (`just
crate-test convert`, `just crate-test events` in the-advocate).

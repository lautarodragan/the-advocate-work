---
name: "Vampires Dawn: Tradan hangs on arriving from the start"
description: "Jumping to Tradan (170) right after the opening leaves a page active and the main loop without ticks, with main's tools too; maybe a page that waits for state the jump does not give, maybe a hang"
type: bug
status: testing
assignee: taro
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

## The cause

**2026-10-20, Mulita**, at the-advocate `8f290c39` and the ports `68bf55b`.
Reproduced as the draft says —the jump needs `fade_base` too, as
`Session.go_to_map` writes it—: the map loads, the door fade ends about
270 frames later, and from then on `ev_active` is 1, `ev_running` is 28
and `ticks` never moves again.

Index 28 is **EV0029**, a parallel page that is all a loop:

    Loop
      ShowPicture 19 'cloudsky'              (transparency 40, at (0,120))
      MovePicture 19 to (320,120), 10 s, wait
    EndLoop

What the cartridge carries for it, read from WRAM where the map's code
lands: `3D 04 64 64 64 28 64 00` —`OP_BIG_SHOW`, cloudsky as a big
picture— and `13 00 00` —`OP_GOTO` to the start—. **The `MovePicture` is
gone, and its wait with it**, so the loop has nothing that lets a frame
go by: `parallel_tick` enters `run_code` and never comes back.

Why it is gone: `compile_picture` in `rm2k-snes/events/src/compile.rs`
cannot do this move —the big picture only scrolls up and down, and this
one slides sideways; and 100 tenths are 600 frames, past the 255 of
`OP_PICTURE_MOVE`'s byte—, so it answers `None`, "accepted without being
done", and the caller emits nothing. But `loop_waits`, which refuses a
loop that never waits because the console has no ten-thousand-command
cap like RPG_RT's, counted that `MovePicture`'s wait and let the loop
compile. In RM2k the wait does not depend on the move: easyrpg's
`CommandMovePicture` calls `SetupWait(duration)` whatever the picture.

The fix that follows: a `MovePicture` with its wait that is not done
still compiles its wait, an `OP_DELAY` of the duration.

## The fix

**2026-10-20, Mulita.** the-advocate `f6907921` on `mulita-tradan-hang`:
a `MovePicture` that `compile_picture` cannot do now compiles its wait
alone, an `OP_DELAY` of its duration, and the three places that emit that
wait share `picture_wait`. It also stopped skipping a zero duration:
`SetupWait(0)` waits one frame and `OP_DELAY 0` ends the frame, so a
zero-length waiting move in a loop cannot hang either —one command in
Zounds has a zero with a wait—. The compiler's test is
`a_move_not_done_still_waits`, red without the change (the loop compiled
to `OP_GOTO 0 0` alone).

The ROM test is `tests/test_vampires_dawn_tradan.py` in the ports, branch
`mulita-tradan-hang`: the draft's jump and 900 frames watched. Red with
main's tools —"no tick in 3000 frames, on map 170", already inside
`go_to_map`—.

The book's divergence `a-loop-that-never-waits-does-not-compile` says that
the wait counts even when the move is not done, and names the ROM test.

## What was run

With the tools of `mulita-tradan-hang` (`just install-local .local-tools
events convert`), in the ports worktree of the same branch, on
2026-10-20:

* `just crate-test events`: 170 green, `a_move_not_done_still_waits`
  among them; red without the caller's change.
* ABL's `just tests`: 1576 passed, 2 skipped.
* `just boot` from the ports' root: 96 passed and one red,
  `test_the_painted_maps`, Sunset's square. Green with main's tools: the
  opening's waiting moves now wait, control comes 976 ticks later
  (11210 against 10234), and three goldens changed only in the phase of
  what animates on its own. Regenerated until green —snes9x and bsnes—,
  in their own commit, side by side in
  `/shared/captures/2026-10-20-tradan-hang/`.
* `test_vampires_dawn_tradan.py`: red with main's tools, green with the
  branch's; one tick per frame for the 900, in snes9x and in bsnes.
* `just space` for every cartridge of every game, before and after: bank
  0 and everything else equal; only the gaps of the data banks shrink
  —Vampires Dawn 657 B, Zounds 140 (and its `test-exits` 42), Desert
  Nightmare 132, Sunset 85, El Dorado 70, The Frozen World 4—, three
  bytes per wait that comes back. ABL's cartridges do not change.

**Not covered**: no test plays Vampires Dawn's other pages whose waits
came back —120 of its waiting moves are longer than the byte, and
others name pictures a map does not carry—; they now wait as in RM2k, so
a scene that seemed to rush may take its time. Nor the Zounds command
whose zero-length move now waits one frame.

**To install when merging**: `just install events convert`, from
`~/the-advocate`.

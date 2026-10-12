---
name: "Label and JumpToLabel"
description: "The two commands that have no case in the event compiler: the portable console and 8 map pages use them"
type: feature
status: done
assignee: taro
---

Phase 1 of [`research/2026-10-01-the-picture-system.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-01-the-picture-system.html) (Jilguero),
from taro on 2026-10-01: "going ahead with Label, JumpToLabel sounds perfect
to me".

## What RM2k does

Confirmed in easyrpg, `CommandJumpToLabel` and the dispatch of `Cmd::Label`
(`game_interpreter.cpp`):

- `Label` does nothing.
- `JumpToLabel` walks **the frame's whole list from the top** and jumps to the
  **first** `Label` with that number: it does not look at the indentation nor
  at whether it is before or after the jump. A second one with the same number
  is never reached.
- If there is none with that number, **it does nothing** and continues.
- The list is the frame's: a `CallEvent` only sees its own labels.
- There is no block stack. What there is is a sub-index per indentation
  (`subcommand_path`): an `ElseBranch`, a `ShowChoiceOption` or a battle
  handler runs or skips its body according to what **the last block at that
  indentation** left there. Jumping **out** of a block costs nothing. Jumping
  **into** the upper body of a branch with `else` makes the `else` run or not
  according to that leftover: normally not, but a false branch without `else`
  leaves "else" set and then it does.
- `Loop` without the Maniac patch keeps no state; `EndLoop` looks for its
  `Loop` backwards by indentation. Here `Loop` does not compile, so it does
  not matter.

## What was done

`tools/rm2k-snes/events/src/compile.rs`: `label_targets` resolves each jump
like easyrpg —the first one with the number, or nothing— and `page` emits an
`OP_GOTO`: backwards with the position already known, forwards left open and
patched at the end of the page. No new opcode.

**What does not compile**: a jump that lands inside a body that **is not the
last** of its block —the upper one of a branch with `else`, an option that is
not the last, a handler that is not the last—, because there what follows
depends on RM2k's old sub-index and here it is always a jump to the end. If
the label is in the last body —an `else`, the last option, a branch without
`else`— what comes next is the end of the block, which does nothing in either
of the two, and it compiles. The 13 jumps of common 39 that go into a block
all land in an `else`.

**What remains as a risk**: a backwards jump with nothing that waits in
between hangs the ROM —`run_code` does not cut off by number of commands,
like easyrpg, which yields the frame—. Measured over the game: all the
backwards jumps of commons 16, 21 and 39 have a `KeyInputProc` with wait
inside the loop, except the `JumpToLabel 15` of 39, which only loops if none
of the switches 712 to 725 is on.

## How many pages compile now

**None more.** Measured with `rm2k-snes-events scan` over all the game's
maps, the base's binary against the new one: 5560 and 5560. The 8 map pages
are the same page on maps 332 to 339 (Room B to Room I, event 3), and besides
the labels they use two things that do not compile: the branch on the hero's
direction (`ConditionalBranch` type 6) and `ControlVars` from an event's
position (operand 6: X and Y of the hero and of event 7). With those two
neutralised it compiles with the new compiler and not with the old one, which
also required removing `Label`/`JumpToLabel`. The console's commons (16, 21
and 39) have the blockers that Jilguero's study lists.

## Tests

- Unit tests in `compile.rs`: forwards, backwards, out of two branches, the
  first one with the number wins, one that is not there does nothing, inside
  the last body (`else`, branch without `else`, last option) compiles, inside
  one that is not the last does not, and within the same body.
- `rom/pruebas/casos/etiquetas.json` and `rpgmaker/test_etiquetas.py`: a
  backwards loop of three passes, a forward jump over a switch, one to a label
  that is not there, and one into an `else`. **The red**: with the base's
  compiler, `just cartuchos` refuses —"the test page doesn't compile"—.
- The small game of the Python tests (`tests/game/`) used a loose `Label` as
  "a command that does not compile", in common 3 and in page 2 of event 9: now
  it compiles and it changed the scan's hash. It was replaced with a `Loop`,
  which does not compile either, and the hashes in `python.json` stay as they
  were, without regenerating.
- Without the case, `abl.sfc` comes out identical to the base's
  (`645b6b86…`); with the case it changes (one more test page) and no golden
  moves.

## When merging

- Install `events` in the global one: `just -f tools/justfile install events`.
- No golden changes, and there is nothing to play yet: no page of the game
  compiles because of this alone. What can be looked at is the `etiquetas`
  case, which runs in the suite.

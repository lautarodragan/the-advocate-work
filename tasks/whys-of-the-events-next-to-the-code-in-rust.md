---
name: "The whys of the events, next to the code in Rust"
description: "The long comments of each command that were left in tools/port/events.py move next to the line they protect, in tools/rm2k-snes/events/"
type: docs
status: done
assignee: taro
---

Guazú left it noted when moving the event compiler to Rust
(`rust-el-compilador-de-eventos.md`): the whys of each command
—how much it unblocked, when it went in, what was measured, what bug it
protects against— are still in `tools/port/events.py`, but the code they
protect is now in `tools/rm2k-snes/events/`. The AGENTS.md rule is that a
why that protects a line goes as a comment on that line, so they move. It is
prose only: the ROM cannot change.

## Resumed on 2026-09-29

Tordo started and got cut off: a safety classifier interrupted its
response while it was writing the comments of `branch_bytes` in
`compile.rs` (the block of the conditions: items, questions about actors,
skills, equipment), without committing anything. What was decided with taro:

- **everything else** goes ahead, including the ~1,027 lines of whys
  that Guazú's deletion (`1487129f`) took along with the Python compiler:
  they are in `git show 1487129f^:tools/port/events.py`;
- **the `branch_bytes` block is not written**: it stays with Guazú's short
  comments and a pointer to that commit;
- if the classifier cuts off again, the agent doesn't look for a workaround:
  it reports it, and Hornero —letting taro know— applies the comment by hand
  in the worktree.

What Tordo left, uncommitted, is in its worktree
(`agent-a3eccaf0086f4b17e`): comments already moved to constants and
blocks of `compile.rs`. Its mapping of what stays in Python, what goes to
both sides and what goes only to Rust is in its report, copied below by
Hornero.

### Tordo's mapping

- **Stays in Python** (the code is still there): the fade, `PAUSE_FRAMES`,
  `STEP_PER_SPEED`, `JUMP_*`, the rain model, the notes of `KEY_*`,
  `CELL_*`, `TEST_SWITCH`, `CASE_VARIABLE`, `SWITCH_IMPOSSIBLE`, `ENC_*` and
  `Encounters`, `PartyState`, `database`, `Pictures`, `SHAKE_SINE`.
- **Goes to both sides** (the code exists in both): `escape_tail`, the
  header of the messages and `MESSAGES_STEP`, the frequency of the routes,
  the numbering of `Songs`, `BATTLE_PACKAGE`, the triggers and the
  header of the troops, `encounter_backdrop`, `picture_fits`,
  `MapEvents` (the 39 maps).
- **Goes only to Rust**: the rest.
- **Goes nowhere**: the two warnings of "the number is chosen
  looking at the ones there are" (OP_ACTOR_SPRITE, OP_PLACE_VAR), which
  AGENTS.md and `test_no_opcode_shares_a_number_with_another` already cover.
- **Dead Python constants**: `CHOICE_CURSOR` is used by no code;
  `SHOW_PICTURE` only inside `events.py`.
- **The comments of the opcodes** go to the arm of `compile.rs` that emits
  each one, not to `events.toml`: `protocol` discards the comments of the
  TOML, its README says that what an opcode does is written by hand, and
  those comments name the game, which `protocol` cannot know.
- The docstring of the `events.py` module (lines 20-21) says the whys
  are still next to each constant: it gets updated when they move.
- Tordo deleted without putting back, in its worktree, a line of Guazú's
  that was wrongly stuck to the doc of `ITEMS_N` (the gold cap): that fact
  has to be put back in `CHANGE_GOLD`.

Its uncommitted diff is saved in
`<scratchpad>/porques-tordo/tordo-parcial.diff`: it works as a starting
point, unless it touches the `branch_bytes` block.

## Done by Churrinche, on 2026-09-29

It started from Tordo's diff (applied with `git apply`, reviewed: the line
about the gold cap went back to `ChangeGold`, and a `[`refresh`]` that
rustdoc flagged as a link to a private item became `` `refresh` ``). Four
commits, one per Rust file or group:

- `compile.rs`, plus `game.rs` (the inn terms) and `lib.rs`
  (the party common events): each why to the arm of
  `compile_command` that emits its opcode, or to the constant, the function
  or the line of the page loop it protects;
- `route.rs`: the route orders, `decode`, `min_frequency`, `own`;
- `registry.rs`, `messages.rs` and `pages.rs`;
- `troops.rs` and `indices.rs`, with the `cargo fmt` of `pages_of`, which
  came from main unformatted and left `cargo fmt --check` red.

**On merging, only `events` has to be installed**: `just -f tools/justfile
install events`. It is prose only, but the binary gets rebuilt.

### What changed from the plan: the runtime cites events.py

Tordo's mapping said "goes only to Rust: the rest". When deleting, it turned
out that **the runtime and `mapdata.inc` cite events.py by name**: "see
OP_KEY in events.py", "see VAR_REFRESH in events.py", "See
`ChangeScreenTransitions` in tools/port/events.py", about thirty. Deleting
those notes leaves the citations dangling, and fixing the citations changes
the `.s` files —and with them the `.dbg`— and `mapdata.py` —and with it the
`mapdata.inc` of each cartridge—: it stops being prose only and
`rom/build/` stops coming out identical. So **what is cited stays on both
sides**: in events.py, as it was, and copied whole into the crate. They are
the turn (TURN), the transitions, `VAR_REFRESH` and the variables,
`VAR_CHARACTER`, `OP_ITEM`, `ACCESS_BIT` and `ChangeEscapeAccess`,
`OP_WEATHER`, `OP_ANIMATION`, `OP_BATTLE` and `BATTLE_LOSE`, the image,
`OP_ACTOR_SPRITE`, `OP_KEY`, `OP_PLACE_VAR`/`OP_LOCATION`, `OP_SAVE`,
`SKILL_SLOT`, `PARTY_COMMON_EVENTS`, `MESSAGES_STEP`. The module docstring
says so. When someone touches those `.s` files for another reason, they can
point them to the crate and delete the note here.

Only what nobody cites and already belongs only to the crate left events.py:
`CHANGE_EVENT_LOCATION`, `TILE_SUBSTITUTION`, `SHOW_MESSAGE`, the forced
route, `FLASH_SPRITE`, `WEATHER_EFFECTS`, `PLAY_SOUND`,
`SHOW_BATTLE_ANIMATION`, `SHOW_PICTURE`, `OPEN_SHOP`, `TIMER_OPERATION`,
the opcode block except `OP_SAVE`, the offset of
`OP_MESSAGE`, life and HP, the shop, the sound, `HaltAllMovement`,
the parameters of `EnemyEncounter`, the battle branches and the list of
`TROOP_COMMANDS`. And one came back: the header of the random encounters,
which the deletion took and which protects `Encounters`, which is still
in events.py.

### How much

Measured with `git diff` over the four commits: 2257 comment lines go into
the crate and 235 leave it —Guazú's short ones that were replaced by the
whole why, rewrapped to another width—; 369 leave events.py and 44 go in
—the docstring and the header of the encounters—. Guazú's deletion had
taken 1027 `#` lines; `b0001b6b` put back about 170.

### What went nowhere, and why

- **The long whys of the conditions** —the table of how much each type
  unblocks, the actor's questions, the docstring and the comments of
  `branch_bytes`, `OP_IF_VAR`, `OP_IF_ACTOR`—: because of the classifier's
  restriction. `branch_bytes` has a line that points to
  `git show 1487129f^:tools/port/events.py`, and the ones that were in
  today's events.py (`COND_*`, `OP_IF_VAR`, `OP_IF_ACTOR`) are still
  there, untouched. `OP_IF` did go: to the `COND_BRANCH` arm of the page
  loop, which is outside `branch_bytes`.
- **The two warnings of "the number is chosen looking at the ones there
  are"** (`OP_ACTOR_SPRITE`, `OP_PLACE_VAR`): AGENTS.md and
  `test_no_opcode_shares_a_number_with_another` cover them. They were also
  deleted from events.py.
- **Old ones, describing a state that no longer exists**: the debt of
  `ChangeItems`/`ChangeGold` from before the inventory ("nobody reads the
  inventory"), the sentence of `ShowBattleAnimation` saying the ROM doesn't
  draw animations, and the note of `CONTROL_VARS` about "the list
  here".
- **What protected Python code that no longer exists**: the docstring of
  `Messages.tail`, the `visible` field of `MapEvents`, "Returns copies" of
  `troop_commands` —in Rust the input is immutable—, `_Commands`, the
  `index_*` (when the converter calls them), `ENC_DEFAULT_STEPS`, and that
  the `se_*` are read when used and not on import.
- **What the converter decides and not the crate**: the page made
  impossible by item and `SWITCH_IMPOSSIBLE`, the graphic and the
  `tile_pass` of each page.

### Three things that were moved as they were and look wrong

They were copied whole because the task was only to move; whoever reads
them with the code alongside can decide:

- `OP_LOCATION` says "when **recalling** bits 7, 6 and 5 are the
  VAR_REFRESH of each of the three writes", but the bits are set by
  `MemorizeLocation`, which is the one that writes the variables.
- `can_trigger` says about the action on the own cell "we do not do
  those", and the comment below says it is done since 2026-09-07.
- The arm of `ChangeEquipment` says that troops "this port does not
  run", and since 2026-09-21 it runs them; the one of the battle without
  handlers says that `ChangeEscapeAccess` "is accepted and not done", and
  today it is stored.

### Verification

- `cargo test -p rm2k-snes-events`, `cargo fmt --check` and `cargo doc`
  without warnings.
- `NO_CACHE=1 just cartuchos`: the 999 files of `rom/build/` —without the
  cache, the `.o` files, `sello.txt` or `conversor.log`, and the `.dbg`
  without `mtime`— identical to the ones before starting.
- `just pruebas`: 872 green; `just -f tools/justfile test`: 88
  green. Both on the final tree, with `events` reinstalled.

What taro has to look at is not playing: it is reading the diff of the
comments, especially the three things above.

---
name: "Zounds: the intro on map 106 waits for a key nobody reads"
description: "Map 106's autostart waits for variable 4 to be 5 or 6 (the action or cancel key); only common event 3 writes it, with KeyInputProc in its long form, and that event is left out by the long KeyInputProc and by ControlVars from an actor's stats"
type: bug
status: done
assignee: taro
agents: [Aguará]
---

Found by Hornero on 2026-10-16, with the-advocate `af7c399d` and the ports
`f28916b`, asked by taro what keeps Zounds' boot on map 106.

Map 106 "Imágenes": event 1, page 0 (autostart) waits 50 and turns switch
192 on; page 1 (autostart, switch 192) asks variable 4: 5 → EraseScreen,
switch 193, Teleport to map 107 (10,7); 6 → the same to (9,7). No event of
the map reads a key. Common event 3, "Set Gloval Variables" (parallel, no
switch), does: `KeyInputProc` into variable 4 under a branch on switch 315.

`culprits` keeps common event 3 out for:

* `KeyInputProc` with 9 parameters, `[4, 1, 1, 1, 1, 1, 1, 1, 0]`: RM2k
  1.50's and 2003's long form, each direction on its own. The compiler
  requires the 5-parameter form (`compile.rs`, the `KEY_INPUT_PROC` arm,
  "the length is required instead of assumed"). With the four directions
  alike it is the short form.
* `ControlVars` from an actor (operand 5): `[0, 79, 79, 0, 5, 1, 1]`,
  `[0, 137, 137, 0, 5, 4, 0]` and others.

Common events 7 ("Saltar") and 40 ("Notes On Screen") are out for the same
long `KeyInputProc`.

## Work (Aguará, 2026-10-16)

Branches `aguara-zounds-boot` in the-advocate, the ports and the docs,
from the-advocate `af7c399d`, the ports `f28916b` and the docs `49d88e6`.

**The dump says 14 parameters, not 9.** Common event 3's `KeyInputProc`
is `[4, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1]`: RPG Maker 2003 1.05+'s
layout, read against easyrpg's `CommandKeyInputProc`: variable, wait,
(dirs, unread with 14), decision, cancel, numbers, operators, the time
variable, timed, shift, down, left, right, up. Common event 40's asks for no
numbers nor operators: `[4, 1, 1, 1, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1]`. Both
ask for the four directions, the action key and cancel, with no time stored:
the short form. Shift, the numbers and the operators are keys the pad does
not have.

Measured over the nine dumps: **only Zounds uses a long form**, and no
game asks for some directions and not others.

`ControlVars` from an actor, over the nine: level (0) in Zounds and
Vampires Dawn (121 times), experience (1) in Zounds, HP/SP and their
maximums (2–5) in ABL, Book of Three, Vampires Dawn and Zounds, spirit
(8) in Vampires Dawn (42); nobody asks for 6, 7, 9 or the equipment.

### What was done

* **The compiler reads every editor's `KeyInputProc`** —the `KEY_INPUT_PROC`
  arm of `compile.rs`—: the five, RM2k 1.50's ten, 2003's nine and
  fourteen, each against easyrpg's `CommandKeyInputProc`, with the
  game's `is_2003` (new in `Game`, from `System.ldb_id`) choosing the
  layout. A long form asking for the four directions alike compiles to
  the same bytes as the short one; shift, numbers and operators —keys the
  pad lacks— are noted as `key-not-on-the-pad` and never come; some
  directions and not others, and the timed form, stay `cannot()`: draft
  [`key-input-proc-forms-the-compiler-leaves-out`](key-input-proc-forms-the-compiler-leaves-out.md).
* **`ControlVars` from an actor answers all fifteen numbers**: `actor_stat`
  keeps 2–5 and sends the rest to `actor_stat_other`, new in
  `runtime/actor_stats.s`, in `FAR3`: the level (`FAR_EXP`'s byte, or the
  new `actor_level` table of `rm2k-snes-mapdata` for an actor with no
  slot), the experience (saturated at the word, noted as
  `variable-saturated` on the page, and in the book's divergence), the
  four parameters with the equipment (`level_param` plus `item_points`,
  clamped like `eq_parameter`), and the five equipped items. No new
  opcode: 0x52 and 0x53 stay reserved.
* **The test game**: cases `key-long-form` and `actor-stats`, tests
  `test_key_long_form.py` and `test_actor_stats.py`; actor 3 Bram (never
  fights, level 7) and the Sword in its database. Red before: with the
  tools from `main` the cartridge does not build (the cases do not
  compile); green after: 26 passed, 1 skipped. The actor case caught a
  `plx`-then-branch in the first version of the clamp —the trap of
  AGENTS.md—: every attack came out as 1.
* **Zounds' boot**: common events 3 and 7 compile (commons 41 → 43 of 69);
  40 stays out for its accented messages. The boot harness's
  `has_control` now also looks at `auto_n`: map 106's autostart page ends
  within its frame and restarts on the next, so `ev_active` read 0 and
  the harness stopped tapping A right where the page waits for it. With
  that, Zounds goes 106 → 107 → 1 → 4 → 5 → 6 → 7, control at tick ~4470
  and the hero walks: `FIRST_MAP` 7, out of `STUCK`.
* The book: Zounds' Known issues, two rows in `internals/events.md`, a
  bullet in the saturation divergence.
* Draft [`a-parameter-with-a-zero-curve-clamps-before-the-equipment`](a-parameter-with-a-zero-curve-clamps-before-the-equipment.md).

### What to install when merging

`just install events mapdata convert`, from `~/the-advocate`: the compiler
and its binary, the emission (`actor_level`) and the converter, which
links the compiler. The runtime —`actor_stats.s`, `level.s`, `main.s`— is
read by `rm2k-snes-cartridges` from the checkout, so it needs no reinstall.
The ports' harness change (`tests/games.py`, `has_control` with `auto_n`)
and `test_boot.py` come with the ports' branch; the book's, with the docs'.

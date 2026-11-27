---
name: "What the three gone binaries asked, only their tests ask"
description: "With rm2k-snes-battle's, wally's and rm2k-snes-events' binaries gone, the functions they were a main over —the battle's JSON questions, Wally's layers, bakeable and split, the culprits table— are reached only by their own crates' tests"
type: refactor
game: advocate
status: todo
agents: [cardon]
author: cardon
links:
  found-in: [tests-without-the-stages-subcommands]
---

Found by Cardón on 2026-11-27, doing step 7 of
[`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md)
on the-advocate's `cardon-battle` (`3f9a604d`, which removed the three
binaries).

**What is left**, by `grep` over the workspace, with no caller outside its
crate's `tests/`:

* `rm2k-snes-battle`: `stage::asked` and `model::read_request`, and the
  JSON questions they served —`model::simulate`, `lines`, `experience`,
  `field_skill`— with their `*_FILE` names. `simulate.rs` itself is not
  dead: the converter's `model` builds on its `Battle`, `Combatant` and
  `Rng`. The crate's tests ask the four (`tests/model.rs`,
  `tests/field.rs`, `tests/weapon_attributes.rs`).
* `wally`: `stage::layers_of`, `bakeable_of` and `split_of`, and the
  `stage::Command` type, asked only by `tests/layers_stage.rs` and
  `tests/whole_map.rs` (`layers_of` and `split_of` call functions the
  converter also uses, which are not dead).
* `rm2k-snes-events`: `culprits::table`, the per-kind table the binary
  printed —the converter writes `report`, `culprits.json`, and the ports'
  `culprits.py` prints its own table—, and `read_request`, which
  `Request::read` uses and only tests call.

It is the same shape as
[`the-screens-reference-drawing-has-no-caller`](the-screens-reference-drawing-has-no-caller.md):
whether to take them out with the tests that exercise them, or keep them
as the crates' way to be asked by hand, is a judgement left out of the
binaries' commit on purpose. Nothing a ROM carries depends on it.

### 2026-11-27, Hornero: promoted to `todo`

Promoted by Hornero: verified by grep, and the judgement has an answer
already —taro, the same day, on the screens' dead drawing: "if it is
plain dead code, we can delete it"—. What only the gone binaries reached
goes with the tests that exercise only it; a test that covers something
the converter still calls is retargeted. ROMs byte for byte.

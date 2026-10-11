---
name: "Rust: the converter's pilot, the battle tables"
description: "The converter's first domain in Rust: the rm2k-snes-battle crate with the experience and encounter tables (battle_tables.py), called by the Python from the PATH, with the ROMs byte for byte identical"
type: refactor
status: done
assignee: taro
---

Step 4 of the road to Rust, with what was discussed with taro on 2026-09-29:

- the converter is migrated **in stages**, with the Python orchestrating and
  calling each Rust stage from the PATH, like `rm2k-render` and
  `rm2k-snes-audio`;
- in Rust there's **one crate per domain**, because Cargo doesn't allow
  cycles between crates and that way the compiler enforces the boundary; the
  orchestrator (`rm2k-snes-convert`, later on) has no logic of any resource;
- the pilot is small on purpose to settle the shape: `battle_tables.py`
  (experience and encounters) goes to `tools/rm2k-snes/battle/`, the
  `rm2k-snes-battle` crate, which will later receive the rest of the battle.

## The shape that got settled (Surubí, 2026-09-29)

It's the template for the domains that follow. It's in the crate's README, in
English, which is where whoever builds the next one will look for it:
`tools/rm2k-snes/battle/README.md`, "One stage of a converter".

- **One crate per domain, with a library and an executable**:
  `tools/rm2k-snes/battle/`, package `rm2k-snes-battle`, binary
  `rm2k-snes-battle`, project name `battle` for `install` and
  `install-local` (it's the directory: `_install` looks for it as
  `<capa>/<nombre>`). Layer `rm2k-snes`, because it emits tables for ca65.
- **It reads the game itself, from Ditto's dump** (`--data`, the directory
  with `maps.json` and `db/`), only the fields it uses and with small types of
  its own: `src/game.rs`. A missing field is an error that names it, same as
  in `lcf.py`. **It gets replaced by Ditto as a library when that exists**;
  until then the whole model isn't copied.
- **What the dump doesn't say comes in a request** (`--request`, a JSON): what
  the cartridge decided —which actors fight, which maps it carries and their
  size, the forced steps of a test cartridge— and what the project patches on
  top of the dump —the tree nodes of the new maps, which in ABL is the debug
  room—. The request carries decisions and patches, never data the dump
  already has.
- **Another domain's logic comes in as data, not as code**: which actors can
  fight belongs to the party, and arrives as a list; which troops the
  cartridge carries belongs to the troops, and comes back as a list so the
  Python requests them with `troops.request`, in the same order as before.
- **It writes pieces of the `.inc`, one per file, and a JSON** with what the
  rest of the conversion needs (`--out`): `experience.inc`, `encounters.inc`
  and `battle.json`. The Python interleaves them where they were; it doesn't
  know where a cartridge is built.
- **Two exit codes**, like `rm2k-render`: 1 if the answer is no (it doesn't
  fit, the dump is broken), 2 if the call is wrong.
- **Its tests don't need the game**: `tests/python.rs` builds a small one and
  compares against the sha256 of what the Python gave;
  `tests/command_line.rs`, the binary seen from outside.

On the Python side, **the caller is the orchestrator**: `snes_convert.py`
builds the request and runs the stage once, where `rom_encounters` used to
run, and passes what was written to `mapdata.emit`, which interleaves it where
it was. Running a stage is `port/stage.py`, a single one for all: it looks for
the binary in the PATH, writes the request, runs it in a temporary directory
and returns `{archivo: texto}`. No wrapper module per stage remains.
`lcf.TreeMap`'s tree now says which dump it came from (`dump`) and which nodes
the project added to it (`added_nodes`), which is what the stage needs to see
the same tree.

## What it used from other modules

- From `events.py`: `ENC_DEFAULT_STEPS`, `ENC_RATE` and the rows of
  `ENC_TABLE` are **constants**, and were brought over. `enc_base`,
  `enc_step_thresholds` and `encounter_zones` **belong to this domain** —the
  encounters— even though they live in `events.py`, and were reimplemented.
  The Python ones **stay**: they're used by the tests' `Encounters` model,
  `battle_scenes.py` (`encounter_zones`) and `test_encuentros.py` /
  `test_pasos_de_encuentro.py`, which compare the ROM against them. So a
  divergence between the two copies gets caught by the suite.
- From `experience.py`: `max_level`, `exp_for`, `exp_list`, `next_exp`,
  `initial_level` and `initial_exp`, reimplemented. **Nothing is deleted from
  `experience.py`**: `menus.py` uses `initial_level`, `initial_exp` and
  `next_exp`, and the ROM tests use all the rest (`add_exp`, `troop_exp`,
  `exp_list`, `max_level`, `EXP_MAX`).
- `troops.request` (from `battle.py`, the troops) stays in Python: see above.
- `lcf.CURVES`, the order of the six curves, belongs to the format: a
  constant.

## What was found

- **`enc_base` of a map with `encounter_steps` 1 gives 65536**, which doesn't
  fit in `enc_base`'s `.word`: the Python emitted it anyway and the Rust does
  too, because the test pins what it gave. No ABL map has 1; a
  `--test-encounters 1` would break the assembly. Noted, not fixed: it's an
  output change.
- **None of this goes into the on-disk cache**: the tables are computed on
  each conversion, so the cache key has no reason to carry the binary. The
  cartridges' fingerprint does: `CONVERTER_TOOLS` in
  `tools/rm2k-snes/cartridge/src/cartridges.rs`.

## Verification

- `NO_CACHE=1 just cartuchos` before (with `battle_tables.py`) and after (with
  `rm2k-snes-battle`): the 999 files of `rom/build/` identical —the `.sfc`,
  `.msu`, `.pcm` and `.inc`— except the two `.dbg`. Those differ **only in how
  they write each source's path**, which depends on which
  `rm2k-snes-assemble` builds —the global one or the worktree's—, not on the
  converter: rebuilt with the global one, the `.dbg` is the same with the
  `.claude/worktrees/<agente>/` prefix in each `name=`, and nothing else.
- After merging `main` (the rename to Adeleine), again with `NO_CACHE=1 just
  cartuchos` on the merged tree: the `.sfc`, `.msu`, `.pcm` and `.inc`
  identical to those from before starting. The `.toml`s of
  `parches/auto/battlers/` differ, since they carry `adeleine.` in their
  comment (that's from `main`), and so does the `.dbg`, in the size of
  `far_ram.s`: the prose commit changed a comment in it.
- `just pruebas` (874) and `just -f tools/justfile test` (83) green on the
  merged tree; `cargo test -p rm2k-snes-battle -p rm2k-snes-cartridge` green.

## When merging

Install in the global `battle` —the new binary— and `cartridge`, because the
cartridges' fingerprint now includes `rm2k-snes-battle`:

    just -f tools/justfile install battle cartridge

Without `battle` installed, the converter refuses and says what to run.
There's a new `.py`, `port/stage.py`, but it isn't an executable: no
`install-scripts` needed.

## For taro

Nothing to play: the ROMs come out byte for byte identical. What needs looking
at is the shape, in the crate's README, before the next domain copies it.

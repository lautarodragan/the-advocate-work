---
name: "Rust: the event compiler"
description: "tools/port/events.py (event pages to bytecode) as its own crate in Rust, on top of Ditto's library and rm2k-rules, with the ROMs byte-for-byte identical"
type: refactor
status: done
assignee: taro
---

The converter's most expensive piece, discussed with taro on 2026-09-29: the
event compiler goes to its own crate, because the boundary is real —from
RM2k pages to bytecode, with the protocol declared in
`tools/snes/protocol/events.toml`— and because it is what gains the most from Rust.

It rests on what already exists: Ditto's library to read the dump,
`rm2k-rules` for RM2k's rules, and the shape the battle pilot set
(`tools/rm2k-snes/battle/README.md`, "One stage of a converter").
Zorzal noted what is missing on that side: the Shift-JIS guessing
of `lcf.text`, applying the forks of `rom/parches/manual/`, `REFIT_TEXTS`, and
small rules of `lcf.py`.

## Inventory: what `events.py` receives and returns today

Measured on 2026-09-29 on `64d838fa`, reading the whole module (5,600
lines; some 2,000 of code) and all its callers.

### What it receives

**From the dump**, through `lcf` —which has already applied the fork of
`rom/parches/manual/` and `REFIT_TEXTS`—:

- the pages of each map: commands, conditions, trigger, layer,
  frequency, speed, animation type, own route, the CharSet of the
  active page of each event (for `shares_graphic`);
- from the database: the common events (with `REFIT_TEXTS`) and their triggers,
  the troop pages (without `REFIT_TEXTS`: the battle's window is another one),
  the animations (their `timings` and how many frames), the terms of the
  inn and of gold, the battle's audio from `System`, which actors there are (for
  `OP_IF_ACTOR` and `ChangeEquipment`), which skills there are and what each
  actor learns per level (for `SKILL_SLOT`);
- **all the game's maps**, not just the cartridge's: the variable and
  pair (actor, skill) slots come from sweeping the whole game.

**From the converter**, which are not in the dump:

- `REFIT_TEXTS` (`port/texts.py`): the text boxes rebuilt for the
  window's width. It is a pure function of the lines of **one** box;
- `DECORATE_TRANSLUCENT` (`rm2k.decorate_translucent`): the name the
  CharSet of a translucent page carries —baked, with map and cell—. The
  compiler only cares about it for `shares_graphic` (a flash in an
  animation);
- the order of the cartridge's maps (`map_index`) and, per map, the
  `Substitutions` of `blocks.py` (which pair of ROM blocks each
  `TileSubstitution` is), which are built **after** converting the map;
- the image of the `ShowPicture` that kept the slot (`Pictures.choose`,
  which converts PNGs with `picture.py` while each map is converted);
- the associations of `ChangeSpriteAssociation` (`sprite_associations`,
  which belongs to the compiler but runs before everything) and the graphics of
  `--test-graphic` of each map;
- the test pages of the cases (`rom/pruebas/casos/`, which do not come
  from the dump) and on which map each one runs;
- the by-ear decisions of the project file: `[sound_effects]`
  `per_map`, `route_effects_left_out` and `troop_effects_in_package`;
- the troops of the random encounters, which
  `rm2k-snes-battle` answers.

### What it returns

- per map, `map_pages`: one record per page of each event with
  supported conditions —trigger, conditions, layer, frequency,
  speed, the bytecode or `None`, the own route, the graphic, what the
  tile imposes on the cell, whether it turns—;
- the bytecode of each case, compiled with its map's context;
- the registries it filled while compiling, which the rest of the converter reads:
  `Messages` (the ROM's text block, with the cases' first),
  `Songs` (themes and sound effects numbered, what each map asks for, which are
  exit ones, with which theme each `Teleport` jumps), `Graphics` per map,
  `Troops` (which troops and with which background), `TroopPages` (the code of the
  troop pages, deduplicated, with its separate message block);
- `battle_audio`, the compiled body of each party common event
  (`compile_party_common_event`), and each map's debts (which commands it
  accepts without doing them, for the warning);
- the indices: `VARIABLE_SLOT`, `SKILL_SLOT`, `PARTY_COMMON_EVENTS`,
  `ANIMATIONS`, `BATTLE_AUDIO`, `ACTOR_EQUIPMENT`, `INN_TERMS`, which
  `mapdata.py`, `animation.py` and the tests also read.

And it does not emit `.inc`: what reaches `mapdata.inc` is written by `mapdata.py` and
`map_record.py` with the above.

### Who compiles, and with what context

It is not one call but **five passes**, each with its own context, and the
output of the first ones decides what goes into the cartridge:

1. `game_scan.possible_leaders`: all the pages of all the cartridge's maps,
   each one with empty registries, to know which ones compile and
   who joins the party;
2. `sprites.movable_events`, inside `convert_map`: `map_pages` of each
   map with its own `Messages` and no themes, to know who walks and to
   which graphic a route changes —and the numbering of `Graphics` has to
   come out the same as in the real one, a `sys.exit` guards it—;
3. the real one, in `snes_convert.main`, map by map and with everything;
4. the debts, the automatic ones again, with the text block and nothing else;
5. the troop pages, **after** the battle, with the same `Songs`.

And the ROM tests compile loose pages with Python:
`arnes/datos.py`, `test_paginas.py`, `test_posada.py`,
`test_protocolo_contra_el_juego.py`, `test_musica_paquete.py`.

## The boundary

**The compiler's, and it goes to the crate**: reading the pages from the dump with Ditto;
`compile_page` and `_compile` whole —routes, branches, choices, battles,
inn, inline calls, merged cells, the tracking of the exit
theme—; the registries filled while compiling (`Messages`, `Songs`,
`Graphics`, `Troops`, `TroopPages`); `map_pages` in what belongs to the
compiler; the sweeps of variables, pairs and associations; and the five
passes, because they are the same function with different context and the context
decides the bytecode.

**Another domain's, and it goes into the request**:

- `REFIT_TEXTS`: a table of the boxes that change —the lines before and
  the boxes after—, which `texts.py` builds. It is "what the project changed
  over the dump", like the pilot's tree nodes;
- `DECORATE_TRANSLUCENT`: the name of each translucent page that
  changes it, which `rm2k.py` builds;
- the map forks: the path of each JSON of `rom/parches/manual/`, which the
  crate reads with `ditto::dump::read_map`;
- the `Substitutions`: per map, each `(layer, old, new)` with its pairs
  already resolved, or `null`. The crate returns which ones it asked for, and the Python
  asks for them again so that `known_keys` —the `SUB_MAX` cap— counts the same;
- the picture: which `ShowPicture` kept the slot (name, number and
  where), not the picture;
- `[sound_effects]` of the project file, as is;
- the cases: their commands and their map;
- the encounters' troops, from `rm2k-snes-battle`, which therefore now
  runs earlier.

**Stays in Python**: what each page draws (`grafico`, `tile_pass`,
the `@tile:` and baking belong to the port and to `rm2k-rules`), which the Python
adds to each record the crate returns; `texts.py`; `ANIMATIONS`,
which belongs to `animation.py`; and the constants that emit tables of
`mapdata.inc` (`SHAKE_SINE`, `fade_ramp`, the rain, `KEY_*`…).

## The proposal

`rm2k-snes-events`, in `tools/rm2k-snes/events/`, library and executable,
with the pilot's shape. Two subcommands:

- `scan`: passes 1 and 2 and the indices, which run before converting
  the maps. It answers the variable and pair slots, the associations,
  and per map which pages compile (for the party) and the records of
  `map_pages` without themes (for who walks) with their `Graphics`;
- `compile`: passes 3, 4 and 5. It answers each map's records, the
  cases' code, `Songs`, `Troops`, `TroopPages`, the battle's
  audio, the party common events and the debts; and writes separately, in
  binary, the two message blocks and the troops' code.

The opcode numbers come from `events.toml` with `protocol --rust`.

## What remained

### The boundary, as it ended up

The one above, with three adjustments the ROM tests asked for when they stopped
compiling with Python:

- `scan` also returns **the code** of each page compiled alone,
  not just whether it compiles: it is what a test asks about a page of the
  game (`datos.pagina_de`);
- the test page arrives **with** the `ControlSwitches` that turns it off, which
  the converter adds: it is a convention of the harness and not of the compiler; and one that
  does not compile returns `null` and the converter says which;
- the troop pages say **which page they are**, so that a test
  reads the trigger of a particular one.

And one that was not in the proposal: the page an event starts with
—to know who shares a graphic, and with it a palette— is given by
`rm2k-rules` (`starting_page`), not by a copy of its own.

### The crate

`tools/rm2k-snes/events/`, `rm2k-snes-events`, library and executable,
with the pilot's shape. It depends on `ditto`, `rm2k-rules`, `clap` and
`serde_json` (`sha2` in the tests). Sources, counted with `wc -l` after
`cargo fmt`: `compile.rs` (each command, the branches, choices, battles,
inn, inline calls, merged cells, the exit song, 2,548),
`lib.rs` (the request and the two calls, 717), `game.rs` (the dump with
Ditto, the rebuilt boxes, the names, 506), `troops.rs` (308),
`indices.rs` (the sweeps, 266), `pages.rs` (`MapEvents` and `map_pages`,
265), `codes.rs` (the codes, tied to liblcf by a test, 263),
`messages.rs` (252), `route.rs` (240), `registry.rs` (`Songs`, `Graphics`,
`Troops`, `Picture`, 233), `main.rs` (89), `fail.rs` (60) and `opcodes.rs`,
generated by `protocol --rust` from `events.toml` (122). README in English.

Tests: 13 unit tests; `tests/python.rs`, a small game in `tests/game/`
with the two requests and the sha256 of each part of what the
Python answered (`tests/python.json`); `tests/escapes.rs`, which ties the
escape tail to the Python copy with `tests/escapes.json`; and
`tests/command_line.rs`, the two exit codes. The script that built the
game and got the hashes was throwaway: it ran the old `events.py`.

### The page-by-page comparison

Throwaway, inside a real conversion: a temporary module that ran
both things with the same inputs and compared field by field.
**0 differences** in `release` (93 maps, 2,064 pages, 1,995 with
code, 236 cases, 69 troops) and in `test-special` (7 maps, 249 pages,
8 cases, 11 troops): the bytecode and the record of each page, the graphics
of each map, the debts, the requested substitutions, each case, the text
block, themes and sound effects with their packages, exits and jumps, the troops
and their backgrounds, the troop pages, the battle's audio, the party
common events, and the two `scan` passes. And in addition the `scan` over
**the 328 maps** as a single cartridge: 5,601 pages, 5,352 with code,
0 differences.

### Verification

On `b0001b6b`, with `events` and `cartridge` installed in the local
`bin/`:

- `NO_CACHE=1 just cartuchos`: of the 999 files of `rom/build/`, the
  997 that are not `.dbg` byte-for-byte identical to those of the baseline, built
  before touching anything; the two `.dbg`, identical to the baseline's after
  undoing two things that are not the compiler's: that the local
  `rm2k-snes-assemble` writes the build paths relative to the worktree and the global one
  relative to the main checkout, and the size of the ten runtime `.s`
  whose comments the last commit changed. Before that commit,
  with the global `cartridge`, the 999 came out identical at every step.
  `abl.sfc` 7a3c6483…, `abl.msu` 905decd2…, `prueba.sfc` fb6db844…;
- `just pruebas`: 872 (it was 874: two moved to the crate, the exit theme
  and the free inn);
- `just -f tools/justfile test`: 88 (84, minus two that moved to the crate and
  the eight of the boxes with a tail, which are now fourteen cases
  shared with the crate);
- `cargo test` of `rm2k-snes-events` (20), of `cartridge` (43) and of
  `rm2k-rules` (9).

### What was deleted from `events.py`, and what remained

From 5,600 lines to 2,037. The whole compiler went —`compile_page`,
`_compile`, the branches, the routes, the messages, the indices, the troop
pages, `map_pages`— and `cases.case_page`. What remained, and why:

- the constants that emit tables of `mapdata.inc` or that other
  modules and the tests read;
- `VARIABLE_SLOT`, `SKILL_SLOT` and `PARTY_COMMON_EVENTS`, which
  `compiler.apply_indices` fills with the answer and `mapdata` reads;
- `Songs`, `Troops` and `Trigger`: the shape in which the rest of the converter reads
  what the compiler filled, and on `Songs` the music numbers afterwards;
- `Pictures.choose`: which picture keeps the slot is decided by the converter,
  which converts it;
- `MapEvents`, reduced to the RM2k id against the table index, which
  `baking`, `map_convert` and the stones' harness use;
- `escape_tail`, because `texts.py` rebuilds the boxes around the tail:
  **it is at both ends**, and `tests/escapes.json` ties them with a test
  on each side;
- `database`, `index_animations` and `ANIMATIONS`, from `animation.py`;
  `named_backdrops` and `encounter_zones`, from the scenes;
- the tests' models: `Encounters` and the `enc_*`, `key_value`,
  `next_random`, `PartyState`, `walk_code`, `route_targets`;
- and the comments on what the ROM does with each opcode and command, which
  stay next to what remains of each thing.

### What is missing, or is left for later

- **The long comments of each command** —how much it unblocked, when it
  came in, what was measured— still live in `events.py`, next to the
  constants that remained, and the code they protect is in Rust with
  shorter comments. Moving them to the crate is prose work, not
  code work, and I did not do it.
- The runtime comments that already cited old Spanish names
  of `events.py` (`PASO_POR_VELOCIDAD`, `RUTA_DIAGONALES`, `ACCESO_BIT`,
  `VAR_RANURA_MAX`, `MENSAJES_PASO`…) stay that way: they came from before.
- `scan` and `compile` each read the whole dump; I did not measure how much
  it adds to the conversion, which did not visibly change.

## On merging

Reinstall in the global the Rust that changed: `just -f tools/justfile
install events cartridge` —`events` is new, and `cartridge` adds its binary
to the cartridges' fingerprint—. `protocol` did not change: it is only asked for
one more file.

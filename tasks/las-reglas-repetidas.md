---
name: "The repeated rules, in a single place"
description: "What several agents noted two or three times: the actor rules, the engine constants, equip and the escapes tail; each to a single place, with the ROMs byte for byte identical"
type: refactor
status: done
assignee: taro
---

From 2026-10-02, while taro can't review anything: a refactor that verifies
itself. Noted by:

- Cardón (`rust-el-dominio-de-la-pelea.md`): the actor's parameter at its
  level and the summed equipment are in `rm2k-snes-battle`, in
  `rm2k-snes-screens` and in `port/rules.py`; their place is `rm2k-rules`.
- Timbó (`rust-la-emision.md`): the engine constants are in
  `rm2k-snes-mapdata`'s `engine.rs` and in `events.py`, which ABL's tests
  read; likewise `SUB_MAX`, `PARALLEL_MAX`, `ROUTE_EV_MAX`, `OBJ_PRIORITY`
  and `block_tile`.
- Tataupá (`rust-el-dominio-de-las-pantallas.md`): `equip` in the stage and
  in the test harness; the escapes tail in the event compiler and in
  `rm2k-snes-text`.

It starts from `main` at `5a93a5ca`. There: `NO_CACHE=1 just cartuchos`
gives `abl.sfc` `35c765009320d436…`, 1418 files in `rom/build/`; `just
pruebas` 1001, `just -f tools/justfile test` 39.

## How each step is verified

`NO_CACHE=1 just cartuchos` with the crates being touched in the local
`bin/`, and the sha256 of all of `rom/build/` —except the cache, the `.o`s,
`sello.txt` and `conversor.log`; the `.dbg` without `mtime`— against the
baseline.

A trap that showed up halfway: **the global assembler builds with the main
checkout's runtime**, so if `main` changes `tools/runtime/` while one is
working, the `.dbg`s change even though the branch touches nothing. It
happened with Ratona's merge (`main.s`): the baseline was taken again on the
merge, with the commit in question reverted.

## 1. The actor rules → `rm2k-rules`

`157ecf82`. They stay in `tools/rm2k/rules/src/actor.rs`: `level_of`,
`curve`, `curve_at`, `points`, `with_equipment`, `PARAM_MAX`, `EQUIPPED`,
`initial_equipment`, `learned_skills`, `level_learned`. `rm2k-snes-battle`
(`rules.rs`) and `rm2k-snes-screens` (`texts.rs`) put on top only what counts
as an error for each; the battle re-exports what the emission asks of it, so
as not to add a dependency to `rm2k-snes-mapdata`.

`port/rules.py` was deleted: the converter no longer used it and ABL's tests,
the only thing that read it, ask the battle model for the maximums
(`datos.maximos()`). The 60 actors compared against the deleted Python:
identical.

## 2. The engine constants → `engine.rs`

`bb4fdeda`. **Asking the executable was the chosen option**:
`rm2k-snes-mapdata engine` answers by name all those in `engine.rs` and the
two caps of `record.rs` the converter looks at (`PARALLEL_MAX`,
`ROUTE_EV_MAX`), and `port/engine.py` asks for them once per process. Why
that one:

* it's the one `port/vram.py`, `screen_stage.layout()` and
  `modelo.disposicion()` already use: no new mechanism;
* the `.sym` only exists after building, and the converter needs them before
  —`ITEMS_N`, `MESSAGES_STEP`, `ROUTE_FREQUENCY`, the triggers—;
* generating them from a declaration, like `tools/snes/protocol/`, meant
  moving a hundred and ten constants to another format for the same thing.

`events.py` still answers them with their names through a module
`__getattr__`, so no test changed; where each assignment was there's a line
with the name, because the whys are still there and the runtime and the `.inc`
cite them as "see X in events.py". A test of `engine.rs` compares the list it
answers against its `pub const`s.

`345001f6`: **what a page draws** (`oam`) is built by the emission
(`objects::page_oam`), with which `OBJ_PRIORITY`, `OBJ_PRIORITY_ABOVE` and
`block_tile` left `sprites.py`. The converter sends the block and the palette.
Three hashes of `rm2k-snes-mapdata` changed: the made-up map carried some
bytes no block gives; it's explained in the commit and in the test.

**`SUB_MAX` stayed in two places**, on purpose: it belongs to the runtime
(`low_ram.s`), not to `engine.rs`, and the converter's copy is compared by
`test_substitutions.py`. Moving it to the engine means emitting it in the
`.inc` and removing it from `low_ram.s`: that changes the `.inc` and the
`.dbg`, and didn't fit in a refactor that has to come out identical.

`9826efd1`: when removing the Python `block_tile` it turned out the emission
had its own copy of four numbers of `rm2k-snes-map-sprites` —`block_tile`,
`OBJ_COLORS`, `SPRITE_POSES`, `POSE_BYTES`— and of the two of the timer's
glyphs. The emission now depends on that stage and names them from there.

## 3. `equip` → `rm2k-rules`, and the harness asks the stage

`e9eb697a`. `Game_Actor::ChangeEquipment` belongs to RM2k: it stays in
`rm2k-rules` (`actor::change_equipment`). The stage uses it to draw the list
and answers `rm2k-snes-screens equip`; `pantallas.equipar` asks it through
`screen_stage.equip`. It was chosen in that direction because the stage is
the one that runs the rule, in Rust, and the harness already asks it for
everything else about the screens.

## 4. The escapes tail → `rm2k-snes-text`

`e7022dfe`. The one in `refit.rs` stays, and the event compiler depends on
`rm2k-snes-text`; the other way round would bring the compiler into the battle
and the screens, which depend on `text`. `tests/escapes.json` moved with it
and `events/tests/escapes.rs`, which compared the two copies, was deleted. The
why of which escapes compile is still in the compiler's `escape_tail`, which
only translates the error.

## 5. The ones that showed up along the way

Fixed, because they were one line each:

* `8ccdbf82`: `EQUIPMENT_SLOTS` in `engine.rs`, `layout.rs` and `compile.rs`
  → `rm2k-rules`; `ENEMIES_MAX` in `engine.rs` → the battle's `db.rs` one.
* `1bca3fdc`: `RAIN_COLORS`, `rain_pixels` and `CHOICE_CURSOR` in
  `events.py`, unused copies of those of `map-sprites` and the compiler. And
  before, in `bb4fdeda`, `wait_after_step`, `wait_after_turn`, `fade_step`,
  `fade_ramp` and `SHAKE_SINE`, also unused.

Noted and untouched:

* **Two rules for the initial level in `rm2k-rules`**: `level_of`
  (`initial_level`, a 0 is 1) and `initial_level` (the same, capped against
  the final level). The parameters and the skills are read with the first, the
  experience with the second; they only differ if the initial level exceeds
  the final one. Merging them may change the ROM of such a game.
* **`port/constants.py`**: `CELL`, `COLUMNS`, `ENEMIES_MAX` and `MENU_CGRAM`
  are also in `engine.rs`; `rpgmaker/lcf.py` has `EQUIPMENT_SLOTS`;
  `picture.py` and `animation.py` have `GRID` and `OBJ_SIDE`, and
  `picture.py` its own `block_tile` for the pictures' bank. They're imported
  with `from … import` at module level: moving them to `port.engine` forces
  reading them on import, or changing each use.
* **`ITEMS_N`** is in the compiler's `compile.rs` and in `engine.rs`: the
  emission doesn't depend on the compiler.
* **`events.py` and the compiler** still share RM2k's command codes
  (`codes.rs` against `event_codes.py`, which comes from liblcf) and some
  compiler constants that ABL's tests read —`WALK_SPEED`, `ENC_RATE`,
  `ENC_TABLE`, `CELL_DEST_A/B`, `BATTLE_LOSE`, `ROUTE_HERO`, `PLACE_BACKDROP`
  (which is also in `battle_scenes.py` and in `scene.rs`)—. It's the same fix
  as `engine.rs`'s: have the compiler publish them.
* **Against the runtime**: `STEP_PER_SPEED` and `JUMP_PER_SPEED` of
  `events.py` are tables the runtime has written out (`chipset_animation.s`,
  `jump_per_speed`); `SUB_MAX`, see above.
* `rm2k.py` has `ANIMATED_*` and `WATER_*`, which are also in `engine.rs`;
  it's the Python copy of `rm2k-rules`, and `test_rm2k_rules.py` ties it.

`6501dadf` is the prose that named the copies that went away.

## The numbers at the end

On the last merge of `main` (`4248d4f4`): `NO_CACHE=1 just cartuchos`, the
1418 files of `rom/build/` identical to the baseline taken on that merge;
`just pruebas` 1005 —the four extra are Ratona's—; `just -f tools/justfile
test` 39; `cargo test` of `rm2k-rules`, `rm2k-snes-battle`,
`rm2k-snes-screens`, `rm2k-snes-events`, `rm2k-snes-text` and
`rm2k-snes-mapdata` green. Three test hashes changed, those of
`rm2k-snes-mapdata` in `345001f6`, explained there.

## When merging

* **Reinstall in the global**: `just -f tools/justfile install battle screens
  mapdata events`. `rules` and `text` are libraries: what changed in them is
  used by those four. The others that depend on `rm2k-rules` (`cartridge`,
  `wally`, `rm2k-snes-audio`, `map-background`) only gained functions they
  don't call, and `map-sprites` wasn't touched.
* **Python**: `tools/port/engine.py` was added and `tools/port/rules.py`
  deleted; they're modules and not scripts, so `install-scripts` isn't needed.
* **The order matters**: the new Python asks `rm2k-snes-mapdata engine` and
  `rm2k-snes-screens equip`, and sends `draws` instead of `oam` to the
  emission: with the old binaries in the global, the converter and the tests
  fail. Install before running anything.

---
name: "Rust: the converter's music"
description: "What the converter decides about the music and the .msu (music.py, msu_data.py) to rm2k-snes-audio, with the ROMs and the .msu byte-for-byte identical"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-09-30, in the migration of the converter to Rust. `music.py`
decides which themes each map asks for, which ones may be playing when a
package loads, the job it passes to `rm2k-snes-audio` and the startup's frame
budget; `msu_data.py` builds the `.msu` with the quality backgrounds
and the sound effects. The music itself already belongs to `rm2k-snes-audio`.

It branches from `main` at the commit that launches the task. There: `NO_CACHE=1 just
cartuchos` gives `abl.sfc` `241dc9ad2bf8b43c…`, `special` `63779e111ee18923…`,
`encounter-every-step` `200a0b7355289700…`; `just pruebas` 882,
`just -f tools/justfile test` 49.

## Inventory: what the Python does today

Read on 2026-09-30:

| where | what it does |
|---|---|
| `music.rom_songs`, `songs_of_maps` | adds to the compiler's themes that of the startup map, the title's and the Game Over's —at the end, so as not to renumber the bytecode— and each map's own, from the tree (`Game_Map::PlayBgm`) |
| `snes_convert.main`, 870-955 | the requested sound effects, and the packages: one per map —its own in front, the startup one, the exit ones and the apart ones separated—, the battle's, the Game Over's and the title's |
| `music.separate_songs` | `[music] apart_themes` |
| `music.inherited_songs` | which theme may be playing when each package loads, following the jumps without looking at conditions, minus `[music] jumps_that_never_happen` |
| `music.compile_music` | the job, to `audio-job.json`, and `rm2k-snes-audio compile` |
| `music.boot_frames` and 1010-1024 | that the startup fits in `BOOT_FRAMES`, which it reads from `far_ram.s` |
| `music.write_msu` | the `.msu`: the quality backgrounds and the quality sound effects; what the `.inc` needs to read it, at the end of `musicdata.inc`; and `efectos.json` |
| `msu_data` | the `.msu` format: `build`, the signature, and `index`/`read`, which four ABL tests use |
| `tools/tests/test_inherited_songs.py` | the inheritance test, on a hand-made game |

## The boundary

**Everything above goes to `rm2k-snes-audio`, as a new subcommand,
`cartridge`**, with the shape of "One stage of a converter". It is not a separate
crate because what it decides is exactly what `compile` receives: the
job stops travelling through Python and is built inside, and the stage calls
`compile` in the same process. `compile` stays as it is, because it is used by
the harness (`musica.py`) and the crate's tests.

**The `.msu` goes with the music.** It carries two things —the quality backgrounds and the
quality sound effects—, and of the two the only thing that has to be decided is the
order and the sound effects' tables, which already belong to the music (`msu.rs`). The
backgrounds arrive done: they are bytes the emission builds (`backdrop_bytes`, from
`battle_scenes.py`) with the pixels from `rm2k-snes-images`, and the stage only
puts them in their fixed place. The format goes to `src/msu_data.rs`, next to
`rm2k-snes-msu`, which builds the tracks of the same MSU-1.

**What the request receives** —decisions of the cartridge and what other
domains have already resolved—:

* the themes and sounds the event compiler numbered, **exactly as it
  returns them** (`compiled["songs"]`: names, sounds, what each package asks for,
  the exit ones and which theme each jump carries);
* the cartridge's maps by number, in table order, and which one it
  starts on;
* whether it carries a title, and whether it carries a Game Over: the second depends on the
  image having been found, which belongs to the images;
* the frames for decompressing the startup map (`materials`, the
  emission) and `--measure-headroom`;
* the quality backgrounds, as bytes, by number;
* the tree nodes the project added, as `rm2k-snes-battle` receives
  them.

**What it reads on its own**: from the dump (`--data`), the tree —each
map's music, with `rm2k_rules::tree::Tree::music`— and the `System` —the
title's theme, the Game Over's, and all the `*_music` to number the tracks—;
from the project, `[music] apart_themes`, `[music] jumps_that_never_happen` and
`[rom] msu_data_signature`; from the game folder, the RTP and the
SoundFont, what `compile` already read; and `BOOT_FRAMES` from `far_ram.s`, from the
suite's runtime.

**What it returns**, in `--out`: `musicdata.inc` (with the `.msu`'s
tables at the end, as today), `musica.json`, `audio.json`, `audio-job.json`,
`efectos.json` and the `.msu`; Python puts them where they go —the `.msu` in
`--msu`—. What it prints comes out with what the converter prints.

**What stays in Python**: building the request, the backgrounds' bytes, the
decompression frames and putting the files in their place. `events.Songs` and
`compiler.songs` are left unused and are deleted with the rest.

**The ABL tests that read the `.msu`** stop importing `msu_data`: the
binary adds `msu-index` —the entries of a `.msu`, or that it is not a
valid one— and `msu-sign` —the signature again, to build "the `.msu` of another
build"—, and `constants` adds those of the format. That way the format lives in a single
place; the harness calls them from `musica.py`, as it already does with `constants`.
`test_inherited_songs.py` moves to the crate's tests, so
`just -f tools/justfile test` gives three fewer, its three cases.

## Log

* **The baseline**, at `3afc8199` with `rm2k-snes-audio` and `cartridge` in the
  local `bin/`: `NO_CACHE=1 just cartuchos`, 1032 files of `rom/build/`
  (without cache, `.o`, `sello.txt` or `conversor.log`; the `.dbg` without `mtime`;
  the PNGs decoded), their sha256 and the three `conversor.log` in
  `<scratchpad>/calandria/musica/`. The ROMs give the task's sha256; the
  `.msu` of `release` gives `905decd20b48411f…`.
* **The stage, whole in one go**, and it came out identical on the first run: the
  1032 files identical, **and the three `conversor.log` too**, line by
  line. What the stage prints is what the Python printed, in the same
  order.
* **`audio-job.json` still comes out**, now from Rust, with the format of
  `json.dump(…, indent=1)`: `pyjson` learned the `repr` of a `float`
  (`decompress_frames` is one), with its tests.
* **An oddity of the log, inherited as is**: "battle audio package: N
  song(s), M sound effect(s)" counts the sound effects of the ROM's **last**
  package, which is the Game Over's when the cartridge has it, so it says
  0. It was copied as is to be able to compare the whole log, and was fixed in a
  separate commit: the count dates from when the battle was the last package
  (546fb17d), and the Game Over's came later (9b2abb3b).
* **The crate's tests against the Python**: a small hand-made game
  (`tests/cartridge.json`: six maps, one without pages, exit themes,
  apart themes, a jump that never happens, jumps that carry their theme and what
  came in; with and without title, Game Over and battle) and a `.msu` with two backgrounds and
  the sound effects of three packages. The sha256 come from
  `<scratchpad>/calandria/musica/referencia.py`, which runs `music.py`,
  `msu_data.py` and the old block of `snes_convert.py` taken out with `git show`.
  `test_inherited_songs.py` moved whole to tests in `cartridge.rs`.

## Done

**What the converter decides about the music and the `.msu` is in Rust**, in
`rm2k-snes-audio cartridge`, and the Python that did it was deleted. The three
ROMs, the three `.msu` and all of `rom/build/` come out byte-for-byte identical to those
of `3afc8199` up to the deletion; after the prose only the
`mapdata.inc` and the `.dbg` change (a comment in the `.inc`, see below).

| commit | what |
|---|---|
| `e75b3b2c` | the stage: `cartridge.rs`, `msu_data.rs`, `pyjson` with floats; the converter calls it through `stage.hand_over` |
| `5fc096d7` | ABL's tests read and sign the `.msu` through `msu-index` and `msu-sign`, from `musica.py` |
| `cab90f2b` | the deletion, only deletion: `music.py`, `msu_data.py`, `events.Songs`, `compiler.songs`, `test_inherited_songs.py` |
| `eb58cd9a` | the prose that named what was deleted, and the crate's README |
| `20eef3e1` | the battle's log counts the sound effects of its package |
| `540e8916` | merge of `main` (`d0979c06`, Yarará's troop events) |

**What changed from the planned boundary**: nothing. The files do not go back to
Python: the stage writes them directly in `--out` and the `.msu` in `--msu`,
because the rest of the conversion reads none of them and that way what it prints cites
the real paths. For that `stage.hand_over` learned to pass a
subcommand.

## How it was verified

* **The cartridges**: `NO_CACHE=1 just cartuchos` and the sha256 of the 1032
  files of `rom/build/`, identical to the baseline after the stage, the
  tests and the deletion, **and the `conversor.log` identical line by line**.
  After the prose, identical except the three `mapdata.inc` and the three
  `.dbg`: the `.inc` carried above the `.msu`'s tables "see
  `escribir_msu` in tools/port/snes_convert.py", stale since before, and now
  it says where it is. After the log fix, identical to the prose.
* **The sha256**, before the merge the same as at `3afc8199`:
  * `release/abl.sfc` `241dc9ad2bf8b43c205a6abef97fbe84ba25f3986626d5f0d058e27c742b123e`
  * `release/abl.msu` `905decd20b48411fb509d60ca7a61b3ddbfe1fd5fcf618519972ddba86b83cee`
  * `tests/special/prueba.sfc` `63779e111ee18923fc3335b725c92c55a0587f9ecd6e7a1908ae1a852e5e3710`
  * `tests/special/prueba.msu` `d9e96eab79aa9a0e30685c5f74f09c0a387ff57ab19d37635a24ba63102b1578`
  * `tests/encounter-every-step/prueba.sfc` `200a0b73552897001dcc22509e356c421cd88cf771dd894e0f13e3e19e4fb89c`
  * `tests/encounter-every-step/prueba.msu` `97ed9b74c7fb498279f562067cff9c04694edb4066fe3e12c791c38f333fd455`
* **After the merge** —with `events`, `battle` and `cartridge` also in the
  local `bin/`—: `abl.sfc` `e20182d1bd905de7…`, that of `main`; the three
  `.msu`, the same as above; `special` `6784ab8fc7161ab7…`,
  `encounter-every-step` `5dc9114cd97ff691…`.
* **The suites**: `just pruebas` 882 on each commit with code, 893 after
  the merge; `just -f tools/justfile test` 49 at the stage, 46 since the
  deletion. `cargo test -p rm2k-snes-audio` with `SOUNDFONT`, green.

## On merging

* Install in the global **`rm2k-snes-audio`**: `just -f tools/justfile
  install rm2k-snes-audio`. Without it the converter fails, because the old one does not
  have `cartridge`; and the `.msu` tests too, because it does not have
  `msu-index` or `msu-sign`. It now depends on `ditto` and `rm2k-rules`, which
  are libraries.
* `install-scripts` is not needed: `port/music.py` and
  `port/msu_data.py` were deleted, modules and not programs.
* It touches comments in four runtime files (`interpreter_music.s`,
  `audio_package.s`, `msu1.s`, `msu_effects.s`), with the same lines.
* It moves neither the ROM nor goldens.

## What is missing

* **Three citations of `inherited_songs` in `music.py`** remain in the event
  compiler (`registry.rs` twice, and `exit_songs` "in the converter's
  `Songs`" in `compile.rs`): they were not touched because that crate was Yarará's.
  They go to `cartridge.rs` of `rm2k-snes-audio`.
* **The music of the troop pages** (what Yarará left open): the
  stage builds the battle package with what the compiler notes in
  `per_package` under `battle`. If the troop pages start asking for
  themes, they arrive through there without touching the stage; what has to be decided is whether
  they go to that package —and lower the battle theme's rate— or to a separate one,
  like the Game Over, and that does belong to `cartridge::plan`.
* The dated studies in `docs/research/` cite `snes_music.py` and
  `escribir_msu`: they are snapshots of their day and were not touched.

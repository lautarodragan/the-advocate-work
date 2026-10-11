---
name: "What was left of the maps domain"
description: "The loose ends Mara left when moving the maps to Rust"
type: refactor
status: done
assignee: taro
---

From `rust-el-dominio-de-los-mapas.md` (Mara, 2026-09-30):

- that `rm2k-snes-events scan` answer each page's route targets, so that
  `movable_events` leaves Python;
- the VRAM layouts (`tools/port/vram.py`) in a single place: today the screens
  and the emission read them;
- the rule for the timer's colours is there twice: `timer_colors_of` in Python
  and `timer_colors` in `extras.rs`;
- removing `voodoo` from `cartridge`'s fingerprint: the converter no longer
  runs the binary, the maps stage uses it as a library (it comes in through the
  `rm2k-snes-maps` binary);
- deciding whether `rm2k-snes-maps layers` stays: today only its tests use it;
- the path of the dithered translucent ones (`TRANSLUCENT_MODE=dither`) is
  ported but no cartridge exercises it;
- the clippy warnings of the three crates.

Outside the request: the VRAM layouts (`vram.py`) stay as they are —they are
the emission's, and Cardón, who is moving the battle to Rust, may need them—.

## Done (Ceibo, 2026-09-30)

Base: `968af650`. Each point in its commit; the ROM and all of `rom/build/`
—1032 files, with Mara's fingerprint script— identical after each one, with
`NO_CACHE=1 just cartuchos`.

### 1. Who walks leaves Python

`rm2k-snes-events scan` —and `compile`, which builds the same records—
answers `route_targets` on each page: the events its code sends a route to,
walking the bytecode (`instructions`, next to `size_of` in `compile.rs`). The
rule for who moves —the routes, the own route, the still ones that animate
with their cap of four, the ones that spin— moved to `rm2k-snes-maps`, in
`moves.rs`: the request carries the scan's records as they came out (`pages`)
and the ones a test page sends walking (`also_walk`), and the answer brings
`movable`, `animates_still` and `turning`, which `map_convert` reads for the
NPC table. `movable_events` and `ANIMATES_STILL_MAX` from `sprites.py` and
`events.route_targets` are gone.

How it was verified: before deleting the Python, `map_convert` compared what
the stage answered against `movable_events` on each map of the three
cartridges (102 calls) with an `assert`: all identical. The `events` tests
compare against hashes of the old Python that are not regenerated, so
`route_targets` is removed before hashing and has its own test, with the values
checked against the Python rule; `moves.rs` has its own (without a game).

### 2. The timer's colours, in a single place

The mask of which entries of its palette the digits take —the one
`upload_timer_pal` uploads again without tint— is computed by the stage
(`timer_mask`, in `extras.rs` of `rm2k-snes-map-sprites`, over the palettes as
they end up) and travels in `sprite.timer_mask` of `map.json`; `snes_convert`
emits it as is. `timer_colors_of` from `obj_extras.py` and `Skin.timer()` from
`window.py`, which nobody called any more, are gone. What stays in
`obj_extras.py` are the constants of where the timer is drawn, which are the
emission's (`mapdata.py`).

The `draw: timer` request of `rm2k-render system` was left without callers on
the Python side; it was not touched, because it belongs to another crate and it
is not in the way.

How it was verified: the `timer_mask` table of the `mapdata.inc` files has
non-zero masks on 93 of the 102 maps of the three cartridges, and it came out
identical; all of `rom/build/` identical.

### 3. `voodoo` leaves the fingerprint

`cartridge`'s `CONVERTER_TOOLS` lists the binaries the converter **runs**;
nobody runs `voodoo` any more —the maps and the screens use it as a library,
and it enters the fingerprint through their binaries—. How it was verified that
no path runs it: by reading, all the `shutil.which` and `stage.run` of `tools/`
and every `process::Command` of the crates (none names `voodoo`); and by
running, `NO_CACHE=1 just cartuchos` with a fake `voodoo` first in the PATH
that logs and exits with an error: it was never called, and `rom/build/` came
out identical.

### 4. `rm2k-snes-maps layers` stays

Decided that it stays. What it costs is little: the command-line entry and
`layers::run`, four lines over the same functions `map` uses (`draw`,
`blocks`, `write`). What it gives: it is the only way to convert the layers of
**one** map without building the whole request —leaders, compiler answer,
cartridge—, to look at what Adeleine decided for that background alone; and
the crate's command-line tests exercise the layers' drawing through it
—search directories, painted cells, errors— with a three-field request.
Removing it would have forced rewriting them against `map`, which mixes in
everything else. It was stated in its README.

### 5. clippy in the three crates

`cargo clippy -p rm2k-snes-map-background -p rm2k-snes-map-sprites -p
rm2k-snes-maps --all-targets` without warnings from the three. What is left
are warnings from `ditto` and `rm2k-rules`, which are dependencies and were not
touched. Named types for the answers of three functions, the walks over
palettes and rows by reference, the `entry` of the baking's opaque cache, the
test modules at the end of the file and `is_multiple_of` in the tests. Same
behaviour: `rom/build/` identical and `cargo test -p` of the three green.

### 6. The dithered translucent ones (`TRANSLUCENT_MODE=dither`): only noted

Nothing was added. What was measured: `TRANSLUCENT_MODE=dither NO_CACHE=1 just
cartuchos` builds the three cartridges without complaining; the `release` ROM
comes out different (`271ffcede687…`) and the test ones identical, because they
carry no translucent events. That is, the path works end to end, but nobody
looked at how it looks.

What no test covers is small: the `~trama` of `Drawer::draw` in `sheets.rs`
—fifteen lines: draw the base sheet and empty the pixels `drops` says— and
`drops` with its five patterns. **A crate test is worth it**, without a game,
that draws a `~trama` over a made-up CharSet and looks at which pixels were
left; it costs little and covers everything that belongs to the path. **A
cartridge is not worth it**: the mode exists to compare the two outputs in the
same tree, `release` does not use it, and one more cartridge is time in every
`just cartuchos` for a path that is not played. I did not add it because the
request asked to note it; if taro says yes, it is a test in `rm2k-snes-maps`.

**A trap I found in passing**: neither `TRANSLUCENT_MODE` nor `DITHER_PATTERN`
enter the cartridges' fingerprint. Building with one of those and then without
it leaves the dithered ROM taken as good until something else changes: to go
back one has to delete the `sello.txt` files (or build with `NO_CACHE=1` and
the stamps deleted, which is what I did). I did not fix it: it belongs to
`cartridge` and the project, and it is better to decide first whether the mode
stays.

## How it was verified

With Mara's fingerprint scripts, copied to `<scratchpad>/ceibo/`: `NO_CACHE=1
just cartuchos` with the stamps deleted, and the sha256 of all of `rom/build/`
—1032 files, minus the cache, the `.o`, `sello.txt` and `conversor.log`; the
`.dbg` without `mtime`— against the base at `968af650`, built with this
worktree's local binaries. Identical after each of the five commits. The ROMs:

* `release/abl.sfc` `cdcc323197ee6c66d82b1304ce20c3c37f4124d13a6867e851fd13226046b7df`
* `tests/special/prueba.sfc` `15e4f331fe8ff8123803ae3819a2212a5b84d71cd0a053b7261a9188bbab84b9`
* `tests/encounter-every-step/prueba.sfc` `dc83ed698b348032514dbb76eaf5f535b6296944075fcba786087533ed5b8a4b`

After merging `main` (`be94c1d8`, Cardón's battle) the three ROMs stay
identical; only the three `.dbg` change, because of the runtime comments that
merge brought.

The suites on the merged tree: `just pruebas`, 878 pass; `just -f
tools/justfile test`, 49. `cargo test -p` of `events`, `map-background`,
`map-sprites`, `maps` and `cartridge`, green.

## When merging

* Install in the global one `events` —the scan answers `route_targets`—,
  `maps` —it reads `pages` and `also_walk`, and returns who moves and the
  timer's mask— and `cartridge` —the fingerprint without `voodoo`—: `just -f
  tools/justfile install events maps cartridge`. **They have to go together
  with the Python**: the new `map_convert` sends the stage a request the old
  one does not understand, and the old one answered it without `movable` or
  `timer_mask`. `map-background` and `map-sprites` are libraries: they come in
  with `maps`.
* It moves neither the ROM nor the goldens. The cartridges are rebuilt once,
  because the fingerprint changes.

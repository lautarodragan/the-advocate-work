---
name: "The errors that name neither the map nor the song"
description: "'the song uses N sounds…' does not say which song or which map, and 'this map can't carry a message window' does not carry the map number on its line"
type: chore
status: testing
assignee: taro
agents: [Hornero, Cardón]
---

Noted by Calandria on 2026-10-11, while sweeping the ports' exclusions: to know which map to take out they had to be taken out one at a time, or the previous header looked up in the log. Cheap, and it saves every sweep some rounds.

## What was done (Cardón, 2026-10-11)

In `the-advocate`, branch `cardon-errores-y-huella`:

* **The converter** (`rm2k-snes/convert`): `Stop::in_map`, in `fail.rs`, puts `map N: ` in front of a stop that does not name the map on its first line —and does not repeat it if it already names it—. The three per-map stages use it: `maps::prepare`, each call to Wally from `run_all` and `maps::map_info`. With that, "this map can't carry a message window" comes out `map 15: this map can't carry…`, and so do Wally's that did not say it (the panorama's `attempt`s, `drawable_npcs`…). The one from `vram_layout` in `map_info` also says it explicitly, as the panorama's already did.
* **The music** (`rm2k-snes/rm2k-snes-audio`): `in_song`, in `compile.rs`, puts on what stops a song —`build_events`, `pack`, `fold`— the song and the packages that carry it, which in a cartridge are the maps: `song "Graig", in map 10: the song uses 291 sounds and the index is one byte`. A package that is not a map's comes out by its name (`package pelea`). `check` already named the song.
* **`rm2k-snes-mapdata`**: the two from `ev_pos_bytes` ("the map has N events…", "a twin at…") did not carry the number; now they do.

The others of the same class that were looked at and already say it: the `stop!`s of the two per-map passes of `convert.rs`, `map_entry`, `pages`, those of mapdata's `record.rs` and `materials.rs`. The ones that stop on something internal —`bytecode::walk`— were not touched, nor those of the emission that compresses everything together (`compress_many` does not know which map each block belongs to; `materials.rs` stops earlier, with the number).

Verified, with the branch's tools first in the PATH, in a worktree of the ports:

* Dooms 2 without excluding 10: `rm2k-snes-audio: song "Graig", in map 10: the song uses 291 sounds and the index is one byte`.
* Vampires Dawn with its toml: `map 15: this map can't carry a message window: it spends 576 background tiles, …`.
* New tests: `a_stop_in_a_map_names_it_once` (convert) and `a_song_that_stops_says_which_maps_carry_it` (audio). They are of new functions: before they did not compile, there is no red to show.

## Result

Branch `cardon-errores-y-huella` of `the-advocate` (with the two tasks, and `tijereta-sonidos-de-una-cancion` merged); in the ports there are no commits. With the branch's tools first in the PATH (`convert`, `mapdata`, `rm2k-snes-audio`, `cartridge`), in a worktree of the ports with `main` 4072372: ABL's suite gives 1176 passed, and `abl.sfc` = `ea49ff07fd9d…`, the same as `main` with Tijereta's work. `just test` and the tests of the four crates, green.

At merge time, reinstall: `just install convert mapdata rm2k-snes-audio cartridge`.

What the suite does not cover: no error message —no ABL test stops a cartridge—; they were seen by hand in Dooms 2 and Vampires Dawn. And the fingerprint: the suite builds from a `data/` that does not change; the rebuild was measured by hand in Sunset.

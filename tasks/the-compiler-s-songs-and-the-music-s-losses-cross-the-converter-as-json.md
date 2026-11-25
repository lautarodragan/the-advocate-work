---
name: "The compiler's songs and the music's losses cross the converter as JSON"
description: "After B7 the music stage's request is typed, but its songs arrive as the event compiler's `Compiled::songs: Value` and are read into `rm2k_snes_audio::cartridge::Songs` with one `from_value`; and the losses the music decides come back in `audio.json`, which the converter reads by key with `unwrap_or` defaults"
type: refactor
game: advocate
status: testing
assignee: taro
agents: [mulita]
author: mulita
links:
  found-in: [the-stages-speak-json-nobody-types]
  part-of: [the-stages-speak-json-nobody-types]
  relates: [the-emission-s-request-still-takes-seven-pieces-through-json]
  found: [the-losses-the-stages-hand-over-are-json-the-converter-reads-by-key]
---

Seen by Mulita on 2026-11-24, doing B7 of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
(the-advocate `mulita-b7`, over `bb961337`).

**What**: two ends of the music stage still cross the converter as JSON.

* **The songs, going in**: the event compiler answers `songs` as a
  `serde_json::Value` (`rm2k-snes/events/src/answer.rs`, `Compiled::songs`,
  built by `Songs::to_json` in `registry.rs`). B7 typed the music's request,
  `rm2k_snes_audio::stage::Request`, whose `songs` is
  `cartridge::Songs`; the converter reads one into the other with
  `serde_json::from_value` (`rm2k-snes/convert/src/convert.rs`, where it
  builds the request). Both ends are typed and the middle is JSON: a key
  renamed in `to_json` compiles and fails only when a game converts. Same
  for `Compiled::battle_audio`.
* **The losses, coming out**: the music stage leaves what it lost in
  `audio.json`'s `losses`, and the converter reads them by key —
  `loss["kind"].as_str().unwrap_or("")`, `loss["map"].as_i64()`— to put
  them in `degradations.json`. The audio crate builds `audio.json` with
  `json!` in `stage::compile`.

**The shorter form**: the event compiler answers its songs as a type both
crates see —the events crate's own, read into the music's with plain Rust,
or one type in a crate both depend on, as taro chose producer-owned types
for the contracts—, so `to_json` and the `from_value` go; and the music's
`cartridge` returns its losses typed beside its files, as A7 already
returns the files themselves.

**What it risks**: low. The songs' JSON is in the event compiler's cached
answer, so changing its shape moves that cache value once; `audio.json` is
written to the build, and ABL's tests read it too
(`tests/harness/music.py`, from the test cartridges' compile), so its shape stays and
only the converter's reading of it changes. Verified as B7 was: the
nine games' builds byte for byte.

**How to reproduce**: `rg 'from_value\(compiled.songs' rm2k-snes/convert`
and `rg '"losses"' rm2k-snes/convert` in the-advocate.

## Log

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: verified in the merged code, it finishes the stages
task along the producer's-crate rule taro chose, checked byte for byte
with nothing seen or heard changing. A step of phase B, after the MapInfo
one.

### 2026-11-24, Mulita: the songs, the battle's audio and the losses typed

On the-advocate `mulita-songs`, from `3e71d3a1`, with `main` at `2695bd89`
(Calandria's seven pieces) merged in by hand; work `a7acf74`; ports
untouched (a detached worktree at `4c23c9e`, only to build and run). The
book's `internals/pipeline.md` on its `mulita-songs`.

#### What changed

* **The songs**: the event compiler answers `answer::Songs` —its
  registry's lists as they are: names, sounds, and `per_package`, `exits`
  and `jumps` keyed by `registry::Package`, which with `Wants` derives
  serde now—, built by `registry::Songs::answer`. `Songs::to_json` went,
  and the `requested` counter it wrote, which nobody read. The converter
  reads it into the music's `cartridge::Songs` with plain Rust,
  `compiler::songs` —the packages into a `HashMap<Key, _>`, the sounds'
  volume, tempo and pan from i32 to i64—, so the `from_value` went. The
  music's `Songs` keeps its serde, for the binary's `--request`.
* **The battle's audio**: `answer::BattleAudio`, every field named —the
  two songs, their two levels as `[u8; 6]`, the seven effects—, built by
  `compile::battle_audio` instead of `(name, json!)` pairs; the
  compiler's answer has `Option<BattleAudio>` and mapdata's request
  carries it as it is. The emission's per-key fallbacks went: only the
  one for no battle stays (`$FF`, `$FFFF`, the song as written). Its two
  fixtures say every field, `emit-bare.json`'s `{}` becomes `null`, with
  the values the fallbacks gave. With it the last `emit::typed` call
  went, and the function, after the merge with main.
* **The losses**: `rm2k_snes_audio::stage::cartridge` answers
  `stage::Answer { files, losses: Vec<relief::Loss> }`; the converter
  puts them in `degradations.json` from there, no longer reading
  `audio.json`'s `losses` by key. `audio.json` still lists them, its
  shape unchanged. `convert::stage::call_uncached` is generic over the
  answer for it.

Net lines: +49 against `2695bd89` (209 in, 160 out, 15 files): the two
answer types and the conversion cost more than `to_json` and the readers
did. **Install when merging**: `events`, `rm2k-snes-audio`, `mapdata`
and `convert`.

#### Verified

`NO_CACHE=1 just cartridges --force` in the nine games (ABL
`--without-tracks`) with the branch's tools first in PATH, against the
global tools' builds of `3e71d3a1`, before and after merging main: every
`.sfc` and every `build/` file byte for byte, `converter.log`,
`degradations.json` and `audio.json` included. What differs: the `.o`
(10 to 15 bytes, mtimes) and `.dbg` (the `.inc`s' mtimes), `stamp.txt`,
and the order of the lines of the cartridges' parallel log. Also a warm
double build (the first fills the moved event-compiler cache value, the
second hits it): byte for byte the same way; the cached `.o` differ in
size, as they always do, and the second's `converter.log` lacks the
event compiler's warnings, which is
[`the-event-compiler-s-left-out-warning-never-reaches-the-log`](the-event-compiler-s-left-out-warning-never-reaches-the-log.md).
`abl.sfc` `3bf35fd7665c`.

On the merged tree, with the branch's tools (plus `screens` and `images`,
which main's merge touched) first in PATH: `just lint`, `just test` (29),
`just rust-test --no-fail-fast` (fxpak's four pty tests red, the known
flaky; green alone), `just test-game` (231, 6 skipped) in the-advocate;
ports `just boot` (218) and ABL `just tests` (1694, 2 skipped). No test
reads the compiler's `songs` or `battle_audio` from the binary's answer,
and `rm2k-snes-events scan`'s answer did not change. **What no test
runs**: the binary `rm2k-snes-audio cartridge`, whose `--request` reading
did not change and which only drops the losses now (`.files`).

#### What is left read by key between stages

In `rm2k-snes/convert/src`, after this: `from_value` only on the dump
(`game.rs`, the MapInfo and ChipSet nodes) and in `trim.rs`' tests;
`emit::typed`, none. By key: the emission's answer, `mapdata.json`
(`emit.rs`, and its losses in `convert.rs`), which is
[`the-emission-s-answer-is-read-by-key`](the-emission-s-answer-is-read-by-key.md);
the screens' `boxes.json` and the menus' `debug` (`screens.rs`); the
dump in `fork.rs`; and every stage's losses, kept as `Value`s in
`degradations.rs` and filtered by key in four `forget`s of `convert.rs`:
a [draft](the-losses-the-stages-hand-over-are-json-the-converter-reads-by-key.md).

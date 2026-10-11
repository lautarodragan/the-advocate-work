---
name: "Wally with its two halves inside"
description: "map-background and map-sprites stop being crates: they become Wally modules, with a test that makes sure the background does not use the sprites nor the other way round; mapdata moves to using Wally's library"
type: refactor
status: done
assignee: taro
---

From taro, on 2026-10-02: "map-background could just become part of wally,
couldn't it?" and, for both, "go ahead". Mara split them into three crates
so that Cargo would make sure the background does not know about the
objects and vice versa (`rust-el-dominio-de-los-mapas.md`, "Un crate o
varios"); that boundary is now looked after by a test.

## How it ended up

* `tools/rm2k-snes/wally/src/background/`: what was
  `rm2k-snes-map-background` —`mod.rs` (it was `lib.rs`), `layers.rs`,
  `grid.rs`, `blocks.rs`, `fail.rs`—, and its test against the Python in
  `wally/tests/background_python.rs`, because Wally already had a
  `python.rs`.
* `tools/rm2k-snes/wally/src/sprites/`: what was `rm2k-snes-map-sprites`
  —`mod.rs`, `character.rs`, `npc.rs`, `split.rs`, `bank.rs`, `share.rs`,
  `extras.rs`, `fail.rs`—.
* Each half keeps its `Bad`: `wally::Bad` still converts the background's,
  and the sprites' one is still passed by `map.rs` by hand.
* `rm2k-snes-mapdata` depends on `wally` instead of `rm2k-snes-map-sprites`
  (`wally::sprites::character`, `wally::sprites::extras`). What Wally adds
  to mapdata —`ditto`, `rm2k-rules`, `clap`, `serde_json`— it already had or
  is the workspace's: nothing heavy. The layers do not change: both are in
  `rm2k-snes/`, and `test_layers.py` did not name them.

**The boundary** is looked after by `wally/tests/halves.rs`, reading the
source: in `src/background/` and `src/sprites/`, every `crate::` has to be
followed by that half's name, and no `super::` may leave it. It is the same
thing Cargo looked after: they do not use the rest of Wally either. It reads
the comments too. Red seen: with `use crate::sprites::npc::Npc;` in
`background/layers.rs` and `use crate::background::Converted;` in
`sprites/npc.rs` it fails naming both lines —and the crate compiles anyway,
with an unused warning, which is exactly why it is needed—; without them,
green.

## Commits

| commit | what |
|---|---|
| `94ef6b19` | the move: `git mv` and the `use`s, the manifests, and the two `justfile` lines that named the crates (the projects list and `wally-test`), which otherwise break |
| `e72bd778` | `tests/halves.rs`, and `94ef6b19` into `.git-blame-ignore-revs` |
| `6ae5111a` | the prose: Wally's README, `tools/README.md`, `AGENTS.md`, comments in mapdata, in the `justfile`, in `docs/port/vram.md` and in three runtime `.s` files |

The `justfile` lines went into the mechanical commit and not the prose one
because without them `wally-test` does `cd` into directories that do not
exist.

`blame` follows the move without options (the background's `layers.rs`:
498 of 505 lines in `7db8c984`, 2 in the move), and with `--ignore-rev`
both go back to their commit.

## Verification

In an ABL clone outside `/shared`, with `wally`, `rm2k-snes-mapdata` and
`rm2k-snes-convert` from this worktree at the front of the PATH:

* `NO_CACHE=1 just cartuchos`: the 1424 files of `build/` (without cache,
  `.o`, stamps or log; the `.dbg` without mtime) equal to those of the base,
  built beforehand with the global tools. `abl.sfc` at `35c76500`.
* `just pruebas`: 993, like the base.
* `just -f tools/justfile test`: 32, like the base.
* `cargo test -p wally -p rm2k-snes-mapdata`: 93, green, without touching a
  hash (it includes the two of `halves.rs`).

## When merging

* Install `wally`, `mapdata` and `convert` in the global one: `just -f
  tools/justfile install wally mapdata convert`. `convert` because it links
  mapdata, which now links Wally; the code is the same, but this way the
  global one comes from a tree that exists.
* There is nothing to uninstall: `map-background` and `map-sprites` were
  libraries and never left a binary in the global one.
* The three runtime `.s` files only change comments: the ROM comes out the
  same, but the `.dbg` records each source's size and that changes.

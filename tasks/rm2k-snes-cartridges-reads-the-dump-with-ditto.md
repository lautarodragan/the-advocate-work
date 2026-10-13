---
name: "rm2k-snes-cartridges reads the dump with Ditto"
description: "The third hand-written reader of the dump: cartridges.rs reads maps.json on its own for each node's type; make it use Ditto's library, and a test that prevents a fourth"
type: refactor
status: done
assignee: taro
---

Zorzal noted it on 2026-09-29 (`rust-ditto-as-a-library-and-rm2k-rules.md`):
since Ditto's library is the only place in Rust that knows how to read the
dump, there's one hand-written reader left in `tools/rm2k-snes/cartridge/src/cartridges.rs`,
which reads `maps.json` to know the type of each node of the tree. Move it to
`ditto::dump::Dump`, and a test (in `tools/tests/`, like the layers one) that
fails if a crate that isn't Ditto reads a `.json` of the dump on its own.

## What was done (Cardenal, 2026-09-29)

**`cartridges.rs`** read `data/maps.json` with `serde_json` and built a
`HashMap<id, tipo>` by hand; type 1 was "map". Now it opens the dump with
`ditto::dump::Dump`, reads the tree with `dump.tree()` and stores it as the
`Tree` of `rm2k-rules` —the same one `battle` uses—; "is a map" is
`TreeMapMapType::Map`. The `arbol` node of the new maps in
`patches/manual/new/` is still read from the patch's JSON (it's the
project's, not the dump's), but it's converted with Ditto's type, `MapInfo`,
and overrides the game's with `Tree::insert`, as before. The
`cartridge` test had to write a `ditto.json` in its toy dump.

**A fourth reader that wasn't in the task**: `rm2k-snes-events`
(`game.rs`, `Game::map`) built the dump's `maps/MapNNNN.json` path
by hand to give it to `read_map`. It didn't parse by hand, but it copied the layout;
now it's `Dump::map`. It's one line in Churrinche's crate.

**The test**: `tools/tests/test_dump_readers.py`. The criterion is at the top of
it: no `src/` of a crate that isn't Ditto names the dump's
layout —`"ditto.json"`, `"maps.json"`, `"database.json"`, `.join("db")`,
`.join("maps")`, `"Map….json"`, `.tiles"`— outside comments. The crates'
`tests/` are left out (they write toy dumps), and the
`--request` requests and the patches don't use those names. It's a grep: a
name assembled in pieces gets through.

Seen failing: with a `read_json(&p.data()?.join("maps.json"))` put in on
purpose in `cartridges.rs` it went red naming the line; removed, green.
On the starting `main` (`5dc54ff7`) it would have flagged three lines: the two
in `cartridges.rs` and the one in `events`.

**On merging, install** `cartridge` and `events`:
`just -f tools/justfile install cartridge events`.

**Verified**, with `NO_CACHE=1 just cartridges` and the sha256 of the 999
files in `rom/build/` (without cache, `.o`, `stamp.txt`, `converter.log`, and
the `.dbg` without `mtime`): with this change's binaries, with the starting
`main`'s compiled the same way (installed in the local `bin/` from `5dc54ff7`)
and on the merge with `main`, the three runs give **everything identical**. Against
the run with the global binaries only the two `.dbg` files differ, and
they differ the same way with the local binaries of `5dc54ff7`: it's global versus
local, not this change. `just tests` and `just -f tools/justfile test`
green on the merge; `cargo test -p` of `cartridge` and `events`, too.

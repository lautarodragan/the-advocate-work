---
name: "SuperFamiconv as an oracle for palette packing"
description: "A differential test for Adeleine: hand the same tiles to SuperFamiconv without quantizing and flag every picture it packs in fewer palettes than try_pack, or fits where try_pack says no"
type: test
status: todo
---

# What

A test in `snes/adeleine/` that converts a set of pictures with both
Adeleine's `try_pack` and SuperFamiconv
(<https://github.com/Optiroc/SuperFamiconv>, MIT, Rust since v0.12), and
**fails when SuperFamiconv needs fewer palettes than `try_pack`**, or fits
a picture `try_pack` answers `None` for. Not a dependency of the toolchain:
an external referee, the way bsnes is for snes9x in `test_cores.py`.

# Why

Packing is the one place where SuperFamiconv and Adeleine answer the same
question with no taste involved: with quantization off (no `-Q`), both only
choose how to group colours that all survive, and the one with fewer
palettes is simply better. Today nothing would tell us if `try_pack` got
worse, or how far it is from another good packer: the goldens see pixels,
and a packing that needs one palette more than it should only shows up as a
merge somewhere else.

It also measures [`overload-and-remove-for-try-pack`](overload-and-remove-for-try-pack.md)
from outside, and keeps measuring it after it lands.

# How

* **Lossless only**: `superfamiconv palette -M snes` with no `-Q`, so
  neither side invents or merges a colour; with `-N` and `-C 16` set to what
  the call gives `try_pack`. Comparing `reduce_colors` against `-Q` is not
  this task: SuperFamiconv's quantizer averages colours and dithers, which
  Adeleine never does, so there is no fair winner.
* **Colour zero has to agree.** SuperFamiconv picks it by the longest run
  of pixels unless `--color-zero` says otherwise; the test passes the one
  the caller reserves, or the counts differ for a reason that is not
  packing.
* **The pictures are built inside the test**, like Adeleine's other tests
  —random tiles with shared colours, at sizes where packing gets tight—, so
  it needs no game and names none. A run over a port's real layers is a
  measurement for the other task, not part of this test.
* **Without `superfamiconv` on the PATH it is skipped with a message**, as
  Goombario's tests are without `ca65`. Installing it is `cargo install`
  from a pinned commit; who compiles what in the container is in
  "Where this runs" in `AGENTS.md`.
* A case where SuperFamiconv wins is a bug in Adeleine or a known limit:
  the second kind goes in the test with its reason, like Goombario's
  `pull-branch` exceptions, so the list stays honest.

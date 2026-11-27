---
name: "rm2k-sketch becomes a library"
description: "rm2k-sketch's binary goes and its format stays: the test game's maps keep being sketched as a grid of characters and a legend, and whatever packs the test game's text into RM2k's files reads each MapNNNN.toml itself, instead of the recipe calling rm2k-sketch per map"
type: refactor
game: advocate
status: todo
author: taro
links:
  relates: [ditto-becomes-advocate-import]
---

**Why**: the format earns its place, the binary does not. A map sketched
as a grid —the meadow, 20x15, about 150 tokens and a diff that shows
what moved— against its two layers as 600 tile numbers, some 2,000–2,500
tokens and a diff nobody reads; and an RPG Maker project as the source
of truth would be binary files that git cannot diff and an AI cannot
edit without tools, while the events have to be written as text anyway.
The binary is only the test game's recipe calling it once per map
before `ditto pack`.

> Regarding rm2k-sketch: I have mixed feelings. When I mentioned making
> our own test game, I did not specify _how_. I think rm2k-sketch comes
> from there. What I had in mind is that you directly create a project in
> RPG Maker 2000 format, we keep it as the source of truth, and use ditto
> to derive it. I now think that did not make much sense. I think sketch
> helps for generating maps with AI, right? It is much simpler and less
> token-hungry to build it that way than in another format? I feel maybe
> we could remove it and save ourselves another binary.

> Two separate tasks for tracking, but they can be implemented together.

(taro, 2026-11-27, the second on this task and
[`ditto-becomes-advocate-import`](ditto-becomes-advocate-import.md))

**What is asked**:

* `rm2k/sketch/` stays as a library; its `main.rs` goes, and `cargo
  uninstall rm2k-sketch` where it was installed.
* The step that packs the test game's text —`ditto pack` today, whatever
  `ditto-becomes-advocate-import` decides tomorrow— reads a map's
  `MapNNNN.toml` sketch in place of its `.tiles`, so `test-game/justfile`
  stops calling a binary per map.
* The test game's `.lmu` files, its dump and its ROMs byte for byte the
  same; the README of the test game and of the crate, and the book's
  "The tools", follow.

Implemented together with
[`ditto-becomes-advocate-import`](ditto-becomes-advocate-import.md),
which has to decide where the packing lives; kept apart only to track
it.

## Log

### 2026-11-27, Hornero: written

Nothing done yet.

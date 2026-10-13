---
name: "The window's colors, in Wally's request"
description: "WINDOW_COLORS is a wally constant (13 since the arrow and the bar) and it broke the test that compares the layers against the Python; have it come in the request, from the game's System"
type: refactor
status: done
agents: [Hornero, Tijereta]
assignee: taro
---

`wally::the_layers_are_the_ones_the_python_made` is red on `main`
since the merge of the arrow and the bar (`60b61b9c`, Tijereta): green on its
first parent, red on it. The cause is `WINDOW_COLORS` in
`wally/src/background/layers.rs`, which went from 8 to 13 —the window reserves
those colors of palette 0 in every map—. Checked on 2026-10-04: with the
constant at 8, the test gives exactly the Python's hashes again.

The underlying issue: how many colors the window takes depends on the game's System,
not on the engine. Have it arrive in `wally`'s request (and `mapdata`'s, which
has its own `WINDOW_COLORS`), computed from a single source; the test asks it
for 8 and stays against the Python, and a new test pins ABL's 13.

## Done (Tijereta)

Tools worktree from `c8d5064f`; ABL in the clone
`/extras/scratch/tijereta/abl` from `c76157d`, branch
`colores-de-la-ventana`.

### Where the number comes from

`rm2k-snes-screens window` counts it from the System: the colors of the empty
window, the arrow, the cursor, the text and the shadow —`message_window::colors`,
the same thing `convert` already gathered to build the palette, split into a
`draw` that both use—. It answers `{"colors": n}`. With ABL it gives 13.

The converter asks for it **once**, before the maps
(`screens::window_colors`), and hands it out:

* to each `wally` map, as `window_colors` in the request (`MapRequest`
  and `LayersRequest`); `wally` no longer has `WINDOW_COLORS` or
  `CGRAM_RESERVED`, but `cgram_reserved(window_colors)`;
* to the screens, as `cgram_reserved` = 1 + n, as before;
* to the emission, as `window_colors` in the `emit` request;
  `rm2k-snes-mapdata` does not have the constant either: `cgram_reserved(n)` in
  `cgram.rs`. `rm2k-snes-mapdata vram` stopped publishing `cgram_reserved`
  —nobody read it: ABL's harness only reads `slots`—.

`wally`'s questions (`bakeable`, `split`) do not convert the layers, so
the partial request sets `window_colors: 0` and ABL's harness does not change.

### The tests

* `wally::the_layers_are_the_ones_the_python_made` asks for 8
  (`PYTHON_WINDOW_COLORS`) and goes back to green **without touching its hashes**; the
  block and drawing ones in the same file, also with 8.
* The other `wally` ones and the two `emit` ones in `mapdata` carry 13 in the
  request: their hashes were already with 13 and did not move.
* The new one, in ABL: `tests/tooling/test_window_colors.py`
  pins the 13 of ABL's System. Red with the global tools (`window` did not
  exist), green with the local ones.
* The whole `cargo test --workspace` green: it was red only because of the Python one.

### Verified

* `cargo test --workspace`, whole: green.
* ABL's suite with this branch's tools: 1095, the 1094 and the
  new one. `abl.sfc` byte for byte the same, `924c33ea3b51c958…`, built
  again with these tools (`release: built` in the log).

There is nothing to play: the ROM is the same.

### When merging

Reinstall in the global `screens`, `mapdata`, `wally` and `convert`, the
four together: the converter asks the screens for `window` and passes
`window_colors` to `wally` and to the emission, and a new one with an old one
refuses because of a missing field. And bring in the `colores-de-la-ventana` branch from
`/extras/scratch/tijereta/abl`, with the new test.

---
name: "The test game is red on main: the text layer's widths and the renamed menu"
description: "the-advocate 7951af2a's test game fails four tests: Goombario finds tl_glyph_hi run with a 16-bit A where the source says 8, and the renamed menu and slot goldens differ"
type: bug
status: done
assignee: taro
author: cardon
agents: [Cardón, Calandria]
links:
  relates: [desert-nightmare-the-map-draws-over-the-hero-and-white-boxes]
---

Seen by Cardón on 2026-11-20, doing
[`desert-nightmare-the-map-draws-over-the-hero-and-white-boxes`](desert-nightmare-the-map-draws-over-the-hero-and-white-boxes.md):
`just test-game` in the-advocate at `7951af2a`, with the tools installed
from that same commit, gives 4 failed, 74 passed, 1 skipped. The same four
fail with that branch's tools, which do not touch the text.

- `test_linter.py::test_the_runtime_falls_in_no_trap`: Goombario, `width`
  on `runtime/text_layer.s` 3882 to 3889, in `tl_glyph_hi`: "`lda TL_X` is
  under a 8-bit A in the source, and on the path from `tl_glyph_hi` it is
  16 bits wide", and the same for the `asl`, `lda`, `adc` and `sta` after
  it; and an immediate at 3883 whose size the widths do not explain.
- `test_leader_name.py::test_the_leader_and_a_renamed_actor` (snes9x and
  bsnes): `renamed-menu` differs from its golden in 172 pixels.
- `test_leader_name.py::test_a_rename_travels_in_the_save[snes9x]`:
  `rename-slot` differs in 42.

Not bisected. The last change to `text_layer.s` on main is `6daa9ee4`, "The
font goes once, colour-free, and each writer puts its colours in"
(Calandria, 2026-11-20 05:55).

## What it was (2026-11-20, Calandria)

Neither red comes from `6daa9ee4`: its own message already says the same
four failed at `16081af9`, and both were drafts:
[`goombario-reads-widths-from-an-untaken-if-branch`](goombario-reads-widths-from-an-untaken-if-branch.md)
(Chajá, 2026-11-17) and
[`the-test-games-leader-name-goldens-are-red-on-main`](the-test-games-leader-name-goldens-are-red-on-main.md)
(Aguará, 2026-11-16). This task closes both.

**Goombario on `tl_glyph_hi`**: the ROM is right. The `.if ::DEBUG_SCREEN`
that `24d84b33` (2026-11-16) put in `tl_glyph_hi` ends its branch in
`.a8`; the test game has no debug screen, so ca65 skips that branch and
assembles the `.else` under the `.a16` before it —the `and #$0007` is three
bytes—. Goombario read the source's widths in text order, both branches
one after the other, as its own header admitted. By AGENTS.md's rule the
tool is improved, not the runtime: each branch now starts from the widths
before the `.if`, and after `.endif` they are those of the branch the debug
file shows code assembled from (the last branch's, as before, when that
cannot be told). A toy test, red before.

**`renamed-menu` and `rename-slot`**: only the System cursor's green edge,
(74,121,90) in the goldens against (65,113,74). The System draws that edge
in two shades; the cursors share the actor choice's sixteen BG1 colours,
and `42dff8fe` (2026-11-01) had blessed the two merged into one by
Adeleine. Bisected with each commit's tools: green at `3defe2ed^`, red at
`3defe2ed` (the actor choice's new layout, 2026-11-02), which moved the
counts so both shades fit. The captures are the more faithful ones; the
golden had pinned a loss, so the golden moves, in its own commit. Side by
side in `/shared/captures/2026-11-20-test-game-leader-name/`.

**`just lint`**: `cargo fmt` over the five files, alone in its commit; and
clippy's two —a `vec!` that is an array in `layer_text.rs`, the precedence
of `*` against `|` in `message_window.rs`'s `planes`— in another, with the
screens' and mapdata's crate tests green.

## Verified (2026-11-20, Calandria)

On the-advocate `calandria-test-game-red`, from main `82ce793c`:
`just test-game` (FluidR3_GM, the branch's Goombario, the rest the global
tools of main) 78 passed, 1 skipped; `just lint` green; `just test` 29
passed; Goombario's crate tests, the new toy one included. ABL's
`tests/tooling/test_linter.py` with this Goombario: 11 passed, so following
the `.if`s raised nothing new on ABL's cartridges.

**Merging**: reinstall `goombario` (`just install goombario`); `screens`
and `mapdata` changed only by clippy and rustfmt, with no change to what
they compute.

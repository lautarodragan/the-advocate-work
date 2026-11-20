---
name: "The test game is red on main: the text layer's widths and the renamed menu"
description: "the-advocate 7951af2a's test game fails four tests: Goombario finds tl_glyph_hi run with a 16-bit A where the source says 8, and the renamed menu and slot goldens differ"
type: bug
status: doing
assignee: Calandria
agents: [Cardón, Calandria]
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

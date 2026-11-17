---
name: "routes_moved is written and never read"
description: "A byte of bank 0's BSS whose comment promises a skipped sort that no code does"
type: bug
status: done
assignee: taro
agents: [Hurón, Tijereta, Carpintero]
---

Seen by Hurón on 2026-10-18, reading the runtime for
[`the-runtime-optimizations-the-book-does-not-tell`](the-runtime-optimizations-the-book-does-not-tell.md),
at the-advocate `df9a0f9c`.

`routes_moved` (`runtime/low_ram.s`) says "Whether any move route slot did
something this frame. It is what decides whether the NPC table has to be
sorted again, which otherwise costs every frame." `move_events`
(`runtime/event_routes.s`) clears it and sets it, and nothing in
`runtime/` reads it: `grep -n routes_moved runtime/*.s` gives those three
lines. It was born that way, as `rutas_movieron`, in `e1b4430b`
(2026-09-04), and the history has no reader for it under either name
(`git log -S`).

The sort it speaks of is done today one row at a time, by `fit_far` in
`runtime/far_npcs.s`, for the row that moved, so the skip may have stopped
being needed; what is left is one byte of a BSS that is full and a comment
that describes something the code does not do. The book's Optimizations
section does not tell it, on purpose.

## Defined (2026-10-20, Tijereta)

Checked against the-advocate `8f290c39`: still so —`routes_moved` is a
`.res 1` in `runtime/low_ram.s` and its only uses are the `stz` and the
`sta` in `move_events` (`runtime/event_routes.s`)—. The sort it speaks of
is `fit_far`'s, per row. **Done**: the byte, its two writes and its
comment gone, in a commit of their own; ABL's suite and the test game's
green, and their goldens unchanged —nothing reads it, so nothing seen can
move—. **First step**: `grep -rn routes_moved` over `runtime/` and the
Rust, to be sure nothing outside the runtime (the harness's symbols,
Goombario) names it.

## Done (2026-11-17, Carpintero)

From the-advocate `ea529d5a` and the ports `69a722b`. The first step
first: `grep -rn routes_moved` over all of the-advocate —runtime, Rust,
test game— and the ports gave only the three lines, nothing in the
harness's symbols or Goombario.

Commit `f727838e` on `carpintero-routes-moved` in the-advocate: the `.res
1` and its comment out of `runtime/low_ram.s`, and the `stz` and the `lda
#1` / `sta` out of `move_events` in `runtime/event_routes.s`. The `lda #1`
only computed the value stored; right after it comes `next:`, whose `rep`
and `txa` overwrite A and the flags, so nothing downstream read them.
Also gone: the line above it, "What `refresh_npc` copies from the slot
before using X for something else", born in the same `e1b4430b` with no
variable under it —it was already orphaned, and without `routes_moved` it
would have sat over `cmp_a`—.

`just space` in ABL before and after, with the branch's tools: **8 B of
bank 0 and 1 B of BSS on every one of the eleven cartridges** (the
tightest in bank 0, `test-change-system`, goes from 18 to 26 B).

Then merged main (the-advocate `272a0b66`, the ports `ea5a1e7`): merge
`06c7c437`. Measured again on it, main against the merge, with the same
local tools —`project cartridge`, plus `events convert` because the
global converter was older than Aguará's event-compiler change—: the
same **8 B of bank 0 and 1 B of BSS on every cartridge**;
`test-change-system` goes from 8 to 16 B.

What was run, all with the branch's tools:

* ABL's `just tests`, on the branch before the merge: 1670 passed, all
  green. On the merge: 1673 passed and the 2 known reds of `test_msu.py`
  (`test_with_msu_a_save_pauses_seeks_and_plays_again`,
  `test_with_msu_and_no_track_a_save_seeks_alone`, red until the audit
  core is rebuilt with `just audit-core`). No golden moved.
* `just test-game` (SOUNDFONT FluidR3_GM), on the merge: 66 passed, and
  the known reds: 3 in `test_leader_name.py` and Goombario's in
  `test_linter.py` (`tl_glyph_hi` in `runtime/text_layer.s`, not this).
* `just boot` at the ports root, on the branch before the merge: 155
  passed. Not repeated on the merge.

What no test sees: nothing read the byte, so the only thing a test could
catch is a broken `move_events`, and the walkthrough's moving NPCs cover
it.

**To install when merging**: nothing. No Rust changed, and the global
tools assemble the runtime from `~/the-advocate`, so merging is enough.

## Closed (2026-11-17)

> I just tested Zounds, from the start of the ship until entering the desert of death.

By taro, with the builds of the ports `428e7c3` and the-advocate `fe5529a3`.

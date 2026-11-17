---
name: "routes_moved is written and never read"
description: "A byte of bank 0's BSS whose comment promises a skipped sort that no code does"
type: bug
status: doing
assignee: Carpintero
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

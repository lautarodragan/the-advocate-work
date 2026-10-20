---
name: "routes_moved is written and never read"
description: "A byte of bank 0's BSS whose comment promises a skipped sort that no code does"
type: bug
status: todo
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

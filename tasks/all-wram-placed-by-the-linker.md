---
name: "All WRAM placed by the linker"
description: "Move what is still at hand-written addresses in WRAM to segments the linker places, subsystem by subsystem, each move byte for byte the same ROM; what has a real reason to be fixed —the grid's halves, overlays, alignment— becomes a declared memory area, not a number"
type: refactor
status: todo
---

taro, on 2026-11-16, after reading the book's
[RAM is placed by the linker](https://lautarodragan.github.io/the-advocate-docs/decisions/ram-is-placed-by-the-linker.html),
the WRAM research snapshot and "The grid lives in WRAM":

> Wouldn't the ideal be that all the WRAM is placed by the linker, and
> nothing by hand? I suspect what is currently placed by hand is legacy,
> to avoid introducing a big refactor.

It is: the decision of 2026-10-11 left what was already declared where it
was. What has a reason to be fixed: the grid's two halves at `$7E8000` and
`$7F8000` (its readers step between them by address arithmetic), the
overlays the battle shares with the map (and, since 2026-11-16, what lives
behind the grid: see `internals/wram.md` in the book, from
[`event-page-records-compressed-behind-the-grid`](event-page-records-compressed-behind-the-grid.md)),
and buffers that need alignment. `ld65` can say all three: memory areas,
segments sharing one, `align`.

Done means: no hand-written WRAM address left in `runtime/` but the
declared areas; each subsystem's move in its own commit with the ROM byte
for byte the same where it can be (or the reason it isn't); the book's
`internals/wram.md` and the decision updated.

## Log

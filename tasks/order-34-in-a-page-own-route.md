---
name: "Order 34 in a page's own route"
description: "change_graphic inside a page's own route, which route::own rejects —the page is left out whole—: 11 pages in Sunset over Imdahl, 1 in Vampires Dawn. Own routes carry operands since the switches (2026-10-20); the graphic's would go the same way, with the row's bank of poses given by Wally"
type: feature
status: todo
---

# What

**`change_graphic` —order 34— in a page's own route.** The event compiler
rejects it (`route::own`): an own route is a list of codes with no room for
the operand. None of ABL's own routes use it.

Until 2026-10-05 this was "an event that walks and changes graphic with the
page", and walking won: the row kept the graphic of its first page. That is
done now —each page gives the row its bank of poses and its palette, see
`walker_graphic` in `runtime/event_pages.s`—, and this is what remains,
which is what it was dragging along.

# Status

Noted, not started.

# Why

Order 34 inside a *forced* route is done —on events and on the hero—: see
the book's `internals/events.md` and `decisions/move-route-command-34-on-the-hero.md`.

## Log

### 2026-10-15, Hornero: still open

**Still open on 2026-10-15** (Hornero, when taro asked): `own` in
`rm2k-snes/events/src/route.rs` still returns `None` on a 34, so the page
is left out whole. It is no longer only ABL's question: counted over the
ports' data, own routes with a 34 are **11 pages in Sunset Over Imdahl and
1 in Vampires Dawn**; none in ABL, The Book of Three or the other four.
So it moves from the wishlist to `todo`.

### 2026-10-19, Calandria: not taken with the forced routes' fix

**Not taken with the forced routes' fix** (Calandria, 2026-10-19): the
fix of
[`characters-a-route-gives-a-graphic-are-not-drawn`](characters-a-route-gives-a-graphic-are-not-drawn.md)
gives a row to an event a *forced* route dresses, and reads which graphic
from the compiled `OP_ROUTE`s. An own route still has nowhere to carry the
graphic's operand —`route::own` returns `None` on a 34, and the page record
holds bare codes—, so it does not fall out of that change: it needs the
own route's format to carry the operand and the runtime's own-route walker
to skip it, which that task did not touch.

### 2026-11-17, Hornero: reviewed

Still rejected: `rm2k-snes/events/src/route.rs`, `own()` returns `None`
on `ROUTE_CHANGE_GRAPHIC` (its comment about "the game's 3509 own routes"
is stale). Same count: 11 pages in Sunset, 1 in Vampires Dawn. The
blocker moved: since 9329f602 (2026-10-20) own routes carry the switch
commands' operands (`Page::route_switches`), the precedent for a 34's.
The forced routes' `route_graphics` does not help: it reads only forced
`OP_ROUTE`s.

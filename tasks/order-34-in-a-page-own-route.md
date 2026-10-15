---
name: "Order 34 in a page's own route"
description: "change_graphic inside a page's own route, which the compiler rejects today"
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

**Still open on 2026-10-15** (Hornero, when taro asked): `own` in
`rm2k-snes/events/src/route.rs` still returns `None` on a 34, so the page
is left out whole. It is no longer only ABL's question: counted over the
ports' data, own routes with a 34 are **11 pages in Sunset Over Imdahl and
1 in Vampires Dawn**; none in ABL, The Book of Three or the other four.
So it moves from the wishlist to `todo`.

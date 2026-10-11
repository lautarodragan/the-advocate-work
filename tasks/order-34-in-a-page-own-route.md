---
name: "Order 34 in a page's own route"
description: "change_graphic inside a page's own route, which the compiler rejects today"
type: feature
status: wishlist
---

# What

**`change_graphic` —order 34— in a page's own route.** The event compiler
rejects it (`route::own`): an own route is a list of codes with no room for
the operand. None of ABL's own routes use it.

Until 2026-10-05 this was "an event that walks and changes graphic with the
page", and walking won: the row kept the graphic of its first page. That is
done now —each page gives the row its bank of poses and its palette, see
`walker_graphic` in `tools/runtime/event_pages.s`—, and this is what remains,
which is what it was dragging along.

# Status

Noted, not started.

# Why

Order 34 inside a *forced* route is done —on events and on the hero—: see
"Cambiar el gráfico a mitad de una ruta (la orden 34)" in
`docs/port/events.md` and `decisiones/la-orden-34-sobre-el-heroe.md`.

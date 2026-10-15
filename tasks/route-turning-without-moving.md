---
name: "Route: turning without moving"
description: "The route commands that turn without walking"
type: feature
status: done
agents: [Hornero]
---

# What

Turning without moving in a forced route: `turn_90_degree_right` and its siblings.

# Status

Noted, not started.

# Why

**It isn't left out because of cost but because of where the turn starts.** RM2k turns from the
direction the character already had, and for an event that hasn't turned yet that's
the one its page brings, which the route doesn't read. That is, doing it isn't adding a
command: it's giving the route the event's starting direction.

The four absolute turns —`face_up` and company— are there, and **facing the
hero** too: see "La frecuencia de la ruta, y encarar al héroe" in
`docs/port/events.md`.

**Done on 2026-10-14**, in the-advocate `8ee7fb5f` ("Routes: the hero walks
diagonally, and everyone turns in place and forward"): the relative turns
16 to 20 are `turn_relative` in `runtime/cells.s`, from the facing —an
event's from its page's pose until a route turns it, `facing_now`—, which
was the reason this waited. Forced and own routes, events and the hero.
Closed by Hornero on 2026-10-15, when taro asked whether it was still open.

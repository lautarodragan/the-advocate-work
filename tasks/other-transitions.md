---
name: "The other transitions"
description: "Blocks, blinds and the other transitions that are not the fade"
type: feature
status: wishlist
---

# What

RM2k's transitions that are not the fade: the block, blind and
wipe ones that an event can ask for with `EraseScreen` and `ShowScreen`.

# Status

Noted, not started.

# Why

The fade is there, and it is **the one this game uses** for teleports:
`transition_out` and `transition_in` are 0 in its database. Battle asks for two
others —the zoom, 16, and the mosaic, 17—: the mosaic is the PPU's, and the zoom goes
as a fade, because zooming in on the map is mode 7. See `rom/src/fundido_de_pelea.s`.
Since 2026-09-27 `ChangeScreenTransitions` too: the teleport does
the mosaic, and the zoom and the others the console does not do go as a fade —see
`divergencias/las-transiciones-del-teletransporte.md`—. But `Transition::Type`
has **38**, and an event can ask for any of them.

What makes them expensive is not the number: the block, blind and wipe ones
**are not a master brightness**, they ask to cover the screen by regions, which on the
console is another machine.

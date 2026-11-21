---
name: "A transparent message's layer baked only on the maps that can show one"
description: "A game with any transparent MessageOptions arranges the layer above's palettes on every map (layer_text); narrow it, by a static analysis of the events, to the maps where one can be shown, so the others keep their palettes and their free BG palettes"
type: feature
status: wishlist
author: taro
---

Split from
[`a-transparent-message-keeps-the-layer-above`](a-transparent-message-keeps-the-layer-above.md)
by taro on 2026-10-19: that one bakes every map of a game that can show a
transparent message, and this one narrows it —a nice-to-have, and a
different challenge: an analysis of the events, not of the pixels—. What
it saves is the palette entries the text takes from the maps that never
show one; taro thinks many of ABL's maps never do.

## The rule (taro, 2026-10-19)

At build time, permanent on the map —taro had proposed doing it when the
text opens, and chose this instead—, and **only on the maps where a
transparent message can be shown**, found statically. Conditional cases
are not followed: **if any page of any event of the map —or a common
event it can run— sets the message style transparent, the map is
positive** and is baked, whatever the conditions around it.

What the analysis has to know (Hornero, read in EasyRPG,
`game_interpreter.cpp` and `game_system.h`, and liblcf's save format):
**RM2k does not reset the style when a page ends nor when leaving a map.**
The transparency is a field of the system state
(`SaveSystem::message_transparent`), it goes into the saved game, and
only `ChangeMessageStyle` and the end of a battle (which sets it opaque)
touch it. So a map can show a transparent message without setting it: a
map that sets it and teleports —or ends its page— without setting it
back passes it on. What keeps that cheap: reading each command list in
order, a list that sets it transparent and sets it opaque again before
ending or teleporting does not leak; one that leaks makes the maps it
can lead to positive too —or, simplest, the whole game—. How common each
pattern is in the ports is the first thing to count.

## Log

### 2026-11-17, Hornero: reviewed

Since 2026-11-14 the runtime carries the layer above under a transparent
window (`runtime/message_layer.s`; the book's "The layer above, carried"):
it is not baked any more. What the build still does game-wide is arrange
the layer's palettes on every map (`mapdata/src/layer_text.rs`,
`scan::transparent_messages` is one flag per game). What narrowing would
save is smaller than first thought: in ABL's log, 4 maps lose shades
map-wide ("merges 5 colours": 3, 6, 10, 309 —6 does show one—), 22 only
inside cells with letters, 34 keep the old look; copies also take free BG
palettes.

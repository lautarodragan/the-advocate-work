---
name: "Desert Nightmare: a message's text is cut by the map"
description: "Over some maps parts of BG1 and of the characters draw over a message's text, even with the System's frame; and while a message fades in, its frame shows as lines across the screen"
type: bug
status: doing
assignee: Calandria
game: desert-nightmare
agents: [Calandria]
---

taro, on 2026-11-20, playing the build of the-advocate `7951af2a` and the
ports `42f70e8` in Mesen2, translated (captures in
`/shared/bug-reports-etc/dn/text-below-walls-*.png` and
`show-message-fadein-broken-*.png`):

> About the text showing up under parts of the walls: I was playing with
> showing/hiding layers in Mesen, and in some cases I can see that if I
> hide every layer except 2, the text is perfect. When I show layer 1,
> parts of that layer show up over the text. Sprite/object layer 1 also
> shows up, partly, over the text.

> Careful: not the whole layer shows up over the text. Parts of the same
> layer show up over it or under it.

That parts of one layer go over and parts under points at the tiles'
priority bit: the upper layer's cells drawn above the hero, and the
characters with high priority.

The second one, the same day: while a message fades in, the frame of its
window shows as lines across the whole screen (`show-message-fadein-
broken-1` to `-8`, over map 18's office).

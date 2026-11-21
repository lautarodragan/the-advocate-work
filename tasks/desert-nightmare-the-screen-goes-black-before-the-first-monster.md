---
name: "Desert Nightmare: the screen goes black before the first monster"
description: "In the first dungeon, when the first monster shows up, the screen stays black for about 363 frames and comes back in pieces over four frames; RM2k does not go black there"
type: bug
status: todo
author: taro
game: desert-nightmare
---

taro, on 2026-11-21, translated (captures one a frame, repeated ones
removed, the two ends of each run kept, in
`/shared/bug-reports-etc/dn-black-screen/`):

> In the first "dungeon", when the first monster shows up, frame by
> frame.
>
> * at 63333 the screen goes black until 63696, about 363 frames.
> * at 63698, 63699, 63700 and 63701 four different things show, as if
>   different parts of the screen were loading.
> * the next frames look OK [...]. At 63970 the text box "Sandra:
>   (What... what..." shows up.

The last frame before it, and the first black one:

![Frame 63332: before](images/desert-nightmare-the-screen-goes-black-before-the-first-monster/frame-63332.png)
![Frame 63333: black, until 63696](images/desert-nightmare-the-screen-goes-black-before-the-first-monster/frame-63333.png)

The four frames it comes back in, and after:

![Frame 63698](images/desert-nightmare-the-screen-goes-black-before-the-first-monster/frame-63698.png)
![Frame 63699](images/desert-nightmare-the-screen-goes-black-before-the-first-monster/frame-63699.png)
![Frame 63700](images/desert-nightmare-the-screen-goes-black-before-the-first-monster/frame-63700.png)
![Frame 63701](images/desert-nightmare-the-screen-goes-black-before-the-first-monster/frame-63701.png)
![Frame 63706: back, the monster appearing](images/desert-nightmare-the-screen-goes-black-before-the-first-monster/frame-63706.png)

To look at first: what the scene's page does at that moment —a big
picture, a tint or a flash, an `EraseScreen`/`ShowScreen`, a map
reload—, and what RPG_RT shows there. Since 2026-11-20 a big picture
faded to nothing is taken down and the map reloaded (Aguará's
`big_fade_outs`), and that reload is a suspect.

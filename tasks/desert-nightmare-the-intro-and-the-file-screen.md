---
name: "Desert Nightmare: the intro's menu, the intro, and the file screen"
description: "The start menu's options move with the arrows but nothing shows which is chosen; the intro has broken letters over its first message and goes black; the file screen's cursor is a few brown bits"
type: bug
status: doing
assignee: Aguará
game: desert-nightmare
agents: [Aguará]
---

taro, on 2026-11-20, playing the build of the-advocate `7951af2a` and the
ports `42f70e8` in Mesen2, translated (captures in
`/shared/bug-reports-etc/dn/`):

> At the start the 3 options With Intro / No Intro / Quit show up, and
> pressing the arrows makes sounds and seems to select the options, but
> nothing changes on screen to show it.

> I think it no longer draws garbage in the background. I think the
> background image is fine! The only thing missing would be showing the
> images with their <selected> version. Is it possible to just show the
> images on that screen? If it's feasible, I think it would simplify
> things quite a bit and look nicer. [...] Maybe we could get the result
> just by changing the palette of one of the images. The "selected"
> image is the same as the unselected one, with slightly different
> colours, and a 1px shadow on the inner edges. I think it's a case where
> we could invent something with palette/color cycling, maybe. We'd have
> to see how to make it general, but we can make it specific to this
> game as an experiment, if you think it's worth it.

The original in Wine: `intro-menu-selection-indicator.png`.

> I don't see it that misplaced. The only thing that catches my eye are
> some bits of brown rectangles around "File 1". If I move the selection,
> it shows around File 2, etc; so it must be the selection indicator,
> which we don't manage to render correctly or completely.

`load-file-slightly-broken.png`, and the original in Wine,
`load-file-slightly-broken-original.png`: the face is fine, the cursor
is the only difference.

And the intro: `intro-glitched-bg-1.png`, broken letters over Sandra's
first message, and `intro-black-1.png`/`-2.png`, the intro's messages
over black.

This task also takes over
[`desert-nightmare-start-menu-over-garbage`](desert-nightmare-start-menu-over-garbage.md):
taro sees the background fine now.

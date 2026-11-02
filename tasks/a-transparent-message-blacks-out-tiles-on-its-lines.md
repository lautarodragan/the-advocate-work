---
name: "A transparent message blacks out tiles on its lines"
description: "In Zounds, a sign shown with the message window's transparent background turns part of the map black on the scanlines its text covers, and back when it closes"
type: bug
status: doing
assignee: Aguará
agents: [Aguará]
---

taro, on 2026-11-02, in their words, translated, with two captures of
Zounds —a sign, "Cartel: "No pises el botón."", on a rocky cave map,
and the same screen without it—:

> Another small bug, which I don't know how feasible it is to fix: on
> this map, when showing this text (with a transparent background), some
> of the map's tiles turn black. When it closes they show fine again.
>
> They match exactly the horizontal lines where there is text, and the
> hidden tiles keep showing on other lines, so I don't think it's that
> some tiles were taken out of the SNES's RAM to show the text. Those
> tiles shouldn't be on the object layer either. I can't think of what
> the error can be.

In the capture the black band is on the screen's right edge, where the
dark strip past the map's tiles is, on the scanlines of the text only.
Hornero's guess, unchecked: that strip is the panorama or another
background, and the transparent message's text takes its layer or its
window on those lines.

**Done**: the cause, measured; with the transparent message open the map
shows as without it, as RPG_RT, or —if the console cannot— the limit
measured and a divergence. A ROM test, red before.

---
name: "The test game: a transparent box over a scrolling panorama"
description: "A scene in the test game with characters, a transparent message in the middle of the screen, a floor and a panorama that scrolls on its own, with a test that measures it: the stress case of ABL's map 1, kept where it costs ABL nothing"
type: feature
status: doing
assignee: Aguará
agents: [Aguará]
---

From [`a-window-line-cannot-wait-forever`](a-window-line-cannot-wait-forever.md):
taro's stress case —ABL's map 1 with `EV0002` transparent and in the
middle— was measured but not kept as a test, because in ABL it needs the
whole page in `release`, which moves the text block and the goldens.
taro, on 2026-11-16:

> Can you add this case to the test game? Characters + text in the
> middle, transparent background + floor + a panorama that moves. Even if
> it breaks, it's worth having a test that shows it.

Done means: a map in the test game with a panorama that scrolls on its
own, a floor, characters moving, and a transparent box in the middle
whose letters go over the panorama; a test that measures, per line, the
vblank line it goes up at and its margin, that no display access happens
on the accurate core, and what it looks like (a golden). If something is
wrong —the striped edges of
[`a-transparent-window-over-a-flattened-panorama-shows-striped-edges`](a-transparent-window-over-a-flattened-panorama-shows-striped-edges.md),
for instance— the test shows it: an `xfail` naming the draft, or a golden
of the broken state said as such, not a test bent to pass.

## Log

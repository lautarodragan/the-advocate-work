---
name: "The test game's terrace, in the rain"
description: "Add rain to the terrace's stress case: an event that starts the rain when talked to, and more steps and snapshots at the end of the same test, to see whether the striped edges of ABL's map 1 come from the rain"
type: feature
status: doing
assignee: Aguará
agents: [Aguará]
---

Follows [`the-test-game-a-transparent-box-over-a-scrolling-panorama`](the-test-game-a-transparent-box-over-a-scrolling-panorama.md):
the terrace does not show the striped edges of
[`a-transparent-window-over-a-flattened-panorama-shows-striped-edges`](a-transparent-window-over-a-flattened-panorama-shows-striped-edges.md),
and ABL's map 1 has rain, which the terrace does not. taro, on
2026-11-16:

> Rain! True, I forgot that. That map has too many things on screen! We
> push the SNES to the limit. Can you add a rain case to the existing
> test? I think, instead of cloning the whole test, I'd just add more steps
> and snapshots at the end. It could be an event that makes it rain when
> you interact with it.

Done means: an event on the terrace that starts the rain when talked to;
the terrace's tests go on after the four boxes —the rain on, boxes again
with the rain— and measure the same (vblank lines, margins, waits, the
ceiling, display accesses) plus snapshots; if the stripes show, the test
says so honestly (xfail naming the draft, or a golden of the broken
state); the draft updated either way.

## Log

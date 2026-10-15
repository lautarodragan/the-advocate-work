---
name: "The Book of Three: the intro's torches stand still"
description: "Map 3, the opening's hall, has six still events that animate in RM2k; the console animates four at most, and here none"
type: bug
status: doing
assignee: Calandria
agents: [Mulita, Calandria]
---

Seen by Mulita on 2026-10-15 in the port's opening, next to the
original under Wine, with the-advocate `fa9d1a14` (and `362d3765` for
`degradations.json`) and the ports `0ca371b`, in The Book of Three.

**What is seen**: the hall shown behind the opening text (map 3) has six
flames whose pages animate standing still; in the port they are drawn
still (seen). In the original they were not watched closely: the data says
they flicker.

**What the build says**: `still-animation-dropped`, "map 3: 6 still events
animate in RM2k and the console animates 4 at most: none does" —see
[More than four still events that animate](https://github.com/lautarodragan/the-advocate-docs/blob/main/src/divergences/more-than-four-still-events-that-animate.md)
in the book—.

**How to see it**: boot the release and watch the opening.

taro, on 2026-10-15: they saw them still every time they played and could not tell whether it was on purpose. Take it on.

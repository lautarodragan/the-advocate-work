---
name: "Still animations given up for a picture that is then not drawn"
description: "Sunset's map 46 stops its two animated events to make room for the picture 'Meny', and the picture is left out anyway for lack of a palette"
type: bug
status: todo
---

Seen by Calandria on 2026-10-16, with the-advocate `8c6a345b` and the
ports `059ddcd`, measuring
[`abl-the-sixty-one-torches-of-map-148-stand-still`](abl-the-sixty-one-torches-of-map-148-stand-still.md).
Read from `wally map` on Sunset's `release` request, not played.

**What it is**: `convert` in wally, for a map that does not fit with its
pictures, first tries fewer still events animating, and only then the map
without the pictures. On Sunset Over Imdahl's 46 the first one fits —its
two still events stand still— but the picture `Meny` is still not drawn:
"the map uses 8 sprite palettes and they need 1 more". The animation is
lost and the picture too, where losing only the picture was possible.

**How to see it**: in `sunset-over-imdahl/build/release/degradations.json`,
map 46 has both `still-animation-dropped` (2 events, 0 of 1 looks) and
`pictures-not-drawn`.

**2026-10-17, Calandria**: 46 no longer shows it since the raindrops go
into the free columns of the last row of blocks
([`rain-drops-cost-a-cache-its-slots`](rain-drops-cost-a-cache-its-slots.md)):
its two still events animate, and only the picture is left out. The order
in `convert` that caused it is the same, so another map can still meet it.

## Defined (2026-10-20, Tijereta)

Checked against the release builds of the ports `68bf55b` (the-advocate
`8f290c39`): Sunset's 46 is gone, but the pair is still there on other
maps —El Dorado's 7 ("10 still events animate in RM2k and stand still
here" and "the pictures 'Zeitende, 6_brennender_Ast, 6_Ei' aren't drawn
here") and Sunset's 1, 3 and 12, each with `still-animation-dropped` and
`pictures-not-drawn` in `degradations.json`—. Whether those animations
would have fit without the pictures is what the order in Wally's
`convert` never asks. **Done**: when the pictures do not fit even with
the still events standing still, the map is tried with its animations and
without the pictures, and keeps whichever loses less; a Wally test with a
map where the pictures do not fit either way. **First step**: on El
Dorado's 7, `wally map` with the pictures left out by hand, to see whether
the animations then fit.

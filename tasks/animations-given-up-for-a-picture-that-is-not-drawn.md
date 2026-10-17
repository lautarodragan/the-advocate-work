---
name: "Still animations given up for a picture that is then not drawn"
description: "Sunset's map 46 stops its two animated events to make room for the picture 'Meny', and the picture is left out anyway for lack of a palette"
type: bug
status: draft
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

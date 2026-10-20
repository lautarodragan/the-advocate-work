---
name: "The song a map turns on goes up inside the load"
description: "With the rest of the package in the fade's frozen ticks, the samples of the map's own song still go up in the load's tick, because the song starts there: what is left of the slowest loads, up to some 60 frames"
type: refactor
status: draft
---

Seen by Cardón on 2026-10-18, measuring
[`maps-load-faster-without-losing-anything`](maps-load-faster-without-losing-anything.md),
with the-advocate `c7360e6e`, in snes9x, without MSU-1 tracks.

**What was seen**: since that change, a teleport's package goes up in the
fade's frozen ticks, except the samples of the song the map turns on:
`music_start` starts it at the end of the load, as RM2k's
`Game_Map::PlayBgm` does on setting the map up, and `song_ensure` uploads
them first. When the song is new and big that is most of the load. The
slowest of 200 ABL door pairs, all into map 66: 69>66 adds 74 frames to the
fade, 255>66 71, 310>66 71, 259>66 63; that map's load is its grid (7
frames), its background (11) and its song.

With MSU-1 and a track for that song, it uploads nothing.

**To reproduce**: ABL's `release` without tracks, `go_to_map` from map 69
to 66, counting hardware frames until `fade` goes back to zero.

## Checked (2026-10-20, Tijereta)

Still so at the-advocate `8f290c39`, and said again in "What was left" of
`maps-load-faster-without-losing-anything` (`testing`): starting the song
later, or uploading it while the old map fades, changes when it is heard
or risks the door's sound effect, so it is not lossless. It needs a
decision on which of the two losses is acceptable, if any.

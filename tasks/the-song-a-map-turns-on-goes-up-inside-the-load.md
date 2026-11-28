---
name: "The song a map turns on goes up inside the load"
description: "With the rest of the package in the fade's frozen ticks, the samples of the map's own song still go up in the load's tick, because the song starts there: what is left of the slowest loads, up to some 60 frames"
type: refactor
status: draft
assignee: taro
author: cardon
agents: [cardon]
links:
  found-in: [maps-load-faster-without-losing-anything]
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

## Comments

### 2026-11-24, Cardón: a question for taro

**What to decide**: Tijereta's question of 2026-10-20, still open: the
slowest door loads (up to ~74 frames, all into ABL's map 66) are the
samples of the song the new map starts, uploaded inside the load because
the song starts there, as `Game_Map::PlayBgm`. Without MSU-1 tracks only.

**Options**: (a) leave it; (b) start the song a few frames after the
fade-in, uploading its samples during it —the song is heard later than in
RM2k—; (c) upload them while the old map fades out —risks the door's sound
effect and the old song's samples—.

**Recommendation**: (a): it costs only without the `.msu`, and both others
change when something is heard; if it bothers you playing without tracks,
(b).

## Log

### 2026-10-20, Tijereta: checked

Still so at the-advocate `8f290c39`, and said again in "What was left" of
`maps-load-faster-without-losing-anything` (`testing`): starting the song
later, or uploading it while the old map fades, changes when it is heard
or risks the door's sound effect, so it is not lossless. It needs a
decision on which of the two losses is acceptable, if any.

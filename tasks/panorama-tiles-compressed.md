---
name: "Panorama tiles compressed"
description: "Store panorama tiles in LZ2 instead of raw: ~85 KB freed in ABL's release, about three frames more on the largest panorama's load, and care with a ChangePBG mid-map"
type: feature
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, on 2026-11-16, after [`abl-room-for-still-events-in-the-background`](abl-room-for-still-events-in-the-background.md) (Mulita's study):

> I'd also do the panorama tile compression, honestly. 85 KB is a lot of
> gain, and 3 more frames of loading on the largest map (and I assume it
> only affects the ones with a panorama) is a more than acceptable cost.

The study measured 358,720 B raw, −84,911 B in LZ2, about three frames
more for the largest, and a buffer to watch if a `ChangePBG` swaps the
panorama mid-map.

Done means: panorama tiles in LZ2 in every game, unpacked on load and on
`ChangePBG`; measured gain and load frames per panorama map; ROM tests
(a panorama map's load, a `ChangePBG`); all suites green, goldens
unchanged or explained.

## Log

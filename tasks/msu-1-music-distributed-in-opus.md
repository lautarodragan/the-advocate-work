---
name: "The MSU-1 music, distributed in Opus"
description: "ABL's .pcm files weigh 1.4 GB; distributed in Opus at 160 kbps they would be ~180 MB, and in FLAC ~550 MB, and they are converted to .pcm once at install time"
type: feature
status: wishlist
agents: [Hornero]
---

taro, on 2026-10-11, on the PCMs, in their words, translated:

> they weigh a ton and that's going to make distributing them complicated

The MSU-1 format is fixed —44.1 kHz, 16 bits, stereo, uncompressed—, so they are shrunk only for distributing them. Measured on 6 of ABL's 62 tracks (158 MB): FLAC at 39 %, Opus at 160 kbps at 13 %. To the wishlist by taro's decision, in their words, translated:

> let's leave opus in the wishlist. let's not do anything now

Synthesizing on the console with the SoundFont in the `.msu` does not work: the SPC700 still has 8 voices and 64 KB, and the CPU cannot feed it samples at that rate.

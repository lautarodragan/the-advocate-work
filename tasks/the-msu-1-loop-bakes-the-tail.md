---
name: "The MSU-1 loop bakes the tail"
description: "The next stage of music-loop-like-rm2k: render each song twice so the first pass's release rings over the loop point, cut at E + D and loop at max(D, S) − S; songs with CC111 need a MIDI rewritten from that tick"
type: feature
status: draft
assignee: taro
author: hornero
agents: [cardon]
links:
  relates: [music-loop-like-rm2k]
---

Left open when taro closed [`music-loop-like-rm2k`](music-loop-like-rm2k.md)
on 2026-11-16, whose first stage made the MSU-1 tracks loop like RPG_RT
but cut the tail at the loop. What it takes is written there, under
"What baking the tail would take (the next stage)", measured with
fluidsynth 2.6.0.

## Log

### 2026-11-24, Cardón: a question for taro

**What to decide**: whether to do the next stage of
`music-loop-like-rm2k`, which you closed on 2026-11-16 at its first stage:
the MSU-1 tracks keep the release of the last notes ringing over the loop,
as RPG_RT does, instead of cutting it.

**Options**: (a) bake it for songs without CC111 only —every one of
ABL's—: render twice, cut at `E + D`, loop at `max(D, S) − S`; costs twice
the render time once (the tracks are cached) and up to two seconds more
per track; (b) also songs with CC111, which need a MIDI rewritten from the
CC111's tick; (c) leave it, the cut tail being what is heard today.

**Recommendation**: (a): it is what RM2k sounds like and the measurement
is already in that task; (b) only if a game's song is heard cutting. It
changes what is heard, so it is yours.

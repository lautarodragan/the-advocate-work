---
name: "The MSU-1 loop bakes the tail"
description: "The next stage of music-loop-like-rm2k: render each song twice so the first pass's release rings over the loop point, cut at E + D and loop at max(D, S) − S; songs with CC111 need a MIDI rewritten from that tick"
type: feature
status: draft
author: hornero
links:
  relates: [music-loop-like-rm2k]
---

Left open when taro closed [`music-loop-like-rm2k`](music-loop-like-rm2k.md)
on 2026-11-16, whose first stage made the MSU-1 tracks loop like RPG_RT
but cut the tail at the loop. What it takes is written there, under
"What baking the tail would take (the next stage)", measured with
fluidsynth 2.6.0.

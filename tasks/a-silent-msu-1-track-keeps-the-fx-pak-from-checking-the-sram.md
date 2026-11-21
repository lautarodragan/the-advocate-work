---
name: "A silent MSU-1 track keeps the FX Pak from checking the SRAM"
description: "If the SRAM is ever used as working memory with a .msu, play a silent track whenever no MSU-1 music plays: the FX Pak skips its SRAM checksum and write while any track plays, so every data seek stays at ~2 ms"
type: feature
status: wishlist
author: taro
---

From [`the-sram-as-slow-wram`](the-sram-as-slow-wram.md): on the FX Pak a
data seek made with an MSU-1 track playing costs 2 ms, with none it pays a
checksum of the whole SRAM and, if it changed, a write of it (~1 s at
256 KB). The firmware only looks at the play flag (`msu_audio_usage`), not
at what the track sounds like. taro, on 2026-11-17, translated:

> I suppose that solving the save issue we're fine. And we can analyse the
> use of music in cases where we want to use the SRAM as WRAM,
> exceptionally (because of how fragile it turns out to be, and because
> the MSU is practically mandatory for ABL and other games). Maybe we can
> emit "silence", or a wave at low volume, or something. [...] A sound at
> low volume should be able to "solve" this little issue, if we ever want
> to use the SRAM as WRAM having the MSU.

A track of zeros on repeat (or any track at volume 0) would do, by the
firmware: nothing has to be heard. Only worth doing if the SRAM is ever
used as working memory; and it would make the save fix of
[`a-save-on-the-fx-pak-waits-for-a-silent-seek`](a-save-on-the-fx-pak-waits-for-a-silent-seek.md)
the only way a save reaches the card. To check first: that the FX Pak
treats a silent track and volume 0 like any other playing track
(measurable with the SRAM test ROM).

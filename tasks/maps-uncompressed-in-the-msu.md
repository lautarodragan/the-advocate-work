---
name: "Maps uncompressed in the .msu"
description: "Could each map's streams be stored compressed or not, per map, in the ROM and in the .msu? With MSU-1 a map uncompressed in the .msu goes up by DMA instead of through LZ2: faster loads without committing ROM"
type: research
status: doing
author: taro
assignee: Chajá
agents: [Hornero, Chajá]
game: vampires-dawn
---

> Technically ROM doesn't "spare". Or rather, it's debatable. The msu is
> optional, but I made arbitrary decisions about what to send to the msu vs
> what to leave in the ROM. So it isn't so much "there is room for the
> decompressed map" as "we chose to make room in ROM for decompressed maps
> by sending graphics to the msu, that is, we decided we care more about
> loading 12 frames faster than about having higher-quality graphics".
>
> So the question becomes: do I prefer to use the free ROM for better
> graphics? more maps? decompressed maps? It stops being a binary decision.
>
> I guess that when we consider the port of ABL (or any given game)
> "complete", if there is free ROM, the logical thing is to try to use every
> byte left, if that can give a better experience. But since we aren't
> there yet, I don't dare commit ROM. The msu, instead, doesn't imply much
> commitment, because it is virtually unlimited.

> Let's explore it a bit more; I think an experiment or analysis is worth
> doing right now. Given that Vampires Dawn already loads maps from the
> msu, I want to know:
>
> - how much do those maps weigh in the msu, currently, being compressed?
> - how much would they weigh decompressed?
> - how complex would it be to add the option that maps can be compressed
>   or not, decided per map, both in the msu and the ROM?
>
> In ABL's case it would still be playable without msu, but the msu would
> not only allow better graphics but also offer better load times.
>
> For a game that requires the msu no matter what, the question becomes:
> what do we gain by storing them compressed? A modern internet connection
> gives 200 Mbit/s in the worst case [...] and if the game is in a .zip, the
> zip itself will compress the maps efficiently, so it only matters for
> disk space, and it's rare for someone to have less than 1 TB nowadays.

taro, 2026-11-22, after
[`lashe-city-transitions-lag`](lashe-city-transitions-lag.md) measured
7–15 frames of LZ2 per door in Lashe City.

## Log

### 2026-11-22, Hornero: taken for Chajá, to analyse and experiment

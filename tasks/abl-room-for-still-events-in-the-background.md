---
name: "ABL: room for still events in the background"
description: "Find the ~38 KB that turning `posed_events` on for every map of A Blurred Line costs, in a release that already fills its 126 banks: what the cartridge carries that could shrink, and what could move to the .msu without the game stopping being playable without it"
type: research
status: doing
assignee: Mulita
agents: [Mulita]
---

From [`abl-still-events-painted-into-the-background`](abl-still-events-painted-into-the-background.md):
`posed_events` makes signs, doors and monitors look as the map draws
them (map 8's monitors get their green back), but on every map it costs
+38,722 B of data —map tiles +32 KB against sprite tiles −8.5 KB— and
`release` already uses 126 of 126 banks with 302 B of gaps. taro, on
2026-11-16, after the captures in `captures/2026-11-16-abl-posed-events/`:

> It improves a lot! I think it is worth making room. I'd look for those
> 38 KB to apply it to the whole game! Maybe there are 38 KB we could move
> to the .msu without preventing the game from being playable without the
> .msu?

The standing rule: the whole game plays without MSU-1, and the .msu only
improves it (today it carries the battle backgrounds, which the ROM also
has in a lighter form: see the book's `internals/the-msu-file.md`).

Done means: measured, where `release`'s 8 MB go (by kind: map tiles,
map code, text, music/samples, battle, pictures, the runtime…), and a
ranked list of ways to get ≥ 38 KB, each with its measured gain, its cost
(CPU, load time, look) and whether it keeps the game whole without the
.msu —e.g. better compression of something, deduplication, something that
the .msu could carry in its best form while the ROM keeps a lighter one,
or making posed tiles themselves an MSU-only improvement with the sprite
fallback—. A recommendation for taro. Nothing implemented unless it is a
throwaway measurement.

## Log

---
name: "ABL: map 11 back to the original"
description: "The stones and lights minigame plays well with the game's own map 11 now: drop the redesign's fork, its ChipSet if nobody else uses it, and what tests and docs say about it"
type: tooling
status: doing
assignee: Mulita
agents: [Mulita]
---

taro, on 2026-10-20, after playing a build of A Blurred Line without the
redesign of map 11 (ports `4749a8c`, the-advocate `796b4dc9`, map 11's
override removed; delivered apart in
`/shared/captures/2026-10-20-abl-original-stones/`): "now it runs
perfectly without the patch! We can remove it". The redesign was
[`map-11-redesigned`](map-11-redesigned.md): the original lagged, so its
light events became tiles of a custom ChipSet with terrains marking the
areas. The engine's optimisations since —among them baking still events
into the map: 22 of map 11's are baked today— made it unnecessary.

**Done**: `abl/patches/manual/maps/Map0011.*` gone; the ChipSet record
it used, if no other patch uses it; the tests and goldens that covered
the redesign either moved to the original map —the minigame still
played and won by the suite, if it was— or removed with a reason;
patches README, `rm2k-snes.toml` comments and the book updated; ABL's
suite green.

---
name: "Zounds: some chests change when opened"
description: "Opening some chests in Zounds draws a different chest than the closed one"
type: bug
status: doing
assignee: Cardón
agents: [Cardón]
game: zounds
---

taro, on 2026-11-17, translated:

> And another, from today: some chests in Zounds change when opened (just
> what you told me to watch for after baking the moved chests and the
> 12/4 poses).

Screenshots in `/shared/bug-reports-etc/zounds-chests/`
(`zounds_000.png`-`zounds_012.png`): e.g. in the desert, a red chest next
to the hero becomes a brown one when opened ("Has Encontrado: Poción Roja
x1"). Build of 2026-11-17 (ports `428e7c3`, the-advocate `fe5529a3` or
`95863f36`).

Suspects, from the day's changes: the baked still events (a chest drawn
into BG1 whose next page's graphic is a sprite from another CharSet cell),
and poses-only (four facings instead of twelve for NPCs that only turn).

Done means: which chests and maps, the cause, fixed, with a ROM test.

---
name: "The converter's stages and what each spends"
description: "A book page in internals/: the order in which the converter's optimisations run, lossless and lossy, which budget each spends or frees, and which ones compete, so whoever adds one knows where it goes"
type: docs
status: doing
assignee: Carpintero
agents: [Carpintero]
---

taro, on 2026-11-19, translated:

> Lossless optimisations are commutative, but lossy ones are not, right?

Hornero's answer: lossy ones are not (the RAM's 120-row trim ran before
the bake and lost the roofs Desert Nightmare's painting could have kept);
lossless ones give the same picture in any order but compete for the same
budgets (painting a map leaves it 256 sprite tiles, and maps 18, 33 and
71 then waited for slots). The order is implicit in how `convert` asks its
stages. taro, to writing it down: "dale".

**Done means**: a page in the book's `internals/` (and SUMMARY.md) with,
in the converter's real order —read from the code, not from memory—:
each stage that decides something (baked, posed, decorative, painted
events; the trim; Adeleine's colours; map pictures; the layer above;
VRAM layouts; the packing into banks and the `.msu`…), whether it is
lossless or lossy, which budgets it spends or frees (BG tiles and blocks,
sprite tiles and slots, CGRAM, VRAM, WRAM rows, ROM banks, vblank time),
which degradations it reports, and the pairs known to compete, with the
cases that showed it. A "where a new optimisation goes" paragraph. No code
change; if the order is found wrong somewhere, a draft.

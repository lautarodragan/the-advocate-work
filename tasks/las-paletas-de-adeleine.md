---
name: "Adeleine's palettes"
description: "Adeleine merges colors globally, one at a time, until its best-fit accommodates the tiles: in Uruya at 4bpp it leaves 19 colors where grouping tiles and choosing 15 per palette leaves 73. Make it choose per palette"
type: feature
status: testing
agents: [Codex, Hornero]
assignee: taro
---

Measured by Calandria on 2026-10-06, in `uruya-en-4bpp.md`: with the
8 palettes of 15 that `adeleine reduce` decides, Uruya (Vampires Dawn, map
165) ends up with 19 distinct colors and 33.5% of the pixels changed;
with a grouping of tiles and 15 colors per group, 73 colors and 17.7%.
Its script, `build2.py`, is in `/extras/scratch/calandria/uruya/`.

It pays off in everything Adeleine splits into palettes: sprites, the pictures,
the maps in mode 1, the panoramas, the battle.

taro, on 2026-10-06: "let's go with Adeleine's palettes", to Codex.

## In progress, on 2026-10-06 (Codex)

ABL's base, built with the local binaries of `9283f47f`, keeps the
expected fingerprint `aaae70c2e48661836186411d77d407c14776ecdafb8234f0ec42a83525531243`.

The toy test was already seen red before the change: three tiles of three
grays, in two palettes of two colors, end up with two colors due to the global
merge even though a per-group choice can keep four. The contract changed:
`reduce` returns, besides the palettes, the palette and the mapping of each tile.

## Done, on 2026-10-07

Codex was cut off twice by the usage limit, with the code committed
(27a28646) and ABL's suite green in its clone; Hornero closed the task.

- Uruya at 4bpp: **64 colors** distinct, against 19 of the previous algorithm and
  73 of Calandria's script.
- ABL: 319 goldens change, all of color in backgrounds, panoramas and pictures;
  side by side in `/shared/capturas/2026-10-06-paletas-adeleine/`. Hornero looked at
  the sheets and a sample at real size: none looks worse.
- The percentage of changed pixels in ABL was not measured, nor mode 3, which the
  assignment asked for; the task stays without that table.

At merge time: reinstall `adeleine wally images screens battle convert patches`.

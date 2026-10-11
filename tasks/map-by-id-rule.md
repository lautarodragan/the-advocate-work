---
name: "The map-by-id rule"
description: "release carries the maps with id below 65, minus a short exclusion, plus the additions: it stops being a hand-written list"
type: refactor
status: done
---

# What

The second half of milestone 4 of `race-and-what-comes-next.md`. The
first —the converter's two latent bugs— is already on `main`
(`9d6c0d3`).

`release` stops carrying the hand-written list of `MAPAS_DEL_JUEGO` in
`tools/ensamblado/cartuchos.py` and goes on to carry **the maps with id below
X, without the excluded ones, plus the additions**. Decided by taro: X = 65, the
exclusion 15, 22, 46, 55 and 58 —small, at his request— and 164 as an addition.
The test maps and `test-special` stay as they were.

**It does not move the ROM**: the list that comes out of the rule has to be the same, in
the same order, as the hand-written one of milestone 1.

# How

## "The maps" are the tree's, not all ids

From 1 to 64, besides the five
excluded ones, 24, 25, 27, 31 and 35 are missing from the hand-written list: they are **areas** of the tree
(`RPG_RT.lmt`, type 2), nodes without a `.lmu` that only cover a rectangle of their
parent for the encounters. The rule counts those of type 1, which are the ones that
have a map: otherwise, the exclusion would have ten ids and five would be "not a
map".

## Where each thing lives

The three values —`MENOR_A`, `EXCLUIDOS` and `AGREGADOS`— live in
`cartuchos.py`, and the rule is expanded **there**, with the tree from the dump in
`data/`. The converter still receives the explicit list in `--mapas`,
as until now. There is no `--exclude-maps` flag, and that is on purpose:

* **Nobody else calls the converter**: the only one that invokes it is `cartuchos.py`
  (grep for `snes_convert` in `justfile`, `tools/` and `pruebas/`). A flag would
  give a second way of receiving the maps to a program that already has
  one, for a single caller.
* **Those that read the list in Python need it without running the converter**:
  `test_horneados.py` (`cartuchos.MAPAS`), `test_parches.py`
  (`MAPAS_DEL_JUEGO`) and `parches.mapas_de_prueba`. With the rule in the
  converter it would have to be expanded in two places.
* **The seal**: the cartridge's seal carries its flags, and `data/` does not go into
  the fingerprint. With the list expanded in the flags, a change in the tree that
  changes which maps go in leaves the cartridge stale; with `--menores-a 65` in the
  flags, it would not notice.

And if some day the flag is needed, the name in `tools/` goes in Spanish
(`--excluir-mapas`): the AGENTS.md rule says English flags are
those of the separate projects.

A map that falls outside the rule —a tutorial from another chapter, a
folder— goes to `EXCLUIDOS` **with its reason next to it**; one beyond
`MENOR_A` that is needed, to `AGREGADOS`. `test_ensamblar.py` enforces that each
excluded one is a map the rule would put in and each addition one it would not: a
decorative number in either list says nothing and goes stale.

## Check

* The list the rule gives is the same tuple, in the same order, as the
  hand-written one (compared in Python against the old one).
* **The ROMs, byte for byte**: `just cartuchos` on `69e66ed` and on the
  change —both cartridges were rebuilt, because `cartuchos.py` goes into the
  fingerprint— and `cmp` of `rom/build/release/abl.sfc`, `abl.msu`,
  `rom/build/tests/special/prueba.sfc` and `prueba.msu` against the copies from
  before: all four identical.
* `just pruebas` on the result: all green.

There is nothing taro has to play: the ROM is the same.

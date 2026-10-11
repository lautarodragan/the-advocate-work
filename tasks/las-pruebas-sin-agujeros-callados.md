---
name: "Tests without silent holes"
description: "A missing playthrough golden is declared instead of passing green, and the helpers imported from other test_* move to the harness"
type: test
status: done
assignee: taro
---

The two improvements from Codex's inspection
(`docs/research/inspeccion-integral-del-repo.md`) that Hornero marked as the
ones that pay off most for what they cost, and that taro agreed with on
2026-09-28:

- `Recorrido.foto` does not fail if the golden is missing (`rom/pruebas/arnes/recorrido.py`,
  `_contra_golden`): on purpose, to be able to add a milestone before
  approving its image, but that way "not approved yet" cannot be told apart
  from "deleted". There has to be an explicit list of the pending ones.
- Several tests import from other `test_*` (`test_eventos_de_tropa` from
  `test_tropa` and `test_victoria`, `test_recorrido_carrera_golden` from
  `test_recorrido_lashe_golden`, and more): what is shared moves to
  `rom/pruebas/arnes/`.

No golden changes: if one is missing today, it goes on the pending list.

## What was done

### 1. A missing playthrough golden is declared

Measured on 2026-09-29 with `just pruebas` over `74fe48d5` —867 cases
green—: the playthroughs took 135 snapshots and only 8 had a golden, those
of `apertura/` and `talan/`. The other 127 are in
`rom/pruebas/golden/playthrough/pendientes.txt`, grouped by the test that
takes them and with their why: those of the playthroughs from Lashe City
onwards "are not blessed: they are for taro to look at", according to each
one's docstring, and the 14 of `test_mapa_de_debug.py` are without golden
**on purpose** —the one that counts is the suite's—, so those may not be
pending but permanent: it is taro's to decide. There were no orphans.

Three nets, all three tested red by hand and reverted:

* `Recorrido.foto`: a snapshot without golden fails if it is not on the
  list, and so does one that is on the list and has a golden (removing
  `talan/03`, adding a snapshot to `lashe-pad`, and listing `apertura/02`);
* `Recorrido.verificar_el_tramo`, which an autouse fixture of the conftest
  calls when a test that passed ends: every golden and every line of the
  stretch must have been a snapshot (with a golden
  `apertura/03-fantasma.png` and a line `vipers/99-no-existe.png`);
* `herramientas/test_goldens_del_recorrido.py`, without emulating: every
  stretch with goldens or pending ones is named by some test (with a folder
  `tramo-borrado/`).

### 2. What the tests imported from each other, to the harness

Ten tests imported from another `test_*` —and `arnes/video.py`, on
purpose—. Only what was imported and what it drags along was moved, as is
—the diff of the deleted lines against the new modules is zero, except for
imports and a comment split in two—:

* to `arnes/batalla.py`: the experience (`exp_y_nivel`, `poner_exp`,
  `ranura_exp`, `rom_de`, `ARDEN`) from `test_experiencia_dibujo`; the page
  message from `test_tropa`; the victory window (`glifos`, `renglones`,
  `ventana`, `paginas`, `primera_pagina`) from `test_victoria`; and
  returning from the Game Over (`VOLVER_TOPE`, `TITULO_QUIETO`,
  `pasar_el_titulo`, `cuadros_hasta_volver`) from `test_game_over`;
* to `arnes/menu.py`: `comparar`, from `test_menu_dibujo`;
* to `arnes/msu.py`, new: `pistas_de`, from `test_msu`;
* to four `arnes/tramo_*.py`, one per source playthrough, because they have
  equal names with different signatures (`sin_encuentros(r)` in the plant
  and `sin_encuentros(p)` in Sorbe): `tramo_lashe`, `tramo_planta`,
  `tramo_wick` and `tramo_sorbe`.

`test_indice.py` now enforces that no test imports from another, with
`arnes/video.py` as the only declared exception.

`video.py` was not touched and does not depend on anything moved: it still
imports `test_recorrido_golden`, which imported from no one. **But `just
video` with playthroughs has been broken since before**, since `release`
boots into the debug map (`991bf935`, 2026-09-27): `video.py`'s `recorrido`
factory does not accept `caso` —`apertura` gives `TypeError`— and does not
pick the page without the map as `tanda.partida` does —`talan` gets stuck on
map 900—. `quieto:120` records fine. It was not fixed: it belongs to the
task of taking `video.py` out of the tests.

## What is left for taro

* **Look at the 127 pending** in `rom/pruebas/golden/playthrough/pendientes.txt`
  and approve those that are right: approving one is copying its capture
  from `rom/pruebas/snapshots/playthrough/<tramo>/` to the golden and
  removing its line, in the same commit; the test refuses if only one of the
  two things is left.
* Decide whether the 14 `debug-*` are pending or permanent: their test says
  they carry no golden on purpose. If they are permanent, today the list
  treats them the same as the others.

## Verified

On the tree merged with `main` at `42986e43`: `just pruebas`, 870 green
—867 at the start, plus the two of `test_goldens_del_recorrido.py` and
`test_ninguna_prueba_importa_de_otra`—; the long playthroughs are inside
that run. `rom/build/release/abl.sfc` the same byte for byte as at the
start. `just video` only with `quieto:120`: with playthroughs it was broken
since before, see above.

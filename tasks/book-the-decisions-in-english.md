---
name: "The book: the decisions, in English"
description: "The 40 decisions in decisiones/ to the book, translated: the tools' ones to decisions/, ABL's to ports/abl/decisions/"
type: docs
status: done
assignee: taro
agents: [Mulita]
---

From taro, on 2026-10-10: all the documentation in one place, the book
(`snes-rm2k-docs`), in English: "The book is for people and for AIs".
This task is one of four in parallel; the common conventions are in
Hornero's brief, and Hornero builds the final `SUMMARY.md`, deletes the
originals and updates the references.

## What was done (Mulita, 2026-10-10)

Branch `mulita-decisions` of `snes-rm2k-docs`, on 149452a, in a separate
clone; three commits: the tools' ones, ABL's and the
`SUMMARY.md`. `mdbook build` without warnings.

- **`src/decisions/`**: 37 decisions and the `README.md`, translated in full
  and with a grouped index (project, events, routes, graphics and memory,
  audio), which is also the order of `SUMMARY.md`.
- **`src/ports/abl/decisions/`**: the two that belong to the game and not to
  the engine —`la-camara-corrida-de-la-reja-es-del-juego` (what the
  original does on map 8) and `el-trueno-va-entero-y-paga-la-lluvia` (an
  effect on one of ABL's maps)— and a `README.md` with its index. The mixed
  ones —an engine rule measured on ABL, like `los-lideres-comparten-…`,
  `la-orden-34-…` or `el-cartucho-pasa-a-8-mb`— stayed in `decisions/`.
- `src/ports/README.md` and `src/ports/abl/README.md` are one-line stubs:
  the real ones are Tijereta's.
- The format: the title goes in English and "Qué / Por qué / Cómo se aplica"
  become `## What / Why / How it applies`.

## For Hornero, when merging

- The links to `../research/…` and `../divergences/…` point to slugs by
  Cardón and Calandria. Two of the studies
  (`2026-10-01-el-juego-entero-sin-msu-1`, `2026-10-01-los-mapas-por-el-msu-1`)
  are from `abl/docs/research/` in the ports, not from `snes-rm2k`: if Cardón
  puts them under `ports/abl/`, those two links have to be fixed (in
  `el-cartucho-pasa-a-8-mb.md` and `el-juego-se-juega-sin-msu-1.md`).
- `el-color-math-no-se-usa.md` and `decisions/README.md` link
  `../divergences/README.md`, which has to exist.
- The citation of `modo3-y-poses-en-caliente` (a memory note, not public)
  was replaced by a link to `cartridge/mode-3.md`.

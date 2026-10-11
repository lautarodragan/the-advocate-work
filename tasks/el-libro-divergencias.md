---
name: "The book: the divergences, in English"
description: "The 42 divergences in divergencias/ to the book, translated, in divergences/"
type: docs
status: testing
assignee: taro
agents: [Calandria]
---

From taro, on 2026-10-10: all the documentation in a single place, the book
(`snes-rm2k-docs`), in English: "The book is for people and for AIs".
This task is one of four in parallel; the shared conventions are in
Hornero's assignment, and Hornero puts together the final `SUMMARY.md`, deletes the
originals and updates the references.

## What was done (Calandria, 2026-10-10)

Branch `calandria-divergences` of the book's clone, on 149452a, in three
commits: 387a431 and bd84ca9 are the 41 pages and the introduction
(`src/divergences/`, with the slugs in Spanish), and ef2c3ba the
`SUMMARY.md` section, grouped by topic with draft entries without a page
—the map and its graphics, events and movement, messages and windows, the
battle, the other screens, the controls—. `mdbook build` without warnings.
There were 42 files counting the README: 41 divergences.

What was decided while translating:

* The originals have no title —the file name acts as the title—:
  each page got an English `#` and its sections went down to `##`.
* The code paths say which repo they are from ("in snes-rm2k", "in the ABL
  port (snes-rm2k-ports/abl)"); the `tasks/` ones with a wildcard
  (`tasks/*/x.md`, `workflow/tasks/*/x.md`) became "the task `x.md`,
  in `tasks/` in snes-rm2k-work".
* Citations between divergences are relative links. The ones to
  `decisiones/` point to `../decisions/<slug>.md` (four:
  `call-event-a-un-cuerpo-compartido`, `el-cronometro-no-tiene-paleta-propia`,
  `las-imagenes-grandes-en-modo-1`, `los-translucidos-van-horneados`), the
  intro to `../decisions/README.md`, and the one to `docs/research/` to
  `../research/graficos-de-rm2k-a-snes.md`: if Mulita put any in
  `ports/abl/decisions/`, it has to be corrected when merging.
* `docs/port/events.md` and `docs/port/vram.md` stayed as text ("in
  snes-rm2k"), without a link: I do not know what name Tijereta leaves them under.
* The only trace of the environment was the captures folder in `/shared` of
  `la-ventana-sin-fondo-no-tapa-a-los-personajes`: it became "kept outside the
  repositories, for review", and where they are gets lost.

When merging there is nothing to install.

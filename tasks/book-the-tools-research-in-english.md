---
name: "The book: the tools' research, in English"
description: "The 9 dated studies in snes-rm2k's docs/research/ to the book, translated and without updating their numbers, in research/"
type: docs
status: done
assignee: taro
agents: [Cardón]
---

From taro, on 2026-10-10: all the documentation in one place, the book
(`snes-rm2k-docs`), in English: "The book is for people and for AIs".
This task is one of four in parallel; the common conventions are in
Hornero's brief, and Hornero builds the final `SUMMARY.md`, deletes the
originals and updates the references.

## What was done (Cardón, 2026-10-10)

Branch `cardon-research` of `snes-rm2k-docs`, on `149452a`, in a separate
clone: one commit per study, one for `src/research/README.md` and a
separate one for `SUMMARY.md`. Nothing to install when merging. The nine
ended up in `src/research/<slug>.md` with the slug in Spanish and the title
in English; the README explains that a research is a snapshot that isn't touched.
Five —the Python map, the test game, the tools today, the
pictures and the panoramas— were translated by forks of mine; I reviewed them by
sampling and searching for stray Spanish.

Criteria I adopted, to look at when merging:

* The number notation became the English one (5.601 → 5,601; 10,3% →
  10.3%); the values didn't.
* The citations to `decisiones/x.md` and `divergencias/x.md` that exist became
  links `../decisions/x.md` and `../divergences/x.md` (six: they are broken
  until Mulita's and Calandria's sections go in); the citations between
  research, relative links; `docs/port/…`, `workflow/…` and `rom/…`
  stayed as text, as they were.
* Identifiers, module names and script output in Spanish
  (`cartuchos`, `techos`, `## ARISTAS POR ARCHIVO`) stayed as is:
  they are names of that day.
* Machine paths: just one, "en el scratch" from the test game →
  "in the scratch directory"; and "una ruta de esta máquina" from the Python
  map → "a path on the development machine".

Verified: `mdbook build` without warnings; the links between research
pages resolve.

---
name: "The book: the tools' and ABL's docs/, and the ports section"
description: "docs/port, rpgmaker, snes and jetbrains.md from snes-rm2k, and ABL's docs/, to the book in English; and the ports/ section, one entry per game"
type: docs
status: done
assignee: taro
agents: [Tijereta]
---

From taro, on 2026-10-10: all the documentation in a single place, the book
(`snes-rm2k-docs`), in English; in their words, translated:

> The book is for people and for AIs

This task is one of four in parallel; the common conventions are in
Hornero's brief, and Hornero puts together the final `SUMMARY.md`, deletes the
originals and updates the references.

## While working (Tijereta, 2026-10-10)

Clone of the book in `~/scratch/tijereta/docs`, branch `tijereta-docs-ports`,
from `149452a`. Sources: `snes-rm2k` at `e43e3e1b`, the ports at
`4eec80a`, this repo at `90f292b`.

* The slugs of ABL's `port/`, `rpgmaker/`, `snes/`, `research/` stay in
  Spanish; the new ones (`README.md`, `contributing/`, each game's)
  in English or like the game's directory.
* Citations of `workflow/decisiones/x.md` become `../decisions/x.md`, those
  of `divergencias/` `../divergences/x.md` and those of `docs/research/`
  `../research/x.md`: the slugs don't change, so the links to the
  sections of Mulita, Calandria and Cardón resolve on merging.

## How it ended up (Tijereta, 2026-10-10)

Branch `tijereta-docs-ports` of the clone `~/scratch/tijereta/docs`, seven
commits on `149452a`; the `SUMMARY.md` goes in a commit of its own (`031f761`).
`mdbook build` with no warnings; the only links that don't resolve in the
branch are to `decisions/`, `ports/abl/decisions/`, `divergences/` and
`research/`, and all of them exist in the clones of Mulita, Calandria and Cardón.

* `internals/`: the seven from `docs/port/`. `pipeline.md` keeps the
  diagram of binaries and outputs, and links to the book's `pipeline.md` for
  the rest; what `cgram.md` and `vram.md` repeated about mode 3 and about what
  is lost, linked to `fitting.md` and `cartridge/mode-3.md`. The
  variables, with today's names (`SOUNDFONT`, `RTP_DIR`), in their own commit.
* `reference/`: `chipsets.md`, `rtp.md`, `emulators.md` (it was already in
  English: it only lost the mentions of the machine) and Bregalad's FAQ,
  as is, as a static file.
* `contributing/`: the four repos and `jetbrains.md`.
* `ports/`: what a port is, ABL (its README, put together from the port's and
  its `docs/`'s; its pipeline, its RTP and the three research pages) and a page
  for each of the seven, as a snapshot as of 2026-10-06: what came from the survey
  and from each `testing/` task that names it.

**What was stale in the original and was translated as is**, for whoever
updates it: `events.md` says that "what remains on the Python side is the
converter", and the converter is Rust now; `vram.md` says that the panorama
layouts "are four" and lists five. ABL's README called the tools repo
`abl-snes`: in the book it says snes-rm2k.

On merging there is nothing to install: it is only the book.

---
name: "The .msu and the tracks are written through a .nuevo file"
description: "the converter and rm2k-snes-audio write the .msu, and the tracks' code each .pcm, alongside as <file>.nuevo and rename it: a Spanish name left in the tools after everything went to English"
type: refactor
game: advocate
status: draft
author: mulita
links:
  found-in: [the-stages-speak-json-nobody-types]
---

Seen by Mulita on 2026-11-24, at the-advocate `mulita-a7` (from
`8b069fc2`), moving the music's `cartridge` into the converter (A7 of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)).

Three places write a file alongside as `<file>.nuevo` and rename it over
the old one, because an emulator may have it open: the `.msu` in the
converter's `convert.rs` and in `rm2k-snes-audio`'s `main.rs` (its
`cartridge` command), and each MSU-1 track in `tracks.rs`. The suffix is
the Spanish of the Python this came from (`bdb59808`), and everything in
the four repos is in English since 2026-10-12. A7 kept it as it was, so
that the step changed nothing but where the code runs.

`tracks.rs` is one of the tracks' cache key's `OWN_SOURCES`: any change to
it renders every track again, 2.4 GB for ABL.

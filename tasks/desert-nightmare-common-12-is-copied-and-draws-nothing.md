---
name: "Desert Nightmare: common event 12 is copied into 181 maps and draws nothing"
description: "The copies of an automatic common event exist so it can draw its small pictures with the map's; common 12's pictures, and those of common 11 it calls, are all 320x240, so its 181 copies draw nothing and are a megabyte of the cartridge, 95% of all the maps' bytecode"
type: refactor
status: done
author: carpintero
game: desert-nightmare
agents: [Carpintero, Chajá]
---

**Fixed** by [`a-common-event-is-copied-only-if-its-copy-draws`](a-common-event-is-copied-only-if-its-copy-draws.md)
(Chajá, 2026-11-20): the converter copies only a common that shows a
small picture, and 12 is no longer copied. Kept as `done` and not deleted
because the book's research on Desert Nightmare's room links it.

Seen by Carpintero on 2026-11-20, at the-advocate `16081af9` and the
ports `1177cbc`, for
[`desert-nightmare-the-cartridge-has-no-room-left`](desert-nightmare-the-cartridge-has-no-room-left.md).
Only cartridge is lost; nothing is seen wrong.

**What was seen**: the converter copies common event 12 (`Menü 4 aktiv`,
automatic on switch 8) into 181 of the 189 maps (`common_pages.rs`, "for
their pictures"). Every picture it shows —`Notiz_Bild1` to `11`— and every
one of common 11, which it calls seven times, is 320x240: none is a small
picture a copy draws and the shared body does not, and the converter log
says the big ones are not shown either way. Each copy is 13,833 bytes of
bytecode; without its seven `CallEvent`s it is 1,023, because a copy
pastes what it calls (`shares` in the event compiler pastes a body whose
pictures compile differently with a map). Compressed, the 181 copies are
about 1,049,000 of the 1,106,568 bytes of LZ2 of all the maps' pages; the
maps' pages without any copy are 57,675.

The rule that decides the copies predates the shared table of the common
events' small pictures (2026-10-17 against 2026-10-20) and asks only
whether the common has a `ShowPicture`.

**To reproduce**: `rm2k-snes-events compile` on `desert-nightmare/data`
with the `events-request.json` the build leaves in `build/release/`, once
as it is and once with `common_pages.commons` emptied, and each map's
pages' `code` summed and compressed with `lz2`.

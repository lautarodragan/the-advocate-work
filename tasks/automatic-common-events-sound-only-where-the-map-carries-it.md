---
name: "An automatic common event's sound effect plays only where the map carries it"
description: "The shared body of an automatic common event without pictures is compiled without a map, and its PlaySounds go into no audio package; parallel ones got theirs on 2026-10-20"
type: bug
status: draft
---

Seen by Mulita on 2026-10-20, reading the event compiler at the-advocate
`9981a638` (branch `mulita-abl-rain`), while fixing
`parallel-common-events-sound-only-where-the-map-carries-it.md`. Not
heard in a ROM: as far as it was looked.

**What happens**: an automatic common event —trigger 3— is compiled once,
as a shared body without a map (`commons::compile`), and the effects of its
`PlaySound`s are numbered but noted in no map's audio package. The ROM
plays an effect only if the package of the map it is on carries the
sample, so those effects sound only on maps whose own pages ask for the
same effect. The ones with a `ShowPicture` are copied into the maps that
can turn their switch on and compiled with them (`common_pages.rs` in the
converter), so their effects do go in; the ones without pictures do not.

**Which**, by a throwaway count over each port's `data/` (automatic, with a
`PlaySound` of their own and no `ShowPicture`): Desert Nightmare's
`Menü 1 aktiv`, `Menü 2 aktiv` and `Menü 3 aktiv` (6, 8, 10: `Beep_3`,
`Button`, `Cansel1`), and Vampires Dawn's `Blutkonzentration`, `Zuflucht`
and `Zuflucht2` (7, 32, 51: `Annihilation1`, `Annihilation2`, `Cold10`).
Not counted: the effects of the common events these call, which are shared
bodies too.

**How it could go**: what parallel ones got on 2026-10-20 —`Songs::loose`
collects a body's effects, and `commons::turned_on` says on which maps its
switch can be on—, applied to each automatic root and the bodies it calls.
What it costs in ARAM has to be measured per game, as the parallel ones'
was (Vampires Dawn's music moved there).

**How to see it**: in Desert Nightmare, open one of those menus on a map
whose pages play no `Beep_3`, and listen to its cursor; in RM2k it beeps.

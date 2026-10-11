---
name: "Parallel common events don't run"
description: "The ROM doesn't run parallel common events, except ABL's equipment ones; five games have some —Vampires Dawn 35, among them the transformations— and it hasn't been looked at what is lost in each one"
type: feature
status: draft
---

Aguará saw it on 2026-10-06 while building the board against RM2k
(`dashboard-against-the-whole-of-rm2k.md`): "parallel common events don't run
—6 in ABL, 35 in Vampires Dawn—, which wasn't in any study". It's still
the same in the-advocate `fc6f7456`: the comment of `party_common_events`,
in `rm2k-snes/events/src/indices.rs`, says "The ROM does not run parallel
common events", and the only exception are the ones that only look at the equipment,
which run when closing the menu (the book's divergence
`los-comunes-del-equipo-corren-al-cerrar-el-menu`).

**Which ones they are**, counted on 2026-10-11 in each port's `data/db/commonevents.json`
(ports `a85b7e3`; parallel trigger and with commands):

* ABL: 1 `TalanLateForWork`, 2 `DisableSaving`, 3 `Raining`, 36
  `ManageQuarryTimer`, and 37 `UpdateAG7 Skills`, which is the equipment one and does
  run in its own way;
* The Book of Three: 16 `DisableSaving`, 18 `Reraise KO'd chars`, 21
  `Eilonwy's Upgrades`, 22 `LegendariesActivated`;
* Desert Nightmare: 4 `Hauptmenü`, 23 `Vergiftet`;
* Sunset Over Imdahl: 4 `MenuCaller`;
* Vampires Dawn: 35, among them the summons (`Skelett beschwören`,
  `Dämon beschwören`…) and the transformations (`Wolfsverwandlung`,
  `Fledermausverwandlun`, `Verwandlung beenden`);
* Dooms 2, El Dorado and The Frozen World: none.

**What isn't known**: what is lost when playing each game. None was
looked at in an emulator, and some may be covered by another path (a
`CallEvent` from a map). What was measured on 2026-09-27 about doing them
for real —another interpreter, the body on each frame while the switch
is on— and why it wasn't done then is in that same comment
and in `automatic-common-events-the-shared-callevent-and-v-n.md`: ABL's 2,
`DisableSaving`, has no switch and would always run.

**How to see it**: the list comes from each port's `commonevents.json`
(`trigger` 4); what's lost, by playing up to where each one's switch
turns on and comparing with the original in Wine.

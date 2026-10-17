---
name: "Parallel common events don't run"
description: "Parallel common events run in the ROM, each with its own interpreter, the pure ones only when what they read changes, and Loop compiles; what still does not run in each game is in drafts"
type: feature
status: done
assignee: taro
agents: [Aguará]
---

Aguará saw it on 2026-10-06 while building the board against RM2k
(`dashboard-against-the-whole-of-rm2k.md`): "parallel common events don't run
—6 in ABL, 35 in Vampires Dawn—, which wasn't in any study". It's still
the same in the-advocate `fc6f7456`: the comment of `party_common_events`,
in `rm2k-snes/events/src/indices.rs`, says "The ROM does not run parallel
common events", and the only exception are the ones that only look at the equipment,
which run when closing the menu (the book's divergence
`pure-parallel-common-events-run-only-when-what-they-read-changes`).

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

## Done (Aguará, 2026-10-12)

From the-advocate `25d93f0a`, ports `742e127`, book `381001b`, merged
with main before delivering; branches `aguara-comunes-paralelos` in the
three. **To install when merging**: `events`, `mapdata`, `convert` and
`cartridge` (the runtime changed too).

**What runs.** `compar_tick` (runtime/common_events.s), from `map_events`
right before the map's parallels —easyrpg's `UpdateCommonEvents` goes
before `UpdateMapEvents`—: each parallel common event with its own
interpreter, every frame while its switch is on, or always without one.
Bodies compiled once without a map (`commons::parallel_commons`), their
`CallEvent`s pasted —the call stack is the foreground's—. State in
`FARBSS`, six bytes each; it survives map changes and does not travel in
the save. With its switch off it is frozen, not restarted
(`Game_CommonEvent::Update`); **both RPG_RT, 2000's and 2015's, do the
same**, checked with Wine on a copy of ABL whose common event turns its
own switch off and then shows two messages: the second never shows. That
is exactly ABL's `TalanLateForWork`: in the original its second message
never shows either. `pair_ev` is `$80` plus the index while one runs, so
the message guards own its messages.

**The equipment path is gone**, and its idea is general now: a **pure**
one (`commons::pure`: only switch and equipment branches, only skills and
permissions written) runs only on the frame its switch turns on and the
frame after `compar_owed`, which `set_switch`, `ChangeEquipment`, the menu
closing and the permission opcode set. ABL's 2, 8 and 37 are pure. Every
frame they cost the race lap 53 hardware frames over its 976 ticks, past
the 5% cap. The divergence is rewritten in the book under its old file
name.

**Loop, BreakLoop and EndLoop compile** (as jumps, as RM2k without
Maniac): 22 of Vampires Dawn's parallel common events have one. A loop
with nothing that lets a frame go by does not compile —new divergence—.

**And common events on a switch past 1023** —the bitmap's end— never run,
parallel or automatic: the ROM read past `switches` for them. Vampires
Dawn's 52 was one.

### Per game, from each converter's report

* ABL: 1 `TalanLateForWork`, 2 `DisableSaving`, 3 `Raining`, 8
  `EnableSaving`, 37 `UpdateAG7 Skills` run; 36 `ManageQuarryTimer` does
  not compile (its `Teleport` goes to map 150, not in `release`).
  Seen: the menu's Save is grey with 236 off in the ROM and in the
  original under Wine; `Raining` runs but its `Rain1` does not sound.
* The Book of Three: 16 and 22 run; 18 and 21 do not compile.
* Desert Nightmare: both run (4 `Hauptmenü`, 23 `Vergiftet`).
* Sunset over Imdahl: 4 `MenuCaller` runs.
* Vampires Dawn: 22 of 35 run —rain, storm, day and night, mines, clock,
  the stones…—; the summons, the transformations, 30, 48, 49 and 52 do
  not. None of the transformations or summons could be reached.

The other four games build and reach their first map in snes9x and bsnes
(`just boot`, ports root).

### Cost

* **CPU**: an idle frame of the table, some two scan lines (measured with
  the line counter around the tick). Lost frames outside fades in ABL's
  walkthroughs, the same tree with `compar_tick` emptied against it: +23
  in 155,000 frames, +10 of them in the race's 5,400 and +6 in the other
  race; the rest 0 or 1. Counted with a throwaway pytest plugin that reads
  `lost_frames` after each frame and puts it back to zero.
* **ROM**: bank 0 gains four `jsl`s (map_events, set_switch, op_access,
  boot) and loses nothing; the rest is bank 1. `just space` for what is
  left.
* **RAM**: six bytes per entry and sixteen more, in `FARBSS`. Vampires
  Dawn has 53 bytes of `FARBSS` left with Chajá's conditions in.

### Tests

* `tests/rpgmaker/test_parallel_commons.py` (four), with ABL's own:
  2 without a switch prohibits saving; 8 enables it even after a page's
  `ChangeSaveAccess`; turning 236 off prohibits it on the next frame; 1
  opens its message as its owner, turns its switch off, stays frozen, and
  turning it on again goes on from there. Red with main's tools.
* The compiler's: three on loops, one on switches past the bitmap (red
  without the filter), one on `parallel_commons`' answer.
* `test_ag7_and_the_plant.py` waits a few frames after the menu, and
  `battle-113` a `Wait` between the switch and the battle: in RM2k the
  battle would not see the common event either.
* Menu tests turn 236 on (`SAVE_SWITCH`); eleven menu goldens moved,
  Save grey, 56 pixels each, looked at one by one.
* The battle flash test counts levels and not frames: see the draft
  `battle-flash-test-depends-on-the-cycles-before-the-battle`.

**What the suite does not cover**: no ROM test runs a `Loop`, a
`BreakLoop` or an `EndLoop` (only Vampires Dawn has them, and it has no
suite); nor a parallel common event across a map change, nor one with a
`Wait` resuming after a teleport, nor `ChangeEquipment` waking a pure one,
nor the `MenuCaller`/`Hauptmenü` of Sunset and Desert in play, nor
anything of Vampires Dawn beyond reaching its first map.

### Drafts

* `parallel-common-events-sound-only-where-the-map-carries-it`
* `vampires-dawn-transformations-dont-compile`
* `vampires-dawn-summons-dont-compile`
* `book-of-three-reraise-and-eilonwy-dont-compile`
* `abl-manage-quarry-timer-jumps-to-a-map-not-carried`
* `battle-flash-test-depends-on-the-cycles-before-the-battle`

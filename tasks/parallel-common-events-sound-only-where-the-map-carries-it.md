---
name: "A parallel common event's sound effect plays only where the map carries it"
description: "ABL's Raining runs on map 20 with switch 94 on, but its Rain1 every three seconds is silent: a common event's effects are noted in no map's audio package"
type: bug
status: doing
assignee: Mulita
agents: [Mulita]
---

Seen by Aguará on 2026-10-12, with the-advocate `6ed7c4a0` and the ports
`0e1d9ba` (`parallel-common-events-dont-run.md`), in ABL.

**What is seen**: common event 3, `Raining` —parallel on switch 94, which
map 21 turns on before sending the hero to map 20 in the rain—, runs: its
interpreter goes through its three-second `Wait` over and over. But its
`PlaySound Rain1` never sounds: in 600 ticks on map 20 with 94 on, no
effect starts on either voice.

**Why, as far as it was looked**: the bodies compiled without a map number
their effects but note them in no package, the same as the automatic
common events' shared bodies (`commons::compile`); an effect plays only if
the map's package already carries its sample, and map 20's does not carry
`Rain1`.

**How to see it**: `partida(caso="grupo-11-en-20", switch=[94])` and the
`arranques` of `tests/rpgmaker/test_sound_in_route.py` over 600 ticks:
empty. In the original the rain sound repeats every three seconds.

## Defined (2026-10-16, Carpintero)

Heard in ABL, the main game: the rain on map 20 is silent. **Done**: a
common event's sound effects are in the audio package of every map
where it can run —all maps, or those that can turn its switch on; the
agent picks and measures what each costs in ARAM—, and
`test_sound_in_route.py` hears `Rain1` start on map 20 with switch 94 on,
red before the fix. **First step**: where the packages collect a map's
effects, and how many common events with sounds each game has.

## How many and where (Mulita, 2026-10-20)

Parallel common events with a `PlaySound` of their own (a throwaway count
over each port's `data/`): A Blurred Line 1 (`Raining`), Vampires Dawn 18
—rain, thunder, the summons and the transformations—, Zounds 3; the other
five games none. Automatic ones with sounds: ABL 3, Vampires Dawn 7,
Desert Nightmare 5, Zounds 3, and one each in The Book of Three, Frozen
World and Sunset —menus, mostly—; those are not this task: the ones with
pictures are already copied into the maps that can start them, and compile
with them.

Which maps can **be** on with the switch is the closure of the teleports
from the ones that turn it on, and that is every map: ABL's switch 94 is
turned on in 20 and 21, and the closure from them is 302 of the 328 maps;
in Vampires Dawn it is all 440, as many of its switches are turned on by
skills. And `Rain1` goes whole in ABL, five seconds at 6 kHz, ~17 KB of
ARAM: in every package it would take that from every map's music. So the
rule is the one `common_pages.rs` already uses to copy the automatic ones:
**the maps whose pages can turn the switch on**, through the common events
they call, and every map if a switch item or skill, or a parallel or
automatic common event, can. ABL: maps 20 and 21. What is left out: a map
the party reaches with the switch already on and that does not turn it on
itself stays silent.

**A switch turned on right before a `Teleport`** —only instant commands
in between: switches, variables, the weather, comments— **counts for the
destination**: RM2k moves the party in that same frame (easyrpg's
`Scene_Map::UpdateStage2` starts the pending teleport after the map's
update, where the parallel common events already ran), so the common event
never runs on the map that turned it on. It is ABL's map 21: counted there,
`Rain1` went into its package and the map's song lost its guitar, trumpet
and organ from 22, 22 and 13 kHz to ~10, ~9 and ~10 kHz —measured, its
`audio.json` against `main`'s—, for a rain that never sounds there. With
the rule, only map 20's package gains `Rain1`, and map 20 had 45,698 B
free: no instrument moves.

## What it costs, per game (Mulita, 2026-10-20)

Each game's `release` built with the branch's tools against one built with
`main`'s, comparing `audio.json` and `audio-job.json` (throwaway scripts):

* **A Blurred Line**: only map 20's package gains `Rain1`; no music sample
  moves and no package loses anything.
* **Zounds**: `water3` —`Botella con Agua`, on switch 55, which an item
  turns on— goes into every package, and `fire3` into map 163's
  (`SONIDO DE PORTON`). The music bank does not move beyond a few Hz.
  `Envenenamiento`'s `heal8` does not go anywhere: its body does not
  compile.
* **Vampires Dawn**: the most expensive. Its rain and thunder (`Regen`,
  `Gewitter`, `Innenregen`: switches a common event turns on) and two
  spells' `Holy3` and `Cold10` (switches skills turn on) can sound on any
  map, so `Rain1`, `Rain2`, `Thunder`, `Holy3` and `Cold10` go into almost
  every package —before, `Rain1` was in one of the 433—. The shared music
  bank re-plans: of its 136 samples, 48 go down more than 10% and 12 go up
  more than 10%, the geometric mean of the rates is 0.93, and 43 are under
  8 kHz instead of 38. And three packages relieve themselves: map 240
  leaves out `Thunder`, `Cold10` and `Holy3`, map 4 leaves out `Holy3` —the
  common events' effects go last, so they are the first left out—, and map
  252's `WA-Zeik Battle` and map 140's `Battle_Fierce2` and `Angel` are now
  uploaded when their `PlayBGM` asks for them, with a pause.

Vampires Dawn is a first version to be heard: before, its rain was silent
on every map but one. If it costs too much, the knob would be per game
—which common events' effects go everywhere—, the way
`route_effects_left_out` is.

What is left out: a switch turned on **after** a `Teleport` in the same
page counts for the map that turns it on, not for the destination (Zounds'
map 58 does that with 111). And the automatic common events without
pictures have the same problem: draft
`automatic-common-events-sound-only-where-the-map-carries-it.md`.

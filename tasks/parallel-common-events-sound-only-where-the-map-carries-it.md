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

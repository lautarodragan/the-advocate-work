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

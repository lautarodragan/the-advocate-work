---
name: "What the compiler ignores silently"
description: "Every page field and command parameter ABL uses with a non-default value that the converter never reads: the features that compile but are not there, like trigger 2 and the movement types were"
type: research
status: done
assignee: taro
agents: [Cardón]
---

taro, on 2026-10-14: "that's what I want to know: what is in those silent
holes". The culprits report says every page of ABL's whole game compiles,
but in the same week two features were found missing that it could not
see, because the pages compiled anyway: the event's touch (trigger 2,
pages compiled empty) and the movement types 1–5 (ignored). This
measures that class: a field or a parameter the compiler never reads.

## Log

Done on 2026-10-14 by Cardón, tools `14e200fc`, ports `f775b66`. Nothing
was changed, built or run but the installed `rm2k-snes-events`.

**Method** (the full account is in the research,
[What the compiler ignores silently](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-14-what-the-compiler-ignores-silently.html)):
a mutation probe over the event compiler (every parameter slot the cartridge
uses, changed everywhere at once and then value by value, 272 slots and
4,212 runs for ABL, the same on the other seven games' own requests), each
slot that did not move the answer read against its arm and easyrpg, and a
search of the Rust for the fields outside the compiler's answer (page
fields, the maps' flags, the database).

**Found**:

* Page fields: nothing silent that ABL sets. `overlap_forbidden` (17 pages)
  is not read, and none of them belongs to an event that moves.
* Command parameters: 23 of 272 slots never moved the answer; ten are slots
  RM2k ignores too, ten were already written down, three are new.
* Outside the commands, two that matter: a map's save and escape flags
  (75 of 308 maps forbid saving) and the elemental attributes in battle
  (74 of 100 reachable enemies).
* Sixteen known silent things were found again, listed in the research.

**Drafts, one per new hole** (ABL's count in brackets):

* [`elemental-attributes-are-not-applied-in-battle`](elemental-attributes-are-not-applied-in-battle.md) (74 of 100 enemies)
* [`a-maps-save-and-escape-flags-are-never-read`](a-maps-save-and-escape-flags-are-never-read.md) (75 maps)
* [`playbgm-fade-in-is-dropped`](playbgm-fade-in-is-dropped.md) (3)
* [`a-forced-routes-repeat-flag-is-dropped`](a-forced-routes-repeat-flag-is-dropped.md) (6)
* [`the-timers-battle-flag-is-dropped`](the-timers-battle-flag-is-dropped.md) (1)

**Not drafted**: `overlap_forbidden`, the first strike of `EnemyEncounter`
(ABL sets none), the bush depth of a forest tile (149 cells on map 5).

**What it does not cover**: a value ABL does not use, anything outside the
event compiler's answer other than by searching the Rust, and whether any of
it is seen playing: none was played, so none went to a port's "Known
issues".

To merge: the book branch `cardon-silent` in the-advocate-docs (one commit,
the research and its `SUMMARY.md` line). Nothing to install.

---
name: "Zounds' map 114 event 13 may not work"
description: "On Cueva 5 (map 114) EV0013 —action key, no graphic, on switch 207: a sound, a wait, battle animation 194 on event 11, switch 206— may not do anything in the port"
type: bug
status: done
assignee: taro
agents: [Calandria]
---

taro, on 2026-11-02, in their words, translated:

> On Zounds' map 114, I'm not sure, but event EV0013 may not be working.

What Hornero read at ports c82effe: map 114 is "Cueva 5", 20x15. EV0013
is at (12,4), same layer as the hero, no graphic; page 1 on switch 207
(action key): `PlaySound` NAU_Mslash, `Wait` 1.0 s, `ShowBattleAnimation`
194 on event 11 (at (14,5), no graphic), switch 206 on; page 2 on switch
206, empty. Only map 114 itself turns on 207. `just culprits` lists none
of its pages, and the converter warns nothing for map 114.

**Done**: whether it works, played in the ROM from where the game turns
207 on; if not, why, fixed or written down. A ROM test in Zounds' tests
if the suite can reach it.

## It works (Calandria, 2026-11-02)

At ports c82effe and the-advocate 244f4013 —the build taro has in
`/shared/builds/zounds/`—, in snes9x and bsnes, and the same in EasyRPG
Player 0.8.1.1 with the game at `~/juegos/zounds` untouched:

* **How the game reaches it**: map 113 (and 124) door onto map 114 at
  (7,12). Event 12's page 1, autostart and unconditional, is the voice: it
  walks the hero up to (8,5), under the door, tells where the lever is
  ("to the right of the light that is to the right of this door") and ends
  with switch 207 on. Nothing else in the game touches 206 or 207, not even
  common events.
* **Where the lever is reached from**: the door is event 1 at (8,4), the
  lights are at (5,4) and (11,4), and the lever, event 13, at (12,4). The
  light's column also blocks (11,5), so walking right along row 5 from the
  door stops at (10,5): the lever is faced from (12,5), reached from below
  through (12,6). Same in EasyRPG (the hero stops at (12,5) walking left
  from (13,5)).
* **What A does there**, measured in the port: NAU_Mslash starts on the
  tick of the A (sample 184), the second's wait, battle animation 194 drawn
  over the rocks with its own two effects (samples 187 and 189, ticks 59
  and 89), and switch 206 on at ~119 ticks. Battle animations are drawn on
  map 114 (the converter: "64 tiles from 192, palette 4").
* **What 206 changes**: events 10 and 11, the two rocks drawn from tile 59
  at (14,6) and (14,5), go to a page with no graphic below the hero, and
  the stairs behind them, events 8 and 9 at (15,5)/(15,6), lead to map 115.
  Event 1's page 3 makes the door say "¡Rescátenme rápido!" instead of the
  hint. Without A, the hero walking right from (13,5) stays there, in the
  port and in EasyRPG; with it, both reach map 115.

The original game has no bug here. If taro did not find it, a guess, not
measured: the lever has no graphic and the light's column makes row 5 a
dead end from the door, so it is only found going round below.

Captures, the port and EasyRPG side by side:
`/shared/captures/2026-11-02-zounds-map-114-lever/`.

**Test**: `tests/test_zounds_map_114_lever.py` in the ports, from the debug
room, jumping to map 114's door with 207 off: the autostart turns 207 on,
the rock blocks before the lever, A under the lever plays NAU_Mslash and
turns 206 on, and walking right leads to map 115. It was never red, since
nothing was broken; with the A taken out it goes red at "switch 206 is
still off".

**When merging**: the ports' `calandria-map-114` (one new test file).
Nothing to install: no tool or runtime changed, so no golden moved and
ABL's suite and `just boot` were not run.

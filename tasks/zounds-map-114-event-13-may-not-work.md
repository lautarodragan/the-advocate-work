---
name: "Zounds' map 114 event 13 may not work"
description: "On Cueva 5 (map 114) EV0013 —action key, no graphic, on switch 207: a sound, a wait, battle animation 194 on event 11, switch 206— may not do anything in the port"
type: bug
status: doing
assignee: Calandria
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

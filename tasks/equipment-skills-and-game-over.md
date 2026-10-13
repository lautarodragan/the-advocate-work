---
name: "Equipment, skills and Game Over"
description: "ChangeEquipment, ChangeSkills and GameOver, which were blocking the rooftop and the Workshop"
type: feature
status: done
---

**Implement `ChangeEquipment` (10450), `ChangeSkills` (10440) and `GameOver` (12420).**

Today none of them compiles, so the whole page that uses them doesn't run:

- the `Craftsman` in `Sector 27 Workshop` (map 30, event 1): `ChangeEquipment [0, 0, 1, 0, 0]`;
- the rooftop cutscene in `Sector 27 Warehouse` (map 32, event `EV0005`, and
  events 23 and 25): `ChangeSkills [1, 14, 0, 0, 133]`, `ChangeEquipment [1, 25, 1, 4, 0]`
  and `GameOver`.

Done means: those pages compile and run, with cases in `tests/cases/`.

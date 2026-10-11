---
name: "The goldens of the Neon Vipers playthrough"
description: "The shots of the vipers playthrough have no golden, so they always pass"
type: test
status: todo
assignee: taro
---

`pruebas/abl/test_recorrido_vipers_golden.py` takes its shots, but none
has a golden, and a shot without a golden always passes (`pruebas/arnes/recorrido.py`,
on purpose: nobody blessed it). Until they are frozen, the playthrough checks
what it looks at in RAM but not what is seen.

**It is blocked on taro**: freezing them is saying "this is how it has to look", and
he decides that by looking at the shots. What's needed on this side is to leave him
the current shots in `/shared/goldens/<fecha>-vipers/` so he can look at them; with
his ok, they are copied to `pruebas/golden/` in a commit that says he looked at them.

**Careful before freezing them (2026-09-26):** the game started through "Begin the Story" has DummyHero as leader (actor 10, with no graphic), so in the shots of `test_recorrido_vipers_golden.py` Talan doesn't appear, at least in the HQ. The new test in the other branches solves it with `poner_grupo(14)`; this one would need the same line before taking the final shots.

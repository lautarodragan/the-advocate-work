---
name: "Experience and levelling up"
description: "Gaining experience, levelling up and growing according to the LDB's curves"
type: feature
status: done
---

**Experience and levelling up.**

Today they do not exist: each actor stays at the LDB's `initial_level` and
learns the skills of that level (`batalla.habilidades_de`). What is missing is
gaining experience when winning a battle, levelling up with the LDB's
experience curve, and, on levelling up, HP, SP, attack, defence, mind and
agility growing according to each actor's parameter curves, and the skills of
the new level being learned.

Reference: EasyRPG's `Game_Actor` in `/extras/ref/easyrpg-player`. Taro asked
for it on 2026-09-21.

Done means: a battle won gives experience, an actor levels up and its numbers
grow as in RM2k, and all of that travels in the saved game.

## Where it stood, on 2026-09-21

What "done means" asks for is there, with cases that run the ROM in
`tests/rpgmaker/test_experiencia.py`. What was left out:

- **The victory says nothing**: RM2k shows "N EXP received", "<nombre> Level
  up!" and what was learned (`PushExperienceGainedMessage`, `ChangeLevel` with
  its `PendingMessage`), and here the battle still says only the victory term.
  The state changes anyway; what is missing is telling it. It moves the
  suite's end-of-battle screens.
- **`ChangeExp`, `ChangeLevel` and `ChangeParameters` are not there**, because
  the game does not use them: no map, common event or troop in `data/` names
  them, and no branch asks about an actor's level. Nor the `*_mod` of
  `ChangeParameters`, for the same reason. If any of them shows up,
  `exp_sumar` is the half of `ChangeExp` that goes up; going down a level also
  asks for capping HP and SP, which is easyrpg's `SetLevel`.
- An actor that cannot join the party has no experience: only those fight.

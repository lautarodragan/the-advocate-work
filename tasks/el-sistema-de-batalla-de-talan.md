---
name: "Talan's battle system"
description: "Detect Aura and Absorb Aura run their troop's pages"
type: feature
status: done
---

**Talan's battle system: `Detect Aura` and `Absorb Aura` in battle.**

It is the first stretch of `eventos-de-tropa-en-la-pelea.md`, narrowed to Talan: if it works,
the mechanism is proven and the other 31 systems are a matter of completing commands.

Both skills are of the switch type (3), battle-only and with no SP cost:

- `Detect Aura` (133) turns on switch 134 (`DetectedAura`);
- `Absorb Aura` (134) turns on switch 135 (`AbsorbedAura`).

Each switch triggers a page in 142 troops:

- **134**: 7 distinct bodies, and they only use commands the port already has
  (`ChangeSkills`, `ShowMessage`, `ControlSwitches`, `ControlVars`);
- **135**: 86 distinct bodies, and they add the only new command needed:
  `ConditionalBranch_B`, the battle one.

What's missing: that a switch-type skill can be used in battle and turn on
its switch, that the troop pages watching it run —with their messages in the
battle window—, and `ConditionalBranch_B`.

Done means: in a battle, Talan uses `Detect Aura` and then `Absorb Aura`, and what
happens in RM2k happens, with a test that walks through it.

Reference: EasyRPG's `Game_Battle::UpdateEvents` and `Game_Interpreter_Battle`.

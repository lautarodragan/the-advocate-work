---
name: "ShowBattleAnimationB in troop pages"
description: "The battle animation on a monster is not in the troop pages' command list: it keeps out Taran's Last Stand in 52 troops and the two scripted endings of The Book of Three (the Cauldron-Born at map 26, the Horned King with Dyrnwyn at map 78), which may leave those fights without an end"
type: feature
status: draft
---

Seen by Calandria on 2026-10-14, with the-advocate `14e200fc` and the ports
`f775b66`, measuring what The Book of Three leaves out
([research](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-14-book-of-three-and-frozen-world-left-out.html)).
**Read in the data, not played.**

**What is seen**: `ShowBattleAnimationB` (13260) is not in `TROOP_COMMANDS`
(`rm2k-snes/events/src/troops.rs`), so any troop page with one is left out.
Book of Three has 56 uses, no other game any:

* 52: the Last Stand page of troops 83 to 135 (with
  [`changeitems-and-changemonsterhp-by-a-variable`](changeitems-and-changemonsterhp-by-a-variable.md));
* 3 in troop 96, **three Cauldron-Born** (map 26, event 10, a fixed fight):
  page 11, at turn 6, is Gwydion's "Summon... BLAZING STAR!" (animations 128,
  129, 130) and ends the battle with `TerminateBattle`. Page 9 says they
  "cannot be killed" and page 8 heals them. Without page 11 the fight can
  only be won by killing them, which the story says cannot be done;
* 1 in troop 136, **the Horned King with Dyrnwyn** (map 78, event 6): page 1,
  on the enemy's HP, plays Dyrnwyn (117) and ends the battle.

**Not looked at**: whether the player can flee from those two fights, and
what happens when the party loses.

**What it would take**, as a measurement: accepting the command as a declared
debt (no animation, a wait) lets the two ending pages in and ends both fights
at the cost of the animation; drawing one needs the battle scene to play an
animation on a monster, which it does not do for anything today (see
[`animations-in-battle`](animations-in-battle.md), for the skills').

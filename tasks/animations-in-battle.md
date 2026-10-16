---
name: "Animations in battle"
description: "The animation_id of skills and weapons, drawn over the scene"
type: feature
status: wishlist
---

# What

Have a skill —the party's or an enemy's— draw its `animation_id` over
the battle scene, like `Game_BattleAlgorithm::GetAnimationId`. Today none is
drawn: neither the seven of the intro's party nor `ShortCircuit` (number 62),
which milestone 4 of Lashe City (`lashe-4-ag7-in-battle.md`) asked for.

# Status

Noted on 2026-09-27, not started. It was left out of milestone 4 for size: it
is a new subsystem inside the battle, and the milestone's mechanics didn't
depend on it.

# What is known

The drawing of animations exists **for the map** —`OP_ANIMATION`,
`rom/src/animacion_de_batalla.s`—: four 32x32 objects in a 64x64 box,
a sprite palette and the frames uploaded by DMA in vblank. In the
battle none of that runs, and what it would take, looked at on 2026-09-27:

* **VRAM**: the battle uses from `$2000` onwards —the text, its two tilemaps
  and the 32 KB of the scene— and leaves `$0000`-`$1FFF` free, which is
  enough for the box's 64 tiles with `OBSEL` pointed there.
* **CGRAM**: the scene hands out **one palette per distinct battler from 8
  on** (`ESC_PAL_N` in `batalla_escena.s`), which are the objects' ones. With
  a troop's battlers the upper ones stay free, except in a troop of eight
  distinct battlers.
* **The screen**: `TM` turns on only BG1 and BG2; objects would have to be
  turned on and OAM built in the battle loop, which today doesn't touch it.
* **The time**: the action's message lasts `BA_MSG_CUADROS`, and the animation
  would have to fit inside it or stretch it.
* **The cartridge**: an animation is tens of KB (number 77, 40 KB), and the
  cartridge carries only those some map's `ShowBattleAnimation` asks for.
  Number 62 is already there (`patches/auto/animations/0062.toml`); of those
  from AG7's skills —1, 118, 145, 78, 8, 95, 119, 30, 93, 60, 38, 115, 151—
  only 1 and 78.

# Why

It shows. taro confirms it by playing: today a skill is a message and a number
going down.

## Checked on 2026-10-16

At the-advocate `759aa0ba`, by Cardón: still not started —no battle code
reads a skill's or weapon's `animation_id`—. Names above that moved with
the translation and the moves since: `rom/src/animacion_de_batalla.s` is
`runtime/battle_animation.s` (and `battle_animation_frames.s`),
`batalla_escena.s` is `runtime/battle_scene.s`, `ESC_PAL_N` is
`SCN_PAL_N` and `BA_MSG_CUADROS` is `BA_MSG_FRAMES`
(`runtime/battle_loop.s`); the patch is `abl/patches/auto/animations/0062.toml`
in the ports. Related since 2026-10-14 (`e36ff5d8`): a troop page's
`ShowBattleAnimationB` compiles as a wait, a declared debt, not drawn.

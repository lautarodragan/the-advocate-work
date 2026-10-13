---
name: "A jump that fails doesn't turn the hero"
description: "RM2k sets the jump's direction before checking whether it can land; the ROM only if it can"
type: bug
status: done
assignee: taro
---

It showed up while reading the gate of map 12 —event 1 at (1,47)— for
`tests/abl/test_playthrough_vipers_other_branches_golden.py`, and **it isn't
visible in any covered case**: there the hero is already facing down when
the jump fails.

In easyrpg, `Game_Character::Jump` sets the direction —and the `facing`, if
it isn't locked— **before** calling `MakeWay`, so a jump that can't land
leaves the character facing where it wanted to jump. In the ROM,
`armar_salto_heroe` only calls `direccion_del_salto` in `se_puede`: if
`puede_caer` says no, the hero stays facing as he was.

Besides, RM2k, with the route lacking "skip if it can't", **retries** the
jump; the ROM skips it, and that one is on purpose —`paso_de_ruta`'s comment
says so—. What's missing is only the turn.

Done means: a case with a jump blocked towards a side different from the one
the hero faces, which checks `hero_dir` afterwards, seen red before the fix.
The events' jumps need looking at too, since they have their own setup.

# What was done (Guanaco, 2026-09-30; the wrap-up, Hornero)

Hornero writes it with Guanaco's report: auto mode's classifier denied
Guanaco reading this file, and also regenerating the frames that were left.

**Confirmed in easyrpg** (`Game_Character::Jump` and `UpdateMoveRoute`),
for the hero and the events: `Jump` sets the direction —and the `facing` if
it isn't locked— before `MakeWay`. If the jump fails and the route can't be
skipped, RM2k retries it and the turn stays; if it can be skipped, RM2k
restores the direction and the `facing`. The ROM receives every forced route
as skippable and doesn't tell them apart, so it always turns: of the game's
410 forced routes with a jump, only 6 are skippable and none is the hero's.
The code's comment says so. **It wasn't confirmed with RPG_RT under Wine**:
it required building an RM2k map with the jump blocked.

**The fix** (`7fd79fa6`, `tools/runtime/oam.s`): in `build_hero_jump` and
`build_ev_jump` the turn goes before `can_fall`, and the events' one also
looks at the locked-direction bit (+18 `$08`). A second bug came up while
writing the locked case: the ROM turned a locked event even if the jump
landed fine. It was fixed in the same commit.

**The tests** (`rom/pruebas/rpgmaker/test_salto_bloqueado.py`), all four
against the edge of map 6: the hero (he ended up facing up instead of left),
Kersh (down instead of up), Kersh locked with a jump that lands (right
instead of down) and Kersh locked with one that doesn't land, which already
passed. The first three, red before the fix.

**The goldens**: the droid of map 2 (EV0040) has a fixed direction facing up
and jumps downwards; the ROM left it facing down after each jump and now it
keeps facing up. Twelve frames of `block`, `droid` and `droid-covered`
change, only in the droid: three in `915a4801` (Guanaco) and nine in
`255c7252` (Hornero, looked at one by one). The before and after are in
`/shared/captures/2026-09-30-salto-que-falla/`. **The merge awaits taro's
approval.** (The message of `915a4801` says those three are all that
changes, and the one of `7fd79fa6` names only three frames: both fell
short.)

**When merging**: no Rust to install. The ROM moves, so the music ceilings
may need measuring again; `test_music_ceilings.py` passed on the branch.

**What's left**: the divergence of skippable routes, where RM2k restores the
`facing` and the ROM doesn't; and the same with an event's blocked
`move_*`: the ROM keeps the turn and RM2k undoes it. Not touched.

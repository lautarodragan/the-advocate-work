---
name: "The menu like RM2k"
description: "The experience in the menu, the enemies' HP in battle and the colour of the number that changes when equipping"
type: feature
status: done
assignee: Tero
---

# The menu like RM2k

What taro asked for, on 2026-09-28, in their words, translated:

> - the menu should show how much experience each hero has and at how much
>   they reach the next level
> - battles don't show the enemies' hp in the original. I don't know if
>   there's some technique or item that lets you see them, or if it's always
>   impossible. I don't know whether to remove the feature completely or leave it
>   hidden
> - on the equip item screen, the original game shows the number
>   that would go up in another colour (yellow, I think). it may use red or something if
>   it would go down — I don't know

The three were looked at in easyrpg-player and in the original running under Wine
(the 2015 RPG_RT), with a copy of the game whose map 4 starts with Kersh and
Core in the party and the tests' items in the inventory: that way you reach the
menu without playing the intro. The captures are in
`/shared/captures/2026-09-28-el-menu/`.

## 1. The experience in the menu — done

**Where RM2k shows it**: only in the main menu. 2000 has no
status screen —that's 2003's—, and the actor choice
(`Window_ActorTarget`) doesn't show it. In each actor's row it's the third
line: `Ex 14522/ 16708`, the term `exp_short` in colour 1 and
`"%6d/%6d"` —the current one and the accumulated one the next level asks for,
`GetNextExp`— (`Window_Base::DrawActorExp`). At the cap, dashes: easyrpg
puts them only in the second half, and its comment says RPG_RT puts
them in both; we follow RPG_RT. The original, captured, gives Kersh
`14522/ 16708` and Core `6473/ 7750`, and the ROM gives those numbers.

**How it goes**: in sprites, twelve pixels below the HP and in the font's
six pixels —RM2k's exact format—. It's the only thing on the screen outside
the cell grid, and the why is in `MENU_EXP_X` (titulo.py): in 256
pixels RM2k's two columns with eight-pixel letters don't fit, nor a fourth
line of cells in the row's 56 pixels. The routine is
`rom/src/experiencia_en_el_menu.s`.

What's still different, cosmetic and already declared in the menu: without the
actor's title or the SP, and the HP below the level and not to its right.

## 2. The enemies' HP in battle — investigated, not implemented

**RM2k never shows it.** In 2000 the target choice is a list
of names (`Scene_Battle_Rpg2k`), and there's no event command that draws the
HP of an enemy.

**ABL doesn't have a way to see it either**, measured over `data/`:

- no `ControlVariables` in maps, common events or troops reads the HP of
  an enemy (operand 8, "enemy", doesn't appear even once), so no
  message can say them with `\V[]`;
- no troop or common event message names them: the ones that say "HP"
  are about items you gain or party heals;
- the only skill that "looks at" the enemy, `MindProbe` (144, Manta's), is of
  switch type and what it turns on is learning its techniques, not seeing its HP;
- no item does it.

**Where the ROM draws it**: in `ba_renglon` (`rom/src/batalla.s`), which writes
each combatant's line: the name, "HP" and the number, and the bar with the
maximum only if it's the party's —bit 0 of `BA_CONMAX`—. The geometry is
`BA_HP_COL`/`BA_HP_NUM` in `screens.py`, and the decision to show it is
written right there, above `BA_ENEMIGO_FILA0`: *"se ven los HP de los
enemigos. RM2k no los muestra. Acá sí, porque lo que esta vuelta tiene que
dejar ver es justamente la mecánica"*.

**Proposal**: hide it by default, like the original, with a build flag
for debugging, just like `CON_MAPA_DE_DEBUG`:

- `CON_HP_DE_ENEMIGOS = False` in `tools/ensamblado/cartuchos.py`, which passes
  `--hp-de-enemigos` to the converter; the converter emits `BA_HP_ENEMIGOS = 0/1`
  next to `BA_HP_NUM_DX`;
- in `ba_renglon`, after the name: `.if BA_HP_ENEMIGOS = 0` / `lda
  BA_CONMAX` / `and #$01` / `bne` to the "HP" / `rts` / `.endif`. It's seven bytes
  in the battle bank with the flag off and zero with it on; bank 0 isn't
  touched;
- `screens.py` the same in the battle screen's reference, with the
  same flag;
- it moves all the goldens where the enemy list is visible —the `batalla*` ones
  for sure; the rest the suite will say—, so it goes in a commit with its
  why.

It's cheap, but **I didn't implement it**: there's another agent in the battle
(`batalla*.s`, `battle.py`, `eventos.py`) and we'd clash precisely in those
goldens. It's left for after that gets merged.

## 3. Equipping: the value that changes, in colour — done

`Window_EquipStatus::GetNewParameterColor`: the value it would become goes in
colour 0 if it's equal, in 2 if it goes up and in 3 if it goes down. In ABL's skin
2 is a peach (not yellow) and 3 the "can't" grey. The capture of the
original confirms it: with the Leather Jacket instead of the Trenchcoat, defence
`147> 55` in grey, agility `82> 85` in peach, attack and mind in
white. The ROM's colours and the original's match at 15 bits.

The screen's font carries variant 2 **only with digits** (`ITEM_SUBE`
in titulo.py): the whole font in one more colour didn't fit, because the bank
has a ceiling that the battle imposes —`ITEMS_TILES_MAX`—.

What the original has and is still missing here, cosmetic: the terms of the
parameters and of the slots in colour 1 (red), and the `>` arrow also
while choosing the slot, without the new value.

## Tests

- `menu`, `menu-2` change —the experience line—; new `menu-party`
  (case `menu-party`: Kersh, Core and Talan).
- `equipment-list` changes —the Bow's 95, which goes down, in grey—; new
  `equipment-rises-low` and `equipment-rises` (case `equipment-colors`).
- `test_the_menu_shows_dashes_at_the_top_level`, the cap path.
- `render_menu` draws the experience, and the tests that compare the menu
  after levelling up or fighting pass it the game's.
- The music ceilings were re-measured (`just ceilings`): the ROM
  change shifted `dcbest`'s peak until it clipped, as the test warns
  can happen with any change.
- Verified with `just cartridges` and `just tests` on merged `main`: all
  green.

## What taro has to look at

- Open the menu with the intro's party and with more than one: the "Ex" line
  below the HP, that it reads and doesn't run into the row below.
- Win a battle and open it again: the experience goes up; if they level up,
  the second number changes.
- Equip something that goes up and something that goes down: peach and grey.
- Close the menu: the hero and the NPCs with their usual colours (the menu's
  sprites borrow a palette from the map).

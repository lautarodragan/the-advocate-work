---
name: "SP items in battle and the pills"
description: "In battle the items that recover SP can't be used, and the Agility Pill can't be used anywhere: medicines with SP and type 8 items (the ones that raise attributes)"
type: bug
status: testing
assignee: taro
agents: [Mulita]
---

From taro, on 2026-10-04: "I can't use items that recover SP in battle, and
I can't use the Agility Pill in general".

In ABL (dump, `data/db/items.json`):

* medicines (type 6) with SP: 3 Magic Ether, 4 Miracle Drop, 8 Pocket
  Shelter, 103 Cheap Wine-SP, 107 Bottle of Health, 125 Bottled Water-SP,
  129 Motor Oil-HPSP, 258 Recharge Draught-SP;
* type 8, the ones that raise attributes: 10 Apple, 11 MP Apple, 12 Powr-Up, 13
  Defensive-Up, 14 Mind-Up, 15 Speed Up, 109 Agility Pill-AGL, 134 Vitality
  Pill-MHP, 259 Agility Potion-AGL, 260 Strength Potion-ATK (these last
  two also heal HP).

## Mulita, 2026-10-04

Tools from `43b2c5a5`; ABL in the clone `/extras/scratch/mulita/abl`,
branch `mulita-items`, from `88c00a4`.

### Why

* **SP medicines in battle**: `item_usable_in_battle`
  (`rm2k-snes-battle`, `rules.rs`) asked for `recover_hp` or `recover_hp_rate`.
  The blame gives `e9441441` (the battle to Rust), which copied it from Python; `git
  log -S` leads to `72109da8` (2026-09-12, "`Use Item` anda"), which says it
  in the message: "Quedan afuera las medicinas de SP […]: los SP no son
  estado". They stopped being true with skills (2026-09-13) and nobody
  went back to the rule. The ROM also didn't know how to restore SP in battle.
* **Materials (type 8)**: they were never implemented. `item_usable` in
  `rm2k-snes-screens` (`2b017b2e`, which comes from `0b060661` and `ced94647`)
  only allows using medicines and switches; `items-screen-like-the-original`
  noted it: "materials […] go greyed out […] because the ROM doesn't yet
  know how to use them".

### What RM2k does (easyrpg)

* Medicine in battle: `Item::vExecute` restores HP and SP; the result
  message is one per parameter, each one in the place of the previous
  (`ProcessBattleActionParamEffects`), and the SP one only if it restored something. Before that
  it looks at `IsItemUsable` (the `actor_set`).
* Material: `Game_Actor::UseItem` on a standing one adds the six
  `*_points` to the actor's `*_mod` and returns that it worked; on a fallen one, nothing.
  **It doesn't read `recover_*`**: the Agility and the Strength Potion carry
  `recover_hp_rate` 75 from when they were another type —the editor keeps the fields
  it hides—, and RM2k doesn't heal with them. It was done like RM2k: they raise, they don't heal.
  `IsItemUsable` says no in battle: they don't go in its list.

### What was done

* SRAM goes to 32 KB, one slot per bank: ABL's save was at
  1983 of the 2038 bytes of a 2048 slot, and the materials part is
  12 bytes per actor who fights (216). See `SRAM_STRIDE`.
* The battle: `item_usable_in_battle` with SP; `ba_item_use` restores SP
  (`ba_item_sp`); the percentage is computed in two halves (`ba_rate_of`), so
  it doesn't go past 16 bits with a maximum of more than 655; the cursor of whom
  it targets looks at the `actor_set` (the Motor Oil is the droids'). The message: the HP
  line if the item heals HP, otherwise the SP one; with both, the SP one in a
  message of its own afterwards (`BA_MSG_ITEM_SP`). The Rust model restores SP and
  looks at the `actor_set`.
* The menu: materials go in white and open the actor choice;
  `medicine_use` adds them to `FAR_GROWTH` —six words per experience
  slot— from the converter's `item_up` table, and `level_param`
  adds that, with RM2k's ceilings: that way the menu, the equipment and the battle see it.
  It travels in the save and starts at zero. The choice is redrawn in full
  after a material, because it can change a maximum.

RAM: `FAR_GROWTH`, `$7E7D00`-`$7E7EEF` (uses `EXP_K * 12`, 216 in ABL);
`BA_MHPLINE`, `BA_MSP`, `BA_MSP_NEXT` at `$7E7851`-`$7E7854`, inside what
already belonged to the item message (`$7E7850`-`$7E785F`). Opcodes: none.

### Verified

* A Blurred Line's whole suite, with the tools from this branch (`battle`,
  `screens`, `mapdata`, `convert`, `cartridge`) and the clone's `mulita-items`
  branch, both with `main` merged: **1094 green**. Ten new
  tests (four in `test_battle.py`, six in `test_materials.py`), all
  red with the tools from `main`. **No golden changed**.
* `cargo test` of `rm2k-snes-battle`, `-screens`, `-mapdata`, `-convert` and
  `-cartridge`; `just -f tools/justfile test`: 27. In the same run
  `wally`'s `the_layers_are_the_ones_the_python_made` fails, which doesn't depend on
  anything this branch touches: inherited, not bisected.
* What the suite doesn't cover: the SP of an item that revives a fallen one (in ABL
  the only one is the Pocket Shelter, which isn't usable in battle), a material that
  lowers a maximum, and that the redrawn choice looks right —it is looked at by playing—.

### When merging

Reinstall in the global `battle screens mapdata convert cartridge`
(`cartridge` because of the runtime). Old saved games don't load.

## For taro

In battle, use the Magic Ether or the Bottled Water-SP and watch the SP go up;
the Miracle Drop shows two messages, HP and then SP. In the menu, the
Agility Pill (and the other materials) go in white; using it raises
agility forever —it shows in the equipment and in battle—. The Agility and the
Strength Potion don't heal: RM2k doesn't either, the `recover_hp_rate` they carry is
a leftover from the type they had before.

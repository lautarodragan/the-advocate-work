---
name: "The battle menu like RM2k's"
description: "The whole battle menu and text in the bottom strip, on black, like RM2k: the commands on the left, the party on the right, the list of enemies, items and skills below and the description above; without the Engage/Automatic/Escape menu, with Escape as a fifth option"
type: feature
status: done
assignee: taro
---

From taro, on 2026-10-04: "the battle menu. Today it's very different from
the original. In the original, all the menus and text appear at the bottom of
the screen". His decisions:

* No text over the background or over the enemies: the enemies' names go in
  a list on black, below. The bottom strip can be in another mode (HDMA)
  while the top stays in 3.
* Without the initial Engage / Automatic / Escape menu. Each character's
  commands: Attack, Special, Defend, Use Item, and **Escape as the fifth**
  (chosen by taro on 2026-10-04), only in battles that can be fled: an
  addition of RPG Maker 2000 PLUS.
* The party's status, one line per character: `Talan  Normal  HP 49 / 49
  SP 46`.
* Use Item and Special: the list in that strip and the description above.
  Attack: the list of enemies on the left, with no movement.
* The original's horizontal slide is optional: if it gets complicated, a
  first version without it.

## Cardón, 2026-10-04

Tools worktree from `d06a5779`; ABL in the clone `/extras/scratch/cardon/abl`,
branch `menu-de-la-pelea`, from `5b29ba9`.

### The original, looked at

With Wine, in the 2015 runtime's battle test (`RPG_RT_2015.exe BattleTest
ShowTitle Window <tropa>`, without playing up to an encounter), troops 82 and
87. The bottom strip is 80 of 240 lines, on black; above, the scene with
nothing on top. What's seen, from left to right:

* **choosing the order**: the party on the left (`Talan  Normal  HP 49/ 49
  SP 49`, one line per actor, the one choosing highlighted) and the orders on
  the right, four rows;
* **Attack**: the list of enemies covers the party's name and status; the HP
  and SP are visible;
* **Use Item / Special**: the list in two columns of four rows (`Potion   :
  99`, `Memorize   -  5`) takes the whole strip, and the description goes in a
  32-line window at the very top, covering the scene;
* **the messages** ("attacks the enemy" / "health lost." / "collapses!") and
  the **victory** go in a full-width window, from top to bottom, and nothing
  else is visible.

The screenshots, in `/shared/capturas/2026-10-04-menu-de-la-pelea/original/`.

### The plan

* The bottom strip **stays in mode 3**: the text is already 4bpp BG2 on the
  black the 128-line scene leaves, and the 447 pairs are enough. Without the
  slide no other layer is needed; a mode change via HDMA would require another
  tilemap and other tiles for nothing.
* The strip's rows, on the **odd** rows 17 to 25: five of 16 lines, with 10 of
  headroom above and 8 below.
* The description, in a 32-line strip at the top: the first four tile rows of
  the scene's tilemap switch to the transparent tile while a list is open, and
  come back when it closes.
* Escape, fifth, only if the battle allows fleeing: `escape_mode` other than 0
  in `EnemyEncounter`, always in a random encounter (easyrpg's
  `args.allow_escape`). It travels in `OP_BATTLE`'s escape destination, which
  with `escape_mode` 0 is never used.
* Fleeing belongs to the party, as in RM2k: whoever picks it tries; if it
  fails, the turn's orders are forgotten, the message appears and the enemies
  act (`ProcessSceneActionEscape`, `eFailure`).

### Done

Tools, branch `worktree-agent-a299fc4e75fe398cc`:

* `Compilador: una pelea de la que no se puede huir lo dice en OP_BATTLE`
  —`BATTLE_NO_ESCAPE`, $FFFE, in the escape destination with `escape_mode`
  0—.
* `Pelea: las ventanas en la franja de abajo, como RM2k, y Escape del grupo`
  —the runtime, `rm2k-snes-battle`'s geometry and the converter—. What was
  asked to be split (the windows, the orders and Escape, the Rust model) goes
  in a single commit: they share `ba_compose`, `battle_run.s`, `far_ram.s` and
  `model.rs`, and separately the ROM didn't build. There was no mode change.

ABL, branch `menu-de-la-pelea` of the clone `/extras/scratch/cardon/abl`: the
tests in one commit and the goldens in another.

What remained:

* The strip **stays in mode 3**; the **slide wasn't done**.
* The cursor is still ">": Tijereta's bar (`window_bar`, and
  `rm2k_render::system::cursor_over` on the converter's side) is composed into
  the message window's tiles, and the battle's text is BG2 with no background,
  on top of the 8bpp scene, without a free layer below. The bar would require
  the strip in another mode via HDMA —mode 1 leaves 4bpp BG1 and BG2 and
  BG3—, which is the next step if wanted.
* What isn't the same as the original is in
  `workflow/divergencias/lo-que-el-menu-de-la-pelea-no-modela.md`, and Escape
  in `workflow/divergencias/escape-es-la-quinta-orden.md`.
* The victory splits its term by letters (31) and not by pixels: "The combat
  has resulted in victory!" goes on two rows.
* With ABL's font and +1, the converter warns that three actor names get cut
  (DummyHero, Gang Member, MobilizedCar: none is in the party), seven skills
  and four items —"Pungent Elixir-LIFE", "Jumper Cable-LIFE",
  "HerbSproutSalad-HP", "Healing Draught-HP"—: two columns of twelve cells,
  which is what RM2k also allows.

RAM: `$7E3CB3`-`$7E3CB7` (`FAR_BATTLE + 691` to `+ 695`). VRAM: nothing new
—the description's strip is the scene's tilemap pointed at the transparent
tile—. Opcodes: none.

### Verified

* ABL's suite with this tree's `battle`, `events`, `mapdata`, `convert` and
  `cartridge`: **eighteen goldens** change, all from the battle, looked at
  side by side; repeated until no new red appeared (the two `msu-*-msu`
  appeared in the second round, because their test stopped at the first
  golden): **1072 green**.
* Two new tests: `test_huir_es_del_grupo` and `test_sin_huida_no_hay_escape`.
* `cargo test` of `rm2k-snes-battle`, `-events`, `-mapdata` and `-convert`;
  `just -f tools/justfile test`: 27.
* What the suite doesn't cover: the scrolling of the enemy list —no test troop
  has more than five— and the item that goes back to the inventory with a
  failed escape.

## For taro

A battle that can be fled and one that can't; the item and skill lists with
the cursor going through them; Attack with several enemies; Escape, and that
if it fails only the enemies act. The screenshots, with the original under
Wine alongside, in `/shared/capturas/2026-10-04-menu-de-la-pelea/`.

The second round, below, replaces what needs reinstalling.

## Cardón, second round, 2026-10-04

What the coordinator asked for after comparing with the original: the party on
the left and the orders on the right; the System's windows with their border
and the cursor bar; the victory split by pixels.

### What was done

* **The windows go on BG1, the scene's layer, in mode 3**, on the tilemap rows
  the scene doesn't use. Mode 1 via HDMA in the strip was asked for; it wasn't
  done because in mode 1 BG1 needs a palette between 0 and 7, and in battle
  they're all taken (text and the background's 96 colors). In 8bpp the windows
  use the battlers' last palette: a troop is limited to seven distinct
  battlers (ABL uses three at most; the converter refuses with eight). BG1's
  horizontal scroll per strip does go via HDMA (channel 5), so the shaking
  doesn't move the windows: looked at by hand in the agents' battle.
* **VRAM**: the text, from 447 pairs to 255 (words 0 to $1FFF; ABL's widest
  list asks for 170); the windows, at $2000-$37FF: ABL uses 34 tiles of 192
  and 4 colors. See `docs/port/vram.md`.
* The bar: `rm2k-snes-screens`'s `Skin::cursor`, which is Tijereta's
  `cursor_over` in rm2k-render; the windows are drawn in the converter
  (`battle.rs`) and the ROM puts them in during vblank once the text is ready.
* The victory is split with the game's font: "The combat has resulted in
  victory!" on one row.
* The description goes on one row; the items' one, whole (`ba_item_desc`).
* While a page runs without a message, the message window is empty: before,
  the orders showed with garbage in the skill one.

RAM: `$7E3CB6`-`$7E3CC8` (`FAR_BATTLE + 694` to `+ 712`), besides the three of
the first round (`+ 691` to `+ 693`). Opcodes: none. `text_layer.s` and the
pause menu weren't touched.

### Verified

ABL's suite with this tree's `battle`, `screens`, `mapdata`, `convert`,
`events` and `cartridge`: the same eighteen goldens, looked at side by side
with the original; **1072 green**, three rounds with no new reds. cargo test
of the touched crates and `just -f tools/justfile test`: 27. Not covered: the
shaking with the windows (looked at by hand), a battle without a scene and the
scrolling of the enemy list.

Screenshots: `/shared/capturas/2026-10-04-menu-de-la-pelea-2/`.

When merging, reinstall `battle`, `events`, `screens`, `mapdata` and
`convert`.

---
name: "Who to equip, from the menu"
description: "Choose who to equip on the main menu, like Scene_Menu, and not on the actor choice screen with the left half empty"
type: feature
status: done
assignee: taro
---

It came up on 2026-09-28, looking at the actor choice's `equipo-a-quien`
golden (`actor-selection-like-the-original.md`, Ñandú): choosing
who to equip uses the actor choice screen without the item's
windows, and the left half is left black. Before that change it was already like that,
on black and with the ">".

In RM2k there's no separate screen: `Scene_Menu`, with Equipment, moves the
cursor to the party panel of the same menu —the commands stay on the
left— and A opens `Scene_Equip` with that actor. It has to be confirmed in
easyrpg (`scene_menu.cpp`) and with RPG_RT under Wine.

taro hasn't asked for it yet: Hornero noted it when proposing it.

## What the original does

**The 2015 RPG_RT under Wine**, from a new game —after the intro
the party is Kersh, Core and Manta—. The captures, at 640x480, in
`/extras/capturas/2026-09-30-a-quien-equipar-wine/` and copied to
`/shared/capturas/2026-09-30-a-quien-equipar/original/`:

- `05-equipo-elegir`: A on Equipment leaves **the same menu**, with the red bar
  still on "Equipment" and another on **the first actor's text** —the
  three lines, name, level and Ex, without the face—. There's no separate screen.
- `06-segundo`: down moves it to Core.
- `07-equip-core`: A opens Core's `Scene_Equip`.
- `08-vuelve`: B from the equipment returns to the menu **with the cursor on the
  commands**, on Equipment, and no bar on the party: not to the choice.
- `09-arriba-da-vuelta`: up from the first goes to the last (Manta).
- `10-b-vuelve`: B in the choice returns to the commands, on Equipment.
- `11-tech-elegir` to `13-tech-vuelve`: **Tech Skill does the same**: the bar
  on the party, A opens that actor's technique list (`Scene_Skill`),
  and B returns to the commands.

**easyrpg** (`scene_menu.cpp`) says the same, and matches RPG_RT in
everything that was looked at: `UpdateCommand`, with Skill, Equipment, Status or Row,
deactivates the commands, activates `menustatus_window` and sets its index to
**0** —always the first, not the last chosen—; `UpdateActorSelection`, with
B, returns to the commands with the index at -1 —no bar—; with A it pushes the
scene with `menustatus_window->GetIndex()` and, on returning, the commands stay
active. `Window_MenuStatus`'s cursor is `{48 + 4, index * 58, 168, 48}`:
it starts after the face. An inactive window stops animating the cursor
(`Window::Update` only advances `cursor_frame` if it's active), but keeps
drawing it: that's why the "Equipment" bar stays.

## Skills

In RM2k it chooses an actor just like Equipment —easyrpg and RPG_RT—, and with A
the error sounds if the actor can't act (`CanAct`). **In the ROM "Tech
Skill" is greyed out and A does nothing** (`MENU_DONE` in
`rm2k-snes-screens`' layout, `menu_done` in the ROM): there's no skills screen
outside battle, so there's no separate choice to fix. When
the screen gets done, the choice is the same as this one.

## What was done

- **The choice, in the menu itself** (`menu_choose`, in `actor_choice.s`): A
  on Equipment leaves the menu as it is, with the ">" on the command, and puts the
  red bar on the row of the party's first; up and down wrap
  around; B erases it and returns to the commands without rebuilding the screen; A opens
  the equipment of the one under the bar, and on returning the menu is rebuilt with the cursor on
  Equipment, as before. It lives in the far bank because it didn't fit in bank 0:
  it went over by 86 bytes. It calls `wait_vblank` and `read_pad` through
  the battle's bridges (`ba_t_vblank`, `ba_t_pad`), like the equipment does.
- **The bar** is the actor choice's, with its tiles and its colours,
  but over nothing: the menu has no windows, so outside the bar BG1
  is empty and erasing it is writing zeros. It's `MENU_BAR` in
  `rm2k-snes-screens`' layout: from x = 148 to the edge, like the choice's, and from
  y = 2 to y = 58 —the red from 3 to 57—, because the menu row has a
  fourth line, the experience, which reaches y = 56, one past the
  row, and RM2k covers all of its own. It costs **two tiles** (the choice goes
  from 60 to 62 of the 64 that fit) and no colour; only its
  rectangle is stored, 8 x 14 cells, `menu_bar_cells`.
- **The first version fell short**: it went from y = 2 to 53, symmetric so as
  not to cost tiles, and taro saw with zoom that the bottom of "Ex" and its
  shadow fell on black. Measured in the capture, the red ended at
  y = 52 and the text at 56; now it goes five pixels lower and no pixel of
  text or shadow of the row is left outside. The ×4 crop, before and
  after, is in `/shared/capturas/2026-09-30-a-quien-equipar/`.
- **BG1 on in the menu**, empty, with the choice's base
  (`TARGET_VRAM`): `menu_bar_upload` uploads the tiles, the colours and a
  zeroed tilemap when building the menu, with the screen off.
- **The experience moves to sprite palette 1** (colours 144..159):
  0, 128..143, is the bar's —it already was in the actor choice, which
  has no sprites—. `menu_exp_close` now restores 128..159 on closing.
- **The reference**: `render::menu` with `choosing`, and `pantallas.menu(...,
  eligiendo=k)` and `menu.comparar(..., eligiendo=k)` on the tests' side.
- **What was left dead went away**, in its own commit: the actor choice
  without an item —the guards in `pick_cancel`, the erased cells on the
  left, `rm2k-snes-screens`' no-item layer and its
  `erase_*` fields—. The prose that named it, in another, with the ROMs identical
  byte for byte.
- **No new RAM was used**: during the choice, the row goes in `title_sel`,
  and on leaving it goes back to being the command.

## What doesn't fit

- **The bar on the command**: in RM2k the command is marked with the red
  bar, still. The ROM has marked the commands with a ">" since before, and it stays that way.
- **The bar's pulse**: RM2k's pulses while it's active
  (`cursor_frame`); the ROM's is fixed, as on every screen.
- **Skills**: see above; in the ROM it does nothing yet.

## Tests

- New `test_a_quien_equipar_se_elige_en_el_menu`
  (`test_menu_equipo_dibujo.py`): the menu with the bar on the first, on the
  second, wrapping around from the first, after B and again on the
  first, against `render::menu`; that A opens the second's equipment
  (`comp_char`) and looks like `pantallas.equipo`; and that the equipment returns to the
  menu with the cursor on Equipment and no bar. **Before the ROM change
  it went red** on the first comparison, with 6,661 different pixels.
- `rm2k-snes-screens`: a new menu case with the bar, and the hash of the
  conversion of its test game changes: the menu bar adds tiles to it
  and the no-item layer is gone.
- **Only one golden changes, `equipo-a-quien`**, in its own commit. The before, the
  after and the original side by side, and the RPG_RT captures, in
  `/shared/capturas/2026-09-30-a-quien-equipar/`. **The merge awaits
  taro's approval.** The scenes in `test_menu_golden.py` are one
  capture per case, so there are no more frames that change: the whole suite
  ran and that was the only red one.
- `just pruebas`, `just -f tools/justfile test` and `cargo test -p
  rm2k-snes-screens`, green on the branch with `main` merged
  (`d5680b99`) and the taller bar: **894** and **46**.
  `test_musica_techos.py` and `test_cores.py` passed. `abl.sfc` comes out
  `3423c711…`, the same with `NO_CACHE=1`.

## Space

`just espacio`, `release`: against `main` at `3afc8199`, bank 0 went from
50 to 51 bytes free, bank 1 from 3,126 to 2,769, and the data gaps from
8,799 to 8,603 (the 196 of `menu_bar_cells`, from the first bar). With
`main` at `d5680b99` merged and the taller bar, bank 0 is at
**14** —`main` alone had 13— and bank 1 at 4,697.

## On merging

Install in the global `screens` and `cartridge` —`just -f tools/justfile
install screens cartridge`—, besides what the merges of Yarará
(`events battle`) and Calandria (`rm2k-snes-audio`) ask for. This branch didn't rename or
add any `.py`.

## What taro has to look at

- Menu, Equipment: the menu stays as it is, with the ">" on Equipment, and the
  red bar on Kersh —the four lines whole, "Ex" with its shadow,
  without the face—. Down and up
  move it and wrap around; B returns to the commands.
- A on the second opens their equipment; B from the equipment returns to the menu with
  the cursor on Equipment and no bar.
- The "Ex" line is still visible, also under the bar, and on closing the
  menu the hero and the NPCs have their usual colours: the experience
  moved to sprite palette 1 and closing restores both.
- Items, a medicine: the actor choice, same as before.

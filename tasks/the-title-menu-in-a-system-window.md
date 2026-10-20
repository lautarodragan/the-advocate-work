---
name: "The title menu in a System window"
description: "The title's Begin the Story / Resume the Story menu is drawn as bare text with a mark over the picture; RPG_RT draws it in a window of the game's System, with its cursor"
type: feature
status: done
assignee: taro
agents: [Tijereta]
---

taro, on 2026-10-13:

> Could you make the start menu use the System for the Begin the Story /
> Resume the Story menu, like RPG_RT does?

Today `rm2k-snes/screens/src/title.rs` in the-advocate draws the database's
`new_game` and `load_game` terms with the message font over the title
picture, on BG2 at 4 bpp, one tilemap per option chosen, with a text mark
as the cursor and no window.

RPG_RT draws a window with the System's background and frame, centred
under the picture, with the System's cursor on the chosen option. It also
has a third option, the database's `exit_game` term, and greys
`load_game` when there is no save.

## Log

2026-10-13, Tijereta. Measured first, under Wine, on a copy of ABL's Wine
directory: with the 2015 RPG_RT and also with the 2000 one —it runs, see
the draft [the-2000-rpg-rt-runs-under-wine](the-2000-rpg-rt-runs-under-wine.md)—.
At 320x240 the window is 112x64 at (104, 148): easyrpg's `Window_Command`
width (longest term + 16) and `RepositionWindow` (bottom at 53/60 of the
height), opaque, with the System's frame and background; the bar 104x16
at (108, 156 + 16n); `exit_game` is the third option ("End" in ABL);
without a save `load_game` is greyed and the cursor can go onto it, and A
there does nothing. With a real save (made by inserting `OpenSaveMenu` in
the copy's map 4) `load_game` is in the text colour and **both runtimes
still open on `new_game`** —easyrpg opens on `load_game`—. `exit_game`
fades to black in ~0.5 s and closes. The other seven games' titles were
captured with the 2015 one.

Done:

* `rm2k-snes/screens`: `title.rs` draws `Scene_Title`'s window with the
  game's System, one tilemap per option and per save/no save (6), 15
  colours with Adeleine's merge when a System has more; `render` gets a
  `title` screen (RGBA, transparent where the picture is); the `exit_game`
  term.
* `rm2k-snes/mapdata`: `TITLE_MENU_N` is the options, not the tilemaps.
* runtime: `title_saves` (any slot of this format → `title_saved`),
  `title_upload_menu` adds it, A on a greyed `load_game` does nothing,
  cancelling the slots comes back on `load_game`, `exit_game` fades like
  End Game's "Yes" (`ending_fade`, split out of `ending_screen`) and `stp`.
* ABL tests: the title goldens with and without a save, `saved_sram` and
  `power_on(sram=)`, a drawing test against `screens.title`, the exit, the
  other-build save.
* Book: divergence `what-the-title-menu-does-not-model.md`. `exit_game`
  was kept and made to fade and stop, rather than left out.

Ran, with the branch's tools: the-advocate `just test` (27) and
`crate-test` of screens, mapdata and cartridge; ABL `just tests`, 1294
green after its title goldens (10: 7 changed, 3 new); the ports'
`just boot`, 9. `abl.sfc` of the branch: sha256 `bf582f53…ce7d`. Bank 0
has ~1.4 KB free in every cartridge (`just space`).

Not covered by the suite: the other seven games' menus are looked at only
by eye (side by side with the originals, in
`/shared/captures/2026-10-13-title-menu/`); `test_boot.py` passes their
title by its first option. bsnes is not run on the title goldens (snes9x).
The `stp` of `exit_game` on real hardware.

Branches `tijereta-title-window` in the-advocate, the ports and the docs.
When merging: `just install screens mapdata convert cartridge project` —the
runtime changed, so the binaries that assemble it from the checkout—, and
`just cartridges` in the ports.

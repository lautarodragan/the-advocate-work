---
name: "End Game in the pause menu"
description: "The pause menu's End Game command has to work as in RM2k"
type: feature
status: done
assignee: Yaguareté
---

From taro, on 2026-09-28: "make End Game work properly".

In RM2k, End Game opens `Scene_End`: a window that asks whether to return
to the title, with "Yes"/"No" (the LDB's terms), and "Yes" fades the screen
and the music and goes to the title. We have to see what the ROM does today
with that command (the menu is in `rom/src/menu.s`; the commands and when
they are greyed out, in `tools/port/titulo.py`).

## What the ROM did

The command is greyed out and A does nothing: `MENU_HECHAS` (titulo.py)
does not include it, and the comment said why —"ending the game requires
returning to the title without resetting the SPC700"—. That no longer
holds: since the Game Over screen, returning to the title is a `jml reset`,
which restores everything, and `OP_RETURN_TO_TITLE` does the same.

## What the original does

Looked at in easyrpg-player's `Scene_End` and in the 2015 RPG_RT under Wine
(Tero's copy of the game, with map 4 that starts with the party):

- Black screen with two System windows: on top the question, the term
  `exit_game_message` ("End game?"), 70x32 —the text's width plus 16— at
  y=72; below `yes` and `no` ("Yes", "No"), 34x48, at y=120. Both centred
  on x. Text in colour 0; the cursor is the System's red bar.
- **It enters with the cursor on "Yes"**. easyrpg enters on "No"
  (`SetIndex(1)`): the original prevails. The 2000 RPG_RT does not start
  under Wine (it crashes when changing the video mode), so the 2015 one is
  the only one measured.
- B, or "No", returns to the menu with the cursor on "End Game".
- "Yes": the theme fades in 400 ms (`BgmFade(400)`) and the screen fades to
  black in about 330 ms —measured with captures every 18 ms—; then, the
  title.
- Between the menu and this screen there is a short fade (about 6 frames).
  In the ROM the menu's screens open without a fade, and this one too.

The command had been greyed out since the menu was born (606911f4), for the
why above; `git blame` showed no other reason.

## What was done

- `tools/port/fin_del_juego.py` draws the screen with `Scene_End`'s rules
  —`ventana.ventana`, `ventana.cursor` and `dibujar_linea`, the ones of the
  other windows— and converts it: **a single image of tiles and tilemap for
  both commands, with one palette index per pair of colours** (with the bar
  on "Yes", with the bar on "No"). Moving the cursor is uploading the other
  16-colour palette in vblank. The letters go at 6 pixels, as in RM2k: it is
  not the one-letter-per-cell font of the items screen, because they are
  three fixed words.
- It goes on BG2, over `RANURA_VRAM` and `RANURA_MAP`, which is what the
  menu already writes: on returning, `menu_subir` rebuilds them and the map
  comes back with nothing new.
- `rom/src/fin_del_juego.s`, in bank 1: up and down switch command, B and
  "No" return with `rtl`, and "Yes" fades the theme like a 400 ms
  `FadeOutBGM` —with `op_fade_bgm`'s guard—, fades the screen in 20 frames,
  waits for the theme to finish, silences it (and the MSU-1 track) and
  jumps to `reset`, same as the Game Over screen's exit. The reset is the
  whole boot: music, palettes and RAM as on power-up.
- In the menu, `MENU_FIN` enters `MENU_HECHAS` and `menu_pantalla` does the
  `jsl`; on returning, the cursor stays on End Game. Bank 0 spends 15 bytes
  (`just space release`: from 205 to 190 free).
- What is still different is in
  `divergences/what-the-end-game-screen-does-not-model.md`.

## Tests

- `tests/rpgmaker/test_end_game.py`: the screen against
  `fin_del_juego.render` on both commands and wrapping around; "No" and B
  return to the menu —against `render_menu` with the cursor on End Game—
  without the clock running; "Yes", on map 21 with its theme playing, starts
  the theme fade, resets, reaches the `title` golden, and "Begin the Story"
  starts the game again.
- New goldens `end` and `end-no` (`test_menu_golden.py`). `menu`, `menu-2`
  and `menu-party` change: End Game is no longer greyed out. Side by side
  with the original in `/shared/captures/2026-09-28-end-game/`.
- The music ceilings were measured again (`just ceilings`): the ROM change
  made `dcbest` clip, as the test warns may happen.
- What no test looks at: that the theme fade **can be heard**, and the
  MSU-1 track going silent. The test checks that the fade starts.

## What taro has to test

- Menu, End Game: the question and "Yes"/"No" in windows, with the red bar
  on "Yes". Up and down move it.
- "No", and B: back to the menu with the cursor on End Game; on closing the
  menu, the map as it was.
- "Yes" with music playing: the screen and the theme fade and the title
  appears with its theme; "Begin the Story" starts from scratch and "Resume
  the Story" loads the save. With and without MSU-1.

# Tested

taro, on 2026-09-28: works perfectly, with and without MSU-1.

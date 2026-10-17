---
name: "The System's cursor in the main menu and the save slots"
description: "The main menu's command list and the Save/Load screen mark the selection with a two-cell mark of their own instead of the System's cursor, the rectangle the items, equipment, shop, targets and choices already use"
type: feature
status: done
assignee: taro
agents: [Chajá]
---

taro, on 2026-10-16, playing ABL and The Book of Three: the selector in the
Save/Load screen and in the main menu's list of options on the left does
not use the System graphic; it was always like that.

At the-advocate `30ab0ca6`: `menu_cursor_write` in `runtime/menu.s` writes
a two-cell mark —`menu_cursor_cells`, `menu_cursor_vram` from
`rm2k-snes/mapdata/src/emit.rs`—, and `slot_paint` in `runtime/slots.s`
paints a slot's row in one of four variants, the cursor one of them
(`slot_<n>_<full><cursor>`). The items, equipment, shop, target windows and
the message window's choice bar already draw the System's cursor
(`Game::cursor` in `rm2k-snes/screens/src/game.rs`, `borders.rs`).

## Worked (Chajá, 2026-10-16)

Worktrees `chaja-system-cursor` of the-advocate (from `30ab0ca6`), the
ports (from `ed3e0ee`) and the docs (from `3f105f2`).

### The original, measured under Wine

RPG_RT 2015 with ABL, captures in
`/shared/captures/2026-10-16-system-cursor/`:

* **The menu's command cursor** is `Window_Command`'s: red from x = 5 to
  82 and y = 9 to 22 on row 0, so the rectangle is (4, 8, 80, 16) —four
  pixels left of the text, the window's width minus eight— with the
  System's one dark pixel of edge. It stays on the command while the bar
  chooses an actor.
* **The slot cursor** is `Window_SaveFile`'s: only over "File N", red from
  x = 5 to 49 and y = 49 to 62 on the first window (at y = 40): the
  rectangle (4, 48, 47, 16), which is easyrpg's `width("File") +
  width(" ") * 5 / 2 + 8`. The number goes at `width("File") +
  width(" ") / 2`, as `"%2d"`.
* **It does not blink** with ABL's System: six captures in a row over more
  than a second, the same bytes —the cycle is twenty frames—, because
  `ablskin`'s two drawings are the same pixels. RM2k does alternate them
  with a System whose two differ (easyrpg's `Window::Draw`), but the
  other screens with the System's cursor draw the first one and do not
  animate —the divergence "The choice bar does not alternate its two
  drawings" in the book—, so these do the same.

### What changed

* **The cursors are the System's, on BG1 with the actor choice's tiles and
  colours**, like the menu's bar over the party: `MENU_CMD_BAR` and
  `slot_bar` in `rm2k-snes-screens` (`borders.rs`, `layout.rs`), both
  cut by `alone` and emitted as `menu_cmd_cells` and `slot_bar_cells`
  with where they go per command and per slot, `menu_cursor_vram` and
  `slot_bar_vram`, outside bank 0. The console side is
  `runtime/system_cursors.s`, in FAR3.
* **The menu's commands moved to x = 8**, RM2k's, from 24: the ">" column
  is gone, and at 24 the cursor, four pixels left of the text and the
  column plus eight wide, reached under the faces.
* **The slot rows have two variants and not four**, without the ">", and
  the number goes half a space after the term in two places, as
  `Window_SaveFile::Refresh` draws it; the bank of the slots and the menu
  lost 17 tiles in the screens' test game.
* **The slot screen turns BG1 on** (`target_ppu_on` instead of
  `slot_ppu_on`), and the save point puts back the sprites' palette 0 with
  `menu_exp_close`, as the pause menu does.
* ABL's actor choice tiles go from 42 to 43 of 64.

### Space

`just space` in ABL, every cartridge, before and after: **bank 0 +66 B**
(739 → 805 in `release`; the tightest is `test-change-system`, 688 → 754),
**FAR3 −129 B** (30 467 → 30 338), bank 1 and FAR2 unchanged —the tightest bank 1, `test-msu`, 792 B—, and the
data banks' gaps +3.5 KB (the two slot variants that went). The actor
choice's 8bpp tiles: ABL 42 → 43 of 64; Desert Nightmare 24 → 30, El
Dorado 42 → 44, Frozen World 36 → 38, Sunset over Imdahl 13 → 17,
Vampires Dawn 56 → 59. The Book of Three, Dooms 2 and Zounds already
fused those windows and fuse more: 71 → 82, 75 → 85 and 70 → 81 tiles
as RM2k draws them, for 64. Rendered with the stage, The Book of Three's
actor choice moves 8 pixels.

### Goldens

Sixteen of ABL's suite (the menu ones and the slot ones) and two of the
test game (`renamed-menu`, `rename-slot`), each before, after and the
difference in `/shared/captures/2026-10-16-system-cursor/`, with the
original next to the ROM in `vs-original/` and The Book of Three's from
the stage in `book-of-three/`.

### Tests

`rm2k-snes-mapdata`'s test still hashes what the Python wrote:
`with_the_cursors_as_before` puts the ">" back. `rm2k-snes-screens`'s
answer hash starts again from this change (the bank lost the ">" and its
rows, which renumbers its tiles), and four renders move.

**To install when merging**: `screens`, `mapdata` and `cartridge` (the
runtime). Verified also with `convert` and `wally` of the merged tree
installed locally, because main's map pictures need them and the global
ones were older.

Drafts: [`fused-windows-can-redraw-the-blank-cell.md`](fused-windows-can-redraw-the-blank-cell.md).

### Verified

On the trees merged with main (the-advocate `chaja-system-cursor`, ports
`chaja-system-cursor`), with `screens`, `mapdata`, `cartridge`,
`project`, `convert` and `wally` installed locally: ABL's `just tests`
1555 passed, 2 skipped (`abl.sfc` sha256 `dd229d04…c41d`); the test game
28 passed, 1 skipped; `just test` 29; `just rust-test` 927; `just boot`
at the ports' root 46. **Not looked at by any case I know of**: the
sprites' palette 0 on the map after a save point's slot screen —what
`menu_exp_close` puts back in `op_save`—, and the command cursor on a
custom menu's row past the sixth.

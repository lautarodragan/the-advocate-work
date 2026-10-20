---
name: "A debug screen in the pause menu"
description: "RPG Maker 2000's F9 screen —switches by groups of ten, with their names, turned on and off— as an option of the pause menu, for any game, behind a debug knob"
type: feature
status: testing
assignee: taro
agents: [Tijereta]
---

taro, on 2026-10-20: "Could you add a debug screen like the original RPG
Maker 2000's, that lets me change switches? Since we have no F9, I'd add
it as an entry of the pause menu (as we did with the console in ABL)."
The precedent is ABL's console
([`console-custom-menu`](console-custom-menu.md)): one more option of the
pause menu, full screen.

**What RPG_RT's is** (to confirm against EasyRPG's `Scene_Debug` and,
if it helps, the original under Wine): a list of ranges of ten on the
left, the ten switches of the chosen range on the right with their number,
name and ON/OFF; A toggles, B goes back. Variables are on the same screen
in RPG_RT —a value per variable—: here, second, if it is cheap.

**Behind a knob**: on in the builds taro plays while porting, off in a
clean delivery, like `[debug] debug_map`; a game without the knob has no
entry and no cost in its ROM.

## Work log (Tijereta)

Taken on 2026-10-20 from the-advocate `8715b90e`, the ports `c333ab6` and
the book's `main`, on branches `tijereta-debug-screen`.

### What RPG_RT's is, measured

The original under Wine, with the **2000 runtime** —`RPG_RT.exe TestPlay
ShowTitle Window`—: the 2015 one does not open it on F9, nor does any
runtime while an autorun page runs, so the copy started on a map with
none (36, then 84) by rewriting the `.lmt`'s start. What it shows:

* two windows, 176 tall at y = 32 of 240: the ranges, 96 wide, ten rows
  of `S[0001-0010]`; and the list, 224 wide, ten rows of
  `0001: StrongBox` with `[OFF]` or `[ ON ]` at the right, all in the
  normal colour —OFF is not grey—;
* the range cursor stays on while the list is active; A enters the list
  on its first row, A toggles, B goes back to the ranges, B leaves;
* the range list does **not** scroll with up and down: it wraps within its
  ten rows;
* **left and right in the ranges flip pages of ten ranges** —a hundred
  switches—, round: after the last page of switches come those of the
  variables, `V[0001-0010]`, whose rows show the value right-aligned;
* on a variable, A opens a number input over the list —a sign and seven
  digits, up and down change the digit, left and right move— and A again
  sets it.

The captures are in `/shared/captures/2026-10-20-debug-screen/original/`.

### The design

* **The knob**: `[debug] debug_screen`, required like the other two;
  `rm2k-snes-cartridges` passes `--debug-screen` to every cartridge. On in
  the nine games; off in the tools' test game, so one project builds
  without it.
* **The option is the pause menu's last row**, after End Game, as one more
  command after the custom menus' —`menu_rows_build` and `cm_from_menu`, in
  `custom_menu.s`, each with an `.if DEBUG_SCREEN`—. Last so that no row the
  tests walk to moves. Its label, "Debug", goes into the menu's bank like a
  custom menu's.
* **The screen** is `runtime/debug_screen.s`, in `FAR3`, the custom menus'
  full screen as the skills screen uses it: text on BG2 through the text
  layer, the System's windows on BG1 at 8bpp, a cursor bar per row of each
  window uploaded only in its window's columns, so the two cursors share a
  row. Its RAM is 36 bytes of `FARBSS`; the page and the cursors are kept
  between openings behind a magic word, so the WRAM's garbage cannot pick
  them.
* **The data** comes from `rm2k-snes-screens` —`debug_screen.rs`—: the
  windows' tilemap, bars, tiles and colours, and one block of names cut to
  the room the font leaves —a word per switch, two per variable (the name
  and its slot, `$FFFF` if not kept)—, emitted by `rm2k-snes-mapdata`'s
  `emit/debug_screen.rs` in `RODATA`, which the packing puts in a far bank.
  Bank 0 pays nothing in any game.
* **Variables went in**: they cost the variables' table, four bytes each,
  and some 150 bytes of code. Left and right move them by one, L and R by
  ten; a number input like RPG_RT's was left out.
* **A change takes effect on return to the map**: it sets `refresh`, and the
  pause menu already calls `compar_owe` when it closes.

No opcode was needed.

### What it costs, measured with `just space` (knob on, against main)

| | bank 0 | `$C0` (FAR2) | `$C1` (FAR3) | far RAM |
|---|---|---|---|---|
| A Blurred Line, `release` | 111 → 108 | 2,423 → 2,408 | 25,010 → 23,061 | 1,830 → 1,794 |
| Sunset over Imdahl | 28 → 25 | 175 → 160 | 22,923 → 20,974 | 3,795 → 3,759 |
| Vampires Dawn | 48 → 45 | 2,235 → 2,220 | 23,121 → 21,172 | 2,191 → 2,155 |

ABL's tightest cartridge, `test-change-system`, is at 53 B of bank 0. The
**3 bytes of bank 0** are the pause menu's two tables of one entry per row,
`menu_done` and `menu_option_vram`, in `TABLES`, which grow by the Debug
row; moving them out would change every ROM, knob or not, so they stay. The
code is some 1.9 KB of FAR3 and 15 bytes of FAR2. The names are a far block:
3 KB in El Dorado to 29 KB in Vampires Dawn, whose ROM was already full and
needs the MSU-1, so as much of what may travel in the `.msu` goes there.
The Debug label takes 8 to 14 tiles of the menu's bank: no game loses a face
it was not losing already (Dooms 2 loses the same three).

**Knob off, byte for byte**: ABL's, Sunset's and Vampires Dawn's `release`
built with the branch's tools and `debug_screen = false` are identical to
the ones built with the tools at 8715b90e.

### Verified

* ABL's suite with the branch's tools, on the ports merged with main
  (f3f686b): 1576 passed, 2 skipped. New: `test_debug_screen_golden.py`
  —670 turned on there, and map 278's guard gone when the menu closes; 111
  moved by one and by ten—. Twelve pause menu goldens gain the Debug row,
  154 pixels each and only there; the End Game tests now walk down four rows
  instead of up from the first, and the wrap test expects the last row.
* `just boot` from the ports' root, the nine games with the knob on: 96
  passed.
* `just test`, `just rust-test` and `just lint` in the-advocate.
* What the suite does **not** cover: the screen in the other eight games
  (only that they build and boot), the page flip past the last page, a
  switch past the table (grey), the saturation at 16 bits, L as -10, and
  the screen's sound —it plays none—.

Captures in `/shared/captures/2026-10-20-debug-screen/`: the original, the
new goldens and the changed ones side by side.

### To install when merging

`just install screens mapdata convert cartridge` —`ditto` is a library and
goes in with `screens`—, and the runtime travels with the checkout.

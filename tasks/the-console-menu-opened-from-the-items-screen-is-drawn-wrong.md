---
name: "The console menu opened from the items screen is drawn wrong"
description: "ABL's Portable Console, opened by using the console from the items screen, sometimes shows window-frame pieces tiled over its background; opened from the main menu's entry it looks right"
type: bug
status: testing
assignee: taro
agents: [Carpintero]
---

taro, on 2026-10-18, playing ABL on Mednafen: the console's menu (the
custom menu, `runtime/custom_menu.s` in the-advocate) sometimes looks wrong
when entered from the items screen, using the Portable Console item, and
right when entered from its entry in the main menu. taro's screenshot (page
2/2: Arden's face, "Neon Viper", Skills, Tutorials): the text, the face and
the windows' frames are there, but the background around them is filled
with pieces of window frame, tiled over the whole screen.

Done means: entering the console from the items screen draws it the same
as from the main menu, every time, measured in a ROM test that compares
both ways in.

## Log

**2026-10-18, Carpintero.** From the-advocate `f04e2029`, the ports
`04422f7`. In taro's screenshot the frames are not out of place: every BG1
tile is wrong —edges drawn as corners, the bar an outline instead of red—,
while BG2's text and the objects' portrait are right. That is BG1's 8bpp
tiles read as 4bpp: **the menu drawn in mode 1**. A map whose panorama is on
BG3, or a painted one, is mode 1 (`pano_ppu`), and every screen that opens
over the map goes back to mode 3 with `pano_mode3` —`screen_ppu_on`,
`slot_ppu_on`, `target_ppu_on`—, but `cm_screen_upload` does not. From the
pause menu's entry the menu screen already put mode 3; from the item, the
items screen closes to the map first (`back_to_map` → `pano_ppu`, mode 1
again) and `OP_MENU_OPEN` opens the console over it. So "sometimes" is "on
a mode-1 map", and the item path is just the way to get there with the
map up; an autostart `OP_MENU_OPEN` on such a map would do the same.

Blame: the custom menu is `88051c55` (2026-10-04); mode 1 and `pano_mode3`
came the next day, `a67ce9c5`, whose message lists the screens that go back
to mode 3 and does not name the custom menu, which was then the only one
opened from a page over the map. Not intentional.

Reproduced with `console-saldra` taken to map 32 (mode 1 in
`converter.log`, like 3, 6, 105 and 255): from the item, both subjects with
the frames all over; from the entry, right. On map 5 both ways were equal,
which is why `test_menu_custom_golden.py`'s from-the-item case never saw
it. Scrolling the item list plays no part.

Fix, the-advocate `d4ffe731`: `cm_screen_upload` calls `pano_mode3`.
Closing gives the map mode 1 back through `back_to_map` → `pano_ppu`
(looked at on 32). Test, the ports `9b52975`:
`rpgmaker/test_menu_custom_ways_in.py`, item against entry at 15 bits, both
subjects, snes9x and bsnes, on 32 and on 1 (flattened, for BG1's mask; it
was already green). Red on 32 in both cores before the fix, green after.
A painted map takes the same path and is not run: ABL has none.
Captures: `/shared/captures/2026-10-18-console-from-items/`.

Run with the branch's tools (`install-local cartridge project`, only for
the runtime's path; no Rust changed): ABL's whole suite, 1570 passed and 2
skipped, no golden moved; `just test`, 29 passed. Nothing to reinstall when
merging: the runtime is read from the-advocate's main checkout. Branches
`carpintero-console-from-items` in the-advocate (`d4ffe731`) and in the
ports (`9b52975`), both on today's `main`. For taro: use the console from
the items screen on map 32 (or 3, 6, 105, 255) and close it.

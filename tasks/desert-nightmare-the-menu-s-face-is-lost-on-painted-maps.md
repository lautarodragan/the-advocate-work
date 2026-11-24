---
name: "Desert Nightmare: the menu's burning face is lost on a painted map"
description: "On a painted map the menu's face shows behind the options, but the inventory, keys, notes and maps screens show black where the face should be, with a sliver of it at the right edge"
type: bug
status: testing
assignee: taro
author: huron
game: desert-nightmare
agents: [Hurón, Mulita]
links:
  relates: [desert-nightmare-interiors-painted-now-that-the-box-is-a-window, painted-map-strips-may-land-on-a-big-picture]
---

Seen by Hurón on 2026-11-22, at the-advocate `0ae40e0a` (tools as
installed) and the ports `89f77b4` —main— and the branch
`huron-dn-interiors` (`de7eeac`), doing
[`desert-nightmare-interiors-painted-now-that-the-box-is-a-window`](desert-nightmare-interiors-painted-now-that-the-box-is-a-window.md).

**What is seen**: B opens the menu over the burning face, as on any map.
A on Inventory (or Keys, Notes, Maps): on a map that is not painted the
face stays behind the windows; on a painted one the screen is black
around the windows, with only a sliver of the face at the right edge, and
the face behind the options already sits some 8 pixels off. On main it is
so on the 95 maps `painted_events` paints —the towns, apartment 37—; no
test saw it, because the menu test opens the menu in the warehouse's
room 4 (map 26), which was not painted. With the 42 interiors painted it
is, and its six goldens past the options move to this: they were not
blessed.

![Map 26 unpainted and painted; map 37, painted on main](images/desert-nightmare-the-menu-s-face-is-lost-on-painted-maps/face.png)

**To reproduce**: `tests/test_desert_nightmare_menu.py` in the ports on
`huron-dn-interiors`, red on `desert-nightmare-menu-inventory`; or on main
with `MENU_ROOM = 37`. All six captures, side by side, in
`/shared/captures/2026-11-22-dn-interiors/goldens-menu-not-committed.png`
and `menu-face-on-painted-maps.png`.

**Not looked at**: why. A painted map keeps its own layout of VRAM and
BG1 (`painted.s` in the runtime, "A painted map keeps only what the screen
shows" in the book's VRAM split); the face is a big picture and the grid's
windows go up after it, so the windows or the painting's column uploads
may be taking what the face had. `git blame` first.

## Log

### 2026-11-22, Mulita: the window mask hid BG1, which was the face

#### The cause

Not VRAM: the face's tiles and tilemap were whole. A painted map —and a
flattened one, `PANO_ON` 3— sets `TMW` to `$11` in `pano_ppu`
(`runtime/pano.s`, taro's 2026-10-05 and 2026-10-11, `7f62dcdb` and
`40cbad47`) so that the windows' HDMA mask —channel 6 into `W12SEL`—
hides BG1 on a window's lines: the painting's cells in front of the hero
are BG1 priority 1 and would cover the window, which is BG2. A big
picture is BG1 too, and `big_load` left `TMW` as the map had it, so
`sw_vblank`'s mask —window 1 from the leftmost window's left edge to the
rightmost's right edge, `SW_X0` to `SW_X1`, on every line with a
window— hid the face there: black, and only past `SW_X1` the sliver.
Behind the options the one window is opaque over what it hides, so
nothing showed. The message window had the same mask on its lines, over
any big picture on a painted map; `message_place.s` already knew "a big
picture is BG1" for the trade of BG1 and BG2 (2026-10-16) but not for
the mask.

**The "8 px off" did not reproduce**: on map 37 on main the options are
the golden `desert-nightmare-menu-options` taken on map 26, pixel for
pixel, before and after the fix; and on Hurón's branch, with map 26
painted, the options golden passes with the fix too.

#### The fix

`big_load` writes `TMW` back to `$10` —the objects alone— when the
picture goes up, and so does the zoomed picture's load
(`big_picture_zoom.s`); erasing the picture goes through `back_to_map`,
`ppu_init` and `pano_ppu`, which put the map's back. the-advocate
`662f3f3f` on `mulita-dn-menu-face`.

#### The test

`test_the_face_stays_behind_the_menu_on_a_painted_map` in
`tests/test_desert_nightmare_menu.py` (ports, `895e7de` on
`mulita-dn-menu-face`): the menu opened on map 37, asked to be painted
(`PAINT_ON`), and its options, inventory and the empty notes' message
against the same three goldens as map 26 —the face covers the screen—.
Red with the tools of `0ae40e0a` (the inventory, 15,568 of 57,344 pixels)
and green with the fix. No golden moved, none is new.

On Hurón's `huron-dn-interiors` (`b25f741`, read-only, in a detached
worktree of mine) with the fix's tools: the six menu tests green, the
six goldens past the options with the face, as committed on main.

#### Found and not fixed

[`painted-map-strips-may-land-on-a-big-picture`](painted-map-strips-may-land-on-a-big-picture.md):
`paint_flush` uploads a painted map's columns with a big picture up too,
and the slots share VRAM with the picture's tiles. Read, not reproduced.

#### Verified, and what to install

On the ports branch merged with main (`283339f`) and the fix's tools:
`just boot -k desert`, 40 passed; ABL's `just tests`, 1728 passed and 2
skipped. Not covered by any test: the zoomed big picture's load
(`big_picture_zoom.s`) on a painted map, and a framed message over a big
picture on a painted map past the empty notes' one-line box. Merging
needs only `just install cartridge` —the runtime is compiled into it—.
Hurón's `huron-dn-interiors` book branch adds a "Known issues" line for
this; main's book has none, so it goes when that branch is merged.

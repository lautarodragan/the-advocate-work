---
name: "The window with more than 15 colors"
description: "A System whose window (background, frame, arrow, cursor, font and shadow) goes over the colors that fit stops the whole game today; have Adeleine reduce it instead of stopping, for any game"
type: feature
status: testing
agents: [Tijereta]
assignee: taro
---

From Aguará's survey ([`docs/research/2026-10-05-otros-juegos.md`](https://lautarodragan.github.io/the-advocate-docs/research/2026-10-05-otros-juegos.html)): it
happens to 5 of the 7 games, which today build only with the System reduced by hand
in a copy of the game. taro, on 2026-10-05, chose this as the first,
one at a time because of the usage limit: without prior mockups, with before and
after captures.

## How it ended up (Tijereta, 2026-10-05)

`message_window::draw`, in `rm2k-snes-screens`, no longer stops when the
window goes over fifteen colors: it passes them to `adeleine::merge_least_visible`
and repaints everything —background, frame, arrow, cursor, font rows and shadow—
with what's left. The weight of each color is what it covers in the empty window,
the arrow and the cursor, and the font and the shadow weigh a whole row of the text
area per line, so they aren't the first to go. A System that fits
doesn't go through there.

What's lost travels in `window`'s answer (`brought`, `merges`, `system`)
and the converter writes it in the patches as a new type,
`parches/auto/ventanas/<System>.toml`, only if there were merges.

With the original System, `rm2k-snes-screens window` answers:

    dooms2          18 -> 15
    frozen-world    16 -> 15
    book-of-three   23 -> 15 (but the stretched frame doesn't fit in the tile bank)
    desert          15, fits (what stopped it was End Game, another limit)
    el-dorado, sunset: fit
    vampires-dawn   its System isn't in the copied game

The same in the 8bpp windows of the text screens (`borders.rs`:
items, equipment, shop, actor choice), which had their own "the
windows use N colours and from 128 there is room for 16": Dooms 2's System
brought 26 and Frozen World's 17. There **what's merged isn't yet
written in the patches**: that's what's missing from this task.

**No game starts yet with the original System.** Behind the
colors the tile bank shows up: a stretched gradient background is one tile
per shade, and with 15 colors Frozen World's message window asks for 266
tiles of 256 (Book of Three 267), and Dooms 2's actor choice goes over
`$4800`. Continuing to merge until the tiles fit was tried
(`merge_until`): Frozen ended up with 4 colors and Book of Three with 2, which
destroys the window. It's not the tool; it goes separately (wishlist
`window-in-the-tile-bank`). Desert stops at End Game and Dooms 2
also at its BMPs.

Captures: `/shared/capturas/2026-10-05-ventana-con-mas-colores/`, Dooms 2's
window decoded from what the cartridge builds, before (System reduced by
hand) and after (Adeleine): the font keeps the gradient.

Verified: the tests of `screens`, `patches` and `convert`; ABL's suite
with these tools, 1136, and `abl.sfc` the same, 27e94e67…, with the first
version and with the final one. The two new tests of `screens`
(`window_colors.rs`) were seen red before the fix. What no
test runs: a ROM with a reduced window, because no game builds.

On merging, `screens`, `patches` and `convert` are reinstalled.

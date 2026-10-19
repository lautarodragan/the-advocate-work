---
name: "The Book of Three: the map's place names are hard to read"
description: "The map item shows the land's map over the whole screen; its place names are partly the picture's transparent colour, which shows the map in RM2k and the backdrop on the console, so they come out grey and dimmer"
type: bug
status: draft
agents: [Chajá]
---

Seen by Chajá on 2026-10-19, fixing
[`book-of-three-the-map-item-shows-nothing`](book-of-three-the-map-item-shows-nothing.md),
with the-advocate's branch `chaja-map-item` (from `9592b88b`) and the
ports' (from `c420032`), in The Book of Three.

**What is seen**: the map item (item 112, common event 23) shows
`bo3map` over the whole screen. The file draws its place names —"Spiral
Castle", "Great Avren River", "Caer Dallben"…— as white letters over the
land; the game shows it at zoom 50, so RM2k already blurs them, but they
stay white and can be made out. In the port they come out grey and blue,
dimmer against the green and brown, and most are harder to read than in
the original. Side by side, in
`/shared/captures/2026-10-19-book-of-three-map-item/` (`map-item-sheet.png`).

**Why**: mostly transparency. The file's colour 0 —the transparent one,
since the `ShowPicture` asks for it— is the letters' white, (248, 248,
247), 1,929 pixels of them; the rest of each letter is near-whites that
are opaque. In RM2k those holes show the map under the picture. On the
console a big picture hides the map, and its holes show the screen's
backdrop, colour 0 of CGRAM, which changes with the map: on the world
map (70) a dark one,
so the letters come out grey and blue; on map 43, a lighter one, they come
out whiter (75 pixels differ between the two captures, all on the
letters). See "What large pictures do not model" in the book's
divergences. Then the scale to 256x224 —LANCZOS, `scaled_rgba` in
rm2k-snes-images— thins them further.

**How to see it**: the ports' `tests/test_book_of_three_map_item.py`, its
golden `tests/golden/book-of-three-map-item.png`; or use the Map of
Prydain from the menu.

If it is taken: a big picture's holes could show a fixed colour of the
picture's instead of the backdrop —here the letters' white—, or the
transparent colour could be left opaque for a picture that covers the
screen. A matter of looks: taro decides whether it is debt.

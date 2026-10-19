---
name: "What is missing from the panoramas"
description: "What each panorama's path does not cover: a ChangePBG in a common event, the sky in mode 1 and the grain of the flattening; a ChangePBG to another picture is done since 2026-10-19"
type: feature
status: testing
assignee: taro
agents: [Aguará]
---

# What

What was left out of `panoramas.md`, for any game:

* **A `ChangePBG` in a common event.** Wally looks at the map's pages to
  know which axes are going to loop and which pictures to carry; one in a
  common event it does not see. No game measured has one.
* **The sky in mode 1.** At 2 bits an RTP sky ends up in four colors
  (105, the sunset). The study left another path untried: the
  panorama in BG2 at 4 bits and what is above in BG3 at 2, with BG3's
  priority above everything and the message window covering it via HDMA.
* **The grain of the flattening.** What is above goes in 8x8 cells: a cell
  that covers less than half ends up behind the hero. What is above with
  objects, in the edge cells, would fix it if there are palettes to spare.

# Why

None of them holds back A Blurred Line today: they are the edges of the rule, and what
another game is going to ask for.

# Log

**2026-10-19, taro**, playing Zounds: "a nice to have: showing the panorama
in this map. Is it feasible?" —`DownLoad Room` (map 32), in `Sala de
Máquinas` of the Hover Tram—. The map has no panorama of its own; its
parallel event 2, `SetBackGround`, sets `Zounds_DesertPan` (a BMP) with
ChangePBG at several scroll speeds, and at the end `Zounds_ScreenShot_01`
(a 320x240 PNG). Asked whether to take it out of the wishlist, measuring
the cost first: "Dale!".

Scope for now: the first two bullets —a ChangePBG naming another image, and
one in a map without a panorama—. `panorama-not-changed` in each game's
`build/release/degradations.json`, on 2026-10-19: Zounds 19 commands in 4
maps (20, 21, 31, 32), Frozen World 240 in 72 (113 in map 1), Sunset 8 in 3,
Desert Nightmare 3 in 2.

**2026-10-19, Aguará**, from the-advocate `54ec3daf` and the ports
`c2912ad`. What the maps' pages name, measured over each game's dump
(distinct names a `ChangePBG` of the map's own pages gives, besides the
map's own panorama; no game has one in a common event):

* Zounds 20, 21, 31: own `dawn1`, and four 640x480 PNGs by time of day
  (`Zounds_{Dawn,Morning,Dusk,Night}Panorama_01`), set by an autostart or
  parallel page on entry by variable 91. Map 32 has none of its own: event
  2 sets `Zounds_DesertPan` (48x64 BMP, looping both ways) at several
  speeds, then `Zounds_ScreenShot_01` (320x240).
* Frozen World 1: own `DarkPanTest` (one colour) and **17** battle
  backdrops, all 640x320 —its battle map—. 70 more maps, almost all with
  no panorama of their own, each name one or two of `CavePanTest`,
  `HillBackDropTest`, `PlainsBackDropTest`, `THighBackDrop`,
  `RelWdsBackDrop`… (640x320).
* Sunset 26, 34, 36: two or three 320x240/448x240 paintings each; the maps
  go **painted**, which this does not cover.
* Desert Nightmare 34 and 82: one or two 320x240 each, both maps flattened.

`git blame` of "the panorama stays the map's": Cardón's `7f62dcdb`
(2026-10-05), on purpose, as the wishlist; the loss line is Hurón's
`3a954b30`.

The plan: every picture a map's pages name goes with it if its panorama
gets a layer —mode 3, flattened or mode 1—, one `pano_table` record per
picture, in the same VRAM tiles, and in mode 3 in the same colour-memory
entries (the most palettes any of them takes); a map with none of its own
gets an empty first record. `OP_PANORAMA` carries the picture's record;
the ROM swaps it with the screen off for the rest of the frame. If the
pictures do not fit with the map, the map goes as before, with its
degradation lines, and the converter log says why.

**Done, 2026-10-19, Aguará** —the-advocate `aguara-panorama-change`
(`d8b7f2cf` and its merge of main), the ports' and the book's of the same
name—. What each map ended with, read in each release's converter log
(`map N: K panoramas, … bytes of ROM, in P palettes from entry E`, and
`its ChangePBG to "X" keeps the panorama there is: <why>`):

| game, map | way | pictures | ROM | mode-3 colours |
|---|---|---|---|---|
| Zounds 20 | flattened | dawn1 + 4 by time of day, 640x240 | 101 KB | 3 palettes |
| Zounds 21 | flattened | the same, 640x320 | 123 KB | 3 palettes |
| Zounds 31 | mode 3 | the same, 640x240 | 101 KB | 4 palettes |
| Zounds 32 | mode 3 | none, desert 48x64, screenshot 320x240 | 8 KB | 4 palettes |
| Frozen World 1 | mode 3 | DarkPanTest + 17 backdrops, 320x240 of 640x320 | 339 KB | 5 palettes |
| Frozen World 145 | flattened | Morning1 + TheHubOnTheScreen | 39 KB | 1 palette |

Each picture is up to the layout's 576 4bpp tiles in mode 3 (768 2bpp in
mode 1); a time-of-day panorama keeps 27–45 colours of 58–136, a Frozen
World backdrop 44–65 of 120–252. No map's background merged a colour more
than before (the reserve came out of free palettes in all of them).

**What a swap costs**: the tiles' DMA is under half a frame; the ring of
the tilemap, 32 rows built cell by cell, about three. Measured on Zounds'
32 with the player in control: 4 frames lost on the swap's tick (1 with
`pano_fill` left out), black. Every swap these games make happens on
entering the map, behind the fade. Draft:
[`a-panorama-swap-goes-black-for-four-frames`](a-panorama-swap-goes-black-for-four-frames.md).

**What does not fit, the limit**, each with its draft:

* a `ChangePBG` after a `Teleport` is the target map's: The Frozen
  World's 125 encounter commands on 69 field maps, which name the battle
  backdrop after jumping to map 1 —[`a-changepbg-after-a-teleport-keeps-the-picture`](a-changepbg-after-a-teleport-keeps-the-picture.md)—;
* a painted map keeps its first painting: Sunset's 26, 34, 36 —[`a-painted-map-keeps-its-first-painting`](a-painted-map-keeps-its-first-painting.md)—;
* a map whose pictures are drawn into its own panorama: Desert
  Nightmare's 34 and 82, Sunset's 60 —[`a-panorama-with-pictures-drawn-into-it-is-not-swapped`](a-panorama-with-pictures-drawn-into-it-is-not-swapped.md)—;
* Frozen World's 127 goes black, as before (its background does not fit
  mode 3);
* the empty name keeps the picture, where RM2k takes it away (a reading;
  none in these games) —[`a-changepbg-with-no-name-keeps-the-panorama`](a-changepbg-with-no-name-keeps-the-panorama.md)—.

`panorama-not-changed` left: Zounds 0 (was 19), Frozen World 126 (was
240; 125 of them after a jump), Sunset 8, Desert Nightmare 3. A map whose
panorama is never seen no longer lists them.

**Verified** with the branch's tools (`install-local cartridge events
wally mapdata convert`, after merging main): `just lint` clean; `just
rust-test`, all green, with new tests for the records
(`a_map_that_swaps_pictures_has_a_record_for_each`), the shared colour
entries (`the_pictures_a_map_swaps_share_their_colour_entries`) and the
compiled picture (`change_pbg_swaps_in_a_picture_the_map_carries`); the
compilation's `maps` hash moved on purpose (one byte more per
`OP_PANORAMA`; without it, the old one); `just test`, 29 passed; `just
boot` from the ports' root on the merged tree, 73 passed, with Zounds' new
`test_the_download_room_shows_the_panoramas_its_event_sets` and its two
goldens —red on the ROM before: map 32 shows no panorama—. Captures
before/after in `/shared/captures/2026-10-19-panorama-change/`. ABL's
whole suite with the branch's tools on the merged tree: 1581 passed, 2
skipped; `abl.sfc` `0bb7056e207398d8…`. Its first run caught a bug of
mine: `SAVE_BYTES`, which repeats the save table's lengths by hand, still
counted the panorama's run as 5 bytes, and every save panicked (52 reds,
fixed in `47dc3f65`); and two ABL tests that repeat the layout from the
save's end on purpose went from 9 bytes to 10.

**Not covered by any test**: a swap with the screen on (only measured by
hand); a saved game on a map that swapped (the picture is saved and
`pano_at` takes it back, unexercised —ABL's save and load in a panorama map runs only the single-picture path—); a swap in mode 1 (no measured map
swaps in mode 1: every one that carries pictures goes mode 3 or
flattened); tiles from the `.msu` in a swap (Vampires Dawn has no
`ChangePBG`); The Frozen World's battle map 1 playing its backdrops
(built and logged, not played). Sunset's bank $C0 has 249 B left with
this (`just space`): the swap's code went to FAR3.

**To install when merging**: `just install cartridge events wally mapdata
convert` —the bytecode changed, which `events` and `cartridge` compile in—.

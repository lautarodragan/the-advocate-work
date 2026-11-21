---
name: "Desert Nightmare: the intro's menu, the intro, and the file screen"
description: "The start menu's options move with the arrows but nothing shows which is chosen; the intro has broken letters over its first message and goes black; the file screen's cursor is a few brown bits"
type: bug
status: testing
assignee: taro
game: desert-nightmare
agents: [Aguará]
---

taro, on 2026-11-20, playing the build of the-advocate `7951af2a` and the
ports `42f70e8` in Mesen2, translated (captures in
`/shared/bug-reports-etc/dn/`):

> At the start the 3 options With Intro / No Intro / Quit show up, and
> pressing the arrows makes sounds and seems to select the options, but
> nothing changes on screen to show it.

> I think it no longer draws garbage in the background. I think the
> background image is fine! The only thing missing would be showing the
> images with their <selected> version. Is it possible to just show the
> images on that screen? If it's feasible, I think it would simplify
> things quite a bit and look nicer. [...] Maybe we could get the result
> just by changing the palette of one of the images. The "selected"
> image is the same as the unselected one, with slightly different
> colours, and a 1px shadow on the inner edges. I think it's a case where
> we could invent something with palette/color cycling, maybe. We'd have
> to see how to make it general, but we can make it specific to this
> game as an experiment, if you think it's worth it.

The original in Wine: `intro-menu-selection-indicator.png`.

> I don't see it that misplaced. The only thing that catches my eye are
> some bits of brown rectangles around "File 1". If I move the selection,
> it shows around File 2, etc; so it must be the selection indicator,
> which we don't manage to render correctly or completely.

`load-file-slightly-broken.png`, and the original in Wine,
`load-file-slightly-broken-original.png`: the face is fine, the cursor
is the only difference.

And the intro: `intro-glitched-bg-1.png`, broken letters over Sandra's
first message, and `intro-black-1.png`/`-2.png`, the intro's messages
over black.

This task also takes over
[`desert-nightmare-start-menu-over-garbage`](desert-nightmare-start-menu-over-garbage.md):
taro sees the background fine now.

## Log

### 2026-11-20, Aguará: done

Branches `aguara-dn-intro-menu` in the-advocate, the ports and the book.
Captures in `/shared/captures/2026-11-20-dn-intro-and-file-screen/`.

#### 1. The start menu: the pictures, shown

**Why they were not shown**: none of the suspects —VRAM, slots, the
converter dropping them for size—. `Introauswahl_1` to `_3` are three
320x240 drawings of the whole menu, one per option lit, under number 1,
and the `map_pictures` rule (`[graphics] map_pictures`) took them as part
of the map: it drew the one shown most (`_1`) into the panorama and
accepted every `ShowPicture` of the three without doing it. The arrows
ran their pages; the screen never changed.

**What was done**: when every show of a number on a map is one of several
drawings of one place —same size, corner and tone, opaque— the converter
draws what they have in common into the map and shows each drawing's own
part as a small picture that goes with the map (`Parts` in
`map_pictures.rs` of rm2k-snes-convert; `with_map` in the events
compiler). It is general, not a Desert Nightmare knob.

**Measured, both ways**:

* the pictures: the three lit boxes are 1465, 1312 and 1143 pixels, 59
  colours each; the map's sprites take 261 tiles in two palettes with
  `Kartencursor`. Fits, and the boxes come out at 15 colours, close to
  the original's —see the captures—;
* the palette swap: the menu is in a mode 3 panorama with 79 colours of
  its own; each lit box would need its 59 colours in entries nothing
  else uses, and the 1 px inner shadow is pixels, not colours. Not done.

**Only map 1 splits.** The first version also took the safe (115) and the
shrine (161); merging Cardón's scene rule (`05f61c64`) and looking at both
on screen against RPG_RT under Wine showed them broken —the safe's parts
did not fit its VRAM, the shrine's wheels took each other's files— and
both are screens the player opens, which the room should not keep. Since
the merge the parts are only for numbers shown from autostart or
parallel pages, by map, number and name, and never for a number Cardón's
rule takes as a scene's (his wins). 115 and 161 are drawn in as on main:
wrong in their own way, the draft
[`desert-nightmare-the-locks-pictures-are-drawn-into-their-rooms`](desert-nightmare-the-locks-pictures-are-drawn-into-their-rooms.md)
and a Known issues line.

#### 2. The file screen's cursor

The cursor's tiles and tilemap were right —VRAM compared word for word
against the save screen opened in game, which drew it whole—: the
title of this game is 4bpp and leaves mode 1 (`be098254`), and
`pano_mode3` only put mode 3 back after a panorama or a painted map, so
the slot screen read the 8bpp cursor as 4bpp. Now it always writes mode
3 (`runtime/pano.s`).

**A Blurred Line does not have it**: its title is 8bpp (`TITLE_BPP = 8`),
in mode 3. Its goldens: see the suite below.

The slot screen draws no window frames, where RPG_RT draws one per file
and one around the header: so does A Blurred Line's (its golden
`suite/save.png`), the port's screen as it was built. taro calls the layout
fine, so it stays.

#### 3. The intro

**The original** (2015 RPG_RT under Wine): the title fades in and out over
black, then the black picture fades out and the whole conversation is
over the gas station, with the game's own text box. So both captures are
bugs.

`Schwarz` and `Introtext` are big pictures —over black, with the map
hidden—, and a big one at transparency 100 stays a black screen: every
message went over black, and the faces' tiles landed on the title's,
which showed as the broken letters. Now a big picture faded to 100 that
the page waits for, with no other big one seen and no later move of the
page bringing it back, is followed by its `ErasePicture` and the map
reloads (`big_fade_outs` in the events compiler). The messages still go
without the game's box: that is the Known issue "Most messages have no
box", Calandria's.

#### Tests

* the-advocate: `drawings_under_one_number_are_drawn_in_common_and_each_shows_its_own`
  (convert), `a_part_of_a_drawing_in_the_map_goes_with_the_map` and
  `a_big_picture_faded_to_nothing_is_taken_down` (events; red without the
  erase).
* the ports: `tests/test_desert_nightmare_start_menu.py`, with five new
  goldens —the three options, the load screen from the title with a game
  saved by the new case `save-screen`, the intro's first message—. Each
  was red before its fix (the menu's three captures were identical; the
  others were looked at). The load screen only in snes9x: the bsnes core
  does not expose the SRAM.

#### The suites

With the tools of the-advocate `d9ff30ba` (this branch): ABL's `just
tests`, 1723 passed and 2 skipped, no golden moved —`abl.sfc` sha256
`860789e009143b2d…`—; the ports' `just boot`, 182 passed, the five new
goldens included. ABL's title is 8bpp and its pages fade no big picture
to nothing, so neither change reaches it.

After merging main with Cardón's `cardon-dn-walls`: see the end.

**How far the fade-out rule reaches**, counted over the dumps with a
throwaway copy of its logic, an upper bound —it does not drop the moves
the console does not compile as big ones, nor the ones an `ErasePicture`
follows anyway—: Desert Nightmare 48 moves, Vampires Dawn 69, The Book of
Three 5, Sunset Over Imdahl 1, the others none. The ones looked at in
Vampires Dawn's map 2 are followed by their own `ErasePicture`, so there
it changes nothing. None of the others was looked at on screen.

#### After merging main with Cardón's `cardon-dn-walls`

His scene rule and the parts' compose with his winning: a number one of
whose shows his rule leaves out is not split (`daf3e4b0`). Then, from
looking at 115 and 161 on screen, the parts go by number and only for
pages that run on their own (`d1972f68`, `e4bbee1e`). With the-advocate
at `e4bbee1e`: ABL's suite 1723 passed, 2 skipped, `abl.sfc` sha256
`d2c519b24ff824b3…` (Cardón's runtime changed it); the ports' `just boot`
185 passed. **The five goldens did not move**: the start menu's test
passes against them as committed.

Then main again (Calandria's and Mulita's, with `OP_WINDOW_COVER`): a big
picture taken down after its fade uncovers the windows as its
`ErasePicture` would (`6c3b09e1`). With the-advocate at `6c3b09e1`:
`just lint` and `just test` green, ABL's suite 1723 passed, 2 skipped,
`abl.sfc` sha256 `75612b88b10d30ae…`; the ports' `just boot` 187 passed.
The five goldens, approved by taro, did not move.

To install when merging: `convert`, `wally`, `events`, and the runtime
(`cartridge`, which assembles from the checkout).

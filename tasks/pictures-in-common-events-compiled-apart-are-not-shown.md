---
name: "The pictures of the common events compiled apart from the maps are not shown"
description: "An automatic or parallel common event, or one a page calls as a shared body, is compiled once without a map, so without pictures: Zounds' pick-axe and notebook, A Blurred Line's portable console and Vampires Dawn's menus show nothing"
type: bug
status: doing
assignee: Carpintero
agents: [Carpintero]
---

Seen by Tijereta on 2026-10-16, with the-advocate `9407d385` plus the
branch `tijereta-more-pictures`, while measuring
[`zounds-pictures-and-the-picture-made-screens`](zounds-pictures-and-the-picture-made-screens.md).
Measured with a throwaway script over the dumps, not played.

**What it is**: the shared bodies of `commons.rs` in the event compiler
—the automatic and parallel common events, and the ones an `OP_CALL`
reaches— are compiled with `pictures: None`: a picture belongs to a map,
its tiles to the map's sprite bank and its entry to the map's table, and a
body compiled once has no map. So their `ShowPicture`, `MovePicture` and
`ErasePicture` are accepted without being done. A map page that calls a
common event with pictures gets them only if the call is pasted in place.

**Where it shows**, most small pictures up at once along the event:
Zounds' `PickAxe` (common 21, automatic on switch 64) 14, `Show Mining
EXP` (27) 10, `Cuaderno de Notas` (29) 9, `Notes- Show Notes` (41) 6;
A Blurred Line's `NewMenuActivated` (39) 11 —the portable console, which
nobody needs to finish the game—; Vampires Dawn's menus (25 to 28, 43, 44)
7; Sunset Over Imdahl's `Menu` (5) 4.

How to see it: build Zounds' `release` and look at
`build/release/degradations.json`: the `picture-not-shown` losses under
`"common"`. The book's research "More pictures at once" weighs what it
would cost.

## 2026-10-17, Mulita: the automatic ones, copied into the maps

Since the-advocate `939a8bd7` (branch `mulita-fw-b-menu`, for
[`frozen-world-the-b-menu-on-the-map-is-not-drawn`](frozen-world-the-b-menu-on-the-map-is-not-drawn.md))
an **automatic** common event with a `ShowPicture` of its own is copied
into each map with room for one more event, as an automatic page of an
added event 0, and its pictures are the map's when they fit beside the
map's own: see `common_pages.rs` in rm2k-snes-convert. What is still as
this draft says: the **parallel** common events, the bodies an automatic
or a page **calls** (an `OP_CALL` to a body without pictures), and the
maps where the copy's pictures do not fit. Zounds' `PickAxe` (21),
Vampires Dawn's and Sunset's menus were not looked at with the change.

## 2026-10-19, Chajá: the big ones are shown

Since the-advocate's branch `chaja-map-item` (for
[`book-of-three-the-map-item-shows-nothing`](book-of-three-the-map-item-shows-nothing.md))
the automatic and parallel common events —and what they call, pasted— are
compiled with **the big pictures** they show: those are the cartridge's,
in a layer that is the same on every map, so a body without a map can show
them. Only when they are all under one number, since the layer holds one
and each it shows takes the screen off; a body that stacks several keeps
them out, and the converter's log says so per common event. Measured on
the ports' games at that branch:

* The Book of Three: common 23's `bo3map`, the map item. Shown.
* Zounds: common 29's `Zounds_Notas_Fondo`, the notebook's background.
  Shown, **alone**: the bar and the "you have notes" text over it are small
  pictures and still not shown, and the map is hidden while it is up.
* Sunset Over Imdahl: commons 4 and 5, big pictures under two numbers. Not
  shown, as before.
* Desert Nightmare: commons 6, 8, 10 and 12, its picture menus, hundreds of
  320x240 pictures under nine or ten numbers. Not shown, as before.
* Vampires Dawn: the body that shows `VDWelt` does not compile, so nothing.
* A Blurred Line: common 16 (`DisplayNameMenu`, automatic on switch 340)
  reaches common 21's six `Aura…Menu`, all under number 1: the cartridge
  carries them, six big pictures more (15 where it carried 9), but in the
  port nothing turns 340 on —only commons 12 and 14 do, which only the
  handheld console reaches, and a custom menu replaces it—, so they are
  never shown: cartridge spent for nothing. A rule that left out the
  automatic common events whose switch nothing starts —what
  `common_pages.rs` already asks for its copies, plus the switch items,
  which it does not count— would save them.

What is still as this draft says: **the small pictures** of every such
body, which need a map's sprite bank, and the big ones a body stacks.

## Defined (2026-10-20, Carpintero)

Measured with the-advocate `3bc68ac4` and the ports `b5cfc1e`.

**How a page gets its pictures today.** A small picture —one that fits
the plane of objects— is **the map's**: the converter cuts the pictures
the scan gathered for the map into 32x32 and 8x8 objects
(`pictures::for_map` in rm2k-snes-convert), Wally puts their tiles at
the end of the map's sprite bank and their palettes from sprite palette 7
down, and the emission writes each one's entry —half size, objects,
palette, colours, base tile— in the map's `picture_data` table. A
`ShowPicture` compiles to `OP_PICTURE slot, image, …`: `image` is the
entry in the **loaded map's** table, and `slot` one of the console's
sixteen, given per map by number. So the bytecode names a picture by an
index that only means something on one map, and its tiles are in VRAM
only because they came up with that map's bank. A body compiled once,
without a map, cannot name one: its `ShowPicture`s are accepted without
being done. The big ones are the exception since Chajá's change: the
cartridge carries them once, in a table every map shares.

**Who is left out, measured.** ABL's portable console is not one any
more: common 39 has been a custom menu of the engine since 2026-10-04
(taro: "va el diseño, con retrato, \"Console\", y sólo con el ítem"),
and what is left with pictures, commons 11 and 16, hangs from switches
335 and 340, which only item 150, `SCRATCHEDOUT`, turns on, and nothing
gives it. ABL loses nothing a player reaches. **Zounds** does: its
pick-axe (21), notebook (29), notes (40) and permit (6) are automatic on
a switch that a **switch item** turns on —items 23, 35 and 8—, which
the copies of 939a8bd7 did not count, so Zounds gets no copy at all.

**Options, measured on Zounds.**

1. **The copies, reached by the switch items too** (what `common_pages`
   does, with the items counted): 187 of 189 maps get the copy event, and
   the cartridge two banks more of bytecode (62 to 64). But a map takes
   the copies' pictures all together or none, and the four do not fit
   together **on any map**: nothing is shown. Each one alone, measured
   by copying only it: the pick-axe fits on 23 maps, the notes on 135,
   the permit on 130, the notebook on none.
2. **The copies, their pictures one common event at a time** —kept if
   each costs the map nothing beside those kept before—: tried. The
   permit, first by number, takes 320 tiles on 128 maps and then the
   pick-axe fits on none; and each map's bank carries the tiles it keeps,
   **eleven banks** more (62 to 73) for one picture stored 128 times.
   Which one goes first is a guess the cartridge cannot make.
3. **A cartridge-wide table of the common events' pictures, their tiles
   uploaded when one is shown.** The tiles are in the cartridge once; the
   body compiled once names its pictures by an index every map shares;
   and each common event is judged **alone** on each map —does its set
   fit beside the map's bank, palettes and message arrow?—, since only
   one set is in VRAM at a time. No copies, so it serves the parallel
   ones and the bodies the automatic ones call too. It costs runtime: an
   upload of the set's tiles through the vblank when it is first shown,
   and two reads that take the base tile and the palette from the map.

**Chosen: 3.** 1 and 2 pay for every map the VRAM and the cartridge of
pictures that are seen on few of them, and 2 makes them compete; 3 pays
once in the cartridge and only while it is up in VRAM. What none of the
three does is show the pick-axe screen where it is used, in the desert
(map 34): its six pictures and digits take 400 object tiles and seven
sprite palettes —`Zounds_Dialogue_4`, the 320x80 box under its
messages, is 384 of the tiles—, and no map with characters leaves that.
That one needs either the characters to give the plane up while the
screen is up, or the box to be the message window: a decision for taro,
written as a draft when this is done.

**Done**: the common events that run without a map show their small
pictures wherever their set fits beside the map; Zounds' notes and permit
on the maps where they fit, and the pick-axe screen on the ones where it
fits, with a golden red before; the converter's log says, per set, on
how many maps it fits; ABL's suite and the ports' `boot` green, the space
of every cartridge measured before and after; the book's
`internals/vram.md` and the divergence say it.

**First step**: the set of each common event that runs anywhere, from
the scan's `commons_pictures`, which today keeps only the big ones.

## 2026-10-20, Carpintero: option 3, built

The-advocate `aadb9151`, branch `carpintero-ce-pictures` (from
`3bc68ac4`); the ports `e8ffd29` and `521e59e`, branch of the same name;
the book `785095d`.

* **Sets**: `commons::picture_sets` in the event compiler gathers what
  each common event that runs without a map shows with every body it calls
  —an automatic one and its shared bodies, merged when two reach the same
  body; a parallel one alone, its calls pasted—, and the scan answers them
  as `common_sets`. The converter cuts each as a map's pictures, from tile 0
  and palette 0 (`common_pictures.rs`), the fewest pictures first, since the
  table names 127.
* **Bytecode**: a body is compiled with its set's pictures; `OP_PICTURE`'s
  image has bit 7 set and the slot is counted from the top. No new opcode:
  0x5A is free. A `MovePicture` of a number the body's set shows small moves
  that one and not a big one under the same number, which another common
  event shows —the notebook's background took the record player's fade—.
* **Emission**: the entries after the maps' in `picture_data`, each set's
  tiles once, and per map the tile and palette where the sets go and a bit
  per set that fits there, measured alone (`picture_common_section`).
* **Runtime**: `runtime/picture_common.s`. Shown, a set goes up past the
  map's bank, arrow and gold window through `vram_drain`'s budget; its
  pictures are drawn once it is there; one set at a time; `load_sprite`
  puts it back.

Measured on Zounds: the permit (6) fits on 53 of 189 maps, the notes (40,
42) on 96, the record player (36) on 128, the music bar (68) on 145; the
pick-axe (21, 27: 400 tiles, seven palettes) and the notebook (29, 30, 41:
704 tiles) on none. Those two are
[`zounds-pick-axe-and-notebook-fit-beside-no-map`](zounds-pick-axe-and-notebook-fit-beside-no-map.md),
a draft with what they would take. The permit shows, but its slide up is
a `MovePicture` that zooms it from 60 % to 100 %, which small pictures do
not do: it stays small and translucent at the bottom.

**Done, against what was asked**: the common events' small pictures show
where they fit, and Zounds' record player has its golden, red before. **Not
done**: the pick-axe and the notebook, which fit beside no map; and ABL's
portable console, which is the engine's custom menu since 2026-10-04 by
taro's decision —its pictures are not shown on purpose—, while its other
picture menus (commons 11 and 16) hang from an item nothing gives.

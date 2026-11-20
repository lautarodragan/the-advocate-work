---
name: "ShowWindow: a window command of our own"
description: "An RPG Maker 2000 PLUS command like ShowPicture that draws a window from the System and composes its text at run time, so a menu made of pictures can be a window that fits every map"
type: feature
status: testing
assignee: taro
agents: [Mulita]
---

Asked by taro on 2026-10-19, while Frozen World's B menu was blind on 22
maps
([`frozen-world-the-b-menu-is-blind-on-the-maps-without-room`](frozen-world-the-b-menu-is-blind-on-the-maps-without-room.md)):
the limit was the menu being `ShowPicture` at all. That menu became RM2k's
own `ShowChoice` —the cheap path—; this is the real one, to design and
measure, a sibling of the wishlist's
[`a-window-system-for-rm`](a-window-system-for-rm.md). It belongs with
RPG Maker 2000 PLUS (the book's `decisions/rm2k-plus.md`): any game can
use it, and the game still runs in RPG_RT.

**What it is**: like `ShowPicture`, a numbered thing put up and taken
down by events, but its pixels are not a file: the console draws the
window's frame and background from the System graphic in use, and
composes its text with the message window's font, at run time. A menu of
three pictures that differ only in which row is lit becomes one window
whose lit row is a variable.

## What was measured (Mulita, 2026-10-19)

With the-advocate `hornero-integ` (`0c9de576`) and its `runtime/`.

* **The message window owns a BG2 tile bank of 256 tiles in every one of
  the VRAM layouts** —`window` in `rm2k-snes/mapdata/src/vram.rs`, at
  `$6800`, `$6000` or `$5000` depending on the layout—, and its own 32x32
  tilemap. That is why `ShowChoice` fits on every map: it never competes
  with the map's sprites, which is what the pictures did. Measured on
  Frozen World's 22 maps that had no room for the menu's pictures: see the
  captures of that task.
* **The text area takes 240 of those 256 tiles**: 30 cells by 8, one tile
  per cell and not deduplicated, composed a line at a time into a 1,920
  byte buffer and uploaded in the next vblank (`runtime/messages.s`, "the
  text composer"). The other 16 are the frame. **So a window that coexists
  with an open message has no tiles in BG2**: the bank is full with the
  message's text, whatever the message says.
* **BG2 is also the map's layer above**: on the window's lines an HDMA
  points BG2 at the window's tilemap (`msg_hdma_build` in
  `runtime/message_place.s`), and the roofs and treetops are not drawn
  there. A second window would take more lines from the layer above, the
  same way.
* **A font of one character per tile would not change any of this**: the
  glyphs are 6 px wide and composed pixel by pixel because they do not
  align to 8 px cells, but what limits is not the font, it is which bank
  the window's tiles live in. The message window was never the limit on
  those 22 maps.
* **The gold window is the precedent for a second window**: RM2k's inn
  opens an 88x32 `Window_Gold` next to its message, and the console draws
  it as 44 8x8 objects, past the map's sprite bank and in the sprite
  palette nobody takes, composing the number into it at run time
  (`runtime/gold_window.s`, decided per map by `arrow_obj` in
  rm2k-snes-mapdata). A map without that room shows no gold window. That
  is the cost of a window that coexists with a message: tiles in the
  sprite bank —Frozen World's menu window, 88x56, would be 77 8x8 tiles
  against the 320 its three pictures took, but on the same bank— and one
  sprite palette.

## The design this leaves

1. **Without an open message, in the message window's own bank**: a
   ShowWindow takes the window's tilemap and its text area while no
   message is up, as `ShowChoice` does. It fits on every map, as the
   window does, and costs no sprite tile. It cannot be up at the same time
   as a message; RM2k's own menus cannot either.
2. **With an open message, as objects**, like the gold window: only where
   the map leaves the tiles and a palette, and the build says where not.
   Second stage, only if a game asks for it.

**Where its text is composed**: the same composer as the messages
(`MSG_CHARS` letters a pass), so a window of four lines appears in about
as long as a message of four lines —a quarter of a second, measured for
the messages in `messages.s`—. Re-lighting a row is redrawing two lines,
not the window.

**How a game authors it**: RM2k's editor has no new commands, and the game
has to keep running in RPG_RT. The proposal is a `Comment` (code 12410)
whose first line is a directive the event compiler reads —`@window 1, x,
y, w, h` with the lines of text after it, `@window_erase 1`, and the lit
row by a variable—: RPG_RT skips comments, so the game runs there without
the window. The other way, a `ShowPicture` of a name that marks it, would
show nothing in RPG_RT either, but it leaves a missing file there.

**Opcodes**: one or two new event opcodes, numbered when the task is
taken.

## Not measured

What it costs in bank 0 and in the runtime's banks, and how a window's
line is lit —a row's background redrawn, or a cursor as the choice's—.

## A strict requirement (taro, 2026-10-19)

The message window's HDMA takes BG2 —the map's layer above— for the
**whole width** of the lines it covers. A message is the whole width
anyway; a narrow window like Frozen World's menu (88 px) would make the
roofs and treetops beside it vanish while it is up, which the pictures it
replaces —objects over the layers— did not do. taro noticed the
difference playing the picture menu, and made it a strict requirement:
roofs cut off while a window is up would be too disruptive. **A
ShowWindow narrower than the screen keeps the layer above beside it**,
however it is done: e.g. its tiles laid into
BG2's own tilemap instead of swapping the line's, or the console's
windows limiting the swap to its columns.

## Taken as a proof of concept (2026-11-20, Mulita)

taro, translated, after Carpintero's study of Desert Nightmare's room
(`ports/desert-nightmare/research/2026-11-20-where-the-room-goes.md`)
and the talk about common events copied for their pictures:

> A common event's show picture should not be map decoration in any case.
> It isn't impossible, but it is unlikely. I'd skip that analysis or take
> it with another depth: assume those show pictures are always custom
> systems, understand how they work by reading the code and the images,
> and see if we can replace images with text. A show picture could be
> converted into a ShowMessage with parametrisable x, y, w, h. That is not
> necessarily always possible, but if we reduce those windows to
> multiples of 8 for x, y, w, h and palettes of 2-4 colours, maybe we
> don't need more than that to show them inside the maps, without making
> them full screen. I think that's the interesting experiment: can we
> invent a ShowMessageWindow that replaces ShowPicture one to one, as a
> POC, and do the image-to-text of the images via AI?

**The POC**: ShowWindow as designed above (stage 1: the message window's
bank, no open message; the strict requirement on the layer above holds),
first used by Desert Nightmare's own menu
([`desert-nightmare-the-game-s-menu-draws-nothing`](desert-nightmare-the-game-s-menu-draws-nothing.md)):
its pictures read by the agent —an image-to-text done once, by looking at
each picture, and kept as a reviewed patch, not run at build time— and
replaced one to one by windows in a patch of the game's data.

taro, translated, through Hornero, on what the image-to-text may cost a
port:

> "AI" is Claude Code, ChatGPT, whatever. It could also be done by hand by
> a person, but packaging it in a prompt works too. If each port needs some
> AI work, as long as it is trivial enough that someone can do it by
> copy-pasting a prompt we give them, and it runs successfully on a 20 USD
> plan without consuming a significant % of the 5-hour limit, we're fine.

And Hornero, on the requirement: it is probably what the transparent
message already does
([`a-transparent-message-keeps-the-layer-above`](a-transparent-message-keeps-the-layer-above.md)):
on a window's lines its plane carries the layer above; the columns beside a
narrow framed window are cells with nothing of the window, which copy the
layer's entries the same way.

## Log (Mulita, 2026-11-20)

Worktrees from the-advocate `16081af9` and the ports `1177cbc`, branches
`mulita-show-window` in both and in the book; main merged in at
`3043b395` / `09d9b0d` / `2d9160a` (Chajá's copies that draw).

**Authoring: a comment in front of the picture.** Of the two ways, the
`Comment` directive, placed **right before the `ShowPicture` it stands in
for**: `@window <id> <x> <y> <w> <h> [plain]`, its lines the text, and the
`ShowPicture` of picture `<id>` right after it is not compiled; an
`ErasePicture` of `<id>` takes the window down too. That is the one-to-one
replacement taro framed, and it keeps the fork running in RPG_RT with its
pictures: RPG_RT skips the comment and shows the picture. A replacement
at the patch level —a table "picture `Optionen2` is this window" read by
the build— would leave the game's data alone, but it is a rule applied at
build time, which is what the POC was asked not to be, and it cannot say
"here a window and no picture" for a game written for PLUS. A comment
alone, with no picture after it, is that. The coordinates are the
console's 256x224, multiples of 8: RPG_RT never draws the window, so there
is no RM2k position to keep.

**Opcodes**: `OP_WINDOW` 0x58 and `OP_WINDOW_ERASE` 0x59, the next two on
main: Hornero's 0x5A and 0x5B leave a gap while Tijereta's 0x58 and 0x59
are not merged, and the declaration does not compile with one. If
Tijereta merges first, these go to 0x5A and 0x5B (both sides read the
declaration; nothing else names the numbers).

**The tiles are the game's, per window id**: every `@window` of the game is
measured, each id gets the widest text each of its lines ever has, two
cell rows of it, and all ids together must fit the message window's 240
text tiles (239: the last is the windows' background). Measured for
Desert Nightmare's menu with the console's font: the options 19 cells
(38 tiles), each item square 8 (16, six of them 96), the description 8 +
21 + 18 (94), the cursor and the page arrows 2 each. It fits with a few
tiles to spare. The keys screen —the same grid, with names like "Clothing
store key", 11 cells— would not fit beside it in the same ids, which is
why only the inventory is done.

**The layer above beside a narrow window** is the transparent message's
mechanism, rebuilt for a framed window rather than reused: `message_layer.s`
carries the layer on the *message's* text lines, inside its pipeline. Here
the screen's span from the first row a window covers to the last is
composed whole in RAM —the layer's tilemap rows read from VRAM in the
vblank, then each window's cells over them— and goes to the window's
tilemap; HDMA points BG2 at it on those lines. Same rule: only with the
camera on the 8-pixel grid, as it always is at rest.

**Built.** the-advocate: `windows.rs` in the event compiler (the
directive, the registry of tiles, the pictures it stands in for),
`compile_window` and the erase in `compile.rs`, the converter's
`window_slots` and `SHOW_WINDOW_SLOTS` in mapdata's emission, and
`runtime/show_window.s` with hooks in `boot.s` (the main loop),
`vblank.s` (`flush_video` with no message up), `messages.s`
(`stamp_window_at`: a map, a big picture or a System loaded draws them
again), `picture_far.s` (`pic_clear`: a map change erases them, as RM2k's
pictures) and `interpreter_message.s` (the two opcodes). A game without a
`@window` assembles none of it.

Things learned on the way, each in a comment where it bites:

* Desert Nightmare's face behind the options is a **big picture** since
  Chajá's copies that draw: the windows go over it, at the window's
  tilemap where the big picture moved it (`MSG_SC`), and the layer above
  they copy is the one it emptied.
* **The vblank needs its own scratch**: `flush_video` can come in the
  middle of the main loop's overlay, and sharing `SW_T`/`SW_U` with it
  wrote the overlay all over far RAM (the first build hung on the
  inventory).
* **The menu shows its options twice in a row** (common 4, then 5): a
  window shown again exactly as it is up costs nothing now (`SW_CHG`).
* **A line's text tiles are the widest the game writes on that line of
  that window**, so a narrow window would ink its neighbour with the
  blank rest of them: the cells drawn are clipped to the window's room.

**The menu, measured** (snes9x, the bulb picked up, room 4 of the
warehouse): the options appear about 20 ticks after B (five lines, one a
frame, the layer read in two vblanks, the rows up in one); the inventory
about 30 more. A box over the menu ("You have no items.", "Really
quit?") takes the windows off and they come back when it closes. Side by
side with the original's pictures in
`/shared/captures/2026-11-20-show-window/`.

**The layer above beside a narrow window**: the case
`window-beside-roofs` shows the options' window alone on map 4's street.
Desert Nightmare paints what is above the hero into BG1 and moves the
unreachable upper tiles below (`unreachable_above_below`), so the pixels
beside the window came out the same even with the runtime's copy taken
out —tried on maps 4, 10 and 37—. What the test checks then is the
tilemaps: right of the window, on its rows, the window's tilemap carries
the layer's entries, 18 of them tiles; with the copy taken out, red (18 of
264 differ). Not shown on a game whose BG2 draws something there: none has
a window.

**What it costs** (`just space`, Desert Nightmare's release, against
main's tools at `afb9165d` —Cardón's painted cells and Calandria's one
font in— with only the two opcodes declared): bank $C0 2,118 → 645 bytes
free, bank $C1 3,019 → 1,428, bank 0 4,178 → 4,133, bank 1 1,285 → 1,255,
far RAM 2,626 → 154 (`SW_MAP`, the screen's 1,792 bytes, is most of it:
it could hold only the span's rows), the text block +1,384 bytes, data
banks 78 → 79 of 126. With Cardón's painted cells FAR3 alone no longer
held the file (1,043 bytes over, before the one font freed some), so it
is split: the vblank's half and the doors in FAR2, the composer and the
composition in FAR3. The letters go through `compose_char_far`, the
message window's own, inked with its colours.
A game without a window assembles none of it: **every other game's ROM is
byte for byte the same** as one built with main's tools plus the two
opcodes —ABL's release and its ten test cartridges, the six other games'
releases and Zounds' `exits`—, and Sunset over Imdahl's and Zounds'
`just space` with it.

**Verified**: the event compiler's tests (five in `windows.rs`, two in
`compile.rs`), `just test` (29), the crates' tests of events, bytecode,
convert, mapdata and cartridge; the ports' `test_desert_nightmare_menu.py`
(three: the menu's four screens against goldens in snes9x, the inventory
the same in bsnes, and the layer above beside the window by its tilemap
entries and its pixels —shown red with the copy taken out—); with the
branch's tools after the last merge, the ports' `just boot`, 175 passed,
and ABL's `just tests`, 1,723 passed and 2 skipped, `test_cores.py`
among them. **Not covered by any test**: a window under a camera that moves
(the copy goes stale until the camera stops on the grid), a window on a
map whose BG2 is its panorama (`PANO_ON` 3: nothing beside it), a System
change with windows up, a window over a battle's return, two non-zero
colours in windows up together (the second goes to the window's nearest),
the gradient background of a System (drawn flat), and anything on real
hardware —every vblank step asks `vblank_line` as the transparent
message's do, but nothing was played on a console or in Mednafen—.

**For a full version**: windows beside an open message (stage two, as
objects, as the gold window); the keys, notes and maps screens (other
window ids, or the window ids decoupled from the picture numbers); the
fades the menu's `MovePicture`s ask for (the windows appear at once); a
window that follows a moving camera; the cursor as the System's cursor
rather than a `>`; a page's own text positions (`\x[n]`) so a grid can be
one window; and the image-to-text prompt run on a real 20 USD plan, which
was only counted here.

**To merge** (main merged in: the-advocate `afb9165d`, the ports and the
book at their merges of the one font): the-advocate `mulita-show-window` (opcodes 0x58 and 0x59:
renumber to 0x5A and 0x5B if Tijereta's land first), the ports'
`mulita-show-window` (the goldens in their own commit), the book's
`mulita-show-window`. Install `events`, `convert`, `mapdata`,
`cartridge` and `rm2k-snes-audio` (every crate the bytecode's declaration
reaches); the runtime is the checkout's.

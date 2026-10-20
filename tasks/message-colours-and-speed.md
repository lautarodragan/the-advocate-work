---
name: "Message colours and speed"
description: "\\c[n] and \\s[n] in a message box are discarded today: coloured words come out in the plain colour and the text goes at one speed"
type: feature
status: doing
assignee: Tijereta
agents: [Tijereta]
---

Split from `draw-the-faces-and-really-wait-on-the-escapes.md` on
2026-10-12, by taro.

`\c[n]` and `\s[n]` are discarded in `with_wait_marks` —`without_waits`
until `waits-in-the-middle-of-a-box.md`, which also left `\.` at the 16
frames of speed 1: in RPG_RT a speed past 16 lengthens it—
(`rm2k-snes/text/src/refit.rs`;
`ignore-the-color-codes-in-messages-for-now.md`). Doing them for real
requires a text palette —the System's twenty text colours, against the
window's CGRAM entries— and a drawing pace that the ROM doesn't have.

## Done when

Hornero's, on 2026-10-20, since the task had none:

* a box's `\c[n]` draws its words in System colour `n`, from the
  System's twenty —a golden of the test game with coloured words, red
  with main's tools—;
* the box is typed at RM2k's pace, `\s[n]` changing it —a test that
  counts the frames per letter at two speeds—, with `\.` `\|` `\>` `\<`
  as easyrpg's `Window_Message` does them;
* what the palette and the text layer cannot hold is measured, said, and
  degrades without stopping a game.

## Working notes (Tijereta)

Branches `tijereta-message-colours` in the-advocate, the ports and the
book, from `3bc68ac4`, `3cd810d` and `0b96ba4`.

**What the games use** (from `data/`, every string): Vampires Dawn 26,000
colour escapes over all twenty colours and 296 speeds; Zounds 5,400
colours —`\c[5]` on the speaker's name— and 24 speeds; Desert Nightmare
4,500 colours (only 1 and 0) and 39 speeds; Sunset 1,700 colours (`\C[2]`
mostly); Dooms 2 five `\S[n]`. **ABL and The Book of Three use none**:
their boxes only change in their pace.

**One colour per line covers almost all**: lines with letters in two
colours other than 0 are 39 of 7,142 in Zounds and 10 of 49,488 in
Vampires Dawn; boxes with two or more, 118 of 2,665 and 57 of 17,363.

**Where a colour can go.** The window's palette is 0 and in Zounds, Vampires
Dawn and Desert Nightmare its fifteen entries are full; every entry past the
window's is the maps' background. With colour `n`'s rows taken to the
nearest of the window's entries —what the grey of an inn's "Yes" does—
Zounds' red `\c[5]` comes out a blue-grey: the windows are blue and grey.
And a colour's gradient wants one entry per row, eight of them. Every HDMA
channel is taken (1-3 the window, 4 the big picture's wave, 5 the face, 6
BG1's mask, 7 and 0 general DMA), so an entry rewritten line by line, which
would give each line its colour with its gradient, has no channel.

**The design taken**: one entry of palette 0 is the box's **ink**, reserved
only in a cartridge whose messages use a colour other than 0. A System
window that already fills the fifteen is reduced to fourteen —Adeleine
merges one of its colours— and one with room gives up one map entry. The
first colour other than 0 a box types takes the ink: its value goes to
CGRAM in the next vblank, and its rows go to the ink or to a window entry,
whichever is nearer —the ink's value is the mean of the colour's rows,
weighted by how many of the font's pixels each row has—. Any other colour
in that box goes to the nearest window entries, as the grey does. Each
letter is recoloured after it is composed, as the grey is.

**The pace**: the box is typed in a window already up, as RM2k does: the
four lines are blanked, the window opens, and the letters go up as they are
composed, at easyrpg's `SetWaitForCharacter` —speed 1 two letters a frame,
speed `n` `n / 2 + 1` frames each, the last letter of the box two—; `\.`
16 frames plus what a speed past 16 adds, `\|` 61, `\!` a key, `\>` and
`\<` the instant text until the end of the line. That replaces the cut of
`message_waits.s`: a wait is a stop in the typing, not a cut box composed
again. A box drawn again with the window up —a choice's cursor moving— is
not typed.

**The window pays for the ink, not the maps.** First the ink took the entry
after the window's, which costs every map's background one; in the test
game the RTP System already fills fifteen, so either way it was the window
that merged a colour —the darkest band of its gradient, 2,168 pixels of
every capture with a box—. Decided: the entries the window takes are the
same with the ink as without it, one of its own colours gives up its entry,
and no map moves in any game.

**Found on the way, fixed**: the vblank that turns the window off wrote
`HDMAEN` without looking at whether the vblank was over. The first vblank
of a box's blanking is heavy —a line's upload and a face's step—, it ran
past, and the face's channel stopped in the middle of the frame with its
colours left in palette 1, the map's: the test game's grass went grey
after a box with a face, and stayed so under the next box without one.
Now it is turned off only while the vblank lasts, as it is turned on.

**Cost** (`just space`, ABL's cartridges, main's tools against these):
bank 0 10 bytes —`release` 108 to 98, `test-change-system` 53 to 43—;
`FAR3` 1,002 bytes more —`message_pace.s` against the cut of
`message_waits.s`—, `FAR2` 12 fewer, far RAM 26 bytes more, BSS one byte
(`MSG_TYPE`). The twenty colours' tables, 520 bytes per System in
`window_gold`, go only in a cartridge with an ink —ABL and The Book of
Three carry none—.

**Every game's bank 0 loses the same 10 bytes**: Sunset is left with 15,
Vampires Dawn with 35, ABL's `test-change-system` with 43 —the tightest
three—. **Vampires Dawn is the one that pays in data**: its 26,000 colours
and speeds are two bytes each in its texts now, instead of being dropped,
and its texts went from 222,209 to 239,921 bytes —22,223 left of the
block—; and its data banks, all 126 used already on main with 970 bytes of
gap, keep 289. The next thing its data grows by may not fit.

**The converter says nothing new**: each game's `converter.log` is the same
as main's but for its paths.

**ABL's suite with the boxes typed**: 107 reds the first time, all of the
same two kinds. Tests that press A as soon as `msg_open` is on —a box
typed does not take the key, as in RM2k— now wait for `box_up` in the
harness, the window up and its box typed. And captures taken at a fixed
tick that now fall in the middle of a box being typed, or a scene that
runs later because its boxes last longer, or the message arrow on the
other half of its blink: looked at one by one, nothing broken.
`auto-close` closes 61 ticks after the box is typed, at 93 and 215 instead
of 63 and 185; its goldens are the same pictures, renamed.

**The race's lap of map 49 loses 63 frames in 976 ticks, against 55 on
main** —and its limit was 58—. Measured that it is not what a frame
costs: the same runtime with the boxes typed at once gives 55; main's
runtime padded with 1,002 bytes in `FAR3` or 10 in bank 0, 55; the
start delayed after the race's boxes by 0 to 128 ticks, 60 to 63. The
boxes before the race last longer, and the race starts from another
moment of what runs in parallel. `EXTRA_FRAMES` goes from 6 to 7.

**The root suite** (`just boot`, the other games): 14 reds, of the same
kinds. Three limits measured against boxes that came up whole —The Book
of Three's camp reaches its inn at tick 4,826 after 44 typed boxes, and
was given 4,000; Desert Nightmare's shop gives control back at 643, and
was given 600— and four milestone photos at fixed ticks that now fell
early in their scenes: each new tick was searched frame by frame, and
the picture there is the old golden pixel for pixel. Twenty goldens move:
Sunset's speaker names, `\C[2]Boy:` and `\C[2]Man:`, now in colour 2
—the feature—; the camp's tutorial question with its arrow, photographed
typed; the rest an animation's phase, flowers, water, a fountain.

**Merging main**: the-advocate's `origin/main` brought Chajá's
`upload_line`, which leaves a window line for the next vblank when it no
longer fits —the hole in The Book of Three's lava tunnels—. It merged
without a conflict and was the convention to look at by hand: its margin
counted on `msg_arrow` writing only the arrow, and with the typing
`msg_arrow` also carries the typed cells, up to 512 bytes. `typed_up` now
makes the same test with its own size, and late cells wait for the next
vblank. The book's lossless page had collided on the same paragraph; it
says both.

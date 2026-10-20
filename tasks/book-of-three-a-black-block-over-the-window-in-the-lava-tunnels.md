---
name: "Book of Three: a black block over the window in the lava tunnels"
description: "On map 46 the message window carries a black block over its lower right corner, about 32 by 8 pixels with a ragged top"
type: bug
status: testing
assignee: taro
agents: [Calandria, Chajá]
---

Seen by Calandria on 2026-10-19 in snes9x captures of the `lava` and
`rescue` milestones of `tests/test_book_of_three_milestones.py`, with the
release built by the-advocate `9592b88b` and the ports `c420032` —before
any change of `calandria-route-graphics`— and the same after it. Not
compared with the original.

**What is seen**: on map 46 ("Lava Tunnels"), while a message is open —
Taran's "Aaaaaaaagggggggghhhhhhhh!!", Fflewddur's "Look! It's Taran... he's
in trouble!"— a black block about 32 by 8 pixels sits over the window's
lower right corner, with a ragged top edge, as if something were drawn
over the window there. The message windows seen on maps 21 and 32 do not
have it.

**How to see it**: the frame some 140 ticks after the action of the `rescue`
milestone (or of `lava`), with
`/shared/captures/2026-10-19-book-of-three-route-graphics/map46-window-block.png`
as the capture.

## Checked (2026-10-20, Tijereta)

Not looked at on screen. A lead, not checked: in The Book of Three's
release build of the ports `68bf55b`, map 46 is one of the maps whose
message arrow "stays in the window's cells" because its eight sprite
palettes are taken —see
[`the-bare-window-s-arrow-keeps-its-band-on-maps-with-eight-sprite-palettes`](the-bare-window-s-arrow-keeps-its-band-on-maps-with-eight-sprite-palettes.md)—,
and it is the map whose route-dressed characters are left out for its
palettes. Maps 21 and 32, without the block, could be compared on that.

## Defined (2026-10-20, Chajá)

Reproduced on the-advocate `3bc68ac4` and the ports `b5cfc1e`, snes9x,
case `milestone-rescue`: 135 ticks after the step, when Fflewddur's "Look!
It's Taran... he's in trouble!" opens, until the box is closed.

**It is not drawn over the window: it is a hole in it.** The window's
tiles 0x13E to 0x142 —the last four and a half cells of the second line of
text, row 6 of the window— stay at colour 0, transparent, and what shows
through is the map's BG1, the cave's dark rock. The ragged top is the DMA
cut in the middle of tile 0x13E: its first five rows have the background,
the rest does not. In VRAM, the line's upload stopped about 150 bytes
before its 1920.

**Why**: that line's DMA, from `upload_line` in `flush_video`, ran past
the vblank. Measured with the scanline latched at the end of the DMA (a
temporary probe): on map 46 a window line usually ends on line 246; with a
step of the ChipSet animation in the same vblank it ends on 255 or 260,
and on tick 135 **both** families stepped —anim_pend $0A, 1664 bytes— and
the line ended on line 1 of the next frame, with its tail written while the
screen was drawing, which VRAM ignores. Map 46 is the one whose lava
animation is near the WRAM cap (25 water tiles), which is why the other
maps' windows never showed it. The budget in `flush_video` caps the poses
when a line waits, but the ChipSet's step goes up whatever the budget
says, and the line goes last.

**Done**: a window line never goes up past the point where its DMA still
fits in the vblank; if it does not fit it waits for the next one —the
composer already waits for `msg_upload` to clear—, and the window does not
appear before its last line is up. Map 46's rescue scene has no hole.

**First step**: `upload_line` reads the scanline and leaves `msg_upload`
set when it is too late; `flush_video` does not finish a window whose last
line is still waiting.

## Done (2026-10-20, Chajá)

the-advocate `0b8847c0`, on the branch `chaja-lava-tunnels`. `upload_line` moved to FAR3 and reads the
scanline first: from `LINE_LATEST` (line 246) on, it leaves the line for
the next vblank with `msg_upload` set, and `flush_video` does not turn on
a box whose last line is still waiting. A deferred line costs the box one
frame; the composer already waited for `msg_upload` to clear. The ChipSet
step could not be the one to wait: `anim_tick` clears what is pending on
every tick, so a deferred step would be a lost one. Bank 0 gains bytes
instead of spending them.

What was run: map 46's rescue scene, case `milestone-rescue`, tick 140,
before and after, in snes9x and bsnes —the hole before in both, none
after—, and a throwaway probe that reads the window's text tiles from VRAM
in snes9x on every frame of the `rescue` and `lava` milestones it saw a
box on map 46 in: colour 0 on four of them before, on none after. **No
test of the suite covers it**: no golden photographs a box on map 46 at
that moment. Captures in `/shared/captures/2026-10-20-lava-tunnels/`.

**To play**: The Book of Three, the rescue in the lava tunnels: when
Fflewddur says "Look! It's Taran... he's in trouble!", the window's lower
right corner is whole.

**What to install when merging**: nothing for this one —it is runtime
only, and the global tools assemble the runtime of `~/the-advocate`—.

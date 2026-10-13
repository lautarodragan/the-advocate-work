---
name: "Waits in the middle of a box"
description: "The escapes \\. \\| \\! in the middle of a message box are discarded today; RM2k waits a quarter of a second, a second, or a key there"
type: feature
status: testing
assignee: taro
agents: [Tijereta]
---

Split from `draw-the-faces-and-really-wait-on-the-escapes.md` on
2026-10-12, by taro: the cheapest of the three, because it competes for
neither palettes nor VRAM.

In RM2k `\.` waits a quarter of a second, `\|` one second and `\!` a key.
The ROM only knows how to wait for `\|` at the end of the box (the header
with the pauses); in the middle, `without_waits` in
`rm2k-snes/text/src/refit.rs` discards them. Doing it for real requires the
box to be drawn in stretches. When done, `\.`, `\|` and `\!` stop being
discarded, and the debt of `faces-and-wait-escapes-in-messages.md` no
longer covers them.

## Working notes (Tijereta)

Branches `tijereta-esperas` in the-advocate, the ports and the book, from
`25d93f0a`, `742e127` and `381001b`.

**How the ROM draws a box today**: off screen, one line at a time
(`message_tick`, `MSG_CHARS` letters per frame into the one-line
`text_buf`, uploaded in the next vblank), and the window turns on only when
all four lines are up. So there is no halfway to show.

**The design**: a wait is a byte in the line, `WAIT` (`$FE`, taken from the
pairs like `VARIABLE`) and which one (16 frames, 61, or a key), counted in
the line's length so a wait after the last letter is still read. When the
composer reads one it **cuts the box there**: the line's length becomes the
letters drawn and the box's line count the lines up to this one, so the
lines below come out blank —the composer already primes and uploads the
lines a box does not carry— and the window turns on with what there is.
After the wait the cut line is composed again from its start, skipping the
waits already done, and the composer goes on. Every box with waits opens
with an announcement byte, so the page holds its tail (`\|` pauses, `\^`)
until the last stretch is on screen. All of it in a new
`runtime/message_waits.s` (bank FAR2), with hooks in bank 0: one `jsl` at
the top of `message_tick`, the line-start clears moved into a `jsl`, a
check in `events_tick` and the reset in `msg_start`.

Why not the other designs: keeping the half-drawn line while blanking the
ones below needs a second line buffer or ROM-to-VRAM uploads in the vblank;
splitting the box into opcodes needs the window to stay open between
`OP_MESSAGE`s, which touches every guard on `msg_open`.

Only `ShowMessage` keeps its waits (`Messages::add_waiting`): a choice's, a
number's, an inn's and a troop page's box drop them as before.

**Boxes with a wait in the middle, per game, before** (from `data/`,
`ShowMessage` boxes, the tail not counted; a box with two kinds counts in
both):

    game                 boxes   any    \.     \|     \!
    abl                  13925     0     0      0      0
    book-of-three         2455     0     0      0      0
    desert-nightmare      2354   115     0    115      0
    dooms2                1609   590    34      0    561
    el-dorado                1     0     0      0      0   (its data/ is not dumped)
    frozen-world          3889     0     0      0      0
    sunset-over-imdahl    1392   330   128    250      0
    vampires-dawn        17363  4517  4517      0      0

**After**: boxes in each built cartridge that wait (distinct boxes, those
whose page compiles), and the waits in them, counted in `mapdata.inc`:

    game                 boxes that wait   \.     \|     \!
    abl                    1 (the test case)  1      1      1
    desert-nightmare     110                0    124      0
    dooms2               359               73      0    435
    sunset-over-imdahl   156              162    154      0
    vampires-dawn        943             2309      0      0

The other three have none, before or after. All four games build with
these tools. Their text block grows with the bytes of the waits and one
pair less in the table.

**Cost**, `rm2k-snes-space` on `release`'s `abl.sfc` against main's: bank 0
8 bytes, bank 1 8, bank `$C0` 331 (`message_waits.s`), far RAM 10, the text
block 180 (one pair less and the new case). ABL is **not** byte for byte:
the runtime hooks are unconditional and the pair table loses a pair;
assembling the waits only for cartridges that have them would leave a
second variant of the composer that the suite covers in one of the two.

**Verified**: `cargo test` of rm2k-snes-text, -events, -screens, -convert,
-battle and -mapdata (the escape cases red before); `just test`; ABL's
whole suite with these tools, green, including the new
`test_commands_golden.py::test_waits` —five of its six cases red with
main's tools— and `test_cores.py::test_waits`. Captures and contact
sheet in `/shared/captures/2026-10-12-esperas/`.

**Not covered by the suite**: any game's own boxes with waits —only the
invented case runs—; a wait inside a box with `\V[n]` (the cut line is
composed again, so a variable a parallel changes during the wait would
show its new value in the redrawn stretch); the frame RPG_RT adds after a
line with an odd number of characters; a `\.` at a speed past 16
(`message-colours-and-speed.md`).

**What taro should look at**: Vampires Dawn (`\.` in a quarter of its
boxes), Dooms 2 (`\!`), Desert Nightmare and Sunset (`\|`). A stretch
appears a line at a time, not a letter at a time, and the cut line is
redrawn over itself: it should not flicker.

**To install when merging**: `text battle events screens convert
cartridge` (and `project`, for the runtime path, as with any runtime
change). Draft found on the way:
`a-box-that-closes-on-its-own-without-a-pause-is-never-seen.md`.

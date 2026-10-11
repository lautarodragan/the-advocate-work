---
name: "The uncompressed texts"
description: "119 KB of text at one byte per letter: repeated messages, names and DTE would bring them down one or two banks, without losing direct access to each box"
type: feature
status: done
assignee: taro
---

Not urgent: it gets done when space gets tight, probably with the chapter
after the world one. taro decided it on 2026-09-27.

# What was measured

With a throwaway script over the `mensajes` block of `release` at
3c16a178 (how it is today is printed by `just espacio`):

    as today, one byte per letter    119,082 B
    LZ2, in two streams of < 64 KB   63,405 B   (47 % less)
    zlib -9, for reference           46,550 B   (61 % less)

It uses 88 byte values out of 256.

# Why not LZ2

The ROM opens each box at its exact offset (`msg_empezar`). With LZ2
you'd have to decompress from the start of a block to reach a
phrase: time or RAM, and the smaller the blocks, the less it compresses.

# What's proposed, in this order

1. **Repeated messages**: a box identical to another points to the same place.
   There are obvious cases (Sewell's comes out three times in a row at the start of the
   block). Free for the ROM.
2. **What repeats inside the boxes**: the characters' names
   (TALAN, KERSH…, in every header) and other frequent phrases. taro
   pointed it out. A dictionary code for whole words, or have DTE
   absorb them.
3. **DTE** (pairs of letters in one byte): the 168 free values for the
   most common pairs. It keeps direct access; the decoder is a
   table and a few instructions in the routine that draws the text. The
   typical figure is 30–40 %; **it isn't measured**.

Measure each step before implementing, and have `just espacio` show the
result.

# What was done (Guayacán, 2026-10-01)

**DTE, idea 3**, in `ba0b2952`. Byte values 95 to 255 —the ones the
font doesn't use: it has 95 glyphs, ASCII minus 32— are pairs of letters, of a
single level. The event compiler picks the 161 most frequent pairs
over the boxes that go into the cartridge and emits the table
(`message_pairs`, `MESSAGE_PAIR_FIRST`); the why of each piece is in
`Pairs` (`messages.rs`), in `compile` (`lib.rs`) and in `msg_letter`.

* A pair doesn't go beyond a line, so it doesn't split anything: the escapes go in
  the header and the length in its byte. The length still counts **letters**.
* Direct access to each box doesn't change: each one stays at its
  offset, with the step of 4.
* The compiler compiles twice —the first only gathers the boxes that
  remain—, because the offset is written into the bytecode when compiling.
  That first pass doesn't have the operand's cap.

## Who reads text from the block

Searched with a `grep` of `messages`, `msg_ptr`, `msg_start` and
`message_tick` in the runtime, and of `messages` in the tests:

* `message_tick`, the only one that reads letters from `messages`: now through
  `msg_letter`, in bank 1. It's used by `ShowMessage` (`op_message`) and
  `ShowChoice` (`pick_open`, which calls `msg_start` again).
  `msg_start` reads only the header and `message_tick` the length, which didn't
  change.
* `ba_page_message` reads `messages_troop`, **another block, which still has no
  pairs**: its comment says so.
* The names, the menus, the shop, the slots, the battle (`scr_text`,
  `slot_text_write`, `level.s`) use `msg_ptr` as a pointer but read
  **other strings**, not `messages`: they weren't touched. `InputNumber` doesn't read
  text from the block.
* In the tests: `cuadro_de_texto` (`tanda.py`) walks the block and now
  decodes the pairs; `test_compositor.py` counts the bytes as letters;
  `mensaje_en_pantalla` (`batalla.py`) reads `messages_troop`, without pairs.

## What was measured

`just espacio`, before (`cd3dce0d`) and after:

    cartridge                     texts before   texts after
    release                       145,792 B      94,417 B   (-35 %)
    test-special                   66,064 B      65,943 B   (*)
    test-encounter-every-step         747 B         463 B

    bank 0, all three              269/1,069/1,113   267/1,067/1,111 B free
    bank 1, all three              4,241 B       4,179 B free
    data banks                     62/16/7       62/16/7 of 128

Without the push re-measured, `test-special` went down to 36,583 B (-45 %).

(*) `test-special` carries the `empujon` case, which exists to push map 255's
box over the bank edge —`test_texto`—: with DTE it ended up
at +36,188 and didn't cross, so it was re-measured (684 boxes, a tail and
two of two letters) until it fell again at +$FFFC, as before.

The table is 322 more bytes. The data banks didn't move: what
the 51 KB free up is half a bank of the 64 KB ones, and today 46 are spare.

**The text's pace didn't change**, measured with a throwaway script that
saves per tick `msg_state`, `msg_line`, `msg_col`, the lost frames and
the emulator's frames, against the base ROM: identical traces in
`grupo-11-en-255` (two boxes of four lines), `autofire`, `ventana`
and 2400 ticks of the game from the title. That is, the same `MSG_CHARS` = 5
letters per loop, and not one extra lost frame: `message_tick` runs in
the main loop, not in the vblank, and the `jsl` per letter doesn't show next
to `compose_char`. The goldens didn't move a single pixel.

## Idea 1, the repeated boxes: it was already done

The compiler has stored each box only once since before —the key of the
`Messages` is the content, escape tail included—, so in `release`'s block
there are **zero** repeated boxes. What remains repeated is
individual lines: 14,878 bytes in lines that appear more than once,
almost all short (the most repeated, 749 times, is 3 bytes: a name). To
share them a pointer per line would be needed, which costs more than it
saves on the short ones and breaks straight-through reading; it wasn't done. And the
padding to the step of 4 is 3,596 bytes: if the block ever got tight, a
step of 2 is enough for 128 KB, which today is plenty.

## For the merge

* Reinstall `events` and `mapdata` (the compiler and the emitter), and
  `cartridge` because the runtime changes: `just -f tools/justfile install
  events mapdata cartridge`.
* With Quirquincho they clash in `rm2k-snes-mapdata` (`emit.rs`: the
  `message_pairs` lines go right after `MESSAGES_CAP`; `request.rs`: the
  `message_pairs` field) and in `main.s`'s list (`message_letter.s`
  before `header.s`). If their branch moves where `messages` starts in
  `test-special`, `test_texto[texto-cruza]` and `[texto-lejos]` will require
  re-measuring the push: the offset is measured from the
  start of the block, which today falls at the start of a bank.
* None of this touches goldens.

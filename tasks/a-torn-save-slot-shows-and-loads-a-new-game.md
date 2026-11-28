---
name: "A torn save slot shows on the slot screen and loads a new game"
description: "A slot whose saved game does not add up to its checksum —half written when the console lost power, or when the FX Pak took its image— is shown on the slot screen like a good one, and picking it starts a new game without saying why; and the previous save in that slot is gone with it"
type: bug
status: todo
agents: [cardon]
author: huron
links:
  found-in: [a-save-on-the-fx-pak-waits-for-a-silent-seek]
  relates: [the-sram-as-slow-wram, a-save-slot-kept-twice]
---

Seen by Hurón on 2026-11-17, reading the runtime for
[`a-save-on-the-fx-pak-waits-for-a-silent-seek`](a-save-on-the-fx-pak-waits-for-a-silent-seek.md),
with the-advocate at `865163eb`. Read, not seen on the console. Every game:
the slots are the runtime's.

**What a slot carries** (`runtime/save_game.s`): the magic, the length
(`SAVE_BYTES`), the format's signature (`GAME_SIGNATURE`) and a 16-bit
**additive** sum of the saved game's bytes. `save_game` writes the data
first and the sum, the length, the signature and the magic after it, so a
slot cut in the middle of the copy keeps the old magic and the old sum over
data that is half new.

**What refuses it, and where**: only `load_game` checks the sum. The slot
screen asks `slot_of_this_format`, which looks at the magic, the length and
the signature and not at the sum, so a torn slot is listed with a name, a
level and faces read from the half-written data. Picking it on the title,
`load_game` returns zero and `title.s` goes to `leave`: **a new game,
without a word**. And the save that was in that slot before is lost with
it: each slot has a single copy.

**When it can happen**: power cut during the copy (a DMA of `SAVE_BYTES`,
3,262 in ABL's `release` on that day, a fraction of a frame: unlikely);
and on the FX Pak with a `.msu`, the firmware's `msu_savecheck` reading the SRAM while the ROM writes it —what
the SRAM test ROM's `LOST` stash looked like after a power cycle
([`the-sram-as-slow-wram`](the-sram-as-slow-wram.md))—. Since
`msu_save_flush` the second one heals on its own: the seek after the save
checks again, sees the SRAM changed and writes the whole image; only a
power-off inside that ~130 ms leaves the torn one on the card.

**What it would take**:

* The slot screen asking the sum too —`slot_of_this_format` plus
  `save_checksum`, a few KB of reads per slot, four slots: invisible— and
  showing a torn slot as such ("damaged") instead of a name; picking it
  saying so instead of starting a new game.
* A CRC-16 instead of the additive sum, which does not see two bytes
  swapped or a run of bytes that adds the same.
* To keep the previous save when the new one is torn: two copies per slot
  —a saved game is a few KB and each slot is an 8 KB bank— written
  alternately, with a generation byte written last; the load takes the
  newest copy that adds up. It changes the slot's layout, so old saves stop
  loading (they already do on every build that moves `GAME_SIGNATURE`).

## Comments

### 2026-11-24, Cardón: a question for taro

Read, not seen; the risk is small (a power cut inside a DMA, or inside
~130 ms after `msu_save_flush`). Each step has something to choose: what
the slot screen shows ("damaged" is a new text), a CRC-16 (a little ROM
and time), and two copies per slot (a new SRAM layout, old saves stop
loading).

**To decide**: which of the three. **Recommendation**: the first two —the
slot screen checks the sum and shows the slot as damaged instead of a
name, and picking it says so instead of starting a new game; CRC-16 for
the sum— and the two copies only if a torn save is ever seen.

### 2026-11-28, taro: a comment

> let’s go with the recommendation, with save doubling as a new wishlist task.

### 2026-11-28, Hornero: to todo, the two copies a wishlist of their own

To `todo` with the recommendation: a CRC-16 over each slot, and a slot
whose sum fails shows as damaged on the slot screen —a new text— and
says so when picked instead of starting a new game. The two copies per
slot are [`a-save-slot-kept-twice`](a-save-slot-kept-twice.md), in
`wishlist`.

## Log

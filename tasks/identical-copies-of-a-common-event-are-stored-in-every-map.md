---
name: "Identical copies of a common event are stored in every map"
description: "A copied automatic common event is the same bytecode in every map it goes into, and each map carries its own: Desert Nightmare's common 14 is 7,317 bytes, one copy in each of 181 maps, and copied with 12 it pushes every map past what decompresses into WRAM"
type: feature
status: todo
author: carpintero
game: desert-nightmare
agents: [Carpintero]
---

Seen by Carpintero on 2026-11-20, at the-advocate `16081af9` and the
ports `1177cbc`, for
[`desert-nightmare-the-cartridge-has-no-room-left`](desert-nightmare-the-cartridge-has-no-room-left.md).

**What was seen**: copied into the 181 maps (`common_pages` with 14 and
12, as before `[events] commons_not_copied = [14]`), the event compiler
gives common 14's copy as one bytecode, byte for byte the same in the 181
maps, and common 12's too. Each map carries its own inside its code stream:
common 14's copy is 7,317 bytes —3,243 without its seven `CallEvent`s to
common 13, which a copy pastes— and common 12's 13,833. Together they put
every one of the 181 maps over `LZ2_CAP_CODE` (19,968 bytes), so every
map's bytecode stays in the cartridge uncompressed (`code_in_rom` in
rm2k-snes-mapdata): 3,940,530 bytes of raw bytecode, against the 2,059,635
bytes the packing could still send to the `.msu`. Nothing weighs a copy
against that cap; the cartridge stops linking instead.

Copied alone, common 14 is 754,186 bytes of LZ2 over the 181 maps and the
largest map's pages are 10,021 bytes.

**To reproduce**: as in
[`desert-nightmare-common-12-is-copied-and-draws-nothing`](desert-nightmare-common-12-is-copied-and-draws-nothing.md),
with `common_pages.commons` set to `[14, 12]` and to `[14]`.

## Log

### 2026-11-22, Hornero: still so, to todo

At the ports `89f77b4` and the-advocate `0ae40e0a`, after Chajá's
[`a-common-event-is-copied-only-if-its-copy-draws`](a-common-event-is-copied-only-if-its-copy-draws.md):
the release's `converter.log` says common 12 is no longer copied (all its
pictures are big) and common 14 is copied into 181 maps and kept in 145
(36 draw nothing with it, none would keep its bytecode in the cartridge).
So nothing breaks any more, but the 145 copies of 14 are still the same
bytecode, one per map.

taro wants it in `todo`: three to seven kilobytes less per map is worth
having in general, unless it turns out very complex.

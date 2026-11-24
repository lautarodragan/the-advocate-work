---
name: "Desert Nightmare: the maps screen's cursor, shared, fits on ten maps"
description: "Common 14's only small picture, a 7x4 cursor, is in one set of the common table with the two 320x84 textbox pictures, 273 tiles, which fits beside the map's bank on 10 of the 189 maps"
type: bug
status: todo
author: carpintero
game: desert-nightmare
agents: [Carpintero, Chajá]
links:
  relates: [a-common-event-is-copied-only-if-its-copy-draws, desert-nightmare-the-cartridge-has-no-room-left]
---

**Since** [`a-common-event-is-copied-only-if-its-copy-draws`](a-common-event-is-copied-only-if-its-copy-draws.md)
(Chajá, 2026-11-20, the-advocate `c0fa2260`): `commons_not_copied` is
gone and 14 is copied again, kept on the maps where Wally puts its
pictures in. On 85 of the 181 maps it can run on the copy draws the
cursor; on the other 96 Wally put the map's own pictures in instead —"the
common events' pictures … aren't drawn here: the map has no room for
them besides its own", the converter log—, the copy goes, and there the
cursor is drawn only where the shared set fits, as below. What is left of
this draft is those maps.

Seen by Carpintero on 2026-11-20, at the-advocate `16081af9` and the
ports `1177cbc`, for
[`desert-nightmare-the-cartridge-has-no-room-left`](desert-nightmare-the-cartridge-has-no-room-left.md).

**What was seen**: with `[events] commons_not_copied = [14]` common 14
runs as the shared body, and its cursor `Kartencursor` is drawn from the
cartridge's table of common pictures. The converter puts it in one set
with `TextboxInnen` and `TextboxRahmen` —"common events 2, 5, 7, 9, 11, 12,
13, 14: their small pictures …, 93 objects in 273 tiles"—, because a set
is what an automatic common shows with every body it calls and the shared
bodies join them. `picture_common_maps` in the ROM says that set fits on
10 of the 189 maps; on the other 179 the cursor is not drawn. Alone it is
one tile.

Not looked at on screen: the maps screen itself shows nothing on the
console (the port's "Known issues").

**To reproduce**: the converter log's line above, and byte 5 of each
8-byte entry of `picture_common_maps` (its address in the `.sym`) in the
built ROM.

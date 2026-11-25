---
name: "share_data on the ROM's last byte does not link"
description: "When no map shares slots, share_data is one byte, and if the bank packer puts it at $FFFFFF ld65 refuses `lda f:share_data + 4, x` with a range error: a cartridge that fits fails to build"
type: bug
game: advocate
status: todo
author: cardon
agents: [cardon]
links:
  found-in: [abl-forem-left-out-at-the-factory]
---

Found by Cardón on 2026-11-24, building throwaway variants of ABL's map 83
for [`abl-forem-left-out-at-the-factory`](abl-forem-left-out-at-the-factory.md),
with the-advocate `5572e9e8` (plus an experimental wally) and the ports
`4c23c9e`.

**What is seen**: `just cartridges release` fails with

    ld65: Error: Range error in module 'runtime/shared_poses.s', line 64
    release: the assembler failed

**Why**: in ABL's release no map shares slots, so `share_table`
(`rm2k-snes/mapdata/src/record.rs`) emits `share_data` as a single byte
(`.block 1`, "offset 0: no map shares"). The bank packer placed that block
as the very last byte of `BANKFF` —32767 bytes of the segment before it in
`mapdata.inc`, `BANKFF` at `$FF8000` with size `$8000`—, so `share_data` is
`$FFFFFF`, and `share_load`'s `lda f:share_data + 4, x` (line 64, from
`9c4e2b994`) asks for `$1000003`, which does not fit in 24 bits. The code
never reads it with `x = 0` —it branches away first—, but the operand is
assembled anyway.

It depends only on where the packing lands: the build that showed it
differed from a linking one by one tile event's palette on map 83 (one
byte less of LZ2 in total). Any change to the data can trigger it, for any
game whose maps share nothing.

**How to reproduce**: not with `main` as it is —it links—; it needs a
packing that ends `BANKFF` with `share_data`. The experiment that showed it
was wally lending `@tile:ChipSet1:138` a palette on maps 17 and 83.

**What would fix it**, to choose: keep the packer from placing a block
whose label is addressed with an offset at the end of the last bank, or
give `share_data` the five bytes a record's header reads when nothing
shares, or read `share_data + 4` through a base that cannot overflow.

## Log

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: reproduced with the linker's error and its line, a
build that fits must link, and nothing seen or heard changes. Of the three
fixes, the one that does not depend on this label: whatever the packer
places, a label read with an offset cannot end a bank —look for the other
`f:label + n` reads before choosing, since `share_data` is only the one
that showed it—; four padding bytes for `share_data` alone would leave the
next one waiting.

---
name: "The item and theme tables, out of bank 0"
description: "Bank 0 of release was down to 95 B: the tables that grow with each new map (items, themes) move out, as the world plan says"
type: refactor
status: done
assignee: taro
---

After Yun, Drust and Paradise (2026-10-01), bank 0 of `release`
was down to 95 B free. What grows there with each map are the item and
theme tables; the world plan (`world-and-what-follows.md`, milestone 5)
already said to move the item ones to bank 1. Zorro counted 19 reads in the
runtime.

## What was measured before (2026-10-01, Pirincho, on `387b1e49`)

`just space`: bank 0 of `release` **95 B**, of `test-special` 1,003 B, of
`test-encounter-every-step` 1,047 B. `TABLES` in `release` is 1,441 B, and in
`test-special` 551 B. The difference, label by label (with the `.dbg`:
each label of the segment up to the next one):

    item_id          328 vs  44   +284   (.word per item)
    item_price       328 vs  44   +284   (.word per item)
    item_type        164 vs  22   +142
    item_use         164 vs  22   +142
    slot_face_block   29 vs  15    +14
    slot_block_lo/hi/bk  42 vs 34  +8 each

The rest doesn't change between cartridges. So what grows with the content is
**the four item tables, 6 B per item**: `release` carries 164 items and
`test-special` 22. The theme ones aren't in `TABLES`: of the music, all that's left
in bank 0 is the DSP prologue (`dsp_init_reg`/`dsp_init_val`), fixed.
The `slot_block_*` ones grow with the faces and the menu windows, not with the
maps.

The reads, with a `grep` of each name in `tools/runtime/`: `item_id` 11
(four already with `f:`, three in the shop with Y), `item_use` 5, `item_type` 1,
`item_price` 1 (with Y). No test or script reads these tables by name.

## What was done

Six commits, one per table (the `slot_block_lo/hi/bk` together: they're a single
pointer table split in three). They all go to `RODATA` with their `.block`, and
each read becomes `f:`:

    item_id          11 reads: 7 changed (4 already had f:); the 3 in the
                     shop indexed with Y and now index with X
    item_use          5
    item_type         1  (a cmp)
    item_price        1  (ti_price, which indexed with Y)
    slot_block_*      6  (slot_block_upload and slot_rect_upload)
    slot_face_block   2  (slots.s and menu.s)

In the shop, `ti_item`, `ti_can`, the listing one and `ti_price` return X = k
as before; they no longer leave 2k in Y, and no caller read it (the procs that
call them end in a `jmp` to the loop). Each commit with `just tests` at 961 and
the goldens unmoved, and with the hashes in `tests/python.rs` of
`rm2k-snes-mapdata` regenerated, because the `.inc` changes on purpose.

`just space`, before and after:

    bank 0    release 95 B -> 1,220 B; test-special 1,003 -> 1,238;
              test-encounter-every-step 1,047 -> 1,234
    bank 1    3,423 B -> 3,405 B in all three (the shop's and the
              slots' f: land there)

`TABLES` now weighs **the same in the three cartridges, 302 B**: what's left doesn't
depend on maps, items or actors. **A new map no longer costs bank 0**:
only new runtime code costs it. What still differs between
cartridges in bank 0 is 18 B of `CODE`, because of `test-special`'s flags,
not the content.

`NO_CACHE=1 just cartridges` comes out with the same `abl.sfc` as the cached
build (`1b606408…`); only `.o` and `.dbg` change, because of the mtimes.
`just -f tools/justfile test`: 39. `cargo test -p rm2k-snes-mapdata`: green.
`test_music_ceilings.py` and `test_cores.py` pass inside `just tests`.

**On merging**: `just -f tools/justfile install mapdata`. The runtime changed
(`tools/runtime/`), but the global assembler builds with the main checkout's,
so the merge is enough.

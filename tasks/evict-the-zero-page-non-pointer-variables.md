---
name: "Evict the zero page's non-pointer variables"
description: "Of the zero page's 253 used bytes only 55 are [dp],y pointers; the other 198 are there for one byte and one cycle per access, and 3 B are left: move the cold ones to the BSS so a new pointer can exist"
type: feature
status: wishlist
---

Suggested by Hurón on 2026-10-15, in the study
[`the-wram-and-sram-map-measured`](the-wram-and-sram-map-measured.md),
with the-advocate `6fa69781` and the ports at `f015801`.

**What was measured**: `just space` prints 3 B of `ZEROPAGE` left in
every game's cartridge. Of the 253 B used, 55 B in 18 labels are read in
a mode that needs the direct page —`[ptr],y`, `(ptr),y`—: `code_ptr`
(213 such uses), `msg_ptr`, `page_ptr`, `comp_glyph`, `cells_ptr`,
`music`, `route_ptr`, `poses_ptr`, `npc_ptr`, `temp` and eight more
three-byte pointers. The other 198 B in 119 labels are only read with
direct-page addressing, which costs one byte and one cycle less than
absolute: some are in the hottest loops (`camera_x`, the `comp_*`, the
strips'), many are touched once a frame or less (`title_sel`,
`menu_open`, `slot`, `is_pal`, `pal_tick`, `token`, `panic`,
`jumps_left`, `jump_*`, `entry_*`, `cam_max_*`, `map_ofs`, `npc_total`,
`restart`…). The hero's forced route already lives in the `BSS` and is
copied into `route_ptr` to be read, for want of a pointer of its own.

**What it costs**: one byte of bank 0 ROM and one cycle per access of
each variable moved; bank 0 has 740–908 B left depending on the
cartridge. It needs `BSS` room first —97 B left—, which is what moving
the DMA-only buffers out of bank 0 gives (its own draft). The trap: a
variable read with a sixteen-bit `ldx`/`ldy` whose one-byte neighbour
moves with it.

**What to decide**: which ones go, by how often each is read; the saving
is the sum of what is moved, 60–100 B by inspection.

## Defined (2026-10-16, Carpintero)

An optimisation: nothing is blocked until a new pointer is needed. Then
it becomes `todo`. **Done**: `just space` shows the zero page with room
for at least one new three-byte pointer in every cartridge, the moved
variables are the cold ones (read once a frame or less), and the suite
and `test_cores.py` are green. **First step**: the per-label count of
accesses, weighted by how often each routine runs; needs the `BSS` room
of [`move-the-dma-only-buffers-out-of-bank-0`](move-the-dma-only-buffers-out-of-bank-0.md) first.

---
name: "Overload-and-remove for try_pack"
description: "try_pack is best-fit decreasing; overload-and-remove, the pagination heuristic SuperFamiconv and rgbgfx use, finds packings best-fit misses. Measure how many layers fall into reduce_colors only because of that, and adopt it if any do"
type: feature
status: todo
author: hornero
---

# What

Measure whether `try_pack`, in `snes/adeleine/src/pack.rs` in the-advocate,
answers `None` for tiles that do fit in the palettes it is given, and if it
does, replace its best-fit decreasing with **overload-and-remove**.

Every such `None` sends the caller to `reduce_colors`, which merges colours:
a lossy step taken where a lossless answer existed. That is what makes it
worth measuring: the gain, if there is one, changes no pixel that had to
change.

# Why this algorithm

Packing tiles into palettes is the *pagination* problem —bin packing where
items that share colours share space—, and overload-and-remove is the
heuristic of Grange, Kacem and Martin, "Algorithms for the Pagination
Problem, a Bin Packing with Overlapping Items" (<https://arxiv.org/abs/1605.00558>).
It places a tile in the page where it takes the least *relative* space,
lets the page go over capacity, and then removes from it the tiles that fit
worst, which go back to the queue and are forbidden from that page. Best-fit
never undoes a placement, so an early tile can close a packing a later one
needed.

It is not new to tile converters: SuperFamiconv uses it since its Rust
rewrite (`src/binpack/overload_and_remove.rs`, MIT, read at
<https://github.com/Optiroc/SuperFamiconv> `56652220`), citing ISSOtm's
`pagination-rs`, and rgbgfx, RGBDS's converter, uses it too. SuperFamiconv
keeps first-fit decreasing next to it (`first_fit_decreasing.rs`), which is
a ready comparison.

Found on 2026-11-09, while looking at whether SuperFamiconv fits the
toolchain. It does not fit as a tool —it decides colours inside its
conversion, which is what Voodoo was designed not to do, and its `-Q`
invents colours and dithers—, but this algorithm is the part worth taking.

# How

1. **Measure first, with no ROM change.** Run both packers over every
   `try_pack` call of a `NO_CACHE=1 just cartridges` of every port —the
   layer above, mode 1, panoramas, the pictures, the debug screen— and count
   the calls where best-fit says `None` and overload-and-remove fits. Also
   the calls where both fit but with fewer palettes, which on the layer
   above frees palettes the background split does not use today. If the
   first count is zero in every game, the task closes with the number and
   nothing changes.
2. **Determinism is a requirement, not a detail**: what came out of
   [`try-pack-tie-break`](try-pack-tie-break.md). Overload-and-remove has to
   order equal-sized tiles by their colours, as `try_pack` does today, with
   no seed and no shuffle: the answer depends on which tiles there are,
   never on the order they were handed in.
3. **If `try_pack` already fits, the answer must stay the same where
   possible**: `reduce_colors` documents that it returns exactly
   `try_pack`'s palettes when they fit, and the layer above's tilemaps move
   with any change in palette assignment. Expect goldens to move with no
   pixel different, as in `3a8e381f`; the ones with different pixels are
   the maps that stopped merging, and those are what taro looks at.
4. The sprite split, `drawable_npcs` in `rm2k-snes/wally/src/sprites/split.rs`,
   is the same problem with priorities —leaders, weights—, and is **out of
   scope** here: it packs whole graphics in an order the game decides, not
   tiles. Noted only so that whoever measures does not take it for
   forgotten.

## Log

### 2026-11-22, Hurón: measured from outside, with SuperFamiconv

From [`superfamiconv-as-an-oracle-for-palette-packing`](superfamiconv-as-an-oracle-for-palette-packing.md).
Its test, `tests/superfamiconv.rs` in `snes/adeleine/` (the-advocate),
builds pictures from seeds. Over 500 of them with no limit on palettes,
SuperFamiconv needs fewer palettes than `try_pack` in 361 pictures, the
same in 133 and more in 6. Most of that is not best fit against
overload-and-remove. `try_pack` puts each tile in the group whose union
ends smallest, not in the one that grows least, as its comment says:
[`try-pack-picks-the-smallest-group`](try-pack-picks-the-smallest-group.md).
A copy that minimises growth still loses to SuperFamiconv in 90 of the 500
and wins in 46. Those 90 are what this task would gain on these pictures,
and they are the second group in the test's `KNOWN`. Step 1 should measure
both changes separately on the real layers.

The smallest of those cut down from seed 1: nine tiles and 30 colours,
numbered in colour order. `try_pack` needs 4 palettes and so does the copy
that minimises growth. SuperFamiconv needs 3:

    [7, 8, 9, 10, 17, 23]  [5, 9, 11, 12, 14, 16, 18, 21, 27]
    [1, 8, 10, 15, 19, 22, 24, 28]  [4, 7, 8, 10, 17, 23, 25]
    [8, 10, 15, 24, 26, 28]  [4, 7, 10, 17, 18]  [0, 20, 29]
    [3, 4, 8, 15, 24, 28]  [0, 2, 6, 12, 13, 21, 22, 25, 29]

SuperFamiconv's three palettes:

    [4, 5, 7, 8, 9, 10, 11, 12, 14, 16, 17, 18, 21, 23, 27]
    [0, 2, 4, 6, 7, 8, 10, 12, 13, 17, 21, 22, 23, 25, 29]
    [0, 1, 3, 4, 8, 10, 15, 19, 20, 22, 24, 26, 28, 29]

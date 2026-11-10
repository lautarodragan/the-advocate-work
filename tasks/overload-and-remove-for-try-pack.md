---
name: "Overload-and-remove for try_pack"
description: "try_pack is best-fit decreasing; overload-and-remove, the pagination heuristic SuperFamiconv and rgbgfx use, finds packings best-fit misses. Measure how many layers fall into reduce_colors only because of that, and adopt it if any do"
type: feature
status: todo
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

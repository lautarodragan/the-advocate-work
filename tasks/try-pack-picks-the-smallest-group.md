---
name: "try_pack picks the smallest group, not the one that grows least"
description: "try_pack's comment says each tile goes to the group that grows the least, but the code puts it in the group whose union ends smallest; doing what the comment says packs in fewer palettes in most of SuperFamiconv's wins"
type: bug
status: draft
author: huron
---

Seen by Hurón on 2026-11-22, doing
[`superfamiconv-as-an-oracle-for-palette-packing`](superfamiconv-as-an-oracle-for-palette-packing.md),
reading the-advocate at `6a8f4162`.

`try_pack`, in `snes/adeleine/src/pack.rs`, says "each into the group that
grows the least", and so did the Python it came from, from the first
version (`330708ae`, "al grupo que menos crezca"). But the code compares
`group.len() + colors.difference(group).count()`, the size of the union, and
takes the smallest. A tile that already fits in a big group with no new
colours goes to a small one where it adds three, because three plus a small
group is fewer than the big group's size. That is closer to worst fit than to
best fit. `git blame` gives no other intention: the comment and the code
have disagreed since that commit.

What it costs, measured with the pictures of `tests/superfamiconv.rs` in
`snes/adeleine/` (the-advocate, branch `huron-sfc-oracle`), over 500 seeds
with no limit on palettes. A throwaway copy of `try_pack` that minimises
growth, with ties going to the first group, needs fewer palettes than
`try_pack` in 362 pictures, the same in 136 and more in 2. Against
SuperFamiconv the copy ties in 364, loses in 90 and wins in 46. `try_pack`
as it is loses in 361. Ties going to the fuller group give the same numbers
within two pictures.

The smallest reproducer, cut down from seed 0: ten tiles, 36 colours,
numbered here in colour order. `try_pack` needs 4 palettes and the copy
needs 3, the least that 36 colours allow. SuperFamiconv also needs 3:

    [14, 25, 30]  [13, 32, 35]  [2, 15, 22, 24, 28]  [12, 26, 33]
    [4, 6, 17, 22, 26, 31, 33]  [6, 12, 31]  [1, 3, 5, 11, 33]
    [12, 20, 27, 34]  [10, 14, 16, 19, 23, 30, 34]
    [0, 7, 8, 9, 18, 21, 29]

The `try_pack` change belongs with
[`overload-and-remove-for-try-pack`](overload-and-remove-for-try-pack.md),
which is about the same function and has the same constraints: determinism,
and goldens that move without a pixel changing. The cheap fix is worth
measuring first, as the first step there: it might already turn the `None`s
that task is looking for into fits. In the oracle test, the seeds this would
fix are the first group in `KNOWN`.

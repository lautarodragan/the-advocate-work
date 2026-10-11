---
name: "Speed: colours per tile"
description: "Keep each tile's colours instead of recomputing them"
type: refactor
status: wishlist
---

# What

Keep the colours of each tile from the first pass instead of recomputing them
in the second: a one-line dictionary in the conversion of the upper layer.

# Status

Noted, not started. It turned up while measuring, not while looking for it.

# Why

The upper layer called `tile_colors` **894,000 times** —measured on
2026-09-16 on `abl` with `SIN_CACHE=1`, a day before Voodoo took over
converting that layer; the recomputation is still in `snes_convert.py`, on the
side that decides the colours, so the number has to be measured again— because
the colours of each tile are recomputed in the second pass instead of being
kept from the first.

It is a free improvement: it doesn't change any colour decision, so the ROM has
to come out byte for byte the same. That is the acceptance criterion, and with
`SIN_CACHE=1`, which is where it is measured.

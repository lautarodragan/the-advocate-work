---
name: "The tools' lint is red on rustfmt"
description: "`just lint` in the-advocate fails at cd3fecb8: rustfmt wants to reformat convert's chipsets.rs and game.rs, mapdata's layer_text.rs and tests/python.rs, none of them touched by the branch that ran it"
type: bug
status: draft
---

Seen by Carpintero on 2026-11-16, running `just lint` in the-advocate on
`carpintero-pano-lz2` with `main` (cd3fecb8) merged in: it stops at
rustfmt's check with diffs in `rm2k-snes/convert/src/chipsets.rs`,
`rm2k-snes/convert/src/game.rs`, `rm2k-snes/mapdata/src/layer_text.rs` and
`rm2k-snes/mapdata/tests/python.rs`. That branch touches none of the four
(its `panorama.rs` is formatted). Not bisected: which merge left each one
unformatted is a `git log` on each file away. Nothing a game shows.

To see it: `just lint`, standing in the-advocate.

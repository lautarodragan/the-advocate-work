---
name: "Several samples per instrument"
description: "Multisample like a real piano"
type: feature
status: wishlist
---

# What

More than one sample per instrument: multi-sample the way a real
piano is, instead of taking a single one and transposing it.

# Status

Noted, not started.

# Why

A real piano is sampled **every few notes**; we take the one at middle
C and transpose. **At the ends of the keyboard that shows.**

What has to be looked at before tackling it is the other side of the account: more
samples per instrument is more ARAM per program, and since the per-package
budget each full package hands it out entirely. What was already done, on
2026-09-26: each program carries the sample of the zone that sounds the most in the
cartridge, not the middle C one (`most_used_zones` in
`tools/rm2k-snes/rm2k-snes-audio/src/bank.rs`). Two zones per program were measured in step 6
of `tasks/la-calidad-de-la-musica.md`: 149 samples instead of 116, each
one at a lower rate.

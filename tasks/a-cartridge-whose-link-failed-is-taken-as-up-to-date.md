---
name: "A cartridge whose link failed is taken as up to date"
description: "After a build whose link fails, going back to the inputs of the last good build leaves the cartridge's directory mixed —the failed build's mapdata.inc and raw/, the good build's ROM— and rm2k-snes-cartridges does not rebuild it"
type: bug
status: todo
author: mulita
agents: [Mulita, cardon]
---

Seen by Mulita on 2026-11-16, in A Blurred Line, with the-advocate at
`bc608480` (branch `mulita-pages-lz2`) installed locally and the ports at
`44e077b`.

What was seen: `release` built fine; then `[graphics] posed_events = true`
in `abl/advocate.toml`, and `just cartridges` converted and failed to link
(far RAM overflow). With `advocate.toml` put back as it was, `just tests`
did not rebuild `release` —it said it was up to date— and 19 tests went
red with what is only explained by a mixed directory: `map 8: 3 different
grid cells`, the patches stale with the posed colours ("layer lower:
colors went from 52 to 53"), `test-msu` booting into another map. The
`raw/` and the `mapdata.inc` were the failed build's, the `.sfc` the last
good one's. Deleting `build/release/stamp.txt` and `build/tests/*/stamp.txt`
and running again: everything green.

How to reproduce: in ABL's `release`, turn on something that converts but
does not link, `just cartridges`, put it back, `just cartridges`, and
compare `build/release/raw/` with what the converter writes for the
inputs.

## Log

### 2026-11-24, Cardón: to todo

Still so at the-advocate `8b069fc2`: `Cartridges::build` in
`rm2k-snes/cartridge/src/cartridges.rs` (lines 862-871) converts over the
old directory and writes `stamp.txt` only after success, but never deletes
the previous good build's stamp first, so a failed link leaves the old
stamp over the failed build's `raw/` and `mapdata.inc`. The fix is not in
doubt —remove the stamp before converting— and changes no ROM. It carries
over to `advocate build`
([`one-advocate-command`](one-advocate-command.md)).

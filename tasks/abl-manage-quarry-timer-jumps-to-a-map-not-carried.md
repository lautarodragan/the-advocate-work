---
name: "ABL's ManageQuarryTimer jumps to a map the cartridge does not carry"
description: "Parallel common event 36 does not compile: its Teleport goes to map 150, which is not among release's maps"
type: bug
status: done
---

Seen by Aguará on 2026-10-12, with the-advocate `6ed7c4a0` and the ports
`0e1d9ba` (`parallel-common-events-dont-run.md`), in ABL.

**What is seen**: of ABL's six parallel common events five run;
`ManageQuarryTimer` (36, switch 450) does not compile, because its
`Teleport` goes to map 150 and `release` does not carry it —a teleport to
a map out of the cartridge leaves the page out—. Not looked at in play:
it is the quarry, further than where `release` reaches today.

**How to see it**: the line "parallel common events" of
`abl/build/release/converter.log`.

2026-10-14, Cardón: it compiles as soon as 150 goes in; what carrying 150 runs into is
[`abl-the-quarry-timer-does-not-fit-on-108`](abl-the-quarry-timer-does-not-fit-on-108.md).

**Done by the ports' `74eb754`** (2026-10-14, "ABL: release carries the
whole game"), with the quarry's timer made to fit on 108 by
[`abl-the-quarry-timer-does-not-fit-on-108`](abl-the-quarry-timer-does-not-fit-on-108.md)
(the-advocate `5b63fcfb`). Checked on 2026-10-16 at the-advocate
`759aa0ba`, by Cardón: 150 is not among `abl/rm2k-snes.toml`'s excluded
maps, and the release build's `converter.log` in the ports checkout
(2026-10-16) says "parallel common events: 6 run, 0 do not compile".
Not played.

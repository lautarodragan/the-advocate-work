---
name: "ABL's ManageQuarryTimer jumps to a map the cartridge does not carry"
description: "Parallel common event 36 does not compile: its Teleport goes to map 150, which is not among release's maps"
type: bug
status: draft
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

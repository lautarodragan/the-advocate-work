---
name: "Bank 1 of ABL's MSU test cartridge is nearly full"
description: "After merging main into Hurón's debug screen work on 2026-10-20, bank 1 of ABL's test-msu cartridge has a handful of bytes left; the next code that lands in the text layer or elsewhere in bank 1 will not link"
type: refactor
status: draft
agents: [Hurón]
---

Seen by Hurón on 2026-10-20, measuring with `just space` in `abl/` of
the-advocate-ports, on the-advocate's `huron-debug-wide` with
`origin/main` merged (the merge after 090b9781).

`test-msu` is the cartridge with the least room in bank 1, the one
`FAR` code goes to —the text layer, `text_layer.s`, among others—. Its
bank 1 went, through that day: 252 B at 090b0037; less after the debug
screen's text layer work (part 1 and part 2 of
[`the-debug-screen-redraws-and-goes-wide`](the-debug-screen-redraws-and-goes-wide.md),
some 150 B); and almost nothing after the merges of Carpintero's,
Calandria's and Cardón's branches that came with `origin/main`. Every
other ABL cartridge has some 600 B there.

How to see it: `just space` in `abl/` with those tools first in PATH, the
line `bank 1` under `test-msu`. A change that adds code to bank 1 fails to
link in that cartridge first.

The precedent is [`bank-1-filled-up`](bank-1-filled-up.md), and the
pattern since then is new code in `FAR3`, entered with `jsl`.

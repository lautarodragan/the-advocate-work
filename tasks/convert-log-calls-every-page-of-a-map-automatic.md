---
name: "The converter's per-map page line says \"automatic\" and counts every page"
description: "\"map 4: 337 automatic event page(s), 336 runnable\" counts all the triggerable pages plus the suite's test pages, and the one without code is the test switch's own"
type: bug
status: wishlist
---

Seen by Tijereta on 2026-10-14, with the-advocate `0255f8f7` and the ports
`a6823c8`, reading ABL's `release` log (`build/release/converter.log`).

**What is seen**: "map 4: 337 automatic event page(s), 336 runnable" and,
for most maps, one or two fewer runnable than pages. It reads as pages the
converter lost. They are not: `m.pages` holds every page of a triggerable
kind (action, touch, collision, autostart, parallel), not only the
automatic ones; map 4 is the boot map, which also carries the suite's
330-odd test pages, and the page without code is the last one, the one
that turns `TEST_SWITCH` off (`test_page(cases.len(), TEST_SWITCH, …,
Vec::new())` in `convert.rs`) and has no code by design. The rest of the
maps' pages without code are pages whose commands compile to nothing
(maps 2, 3 and 9 have one to two; `culprits` finds none of them left out).

**What it should say**: how many pages carry code out of how many, without
"automatic", and apart from the test pages. Reproduce: `just cartridges
release` in `abl/`, `grep 'automatic event page' build/release/converter.log`.

## Defined (2026-10-16, Carpintero)

Still the same line at the-advocate `f4709d0b` (`convert.rs`). Only a log
wording; nothing is lost. **Done**: the line says how many pages carry
code of how many triggerable pages, without "automatic" and with the
test pages apart.

---
name: "ABL's test_cores big-picture-return-240 went red once in a full run"
description: "bsnes drew the map back after the big picture without its lower rows of trees and the person on them, and with a message arrow at the bottom; alone the test passes"
type: bug
status: draft
---

Seen by Tijereta on 2026-10-19, in a full run of ABL's suite on the branch
`tijereta-fw-enemy` (the-advocate `f15cca10` on `2c350d8f`, ports
`dd64707` on `1182513`), with that branch's `events`, `mapdata` and
`convert`.

`tests/rpgmaker/test_cores.py::test_big_pictures[big-picture-return-240]`
failed: snes9x and bsnes differed in 14.27% of the pixels. In bsnes's
capture the map is back after the big picture but its bottom rows —the
trees and the person standing on the path— are not drawn, and a message
window's arrow shows at the bottom centre; snes9x draws them all.
Captures in `/shared/captures/2026-10-19-abl-big-picture-return-cores/`.

The release cartridge the test plays was byte for byte the one in the main
ports checkout (sha1 `a1774252a6ed…`), so the branch did not change what
ran. Alone, `just tests -k test_big_pictures` passed twice in a row right
after, on the same build.

**How to reproduce it**: `just tests` in `abl/` of the ports, several times;
the captures stay in `tests/snapshots/cores/`. See also
[`abl-test-cores-event-red-once-in-a-full-run`](abl-test-cores-event-red-once-in-a-full-run.md),
the same kind of intermittent red on another case.

---
name: "The slots screen's line counts no row cells"
description: "The converter's `slots screen: … B of cells` line adds the slots' rows through `s[\"rows\"][0][0][0]`, one index too many since the port from Python: it is a number, so the rows always count 0 and the line says only the headers' bytes"
type: bug
status: todo
author: calandria
agents: [calandria]
links:
  found-in: [the-stages-speak-json-nobody-types]
---

Seen by Calandria on 2026-11-24, doing B3 of
[`the-stages-speak-json-nobody-types`](the-stages-speak-json-nobody-types.md)
on the-advocate `calandria-b` (from `cef2cdda`).

**What**: every game's `converter.log` has a line like El Dorado's

    slots screen: 4, 249 4bpp tiles (7968 B) + 3 palettes, 256 B of cells; 1 actors with a face: 1 Hernando

whose "B of cells" was meant to be the headers' cells and the slots'
rows'. Python's `snes_convert.py` (the-advocate `97827508^`) added
`vram.SLOTS * 4 * len(slots_data["filas"][0][0][0])`, over the shape the
rows had then; the Rust port (`97827508`) kept the three indices, and
today `rows[0][0]` is a row's cells and `rows[0][0][0]` one cell —a
number—, whose `as_array()` is `None`: the term is always 0. Only the log
is wrong; nothing reads the number.

B3 types the screens' answer and kept the line as it printed, without the
dead term, with a comment pointing here.

**What is not known**: what the `4` was —the slots' two variants, empty
and full, times two planes?— so the right count has to be worked out from
`slots::Slots::rows` and the runtime's `slot_n_m` blocks before fixing
it. The fix changes one line of every `converter.log`, not a ROM.

## Log

### 2026-11-24, Hornero: promoted to `todo`

Promoted by Hornero: verified against the Python it was ported from, the
fix is not in doubt —the line counts what it says—, and it changes only
`converter.log`, nothing seen or heard.

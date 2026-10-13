---
name: "ABL's item text doesn't fit in what the windows leave"
description: "ABL's build warns that the most loaded item list asks for 200 tile pairs and the item and equipment windows leave 167"
type: bug
status: draft
---

Seen by Tijereta on 2026-10-11 (`most-efficient-windows.md`),
tools `fc6f7456`, ports `a85b7e3`, building ABL's `release`.

**What is seen**: in the build, not when playing. `rm2k-snes-screens convert` says
in its answer:

    WARNING, item text: its list asks for 200 pairs of tiles at most, of
    the 167 the item and equipment windows leave

No other of the eight games says it. It wasn't checked what the ROM does
with an inventory that reaches that list —whether the text is cut, or which
names are lost— nor with which inventory it's reached.

**How to see it**: `just cartridges release` in `abl/` of the ports; the warning
is in what `screens` answers (the `says` of its `screens.json`).

A fact measured in passing: with the windows' background in a single color (the
book's research "The windows, made cheaper"), the windows leave 184.
